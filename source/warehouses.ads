--  MODULE 3: Warehouse (Mateusz)
--  One task with its own state (stock of each dumpling kind).

with Common; use Common;

package Warehouses is

   task Warehouse is
      --  Robot delivers goods (Module 2 -> 3)
      entry Store (Product : in Product_Kind; Quantity : in Positive; Taken : out Natural);

      --  Current stock (Monitor, Module G)
      entry Get_Status (Current : out Stock_Array);

      --  Customer order picks goods (Module A).
      --  Success = False when there is not enough of the product.
      entry Take (Product_Kind) (Quantity : Positive; Success : out Boolean);
   end Warehouse;

end Warehouses;
