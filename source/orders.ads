--  Moduł A: zamówienia klientów

with Common; use Common;

package Orders is

   task type Customer is
      entry Start (Number : Customer_Number);
   end Customer;

   Customers : array (Customer_Number) of Customer;

end Orders;
