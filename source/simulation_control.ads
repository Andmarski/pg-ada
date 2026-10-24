--  Wspólny stan symulacji

package Simulation_Control is

   --  flaga końca symulacji - klienci sprawdzają Is_Running w swoich pętlach
   protected Control is
      procedure Stop;
      function Is_Running return Boolean;
   private
      Running : Boolean := True;
   end Control;

   --  kolejne numery dostaw (D1, D2, ...) i zamówień (Z1, Z2, ...)
   protected Numbering is
      procedure Next_Delivery_Number (Number : out Positive);
      procedure Next_Order_Number (Number : out Positive);
   private
      Last_Delivery : Natural := 0;
      Last_Order    : Natural := 0;
   end Numbering;

end Simulation_Control;
