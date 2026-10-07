--  Shared types and simulation parameters.
--  Changes here affect everyone - modify only through a reviewed PR.

package Common is

   ------------------------------------------------------------------
   --  Simulation parameters
   ------------------------------------------------------------------

   Truck_Count    : constant := 3;
   Robot_Count    : constant := 2;
   Customer_Count : constant := 3;

   Warehouse_Capacity        : constant := 50;  --  total dumplings in storage
   Robot_Capacity            : constant := 10;  --  maximum pieces per robot trip
   Maximum_Delivery_Quantity : constant := 20;
   Maximum_Order_Quantity    : constant := 8;

   Simulation_Duration : constant Duration := 40.0;
   Monitor_Period      : constant Duration := 5.0;
   Retry_Timeout       : constant Duration := 1.0;  --  timed entry calls
   Truck_Patience      : constant Duration := 3.0;
   Order_Retry_Delay   : constant Duration := 2.0;
   Shutdown_Timeout    : constant Duration := 15.0; --  maximum wait for tasks at the end

   Truck_Interval_Minimum : constant Duration := 2.0;
   Truck_Interval_Maximum : constant Duration := 6.0;
   Unload_Time_Minimum    : constant Duration := 1.0;
   Unload_Time_Maximum    : constant Duration := 3.0;
   Robot_Travel_Minimum   : constant Duration := 1.0;
   Robot_Travel_Maximum   : constant Duration := 3.0;
   Order_Interval_Minimum : constant Duration := 3.0;
   Order_Interval_Maximum : constant Duration := 7.0;
   Packing_Time_Minimum   : constant Duration := 1.0;
   Packing_Time_Maximum   : constant Duration := 2.0;

   ------------------------------------------------------------------
   --  Products
   ------------------------------------------------------------------

   type Product_Kind is (Potato_And_Cheese, Meat, Blueberry);

   function Product_Name (Product : Product_Kind) return String is
     (case Product is
         when Potato_And_Cheese => "ruskie",
         when Meat              => "z mięsem",
         when Blueberry         => "z jagodami");

   type Stock_Array is array (Product_Kind) of Natural;

   ------------------------------------------------------------------
   --  Numbers of the participants
   ------------------------------------------------------------------

   subtype Truck_Number    is Positive range 1 .. Truck_Count;
   subtype Robot_Number    is Positive range 1 .. Robot_Count;
   subtype Customer_Number is Positive range 1 .. Customer_Count;

   type Robot_State is (Idle, Busy);
   --  TODO (Beata): add e.g. Charging / Broken if needed

   function Robot_State_Name (State : Robot_State) return String is
     (case State is
         when Idle => "wolny",
         when Busy => "pracuje");

   type Robot_State_Array is array (Robot_Number) of Robot_State;

   ------------------------------------------------------------------
   --  Messages exchanged between tasks
   ------------------------------------------------------------------

   --  A truck delivery (Module 1)
   type Delivery is record
      Number   : Positive     := 1;
      Product  : Product_Kind := Potato_And_Cheese;
      Quantity : Positive     := 1;
   end record;

   --  A single robot load (Module 2)
   type Cargo is record
      Delivery_Number : Positive     := 1;
      Product         : Product_Kind := Potato_And_Cheese;
      Quantity        : Positive     := 1;
   end record;

   --  A customer order (Module A)
   type Order is record
      Number   : Positive        := 1;
      Client   : Customer_Number := 1;
      Product  : Product_Kind    := Potato_And_Cheese;
      Quantity : Positive        := 1;
   end record;

end Common;
