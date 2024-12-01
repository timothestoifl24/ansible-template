@echo off
setlocal enabledelayedexpansion

set "PROGNAME=%~nx0"

rem Ask the user for the project path
set /p PROJECTPATH=Please enter the project path: 

if "%PROJECTPATH%"=="" (
    echo Usage: %PROGNAME% <PROJECTPATH>
    exit /b 1
)

if exist "%PROJECTPATH%" (
    echo %PROGNAME%: directory '%PROJECTPATH%' already exists
    exit /b 2
)

rem Function to get the absolute path
for %%f in ("%~f0") do set "SCRIPT_ABS_PATH=%%~dpf"

md "%PROJECTPATH%"
cd /d "%PROJECTPATH%"

for %%d in (playbooks group_vars host_vars roles) do (
    md "%%d"
    echo Created directory: %%d
)

rem Function to write out file contents
call :write_out ansible.cfg
call :write_out .envrc
call :write_out inventory
exit /b 0

:write_out
(
    echo [defaults]
    echo inventory = ./inventory
    echo.
    echo stdout_callback = yaml
    echo.
    echo gathering = smart
    echo fact_caching = jsonfile
    echo fact_caching_connection = ^~/.ansible/fact_cache
    echo fact_caching_timeout = 86400
    echo.
    echo retry_files_enabled = yes
    echo retry_files_save_path = ^~/.ansible/retry-files
    echo.
    echo force_handlers = true
    echo nocows = true
    echo.
    echo roles_path = ./roles
    echo.
    echo ansible_managed = "Managed by ansible, don't make changes here!"
    echo.
    echo [ssh_connection]
    echo #pipelining = true
) > "%1"
echo %PROGNAME%: created '%1'
goto :eof
