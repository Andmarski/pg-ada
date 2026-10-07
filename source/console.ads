--  Terminal setup, so Polish letters (UTF-8) are displayed correctly.
--  The body is platform specific and chosen by dumpling_wholesale.gpr:
--     source/windows/console.adb - switches the Windows console to UTF-8
--     source/unix/console.adb    - nothing to do, terminals already use UTF-8

package Console is

   --  Called once by Logger when the program starts.
   procedure Enable_Unicode_Output;

end Console;
