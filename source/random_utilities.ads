--  Losowe czasy, ilości i rodzaje pierogów; każde zadanie ma własny generator

with Ada.Numerics.Float_Random;
with Common; use Common;

package Random_Utilities is

   type Random_Source is limited private;

   --  bazy ziaren - do bazy dodajemy numer zadania, więc każde ma inne ziarno
   Truck_Seeds    : constant := 100;
   Robot_Seeds    : constant := 200;
   Customer_Seeds : constant := 300;
   Station_Seeds  : constant := 400;

   procedure Initialize (Source : in out Random_Source; Seed : Natural);

   --  losowy czas z przedziału Minimum .. Maximum
   function Random_Duration
     (Source : Random_Source; Minimum, Maximum : Duration) return Duration;

   --  losowa liczba całkowita z przedziału Minimum .. Maximum
   function Random_Quantity
     (Source : Random_Source; Minimum, Maximum : Positive) return Positive;

   function Random_Product (Source : Random_Source) return Product_Kind;

private

   type Random_Source is limited record
      Generator : Ada.Numerics.Float_Random.Generator;
   end record;

end Random_Utilities;
