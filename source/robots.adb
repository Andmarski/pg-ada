with Ada.Exceptions;
with Logger;             use Logger;
with Random_Utilities;   use Random_Utilities;
with Simulation_Control; use Simulation_Control;
with Warehouses;         use Warehouses;
with Monitoring;         use Monitoring;

package body Robots is

   task body Dispatcher is
      --  kolejka FIFO zleceń w tablicy cyklicznej
      type Job_Queue is array (1 .. Dispatcher_Queue_Size) of Cargo;
      Queue : Job_Queue;
      Job_Count : Natural := 0;
      Queue_Head : Natural := 1;
      Queue_Tail : Natural := 1;
   begin

      loop
         --  selektywne przyjęcie z dozorami - pełna kolejka blokuje Submit,
         --  pusta blokuje Get_Job
         select
            when Job_Count < Dispatcher_Queue_Size =>
               accept Submit (Job : in Cargo) do
                  Queue (Queue_Tail) := Job;
                  Logger.Log ("Dispatcher: przyjęto zlecenie D" & Image (Job.Delivery_Number) & " "
                             & Image (Job.Quantity) & " szt. pierogów "
                             & Product_Name (Job.Product, Genitive));
               end Submit;
               Queue_Tail := (Queue_Tail  mod Dispatcher_Queue_Size) + 1;
               Job_Count := Job_Count + 1;
         or
            when Job_Count > 0 =>
               accept Get_Job (Job : out Cargo) do
                  Job := Queue (Queue_Head);
                  Logger.Log ("Dispatcher: przekazano zlecenie D" & Image (Job.Delivery_Number) & " "
                             & Image (Job.Quantity) & " szt. pierogów "
                             & Product_Name (Job.Product, Genitive));
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
         --  wywołanie z limitem czasu - co Retry_Timeout sprawdzamy,
         --  czy symulacja trwa
         select
            Dispatcher.Get_Job (Job);
            Center_State.Set_Robot_State (My_Number, Busy);
            Log (Name & " otrzymał " & Image (Job.Quantity) & " szt. pierogów "
                 & Product_Name (Job.Product, Genitive)
                 & " (dostawa D" & Image (Job.Delivery_Number) & ")");
            Log (Name & " jedzie do magazynu");
            delay Random_Duration (Randomness, Robot_Travel_Minimum, Robot_Travel_Maximum);

            Stored := False;
            declare
               Amount_taken : Natural;
            begin
               while not Stored and Control.Is_Running loop
                  --  wywołanie z limitem czasu - magazyn może przyjąć
                  --  tylko część ładunku, resztę oddajemy w kolejnej próbie
                  select
                     Warehouse.Store (Job.Product, Job.Quantity, Amount_taken);
                     if Job.Quantity = Amount_taken then
                        Stored := True;
                     else
                        Job.Quantity := Job.Quantity - Amount_taken;
                     end if;
                  or
                     delay Retry_Timeout;
                     Log (Name & " czeka na miejsce w magazynie");
                  end select;
               end loop;
            end;

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
