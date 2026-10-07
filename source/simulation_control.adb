package body Simulation_Control is

   protected body Control is
      procedure Stop is
      begin
         Running := False;
      end Stop;

      function Is_Running return Boolean is
      begin
         return Running;
      end Is_Running;
   end Control;

   protected body Numbering is
      procedure Next_Delivery_Number (Number : out Positive) is
      begin
         Last_Delivery := Last_Delivery + 1;
         Number := Last_Delivery;
      end Next_Delivery_Number;

      procedure Next_Order_Number (Number : out Positive) is
      begin
         Last_Order := Last_Order + 1;
         Number := Last_Order;
      end Next_Order_Number;
   end Numbering;

end Simulation_Control;
