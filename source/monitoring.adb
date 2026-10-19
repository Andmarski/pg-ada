with Ada.Real_Time;         use Ada.Real_Time;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Exceptions;
with Logger;                use Logger;
with Simulation_Control;    use Simulation_Control;
with Warehouses;

package body Monitoring is

   protected body Center_State is
      procedure Set_Robot_State (Robot : Robot_Number; State : Robot_State) is
      begin
         States (Robot) := State;
      end Set_Robot_State;

      procedure Set_Stove_State (Stove : Stove_Number; State : Stove_State) is
      begin
         S_States (Stove) := State;
      end Set_Stove_State;

      procedure Delivery_Handled is
      begin
         Deliveries := Deliveries + 1;
      end Delivery_Handled;

      procedure Order_Completed is
      begin
         Orders := Orders + 1;
      end Order_Completed;

      procedure Client_Finished is
      begin
         if Active > 0 then
            Active := Active - 1;
         end if;
      end Client_Finished;

      entry Wait_All_Finished when Active = 0 is
      begin
         null;
      end Wait_All_Finished;

      function Robot_States return Robot_State_Array is
      begin
         return States;
      end Robot_States;

      function Stove_States return Stove_State_Array is
      begin
         return S_States;
      end Stove_States;

      function Deliveries_Handled return Natural is
      begin
         return Deliveries;
      end Deliveries_Handled;

      function Orders_Completed return Natural is
      begin
         return Orders;
      end Orders_Completed;
   end Center_State;

   function Build_Report
     (Title : String;
      Stock : Stock_Array;
      Fresh : Boolean) return String
   is
      Line_Feed : constant Character := ASCII.LF;
      Report    : Unbounded_String;
      Total     : Natural := 0;
      States    : constant Robot_State_Array := Center_State.Robot_States;
   begin
      for Amount of Stock loop
         Total := Total + Amount;
      end loop;

      Append (Report, "--------- " & Title & " ---------" & Line_Feed);
      Append (Report, "Magazyn: " & Image (Total) & " / " & Image (Warehouse_Capacity));
      if not Fresh then
         Append (Report, " (magazyn zajęty - poprzedni odczyt)");
      end if;
      Append (Report, Line_Feed);
      for Robot in States'Range loop
         Append (Report, "Robot R" & Image (Robot) & ": "
                 & Robot_State_Name (States (Robot)) & Line_Feed);
      end loop;
      for Stove in Center_State.Stove_States'Range loop
         Append (Report, "Stacja gotująco-pakująca S" & Image (Stove) & ": "
                 & Stove_State_Name (Center_State.Stove_States (Stove)) & Line_Feed);
      end loop;
      Append (Report, "Dostawy obsłużone: "
              & Image (Center_State.Deliveries_Handled) & Line_Feed);
      Append (Report, "Zamówienia zrealizowane: "
              & Image (Center_State.Orders_Completed) & Line_Feed);
      for Product in Product_Kind loop
         Append (Report, "Pierogi " & Product_Name (Product) & ": "
                 & Image (Stock (Product)) & Line_Feed);
      end loop;
      Append (Report, "-------------------------------");
      return To_String (Report);
   end Build_Report;

   task body Monitor is
      Next_Report : Time := Clock + To_Time_Span (Monitor_Period);
      Stock       : Stock_Array := (others => 0);
      Fresh       : Boolean;
   begin
      while Control.Is_Running loop
         delay until Next_Report;
         exit when not Control.Is_Running;  --  final report is printed by main
         Next_Report := Next_Report + To_Time_Span (Monitor_Period);

         --  CONDITIONAL ENTRY CALL: do not wait if the warehouse is busy
         select
            Warehouses.Warehouse.Get_Status (Stock);
            Fresh := True;
         else
            Fresh := False;
         end select;

         Log (Build_Report ("PIEROGARNIA", Stock, Fresh));
      end loop;
   exception
      when Error : others =>
         Log ("Monitor: błąd - " & Ada.Exceptions.Exception_Message (Error));
   end Monitor;

   procedure Final_Report is
      Stock : Stock_Array := (others => 0);
      Fresh : Boolean;
   begin
      select
         Warehouses.Warehouse.Get_Status (Stock);
         Fresh := True;
      or
         delay Retry_Timeout;
         Fresh := False;
      end select;

      Log (Build_Report ("RAPORT KOŃCOWY", Stock, Fresh));
   end Final_Report;

end Monitoring;
