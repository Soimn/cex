@echo off

setlocal

cd %~dp0

if not exist build mkdir build

set "compile_options= -subsystem:windows"

if "%1"=="debug" (
	set "compile_options=%compile_options%"
) else if "%1"=="release" (
	set "compile_options=%compile_options% -o:speed -no-bounds-check"
) else (
  goto invalid_arguments
)

if "%2" neq "" goto invalid_arguments

odin build src -out:build\cex.exe %compile_options%

goto end

:invalid_arguments
echo Invalid arguments^. Usage: build ^[debug or release^]
goto end

:end
endlocal
