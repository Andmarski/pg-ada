--  Moduł C: stanowisko wysyłkowe
--  Shipping_Station trzyma kolejkę zamówień, stacje gotująco-pakujące
--  pobierają z niej zamówienia, gotują, pakują i wysyłają je klientom

with Common; use Common;

package Shipping is

   task Shipping_Station is
      --  klient oddaje zamówienie pobrane z magazynu
      entry Ship (Current_Order : in Order);
      --  wolna stacja gotująco-pakująca pobiera zamówienie
      entry Pass_Order (Current_Order : out Order);
   end Shipping_Station;

   task type Cooking_Packing_Station is
      entry Start (Number : Stove_Number);
   end Cooking_Packing_Station;

   Kitchen : array (Stove_Number) of Cooking_Packing_Station;

end Shipping;
