--  MODULE 1: Deliveries and the unloading station (Andmarski)
--  Trucks from grandma arrive at random intervals with dumplings,
--  the unloading station serves them one at a time.

with Common; use Common;

package Deliveries is

   task Unload_Station is
      entry Arrive (Arriving : in Delivery);
   end Unload_Station;

   task type Truck is
      entry Start (Number : Truck_Number);
   end Truck;

   Trucks : array (Truck_Number) of Truck;

end Deliveries;
