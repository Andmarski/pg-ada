--  MODULE C: Shipping station (Beata)
--  Receives picked orders, packs them and completes them.

with Common; use Common;

package Shipping is

   task Shipping_Station is
      entry Ship (Current_Order : in Order);
      entry Pass_Order (Current_Order : out Order);
   end Shipping_Station;

   task type Cooking_Packing_Station is
      entry Start (Number : Stove_Number);
   end Cooking_Packing_Station;

   Kitchen : array (Stove_Number) of Cooking_Packing_Station;

end Shipping;
