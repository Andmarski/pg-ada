with Ada.Exceptions;
with Logger;             use Logger;
with Random_Utilities;   use Random_Utilities;
with Simulation_Control; use Simulation_Control;
with Warehouses;         use Warehouses;
with Monitoring;         use Monitoring;

package body Robots is

   task body Dispatcher is
      --  DONE (Beata): replace the single slot with a bounded FIFO queue
      --  of e.g. 10 jobs (guards: Count < Maximum for Submit, Count > 0 for Get_Job)

      -- FIFO queue utilities
      type Job_Queue is array (1 .. Dispatcher_Queue_Size) of Cargo;
      Queue : Job_Queue;
      Job_Count : Natural := 0;
      Queue_Head : Natural := 1;
      Queue_Tail : Natural := 1;
   begin

      loop
         --  SELECTIVE ACCEPT with GUARDS ("when") + terminate
         select
            when Job_Count < Dispatcher_Queue_Size =>
               accept Submit (Job : in Cargo) do
                  Queue (Queue_Tail) := Job; -- add job to the end of the queue
                  Logger.Log ("Dispatcher: przyjęto zlecenie D" & Image (Job.Delivery_Number) & " "
                             & Image (Job.Quantity) & " szt. pierogów "
                             & Product_Name (Job.Product));
               end Submit;
               Queue_Tail := (Queue_Tail  mod Dispatcher_Queue_Size) + 1;
                  Job_Count := Job_Count + 1;
         or
            when Job_Count > 0 =>
               accept Get_Job (Job : out Cargo) do
                  Job := Queue (Queue_Head); -- get job from the front of the queue
                  Logger.Log ("Dispatcher: przekazano zlecenie D" & Image (Job.Delivery_Number) & " "
                             & Image (Job.Quantity) & " szt. pierogów "
                             & Product_Name (Job.Product));
               end Get_Job;
               Job_Count := Job_Count - 1;
               Queue_Head := (Queue_Head  mod Dispatcher_Queue_Size) + 1;
         or
            terminate;
         end select;
      end loop;
   end Dispatcher;

   task body Robot is
      My_Number  : Robot_Number;
      Job        : Cargo;
      Stored     : Boolean;
      Randomness : Random_Source;

      function Name return String is ("Robot R" & Image (My_Number));
   begin
      accept Start (Number : Robot_Number) do
         My_Number := Number;
      end Start;
      Initialize (Randomness, Robot_Seeds + My_Number);
      Log (Name & " gotowy do pracy");

      while Control.Is_Running loop
         --  TIMED ENTRY CALL: wait for a job at most Retry_Timeout,
         --  then check again whether the simulation is still running.
         select
            Dispatcher.Get_Job (Job);
            Center_State.Set_Robot_State (My_Number, Busy);
            Log (Name & " otrzymał " & Image (Job.Quantity) & " szt. pierogów "
                 & Product_Name (Job.Product)
                 & " (dostawa D" & Image (Job.Delivery_Number) & ")");
            Log (Name & " jedzie do magazynu");
            delay Random_Duration (Randomness, Robot_Travel_Minimum, Robot_Travel_Maximum);

            Stored := False;
            while not Stored and Control.Is_Running loop
               select
                  Warehouse.Store (Job.Product, Job.Quantity);
                  Stored := True;
               or
                  delay Retry_Timeout;
                  Log (Name & " czeka na miejsce w magazynie");
               end select;
            end loop;

            if Stored then
               Log (Name & " dostarczył towar");
            end if;
            Center_State.Set_Robot_State (My_Number, Idle);
            Log (Name & " jest ponownie wolny");
         or
            delay Retry_Timeout;
         end select;
      end loop;

      Log (Name & " kończy pracę");
      Center_State.Client_Finished;
   exception
      when Error : others =>
         Log ("Robot: błąd - " & Ada.Exceptions.Exception_Message (Error));
         Center_State.Client_Finished;
   end Robot;

end Robots;
