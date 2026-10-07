--  MODULE C: Shipping station (Beata)
--  Receives picked orders, packs them and completes them.

with Common; use Common;

package Shipping is

   task Shipping_Station is
      entry Ship (Received : in Order);
   end Shipping_Station;

end Shipping;
