with Interfaces.C;

package body Console is

   UTF8_Code_Page : constant Interfaces.C.unsigned := 65001;

   --  Windows API (kernel32): sets the code page used for console output.
   --  The returned BOOL is ignored - without a console (e.g. output
   --  redirected to a file) the call simply has no effect.
   procedure Set_Console_Output_Code_Page (Code_Page : Interfaces.C.unsigned)
     with Import, Convention => Stdcall, External_Name => "SetConsoleOutputCP";

   procedure Enable_Unicode_Output is
   begin
      Set_Console_Output_Code_Page (UTF8_Code_Page);
   end Enable_Unicode_Output;

end Console;
