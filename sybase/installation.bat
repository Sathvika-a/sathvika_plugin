@echo off

set plugin_name="sybase"
set plugin_url="https://raw.githubusercontent.com/site24x7/plugins/suraj/"

set username="sa"
set password="site24x7"
set hostname="localhost"
set port="5000"

call:install_plugin

:install_plugin

echo "------------------------------ Starting Plugin Automation ------------------------------"
echo

set agent_path="C:\Program Files (x86)\Site24x7\WinAgent\monitoring\" 
set agent_temp_path=%agent_path%temp/
set agent_plugin_path=%agent_path%plugins/

REM checking the existance of Agent Temporary Directory

IF NOT EXIST "%agent_temp_path%"(
    echo "%agent_temp_path% directory does not exists."
    echo
    exit /b 0
)
REM Creating the Agent Plugin Temporary Directory
echo "    Creating Temporary Plugins Directory"

set plugins_temp_path=%agent_temp_path%plugins/
IF NOT EXIST "%plugins_temp_path%"(
    mkdir "%plugins_temp_path%"
    IF NOT EXIST "%plugins_temp_path%"(
        echo "$plugins_temp_path directory does not exists."
        echo
        exit /b 0
    )
)

echo "Temporary plugin path exist"

REM Downloading the files from GitHub
call :download_files %plugin_name% %plugin_url% %plugins_temp_path%
echo "    Downloaded Plugin Files"
echo 
    
echo "   Configuring sybase.sh"

for /f "delims=" %%a in ('where java') do set java_path=%%a

if defined java_path(
    echo "Java path available"
) else (
    echo "Java path not available"
    exit /b 0
)

where javac

if %errorlevel% equ 0 (
    echo Java compiler is available
) else (
    echo Java compiler does not available
    exit /b 0
)

set sybase_temp_path=%plugins_temp_path%sybase/sybase.sh

call :replace_string_in_file %sybase_temp_path% 'set HOST=""' 'set HOST="'%hostname%'"'
call :replace_string_in_file %sybase_temp_path% 'set PORT=""' 'set PORT="'%port%'"'
call :replace_string_in_file %sybase_temp_path% 'set USERNAME=""' 'set USERNAME="'%username%'"'
call :replace_string_in_file %sybase_temp_path% 'set PASSWORD=""' 'set PASSWORD="'%password%'"'
call :replace_string_in_file %sybase_temp_path% 'set JAVA_HOME="C:\Program Files\Java\jdk1.8.0_241\bin"' 'set JAVA_HOME="'%java_path%'"'
call :replace_string_in_file %sybase_temp_path% 'set PLUGIN_PATH=C:\Program Files (x86)\Site24x7\WinAgent\monitoring\temp\Plugins\sybase"' 'set PLUGIN_PATH=C:\Program Files (x86)\Site24x7\WinAgent\monitoring\Plugins\sybase"'

REM Setting Executable Permissions for the Plugin
echo "    Creating executable plugin file"

icacls %plugins_temp_path%\%plugin_name%\%plugin_name%.bat /inheritance:r
icacls %plugins_temp_path%\%plugin_name%\%plugin_name%.bat /grant:r "Everyone:(RX)"

if %errorlevel% equ 1 (
    echo Error in executable file of plugin
    exit /b 0
)

echo "    Created executable plugin file"
echo
    
REM Validating the plugin output
echo "Validating the plugin output"

%plugins_temp_path%%plugin_name%/%plugin_name%.bat

if %errorlevel% equ 1 (
    echo Error Occured when executing plugin file
    exit /b 0
) else (
    echo Plugin executed successfully
    call :replace_string_in_file %sybase_temp_path% 'set PLUGIN_PATH=C:\Program Files (x86)\Site24x7\WinAgent\monitoring\temp\Plugins\sybase"' 'set PLUGIN_PATH=C:\Program Files (x86)\Site24x7\WinAgent\monitoring\Plugins\sybase'
)

echo "Moving the plugin into the Site24x7 Agent directory"

move %plugins_temp_path%%plugin_name% %agent_plugin_path%%plugin_name%

if %errorlevel% equ 1 (
    echo Error Occured when moving plugin directory
    exit /b 0
) else (
    echo Plugin Automation completed successfully
    echo
)

:end


:replace_string_in_file

for /f "delims=" %%i in ('type "%1" ^& break ^> "%1" ') do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    >>"%1%" echo(!line:%2%=%3%!
    endlocal
)

:end

:download_files
set temp_plugin_path=%3%%1%

IF NOT EXIST "%temp_plugin_path%"(
    mkdir "%temp_plugin_path%"
    IF NOT EXIST "%temp_plugin_path%"(
        echo "%temp_plugin_path directory does not exists."
        echo
        exit /b 0
    )
)

set java_file_url=%2%%1%/%1%.java
set sh_file_url=%2%%1%/%1%.sh
set jar1_file_url=%2%%1%/jconn4.jar
set jar2_file_url=%2%%1%/json-20140107.jar

