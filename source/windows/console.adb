with Interfaces.C;

package body Console is

   UTF8_Code_Page : constant Interfaces.C.unsigned := 65001;

   --  funkcja Windows API - przełącza konsolę na UTF-8
   procedure Set_Console_Output_Code_Page (Code_Page : Interfaces.C.unsigned)
     with Import, Convention => Stdcall, External_Name => "SetConsoleOutputCP";

   procedure Enable_Unicode_Output is
   begin
      Set_Console_Output_Code_Page (UTF8_Code_Page);
   end Enable_Unicode_Output;

end Console;
