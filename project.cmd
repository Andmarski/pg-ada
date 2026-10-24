@echo off
rem project [run]   - kompilacja i uruchomienie
rem project build   - tylko kompilacja
rem project clean   - usuniecie folderu build
rem project rebuild - kompilacja od zera

setlocal
cd /d "%~dp0"

set "PROJECT_FILE=dumpling_wholesale.gpr"
set "PROGRAM=build\dumpling_wholesale.exe"
set "COMMAND=%~1"
if "%COMMAND%"=="" set "COMMAND=run"

call :find_compiler || exit /b 1

if /i "%COMMAND%"=="build"   goto build
if /i "%COMMAND%"=="run"     goto run
if /i "%COMMAND%"=="clean"   goto clean
if /i "%COMMAND%"=="rebuild" goto rebuild
echo Nieznana komenda "%COMMAND%". Dostepne: build, run, clean, rebuild.
exit /b 1

:build
gprbuild -p -P "%PROJECT_FILE%"
exit /b %errorlevel%

:run
gprbuild -p -P "%PROJECT_FILE%" || exit /b 1
echo.
"%PROGRAM%"
exit /b %errorlevel%

:clean
gprclean -r -P "%PROJECT_FILE%"
exit /b %errorlevel%

:rebuild
gprclean -r -P "%PROJECT_FILE%"
gprbuild -p -P "%PROJECT_FILE%"
exit /b %errorlevel%

rem GNAT z PATH, a jesli go nie ma - z instalacji Alire
:find_compiler
where gprbuild >nul 2>nul && exit /b 0
for %%L in ("%LOCALAPPDATA%\alire" "%USERPROFILE%\.config\alire" "%USERPROFILE%\.cache\alire") do (
   for /f "delims=" %%F in ('dir /s /b "%%~L\gprbuild.exe" 2^>nul') do call :add_to_path "%%~dpF"
   for /f "delims=" %%F in ('dir /s /b "%%~L\gnatmake.exe" 2^>nul') do call :add_to_path "%%~dpF"
)
where gprbuild >nul 2>nul && exit /b 0
echo Nie znaleziono kompilatora GNAT ^(gprbuild^) - dodaj go do PATH.
exit /b 1

:add_to_path
set "PATH=%~1;%PATH%"
exit /b 0
