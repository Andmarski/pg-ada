--  Global simulation state: end-of-simulation flag and unique number source.
--
--  Anti-deadlock rule: every client task (truck, robot, customer, monitor)
--  checks Control.Is_Running in its loops and uses timed entry calls,
--  so after Control.Stop all clients finish and the servers can leave
--  through their "or terminate" alternatives.

package Simulation_Control is

   protected Control is
      procedure Stop;
      function Is_Running return Boolean;
   private
      Running : Boolean := True;
   end Control;

   protected Numbering is
      procedure Next_Delivery_Number (Number : out Positive);
      procedure Next_Order_Number (Number : out Positive);
   private
      Last_Delivery : Natural := 0;
      Last_Order    : Natural := 0;
   end Numbering;

end Simulation_Control;
