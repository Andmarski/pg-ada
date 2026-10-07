--  MODULE A: Customer orders (Mateusz)
--  Customers order dumplings; an order waits until the warehouse
--  has enough of the product, then goes to the shipping station.

with Common; use Common;

package Orders is

   task type Customer is
      entry Start (Number : Customer_Number);
   end Customer;

   Customers : array (Customer_Number) of Customer;

end Orders;
