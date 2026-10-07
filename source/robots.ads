--  MODULE 2: Transport robots (Beata)
--  Dispatcher buffers transport jobs from the unloading station,
--  robots take jobs, drive and hand the goods over to the warehouse.

with Common; use Common;

package Robots is

   task Dispatcher is
      --  Unloading station adds a job (Module 1 -> 2)
      entry Submit (Job : in Cargo);
      --  Free robot takes a job
      entry Get_Job (Job : out Cargo);
   end Dispatcher;

   task type Robot is
      entry Start (Number : Robot_Number);
   end Robot;

   Fleet : array (Robot_Number) of Robot;

end Robots;
