--  Moduł 3: magazyn

with Common; use Common;

package Warehouses is

   task Warehouse is
      --  robot oddaje towar; Taken = ile sztuk magazyn przyjął
      entry Store (Product : in Product_Kind; Quantity : in Positive; Taken : out Natural);

      --  aktualny stan magazynu (dla monitora)
      entry Get_Status (Current : out Stock_Array);

      --  pobranie towaru do zamówienia; Success = False, gdy jest go za mało
      entry Take (Product_Kind) (Quantity : Positive; Success : out Boolean);
   end Warehouse;

end Warehouses;
