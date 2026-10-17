with Ada.Exceptions;
with Logger;           use Logger;
with Random_Utilities; use Random_Utilities;
with Monitoring;        use Monitoring;
with Simulation_Control; use Simulation_Control;

-- DONE (Beata): queue for packing/cooking model
-- 1. Orders go to FIFO queue waiting for cooking
-- 2. Orders are taken from the queue and packed/cooked (delay) on each stove
-- 3. Orders are sent to the customer

package body Shipping is

   task body Shipping_Station is
      Current    : Order;
      Randomness : Random_Source;

      -- FIFO queue utilities (packing/cooking queue)
      type Order_Queue is array (1 .. Shipping_Station_Queue_Size) of Order;
      Queue : Order_Queue;
      Cooking_Orders_Count : Natural := 0;
      Queue_Head : Natural := 1;
      Queue_Tail : Natural := 1;
   begin
      Initialize (Randomness, Station_Seeds + 1);
      loop
         select
            when Cooking_Orders_Count < Shipping_Station_Queue_Size =>
               accept Ship (Current_Order : in Order) do
                  Queue (Queue_Tail) := Current_Order; -- add order to the end of the queue
                  Log ("Wysyłka: przyjęto zamówienie Z" & Image (Current_Order.Number)
                       & " dla klienta K" & Image (Current_Order.Client));
               end Ship;
               Queue_Tail := (Queue_Tail  mod Shipping_Station_Queue_Size) + 1;
               Cooking_Orders_Count := Cooking_Orders_Count + 1;

         or
            when Cooking_Orders_Count > 0 =>
               accept Pass_Order (Current_Order : out Order) do
                  Current := Queue (Queue_Head); -- get order from the front of the queue
                  Current_Order := Current;
                  Log ("Wysyłka: przekazano zamówienie Z" & Image (Current.Number)
                       & " dla klienta K" & Image (Current.Client) & " do stacji gotująco-pakującej");
               end Pass_Order;
               Cooking_Orders_Count := Cooking_Orders_Count - 1;
               Queue_Head := (Queue_Head  mod Shipping_Station_Queue_Size) + 1;
         or
            terminate;
         end select;
      end loop;
   end Shipping_Station;

   task body Cooking_Packing_Station is
      My_Number  : Stove_Number;
      Current    : Order;
      Randomness : Random_Source;

      function Name return String is ("Stacja gotująco-pakująca S" & Image (My_Number));

   begin
      accept Start (Number : Stove_Number) do
         My_Number := Number;
      end Start;
      Initialize (Randomness, Station_Seeds + My_Number);
      Log (Name & ": gotowa do pracy");
      while Control.Is_Running loop
         -- retry mechanism copied from Robot task:
         --  TIMED ENTRY CALL: wait for a job at most Retry_Timeout,
         --  then check again whether the simulation is still running.

         select
            Shipping_Station.Pass_Order (Current);
            Center_State.Set_Stove_State (My_Number, Busy);

            Log (Name & ": gotowanie zamówienia Z" & Image (Current.Number)
                 & " dla klienta K" & Image (Current.Client));

            delay Random_Duration (Randomness, Packing_Time_Minimum, Packing_Time_Maximum);


            Log (Name & ": zamówienie Z" & Image (Current.Number)
                 & " ugotowane, spakowane i wysłane do klienta K" & Image (Current.Client));
            Center_State.Order_Completed;
            Center_State.Set_Stove_State (My_Number, Idle);
         or
            delay Retry_Timeout;
         end select;
      end loop;
      Log (Name & " kończy pracę");
      Center_State.Client_Finished;

   exception
      when Error : others =>
         Log ("Stacja gotująco-pakująca: błąd - " & Ada.Exceptions.Exception_Message (Error));
         Center_State.Client_Finished;

   end Cooking_Packing_Station;

end Shipping;
