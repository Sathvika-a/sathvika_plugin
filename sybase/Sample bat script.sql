@echo off
setlocal

rem Set your Sybase read role name here
set SYBASE_ROLE=your_sybase_read_role_name

rem Set your source and destination folder paths here
set SOURCE_FOLDER=C:\Source
set DESTINATION_FOLDER=C:\Destination

rem Check Sybase read role
rem Assuming you have a command to check the role, replace `check_sybase_role_command` with the actual command
check_sybase_role_command | find /i "%SYBASE_ROLE%" >nul
if errorlevel 1 (
    echo You don't have the required Sybase read role.
) else (
    echo You have the required Sybase read role.
    echo Moving folder...
    move "%SOURCE_FOLDER%" "%DESTINATION_FOLDER%"
    if errorlevel 1 (
        echo Failed to move folder.
    ) else (
        echo Folder moved successfully.
    )
)

endlocal
