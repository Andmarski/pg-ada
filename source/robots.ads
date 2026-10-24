--  Moduł 2: roboty transportowe i dyspozytor zleceń

with Common; use Common;

package Robots is

   task Dispatcher is
      --  stanowisko rozładunkowe dodaje zlecenie
      entry Submit (Job : in Cargo);
      --  wolny robot pobiera zlecenie
      entry Get_Job (Job : out Cargo);
   end Dispatcher;

   task type Robot is
      entry Start (Number : Robot_Number);
   end Robot;

   Fleet : array (Robot_Number) of Robot;

end Robots;
