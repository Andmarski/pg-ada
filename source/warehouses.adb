with Logger; use Logger;

package body Warehouses is

   task body Warehouse is
      Stock : Stock_Array := (others => 0);

      function Total return Natural is
         Sum : Natural := 0;
      begin
         for Amount of Stock loop
            Sum := Sum + Amount;
         end loop;
         return Sum;
      end Total;

   begin
      Log ("Magazyn otwarty (pojemność " & Image (Warehouse_Capacity) & ")");
      loop
         --  SELECTIVE ACCEPT (+ terminate)
         select
            --  TODO (Mateusz): guard on capacity, e.g.
            --     when Total < Warehouse_Capacity =>
            --  and decide what to do when Quantity does not fit.
            accept Store (Product : Product_Kind; Quantity : Positive) do
               Stock (Product) := Stock (Product) + Quantity;
            end Store;
            Log ("Magazyn: przyjęto towar, stan " & Image (Total) & " / "
                 & Image (Warehouse_Capacity));
         or
            accept Get_Status (Current : out Stock_Array) do
               Current := Stock;
            end Get_Status;
         or
            --  TODO (Mateusz): consider an entry family
            --     entry Take (Product_Kind) (Quantity : Positive);
            --  with a "when Stock (Product) > 0" guard instead of polling.
            accept Try_Take
              (Product  : Product_Kind;
               Quantity : Positive;
               Success  : out Boolean)
            do
               Success := Stock (Product) >= Quantity;
               if Success then
                  Stock (Product) := Stock (Product) - Quantity;
               end if;
            end Try_Take;
         or
            terminate;
         end select;
      end loop;
   end Warehouse;

end Warehouses;
