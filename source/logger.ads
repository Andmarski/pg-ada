--  Terminal output for the whole simulation.
--  Always print through Log - it adds a [ss.d] timestamp and guarantees
--  that lines from different tasks are not interleaved.
--  Messages: Polish with diacritics; source files are UTF-8 without BOM,
--  Console.Enable_Unicode_Output switches the Windows console to UTF-8.

package Logger is

   procedure Log (Message : String);

   --  Integer image without the leading space: Image (7) = "7"
   function Image (Value : Integer) return String;

end Logger;
