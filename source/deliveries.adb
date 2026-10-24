with Ada.Exceptions;
with Logger;             use Logger;
with Random_Utilities;   use Random_Utilities;
with Simulation_Control; use Simulation_Control;
with Robots;
with Monitoring;

package body Deliveries is

   --  Dzieli dostawę na ładunki po maks. Robot_Capacity sztuk
   --  i przekazuje je dyspozytorowi
   procedure Hand_Over (Unloaded : Delivery) is
      Remaining : Natural := Unloaded.Quantity;
      Job       : Cargo;
   begin
      while Remaining > 0 and Control.Is_Running loop
         Job := (Delivery_Number => Unloaded.Number,
               Product         => Unloaded.Product,
               Quantity        => Natural'Min (Remaining, Robot_Capacity));
         loop
            --  wywołanie z limitem czasu - przy pełnej kolejce ponawiamy,
            --  dopóki trwa symulacja
            select
               Robots.Dispatcher.Submit (Job);
               exit;
            or
               delay Retry_Timeout;
               exit when not Control.Is_Running;
            end select;
         end loop;
         Remaining := Remaining - Job.Quantity;
      end loop;
   end Hand_Over;

   task body Unload_Station is
      Current    : Delivery;
      Randomness : Random_Source;
   begin
      Initialize (Randomness, Station_Seeds);
      loop
         --  selektywne przyjęcie z terminate
         select
            --  w accept tylko odbiór danych, rozładunek po spotkaniu
            accept Arrive (Arriving : in Delivery) do
               Current := Arriving;
               --  jeszcze w spotkaniu - main nie zakończy programu
               --  w trakcie rozładunku
               Monitoring.Center_State.Set_Unloading (Current.Number);
            end Arrive;
            Log ("Rozpoczęto rozładunek D" & Image (Current.Number));
            delay Random_Duration (Randomness, Unload_Time_Minimum, Unload_Time_Maximum);
            Log ("Zakończono rozładunek D" & Image (Current.Number));
            Monitoring.Center_State.Delivery_Handled;
            Hand_Over (Current);
            Monitoring.Center_State.Set_Unloading (0);
         or
            terminate;
         end select;
      end loop;
   end Unload_Station;

   task body Truck is
      My_Number       : Truck_Number;
      Current         : Delivery;
      Delivery_Number : Positive;
      Served          : Boolean;
      Randomness      : Random_Source;
   begin
      accept Start (Number : Truck_Number) do
         My_Number := Number;
      end Start;
      Initialize (Randomness, Truck_Seeds + My_Number);

      while Control.Is_Running loop
         delay Random_Duration (Randomness, Truck_Interval_Minimum, Truck_Interval_Maximum);
         exit when not Control.Is_Running;

         Numbering.Next_Delivery_Number (Delivery_Number);
         Current := (Number   => Delivery_Number,
                     Product  => Random_Product (Randomness),
                     Quantity => Random_Quantity (Randomness, 1, Maximum_Delivery_Quantity));

         Log ("Przyjazd samochodu D" & Image (Current.Number)
              & " (kierowca nr " & Image (My_Number) & ", " & Image (Current.Quantity)
              & " szt. pierogów " & Product_Name (Current.Product, Genitive) & ")");
         Log ("D" & Image (Current.Number) & " oczekuje na rozładunek");

         Served := False;
         while not Served and Control.Is_Running loop
            --  wywołanie z limitem czasu
            select
               Unload_Station.Arrive (Current);
               Served := True;
            or
               delay Truck_Patience;
               Log ("D" & Image (Current.Number) & " nadal czeka na rozładunek");
            end select;
         end loop;
      end loop;

      Log ("Kierowca nr " & Image (My_Number) & " kończy pracę");
      Monitoring.Center_State.Client_Finished;
   exception
      when Error : others =>
         Log ("Samochód: błąd - " & Ada.Exceptions.Exception_Message (Error));
         Monitoring.Center_State.Client_Finished;
   end Truck;

end Deliveries;
