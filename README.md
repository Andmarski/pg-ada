# Hurtownia Pierogów Babci 🥟

Projekt z przedmiotu **Języki programowania – Ada** (2026/27): wieloprocesowa symulacja
centrum logistycznego. Babcia lepi pierogi, samochody dowożą je do hurtowni, roboty
rozwożą je po magazynie, a głodni klienci składają zamówienia.

Towary: pierogi **ruskie**, **z mięsem**, **z jagodami**.

Moduły:

- **1** – Dostawy i stanowisko rozładunkowe
- **2** – Roboty transportowe
- **3** – Magazyn
- **A** – Zamówienia klientów
- **C** – Stanowisko wysyłkowe
- **G** – Kontroler / monitor centrum

Architektura, spotkania i zasady anty-zakleszczeń: [documentation/ARCHITECTURE.md](documentation/ARCHITECTURE.md).

**Terminy (z wprowadzenia do kursu):** rozwiązanie wgrywa jedna osoba na e-nauczanie
do **25.10.2026**; demonstracja całą grupą (~10 min) wg harmonogramu na e-nauczaniu.

## Instalacja (Windows) – ok. 10 minut

Bez kompilatora GNAT VS Code podkreśla wszystko jako błąd (`cannot find name 'Ada'`,
`cannot find name 'Append'`) – rozszerzenie Ady bierze bibliotekę standardową z instalacji GNAT.

W laboratorium jest **GNAT Studio z GNAT 2021**. Kod piszemy w **Adzie 2012** (`-gnat2012`
w `.gpr`), więc kompiluje się zarówno tam, jak i na nowszym GNAT u nas.

**1. Zainstaluj Alire** (oficjalny instalator narzędzi Ady) – pobierz i uruchom:
<https://github.com/alire-project/alire/releases/download/v2.1.1/alr-2.1.1-installer-x86_64-windows.exe>

**2. Pobierz kompilator** – w **nowym** oknie PowerShell:

```powershell
alr toolchain --select
```

Jeśli `alr` „is not recognized” (instalator nie dodał go do PATH), użyj pełnej ścieżki:

```powershell
& "C:\Program Files\Alire\bin\alr.exe" toolchain --select
```

Wybierz najnowszy `gnat_native`, potem najnowszy `gprbuild` (Enter = domyślny wybór).
Za pierwszym razem Alire może też doinstalować MSYS2 – to normalne, chwilę trwa.

**3. Dodaj kompilator do PATH** (jednorazowo, tylko dla Twojego konta) – wklej w PowerShell:

```powershell
$found = @(Get-ChildItem "$env:ProgramFiles\Alire\bin", "$env:LOCALAPPDATA\alire", "$env:USERPROFILE\.config\alire", "$env:USERPROFILE\.cache\alire" -Recurse -Include alr.exe, gnatmake.exe, gprbuild.exe -ErrorAction SilentlyContinue | ForEach-Object DirectoryName | Sort-Object -Unique); $userPath = [Environment]::GetEnvironmentVariable('Path', 'User'); [Environment]::SetEnvironmentVariable('Path', ((@($userPath -split ';') + $found | Where-Object { $_ } | Select-Object -Unique) -join ';'), 'User'); $found
```

Na końcu wypisze dodane katalogi (powinny być trzy: `Alire\bin`, `gnat_native…\bin` i `gprbuild…\bin`).

**4. Zamknij i otwórz ponownie VS Code** (i terminale), potem sprawdź:

```powershell
gprbuild --version
```

```powershell
.\project run
```

Jeśli symulacja wystartowała – gotowe, błędy w VS Code też znikną.

> Masz już GNAT Studio z GNAT 2021 (jak w laboratorium)? Wystarczy krok 3 z jego katalogiem
> `bin` (np. `C:\GNAT\2021\bin`) – Alire nie jest potrzebny.

## Szybkie komendy – `project.cmd`

