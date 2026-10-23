with Ada.Exceptions;
with Logger;             use Logger;
with Random_Utilities;   use Random_Utilities;
with Simulation_Control; use Simulation_Control;
with Warehouses;         use Warehouses;
with Shipping;           use Shipping;
with Monitoring;

package body Orders is

   task body Customer is
      My_Number     : Customer_Number;
      Current_Order : Order;
      Order_Number  : Positive;
      Taken         : Boolean;
      Order_Wait    : Duration;
      Shipped       : Boolean;
      Randomness    : Random_Source;
   begin
      accept Start (Number : Customer_Number) do
         My_Number := Number;
      end Start;
      Initialize (Randomness, Customer_Seeds + My_Number);

      while Control.Is_Running loop
         delay Random_Duration (Randomness, Order_Interval_Minimum, Order_Interval_Maximum);
         exit when not Control.Is_Running;

         Numbering.Next_Order_Number (Order_Number);
         Current_Order := (Number   => Order_Number,
                           Client   => My_Number,
                           Product  => Random_Product (Randomness),
                           Quantity => Random_Quantity (Randomness, 1, Maximum_Order_Quantity));
         Log ("Zamówienie Z" & Image (Current_Order.Number)
              & " od klienta K" & Image (My_Number) & ": "
              & Image (Current_Order.Quantity) & " szt. pierogów "
              & Product_Name (Current_Order.Product, Genitive));

         --  The order waits until the warehouse has enough product.
         --  DONE (Mateusz): limit waiting time / cancel the order?
         Taken := False;
         Order_Wait := 0.0;
         while not Taken and Control.Is_Running loop
            --  TIMED ENTRY CALL
            select
               Warehouse.Take (Current_Order.Product) (Current_Order.Quantity, Taken);
            or
               delay Retry_Timeout;
            end select;

            if not Taken then
               exit when Order_Wait >= Order_Maximum_Wait;
               Log ("Zamówienie Z" & Image (Current_Order.Number) & " czeka na towar");
               Order_Wait := Order_Wait + Order_Retry_Delay;
               delay Order_Retry_Delay;
            end if;
         end loop;

         if Taken then
            Log ("Zamówienie Z" & Image (Current_Order.Number) & " pobrane z magazynu");
            Shipped := False;
            while not Shipped and Control.Is_Running loop
               select
                  Shipping_Station.Ship (Current_Order);
                  Shipped := True;
               or
                  delay Retry_Timeout;
               end select;
            end loop;
            else
            Log ("Zamówienie Z" & Image (Current_Order.Number) & " oczekiwało za długo i zostało anulowane");
         end if;
      end loop;

      Log ("Klient K" & Image (My_Number) & " kończy zamawianie");
      Monitoring.Center_State.Client_Finished;
   exception
      when Error : others =>
         Log ("Klient: błąd - " & Ada.Exceptions.Exception_Message (Error));
         Monitoring.Center_State.Client_Finished;
   end Customer;

end Orders;
