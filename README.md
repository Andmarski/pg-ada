# Hurtownia Pierogów Babci

Projekt z przedmiotu Języki programowania – Ada (2026/27): współbieżna symulacja centrum
logistycznego. Samochody przywożą pierogi (ruskie, z mięsem, z jagodami), stanowisko je
rozładowuje, roboty wożą je do magazynu, a klienci składają zamówienia, które są gotowane,
pakowane i wysyłane.

## Moduły

| Moduł | Pliki | Zadania | Autor |
|---|---|---|---|
| 1 – Dostawy i rozładunek | `deliveries.ad?` | `Truck` ×3, `Unload_Station` | Andmarski |
| 2 – Roboty transportowe | `robots.ad?` | `Dispatcher`, `Robot` ×2 | Beata |
| 3 – Magazyn | `warehouses.ad?` | `Warehouse` | Mateusz |
| A – Zamówienia klientów | `orders.ad?` | `Customer` ×3 | Mateusz |
| C – Stanowisko wysyłkowe | `shipping.ad?` | `Shipping_Station`, `Cooking_Packing_Station` ×4 | Beata |
| G – Monitor centrum | `monitoring.ad?` | `Monitor`, obiekt chroniony `Center_State` | Andmarski |
| Integracja | `main.adb` | start zadań i zakończenie symulacji | Andmarski |

Pliki wspólne: `common.ads` (typy i parametry symulacji), `logger` (komunikaty z czasem),
`random_utilities` (losowanie), `simulation_control` (flaga końca, numeracja), `console` (UTF-8).

## Spotkania

| Rodzaj | Gdzie |
|---|---|
| Selektywne przyjęcie z dozorami `when` | `Dispatcher` (pełna / pusta kolejka), `Warehouse` (pojemność, rodzina wejść `Take` per rodzaj pierogów), `Shipping_Station` (pełna / pusta kolejka) |
| Wywołanie z limitem czasu (`or delay`) | `Truck`, `Hand_Over`, `Robot`, `Customer`, `Cooking_Packing_Station`, `main`, `Final_Report` |
| Wywołanie warunkowe (`else`) | `Monitor` → `Warehouse.Get_Status` |
| `or terminate` | `Unload_Station`, `Dispatcher`, `Warehouse`, `Shipping_Station`, `Logger` |

## Zakończenie symulacji

Po `Simulation_Duration` `main` wywołuje `Control.Stop`. Klienci (samochody, roboty, klienci,
stacje gotująco-pakujące) kończą pętle i zgłaszają to przez `Center_State.Client_Finished`.
`main` czeka na `Center_State.Wait_All_Finished` (bariera: wszyscy skończyli i nic nie jest
rozładowywane), drukuje raport końcowy, a serwery kończą się przez `or terminate`.

## Budowanie i uruchomienie

GNAT Studio: `File → Open Project…` → `dumpling_wholesale.gpr`, potem `Build & Run`.

Terminal:

```bash
gprbuild -p -P dumpling_wholesale.gpr
```

```bash
build\dumpling_wholesale.exe
```

Bez pliku projektu:

```bash
gnatmake -gnat2012 -Isource -Isource/windows source/main.adb
```

Skrót w PowerShell: `.\project run` (także `build`, `clean`, `rebuild`).

Parametry symulacji (czas, liczba samochodów, robotów, klientów, pojemności) są w
`source/common.ads`.