| Komenda (PowerShell) | Co robi |
|---|---|
| `.\project` lub `.\project run` | kompiluje i uruchamia symulację |
| `.\project build` | tylko kompilacja |
| `.\project rebuild` | czyści i kompiluje od zera |
| `.\project clean` | usuwa folder `build/` |

W **cmd** bez `.\` (`project run`), w **Git Bash**: `./project.cmd run`.
Skrypt sam znajdzie kompilator z Alire, nawet jeśli PATH nie jest jeszcze ustawiony
(ale VS Code potrzebuje PATH – krok 3).

## Praca w VS Code

1. `File → Open Folder…` → cały folder `pg-ada` (nie pojedynczy plik).
2. VS Code zaproponuje rozszerzenia z `.vscode/extensions.json` – zainstaluj:
   - **Ada & SPARK** (AdaCore) – podpowiedzi, F12 (definicja), błędy na bieżąco,
   - **C/C++** (Microsoft) – tylko do debugowania (F5).
3. Skróty:

| Co | Jak |
|---|---|
| Kompilacja | `Ctrl+Shift+B` (zadanie **Build**) – błędy w zakładce *Problems* |
| Kompilacja + uruchomienie | `Terminal → Run Task… → Run` |
| Debugowanie (gdb) | `F5` |
| Kompilacja przez gnatmake | `Terminal → Run Task… → Build (gnatmake)` |
| Sprzątanie folderu `build/` | `Terminal → Run Task… → Clean` |

Konfiguracja jest w `.vscode/` (wspólna dla zespołu). Prywatne ustawienia trzymaj
w ustawieniach użytkownika VS Code, nie w repo.

## Budowanie i uruchamianie

**GNAT Studio:** `File → Open Project…` → `dumpling_wholesale.gpr`, potem `Build & Run → main.adb`.

**Terminal:**

```bash
gprbuild -p -P dumpling_wholesale.gpr
```

albo

```bash
gnatmake -P dumpling_wholesale.gpr
```

Uruchomienie (Windows):

```bash
build\dumpling_wholesale.exe
```

Awaryjnie, bez pliku `.gpr` (np. gdy w laboratorium coś z nim nie działa):

```bash
gnatmake -gnat2012 -Isource source/main.adb
```

Pliki kompilacji trafiają do `build/` (obiekty w `build/objects/`) – są w `.gitignore`, nie commitujemy ich.

## Oddawanie w laboratorium

- [ ] Na najbliższych zajęciach: `gnatmake --version` w laboratorium, sklonować repo
      (albo pobrać ZIP z GitHuba), otworzyć `dumpling_wholesale.gpr` w GNAT Studio, zbudować i uruchomić.
- [ ] Na bieżąco: `main` zawsze się kompiluje i symulacja dochodzi do końca.
- [ ] Tydzień przed oddaniem: powtórzyć test na komputerze w laboratorium na świeżym klonie `main`.
- [ ] Na oddanie: dostęp do repo (login GitHub lub ZIP) + kopia na pendrivie.
- [ ] Czas symulacji na prezentację: stała `Simulation_Duration` w `source/common.ads`.

## Materiały z kursu

Z e-nauczania: `samouczek.pdf` (mini-samouczek Ady do projektu), `ada_intro.pdf`
(wprowadzenie), `Ada_95_Skrypt_Wyd_II.pdf`. Trzymaj je lokalnie w folderze `materials/`
(jest w `.gitignore` – nie publikujemy materiałów prowadzącej).

Najważniejsze wskazówki z samouczka, których się trzymamy:

- spotkania krótkie – w `accept … do … end` tylko przekazanie danych, długie `delay` poza nim (pkt 18),
- każde zadanie ma własny generator losowy (pkt 23),
- `select … else` nie w szybkiej pętli bez opóźnienia (pkt 15),
- `when` musi zależeć od rzeczywistego stanu programu (pkt 31),
- każde zadanie musi dać się poprawnie zakończyć (pkt 24–25),
- kolejność komunikatów różnych zadań może się zmieniać – to normalne (pkt 28).

## Struktura

| Plik | Zawartość | Właściciel |
|---|---|---|
| `source/main.adb` | start wszystkich tasków, koniec symulacji | Andmarski |
| `source/deliveries.ad?` | **Moduł 1**: `Truck`, `Unload_Station` | Andmarski |
| `source/monitoring.ad?` | **Moduł G**: `Monitor`, `Center_State` | Andmarski |
| `source/robots.ad?` | **Moduł 2**: `Dispatcher`, `Robot` | Beata |
| `source/shipping.ad?` | **Moduł C**: `Shipping_Station` | Beata |
| `source/warehouses.ad?` | **Moduł 3**: `Warehouse` | Mateusz |
| `source/orders.ad?` | **Moduł A**: `Customer` | Mateusz |
| `source/common.ads` | wspólne typy i parametry symulacji | wspólne |
| `source/logger.ad?` | `Log` – wypisywanie z czasem `[ss.d]` | wspólne |
| `source/random_utilities.ad?` | losowe czasy, ilości, rodzaje pierogów (własny generator w każdym zadaniu) | wspólne |
| `source/simulation_control.ad?` | flaga końca symulacji, generator numerów | wspólne |
| `source/console.ads` + `source/windows/`, `source/unix/` | UTF-8 w konsoli (wersję wybiera `.gpr`) | wspólne |

Specyfikacje (`.ads`) to umowa między modułami – zmiana entry wymaga uzgodnienia z osobą,
która z niego korzysta. Pliki wspólne zmieniamy tylko przez PR zaakceptowany przez kogoś innego.

## Podział pracy

### Andmarski – Moduł 1 + Moduł G + integracja
- [ ] Dostawy: losowe odstępy, identyfikator, rodzaj, liczba sztuk (jest szkielet)
- [x] Podział dostawy na ładunki ≤ `Robot_Capacity` (`Hand_Over`)
- [ ] Komunikaty zgodne z przykładem z zadania (`Przyjazd…`, `oczekuje…`, `Rozpoczęto…`, `Zakończono…`)
- [ ] Monitor: dopracowanie raportu (np. kolejka dyspozytora, oczekujące zamówienia)
- [ ] `main`: kolejność startu i czyste zakończenie

### Beata – Moduł 2 + Moduł C
- [x] Dyspozytor: kolejka FIFO zamiast jednego slotu (dozory `when Count < Max` / `when Count > 0`)
- [ ] Robot: pełny cykl z zadania (otrzymał → jedzie → dostarczył → wolny), raportowanie stanu
- [x] Stanowisko wysyłkowe: przyjęcie, pakowanie przez określony czas, zakończenie zamówienia

### Mateusz – Moduł 3 + Moduł A
- [x] Magazyn: dozór `when` na pojemność, obsługa przepełnienia, min. 3 rodzaje towarów
- [ ] Magazyn: sprawdzenie stanu (`Get_Status`)
- [x] Zamówienia: realizacja tylko przy wystarczającym stanie, oczekiwanie na brakujący towar
- [x] (opcjonalnie) rodzina entry `Take (Product_Kind)` z dozorem zamiast odpytywania

### Wszyscy – przed oddaniem
- [ ] 3 różne konstrukcje `select` + min. 1 dozór `when`, sensowne w scenariuszu
- [ ] Losowość i opóźnienia w każdym module
- [ ] Brak zakleszczeń, kontrolowane zakończenie programu
- [ ] Kompilacja bez błędów (najlepiej i bez ostrzeżeń)

## Mapa wymagań → kod

| Wymaganie | Gdzie |
|---|---|
| Selektywne przyjęcie z dozorem `when` | `Robots.Dispatcher` (+ `Warehouses.Warehouse` – TODO) |
| Wywołanie z limitem czasu (`or delay`) | `Truck`, `Robot`, `Customer`, `Deliveries.Hand_Over`, `main` (czekanie na koniec) |
| Wywołanie warunkowe (`else`) | `Monitoring.Monitor` → `Warehouse.Get_Status` |
| `or terminate` w serwerach | `Unload_Station`, `Dispatcher`, `Warehouse`, `Shipping_Station`, `Logger` |
| Losowość | `Random_Utilities` – każde zadanie ma własny `Random_Source` |
| Kontrolowane zakończenie | `Control.Stop` → klienci kończą pętle → `Center_State.Wait_All_Finished` → `Final_Report` |
| Komunikaty w terminalu | `Logger.Log` |

## Punktacja (z treści zadania)

| Element | Pkt |
|---|---|
| Moduł 1: Dostawy i rozładunek | 2 |
| Moduł 2: Roboty transportowe | 2 |
| Moduł 3: Magazyn | 2 |
| 3 wybrane moduły dodatkowe (A, C, G) | 4,5 |
| Integracja i współbieżność | 1,5 |
| 3 różne konstrukcje select i min. 1 dozór | 2 |
| Jakość programu i prezentacja | 1 |
| **Razem** | **15** |

## Konwencje

- **Nazwy w kodzie** (identyfikatory, pakiety, pliki, foldery) – **po angielsku i pełnymi wyrazami**,
  bez skrótów: `Number` zamiast `Id`, `Maximum` zamiast `Max`, `Image` zamiast `Img`,
  `Randomness` zamiast `Rand`. Komentarze w kodzie też po angielsku.
- Wyjątki od tej zasady: nazwy narzucone przez narzędzia (`README.md`, `.gitignore`, `.vscode/…`)
  i biblioteka standardowa Ady (`Ada.Text_IO`, `Put_Line`, atrybuty `'Pos`, `'Val`, `ASCII.LF`).
- Komunikaty w terminalu (dane) po polsku, **z polskimi znakami**. Pliki źródłowe zapisujemy
  w **UTF-8 bez BOM** (domyślne w VS Code; w GNAT Studio: `Edit → Preferences → Editor →
  Default charset → UTF-8`). Nie dodajemy `-gnatW8` – wtedy `ł`, `ę` w `String` to błąd.
  Konsolę Windows przełącza na UTF-8 pakiet `Console` (wołany przez `Logger`).
- Na ekran piszemy **tylko** przez `Logger.Log` – nigdy `Ada.Text_IO` bezpośrednio z tasków.
- Parametry symulacji (czasy, liczby, pojemności) tylko w `Common` – bez „magicznych liczb”.
- Klient wywołuje entry z limitem czasu i sprawdza `Control.Is_Running` (patrz ARCHITECTURE).
- Każde zadanie-klient na końcu (także w `exception`) woła `Center_State.Client_Finished` –
  inaczej `main` będzie czekać do `Shutdown_Timeout`.
- Losowanie: każde zadanie deklaruje własne `Randomness : Random_Source` i woła
  `Initialize (Randomness, <X>_Seeds + My_Number)` – nie współdzielimy generatora.

## Praca z gitem

Każdy pracuje na swojej gałęzi, do `main` trafia tylko przez Pull Request.

```bash
git checkout main
```

```bash
git pull
```

```bash
git checkout -b modul-2-roboty
```

Po zmianach:

```bash
git add source/robots.adb
```

```bash
git commit -m "Robots: kolejka FIFO w dyspozytorze"
```

```bash
git push -u origin modul-2-roboty
```

Potem na GitHubie: **Pull Request → main**, ktoś inny przegląda i merguje.

Proponowane gałęzie: `modul-1-dostawy`, `modul-g-monitor`, `modul-2-roboty`, `modul-c-wysylka`,
`modul-3-magazyn`, `modul-a-zamowienia`.

Przed PR: projekt się kompiluje, symulacja dochodzi do końca, `git status` nie pokazuje
plików z `build/`.
