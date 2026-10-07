with Ada.Calendar;

package body Random_Utilities is

   use Ada.Numerics.Float_Random;

   --  Time of program start (tenths of a second since midnight):
   --  makes every run different. Read-only, so safe to share.
   Run_Seed : constant Integer :=
     Integer (Ada.Calendar.Seconds (Ada.Calendar.Clock) * 10);

   procedure Initialize (Source : in out Random_Source; Seed : Natural) is
   begin
      Reset (Source.Generator, Run_Seed + Seed * 7919);
   end Initialize;

   function Uniform (Source : Random_Source) return Float is
   begin
      return Random (Source.Generator);
   end Uniform;

   function Random_Duration
     (Source : Random_Source; Minimum, Maximum : Duration) return Duration is
   begin
      return Minimum + Duration (Uniform (Source) * Float (Maximum - Minimum));
   end Random_Duration;

   function Random_Quantity
     (Source : Random_Source; Minimum, Maximum : Positive) return Positive
   is
      Span   : constant Positive := Maximum - Minimum + 1;
      Offset : constant Natural  :=
        Natural (Float'Floor (Uniform (Source) * Float (Span)));
   begin
      return Positive'Min (Minimum + Offset, Maximum);
   end Random_Quantity;

   function Random_Product (Source : Random_Source) return Product_Kind is
      Count : constant Positive := Product_Kind'Pos (Product_Kind'Last) + 1;
      Index : constant Natural  :=
        Natural'Min (Natural (Float'Floor (Uniform (Source) * Float (Count))), Count - 1);
   begin
      return Product_Kind'Val (Index);
   end Random_Product;

end Random_Utilities;
