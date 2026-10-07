# Architektura – Hurtownia Pierogów Babci

## Zadania (taski) i spotkania

```
 Truck x3 ──Arrive (timed)──► Unload_Station ──Submit (timed)──► Dispatcher ◄──Get_Job (timed)── Robot x2
 (deliveries)                  (deliveries)                       (robots)                         (robots)
                                                                                                      │
                                                                                          Store (timed)
                                                                                                      ▼
 Customer x3 ──────────────Try_Take (timed)──────────────────────────────────────────────────► Warehouse
 (orders)    │                                                                                 (warehouses)
             │                                                                                      ▲
             └──Ship (timed)──► Shipping_Station                     Monitor ──Get_Status (conditional)┘
                                (shipping)                           (monitoring)

 Center_State (protected) ◄── Delivery_Handled / Set_Robot_State / Order_Completed
 Logger.Printer (task)    ◄── Log (...) ze wszystkich zadań
 Simulation_Control.Control ◄── Stop (main), Is_Running (wszyscy klienci)
```

## Przepływ towaru

1. **Truck** losuje dostawę (`Delivery`: numer, rodzaj pierogów, liczba sztuk) i czeka na rampę.
2. **Unload_Station** przyjmuje samochód (`accept Arrive` – tylko odbiór danych, krótkie spotkanie)
   i rozładowuje go już poza `accept` (samouczek, pkt 18).
3. Rozładowany towar trafia jako `Cargo` do **Dispatcher** (kolejka zleceń transportowych).
4. Wolny **Robot** pobiera zlecenie, jedzie, oddaje towar do **Warehouse** (`Store`).
5. **Customer** składa zamówienie (`Order`) – czeka, aż magazyn ma dość towaru (`Try_Take`).
6. Pobrane zamówienie trafia do **Shipping_Station** – pakowanie i wysyłka.
7. **Monitor** co `Monitor_Period` drukuje raport stanu centrum.
8. Po `Simulation_Duration` `main` woła `Control.Stop`, czeka (z limitem czasu) na
   `Center_State.Wait_All_Finished`, aż wszyscy klienci skończą, i drukuje **raport końcowy**.

## Rodzaje spotkań (wymaganie: 3 różne + min. 1 dozór)

| Konstrukcja | Gdzie | Po co |
|---|---|---|
| Selektywne przyjęcie (`select accept … or accept … or terminate`) z **dozorem `when`** | `Robots.Dispatcher`, `Warehouses.Warehouse` | serwer obsługuje różne zgłoszenia; dozór blokuje `Submit` przy pełnej kolejce i `Get_Job` przy pustej (TODO: dozór pojemności magazynu) |
| Wywołanie z limitem czasu (`select call; or delay …`) | `Truck`, `Robot`, `Customer`, `Hand_Over`, `main` | klient nie czeka w nieskończoność, może sprawdzić koniec symulacji |
| Wywołanie warunkowe (`select call; else …`) | `Monitor` → `Warehouse.Get_Status` | monitor nie blokuje się, gdy magazyn jest zajęty |

## Zasady przeciwdziałania zakleszczeniom

- Serwery (`Unload_Station`, `Dispatcher`, `Warehouse`, `Shipping_Station`, `Logger.Printer`)
  mają alternatywę `or terminate` – kończą się same, gdy nikt już nie może ich wywołać.
- Klienci **nie wywołują** entry bez limitu czasu (wyjątek: krótkie wywołania serwerów,
  które nie mają dozoru, np. `Ship`, `Log`). Po każdym timeoucie sprawdzają `Control.Is_Running`.
- `main` po `Simulation_Duration` woła `Control.Stop` – klienci kończą pętle i zgłaszają to przez
  `Center_State.Client_Finished`; `main` czeka na `Wait_All_Finished` (wejście obiektu chronionego
  z barierą `when Active = 0`), maksymalnie `Shutdown_Timeout`, potem drukuje raport końcowy.
  Serwery odchodzą przez `terminate`, gdy `main` się zakończy.
  (Samouczek, pkt 24–25, proponuje też jawne `entry Zakoncz` – to alternatywa; jeśli zmienimy
  podejście, robimy to spójnie dla wszystkich serwerów.)
- Spotkania są krótkie: w `accept … do … end` tylko przekazanie danych, długie `delay` poza nim.
- Stan dla monitora trzymany jest w obiekcie chronionym `Center_State` – zgłoszenie stanu
  nigdy nie blokuje robota ani stanowiska.
- Każdy task-klient ma obsługę wyjątków (`exception when E : others`) – błąd jest wypisany,
  a nie „cicho” kończy zadanie; zadanie i tak zgłasza `Client_Finished`, więc `main` się nie zawiesi.
- Losowanie bez współdzielenia: każde zadanie ma własny generator (`Random_Source`), ziarno =
  czas startu programu + unikalny numer zadania (różne przebiegi, różne zadania).
