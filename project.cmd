@echo off
rem Build helper for the Dumpling Wholesale simulation.
rem
rem   project            build and run (same as "project run")
rem   project build      compile only
rem   project run        compile and run
rem   project clean      remove the build output
rem   project rebuild    clean, then compile
rem
rem PowerShell: .\project run    Git Bash: ./project.cmd run    cmd: project run

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
echo Unknown command "%COMMAND%". Use: build, run, clean or rebuild.
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

rem Uses GNAT from PATH; if it is missing, looks for the toolchain installed by Alire.
:find_compiler
where gprbuild >nul 2>nul && exit /b 0
for %%L in ("%LOCALAPPDATA%\alire" "%USERPROFILE%\.config\alire" "%USERPROFILE%\.cache\alire") do (
   for /f "delims=" %%F in ('dir /s /b "%%~L\gprbuild.exe" 2^>nul') do call :add_to_path "%%~dpF"
   for /f "delims=" %%F in ('dir /s /b "%%~L\gnatmake.exe" 2^>nul') do call :add_to_path "%%~dpF"
)
where gprbuild >nul 2>nul && exit /b 0
echo GNAT compiler not found. See README.md, section "Instalacja (Windows)".
exit /b 1

:add_to_path
set "PATH=%~1;%PATH%"
exit /b 0
