with Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with Console;

package body Logger is

   Start_Time : constant Time := Clock;

   --  tylko to zadanie pisze na konsolę, więc linie różnych zadań się nie mieszają
   task Printer is
      entry Put (Line : String);
   end Printer;

   task body Printer is
   begin
      loop
         select
            accept Put (Line : String) do
               Ada.Text_IO.Put_Line (Line);
            end Put;
         or
            terminate;
         end select;
      end loop;
   end Printer;

   function Image (Value : Integer) return String is
      Text : constant String := Integer'Image (Value);
   begin
      if Value < 0 then
         return Text;
      else
         return Text (Text'First + 1 .. Text'Last);
      end if;
   end Image;

   function Two_Digits (Value : Natural) return String is
   begin
      if Value < 10 then
         return "0" & Image (Value);
      else
         return Image (Value);
      end if;
   end Two_Digits;

   function Timestamp return String is
      Elapsed : constant Duration := To_Duration (Clock - Start_Time);
      Tenths  : constant Natural  :=
        Natural (Float'Floor (Float (Elapsed) * 10.0));
   begin
      return "[" & Two_Digits (Tenths / 10) & "." & Image (Tenths mod 10) & "]";
   end Timestamp;

   procedure Log (Message : String) is
   begin
      Printer.Put (Timestamp & " " & Message);
   end Log;

begin
   --  przed pierwszym komunikatem (zadania z pakietów startują przed Main)
   Console.Enable_Unicode_Output;
end Logger;
