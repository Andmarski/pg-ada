--  Random values for the simulation.
--  Every task owns its own generator (course tutorial, point 23) - nothing is shared:
--
--     Randomness : Random_Source;
--     ...
--     Initialize (Randomness, Truck_Seeds + My_Number);
--     delay Random_Duration (Randomness, 1.0, 3.0);

with Ada.Numerics.Float_Random;
with Common; use Common;

package Random_Utilities is

   type Random_Source is limited private;

   --  Seed bases - every task gets a different seed, so tasks started at
   --  the same moment do not produce identical sequences.
   Truck_Seeds    : constant := 100;
   Robot_Seeds    : constant := 200;
   Customer_Seeds : constant := 300;
   Station_Seeds  : constant := 400;

   --  Seed must be unique per task; the result still differs between runs.
   procedure Initialize (Source : in out Random_Source; Seed : Natural);

   --  Uniform value in Minimum .. Maximum
   function Random_Duration
     (Source : Random_Source; Minimum, Maximum : Duration) return Duration;

   --  Uniform integer in Minimum .. Maximum
   function Random_Quantity
     (Source : Random_Source; Minimum, Maximum : Positive) return Positive;

   function Random_Product (Source : Random_Source) return Product_Kind;

private

   type Random_Source is limited record
      Generator : Ada.Numerics.Float_Random.Generator;
   end record;

end Random_Utilities;
