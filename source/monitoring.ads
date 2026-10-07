--  MODULE G: Center monitor (Andmarski)
--  Center_State collects information reported by other tasks,
--  Monitor periodically prints a report of the whole center.

with Common; use Common;

package Monitoring is

   --  Protected object (not a task) so reporting never blocks for long
   --  and never raises Tasking_Error at the end of the simulation.
   protected Center_State is
      procedure Set_Robot_State (Robot : Robot_Number; State : Robot_State);
      procedure Delivery_Handled;
      procedure Order_Completed;

      --  Every client task (truck, robot, customer) calls this once,
      --  when it finishes its work - also after an exception.
      procedure Client_Finished;

      --  Opens when all client tasks have finished (used by main).
      entry Wait_All_Finished;

      function Robot_States return Robot_State_Array;
      function Deliveries_Handled return Natural;
      function Orders_Completed return Natural;
   private
      States     : Robot_State_Array := (others => Idle);
      Deliveries : Natural := 0;
      Orders     : Natural := 0;
      Active     : Natural := Truck_Count + Robot_Count + Customer_Count;
   end Center_State;

   task Monitor;

   --  Summary printed by main at the end of the simulation.
   procedure Final_Report;

end Monitoring;
