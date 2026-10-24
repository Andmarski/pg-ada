--  Wspólne typy i parametry symulacji

package Common is

   --  Parametry symulacji (czasy w sekundach)

   Truck_Count    : constant := 3;
   Robot_Count    : constant := 2;
   Customer_Count : constant := 3;
   Stove_Count    : constant := 4;  --  liczba stacji gotująco-pakujących

   Warehouse_Capacity          : constant := 50;  --  łączna liczba pierogów w magazynie
   Robot_Capacity              : constant := 10;  --  maks. sztuk w jednym kursie robota
   Maximum_Delivery_Quantity   : constant := 20;
   Maximum_Order_Quantity      : constant := 8;
   Dispatcher_Queue_Size       : constant := 10;  --  maks. zleceń czekających na robota
   Shipping_Station_Queue_Size : constant := 4;   --  maks. zamówień czekających na gotowanie

   Simulation_Duration : constant Duration := 40.0;
   Monitor_Period      : constant Duration := 5.0;
   Retry_Timeout       : constant Duration := 1.0;  --  czas czekania na spotkanie przed ponowieniem
   Truck_Patience      : constant Duration := 3.0;  --  co tyle samochód zgłasza, że nadal czeka
   Order_Retry_Delay   : constant Duration := 2.0;
   Order_Maximum_Wait  : constant Duration := 10.0; --  potem zamówienie jest anulowane
   Shutdown_Timeout    : constant Duration := 15.0; --  maks. czas czekania main na koniec zadań

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

   --  Towary

   type Product_Kind is (Potato_And_Cheese, Meat, Blueberry);

   --  odmiana nazwy: "Pierogi ruskie: 5" / "6 szt. pierogów ruskich"
   type Grammatical_Case is (Nominative, Genitive);

   function Product_Name
     (Product : Product_Kind;
      Form    : Grammatical_Case := Nominative) return String is
     (case Product is
         when Potato_And_Cheese =>
           (case Form is
               when Nominative => "ruskie",
               when Genitive   => "ruskich"),
         when Meat      => "z mięsem",
         when Blueberry => "z jagodami");

   type Stock_Array is array (Product_Kind) of Natural;

   --  Numery uczestników i ich stany

   subtype Truck_Number    is Positive range 1 .. Truck_Count;
   subtype Robot_Number    is Positive range 1 .. Robot_Count;
   subtype Customer_Number is Positive range 1 .. Customer_Count;
   subtype Stove_Number    is Positive range 1 .. Stove_Count;

   type Robot_State is (Idle, Busy);

   function Robot_State_Name (State : Robot_State) return String is
     (case State is
         when Idle => "wolny",
         when Busy => "pracuje");

   type Robot_State_Array is array (Robot_Number) of Robot_State;

   type Stove_State is (Idle, Busy);

   function Stove_State_Name (State : Stove_State) return String is
     (case State is
         when Idle => "wolna",
         when Busy => "gotuje");

   type Stove_State_Array is array (Stove_Number) of Stove_State;

   --  Dane przekazywane w spotkaniach

   --  dostawa samochodem (moduł 1)
   type Delivery is record
      Number   : Positive     := 1;
      Product  : Product_Kind := Potato_And_Cheese;
      Quantity : Positive     := 1;
   end record;

   --  jeden ładunek robota (moduł 2)
   type Cargo is record
      Delivery_Number : Positive     := 1;
      Product         : Product_Kind := Potato_And_Cheese;
      Quantity        : Positive     := 1;
   end record;

   --  zamówienie klienta (moduł A)
   type Order is record
      Number   : Positive        := 1;
      Client   : Customer_Number := 1;
      Product  : Product_Kind    := Potato_And_Cheese;
      Quantity : Positive        := 1;
   end record;

end Common;
