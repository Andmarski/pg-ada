--  Moduł G: monitor centrum

with Common; use Common;

package Monitoring is

   --  obiekt chroniony - zadania zgłaszają tu swój stan, monitor go odczytuje
   protected Center_State is
      procedure Set_Robot_State (Robot : Robot_Number; State : Robot_State);
      procedure Set_Stove_State (Stove : Stove_Number; State : Stove_State);
      procedure Delivery_Handled;
      procedure Order_Completed;

      --  numer rozładowywanej dostawy, 0 = stanowisko wolne
      procedure Set_Unloading (Delivery_Number : Natural);

      --  każde zadanie-klient wywołuje raz, na koniec pracy (także po błędzie)
      procedure Client_Finished;

      --  otwiera się, gdy wszystkie zadania skończyły pracę
      --  i nic nie jest rozładowywane (czeka na to main)
      entry Wait_All_Finished;

      function Robot_States return Robot_State_Array;
      function Stove_States return Stove_State_Array;
      function Deliveries_Handled return Natural;
      function Orders_Completed return Natural;
      function Unloading_Delivery return Natural;
   private
      States     : Robot_State_Array := (others => Idle);
      S_States : Stove_State_Array := (others => Idle);
      Deliveries : Natural := 0;
      Orders     : Natural := 0;
      Unloading  : Natural := 0;
      Active    : Natural := Truck_Count + Robot_Count + Customer_Count + Stove_Count;
   end Center_State;

   task Monitor;

   --  raport końcowy, wywołuje go main
   procedure Final_Report;

end Monitoring;
