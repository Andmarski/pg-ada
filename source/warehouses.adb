with Logger; use Logger;

package body Warehouses is

   task body Warehouse is
      Stock : Stock_Array := (others => 0);
   -- NAME : DATE_TYPE := INIT_VAL -- (others => 0) inicjalizuje pozostałe(nie wymienione) do 0
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
            --  DONE (Mateusz): guard on capacity, e.g.
            --     when Total < Warehouse_Capacity =>
            --  and decide what to do when Quantity does not fit.
            when Total < Warehouse_Capacity => accept Store (Product : in Product_Kind; Quantity : in Positive; Taken : out Natural) do
               if Quantity + Total <= Warehouse_Capacity then Taken := Quantity;
               else Taken := Warehouse_Capacity - Total;
               end if;
               Stock (Product) := Stock (Product) + Taken;
            end Store;
            Log ("Magazyn: przyjęto towar, stan " & Image (Total) & " / "
                 & Image (Warehouse_Capacity));
         or
            accept Get_Status (Current : out Stock_Array) do
               Current := Stock;
            end Get_Status;
            --  TODO (Mateusz): consider an entry family
            --     entry Take (Product_Kind) (Quantity : Positive);
            --  with a "when Stock (Product) > 0" guard instead of polling.
         or
            when Stock(Potato_And_Cheese) > 0 => accept Take (Potato_And_Cheese) (Quantity : Positive; Success : out Boolean)
            do
               Success := Stock (Potato_And_Cheese) >= Quantity;
               if Success then
                  Stock (Potato_And_Cheese) := Stock (Potato_And_Cheese) - Quantity;
               end if;
            end Take;
         or
            when Stock(Meat) > 0 => accept Take (Meat) (Quantity : Positive; Success : out Boolean)
            do
               Success := Stock (Meat) >= Quantity;
               if Success then
                  Stock (Meat) := Stock (Meat) - Quantity;
               end if;
            end Take;
         or
            when Stock(Blueberry) > 0 => accept Take (Blueberry) (Quantity : Positive; Success : out Boolean)
            do
               Success := Stock (Blueberry) >= Quantity;
               if Success then
                  Stock (Blueberry) := Stock (Blueberry) - Quantity;
               end if;
            end Take;
         or
            terminate;
         end select;
      end loop;
   end Warehouse;

end Warehouses;
