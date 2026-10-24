--  Hurtownia Pierogów Babci - współbieżna symulacja centrum logistycznego

with Common;             use Common;
with Logger;             use Logger;
with Simulation_Control; use Simulation_Control;
with Deliveries;
with Robots;
with Orders;
with Shipping;
with Monitoring;


procedure Main is
begin
   Log ("=== Hurtownia Pierogów Babci - start symulacji ("
        & Image (Integer (Simulation_Duration)) & " s) ===");

   for Number in Robot_Number loop
      Robots.Fleet (Number).Start (Number);
   end loop;

   for Number in Truck_Number loop
      Deliveries.Trucks (Number).Start (Number);
   end loop;

   for Number in Customer_Number loop
      Orders.Customers (Number).Start (Number);
   end loop;

   for Number in Stove_Number loop
      Shipping.Kitchen (Number).Start (Number);
   end loop;

   delay Simulation_Duration;

   --  klienci kończą swoje pętle, serwery kończą się przez terminate
   Control.Stop;
   Log ("=== Koniec czasu symulacji - czekam na zakończenie pracy zadań ===");

   --  wywołanie z limitem czasu - nie czekamy w nieskończoność
   select
      Monitoring.Center_State.Wait_All_Finished;
   or
      delay Shutdown_Timeout;
      Log ("Uwaga: nie wszystkie zadania zakończyły pracę w wyznaczonym czasie");
   end select;

   Monitoring.Final_Report;
   Log ("=== Pierogarnia zamknięta ===");
end Main;
