with Logger;           use Logger;
with Random_Utilities; use Random_Utilities;
with Monitoring;

package body Shipping is

   task body Shipping_Station is
      Current    : Order;
      Randomness : Random_Source;
   begin
      Initialize (Randomness, Station_Seeds + 1);
      loop
         select
            accept Ship (Received : in Order) do
               Current := Received;
            end Ship;
            Log ("Wysyłka: przyjęto zamówienie Z" & Image (Current.Number));
            --  TODO (Beata): packing queue / more realistic flow
            delay Random_Duration (Randomness, Packing_Time_Minimum, Packing_Time_Maximum);
            Log ("Wysyłka: zamówienie Z" & Image (Current.Number)
                 & " spakowane i wysłane do klienta K" & Image (Current.Client));
            Monitoring.Center_State.Order_Completed;
         or
            terminate;
         end select;
      end loop;
   end Shipping_Station;

end Shipping;
