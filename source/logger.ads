--  Wypisywanie komunikatów z czasem [ss.d] od startu symulacji

package Logger is

   procedure Log (Message : String);

   --  liczba bez spacji na początku: Image (7) = "7"
   function Image (Value : Integer) return String;

end Logger;
