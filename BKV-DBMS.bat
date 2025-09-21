:: =====================================================
:: File      : BKV-DBMS.bat
:: Author    : WaterRun
:: Description:
::   Bat-KV example program: Simple database manager
::   Demonstrates basic CRUD operations and practical usage scenarios
::   
::   Features:
::   1. Database management: Create, delete database files
::   2. Key-value operations: Add, query, delete key-value pairs
::   3. Data browsing: View all data and statistics
::   4. Configuration management: Save and restore application settings
:: =====================================================

@echo off
setlocal EnableDelayedExpansion

echo ================================
echo   Bat-KV Database Manager v1.0
echo ================================
echo.

REM Initialize application configuration database
call Bat-KV.bat :BKV.New "manager_config.bkv"

REM Check if this is the first run
call Bat-KV.bat :BKV.Include "first_run" "manager_config.bkv"
if "%BKV_STATUS%"=="OK" (
    if "%BKV_RESULT%"=="No" (
        echo Welcome to Bat-KV Database Manager!
        call Bat-KV.bat :BKV.Append "first_run" "false" "manager_config.bkv"
        call Bat-KV.bat :BKV.Append "install_time" "%date% %time%" "manager_config.bkv"
        call Bat-KV.bat :BKV.Append "default_database" "my_data.bkv" "manager_config.bkv"
        echo Initialization completed
        echo.
    )
)

REM Get default database name
call Bat-KV.bat :BKV.Fetch "default_database" "manager_config.bkv"
if "%BKV_STATUS%"=="OK" (
    if not "%BKV_RESULT%"=="" (
        set "current_db=%BKV_RESULT%"
    ) else (
        set "current_db=my_data.bkv"
    )
) else (
    set "current_db=my_data.bkv"
)

:MAIN_MENU
cls
echo ================================
echo   Bat-KV Database Manager v1.0
echo ================================
echo.
echo Current database: %current_db%

REM Check if current database exists
if exist "%current_db%" (
    echo Status: Connected
) else (
    echo Status: Database does not exist
)

echo.
echo 1. Database Operations
echo 2. Key-Value Management
echo 3. Data Browsing
echo 4. Application Settings
echo 0. Exit Program
echo.
set /p choice="Please select operation (0-4): "

if "%choice%"=="1" goto DATABASE_MENU
if "%choice%"=="2" goto KEYVALUE_MENU
if "%choice%"=="3" goto BROWSE_MENU
if "%choice%"=="4" goto SETTINGS_MENU
if "%choice%"=="0" goto EXIT
goto MAIN_MENU

:DATABASE_MENU
cls
echo ================================
echo       Database Operations
echo ================================
echo.
echo Current database: %current_db%
echo.
echo 1. Create New Database
echo 2. Switch Database
echo 3. Delete Database
echo 4. Database Information
echo 0. Return to Main Menu
echo.
set /p db_choice="Please select operation (0-4): "

if "%db_choice%"=="1" goto CREATE_DB
if "%db_choice%"=="2" goto SWITCH_DB
if "%db_choice%"=="3" goto DELETE_DB
if "%db_choice%"=="4" goto DB_INFO
if "%db_choice%"=="0" goto MAIN_MENU
goto DATABASE_MENU

:CREATE_DB
echo.
set /p new_db="Enter new database name (e.g. data.bkv): "
if "%new_db%"=="" (
    echo Database name cannot be empty!
    pause
    goto DATABASE_MENU
)

call Bat-KV.bat :BKV.New "%new_db%"
if "%BKV_STATUS%"=="OK" (
    echo Database %new_db% created successfully!
    set "current_db=%new_db%"
    
    REM Save as default database
    call Bat-KV.bat :BKV.Append "default_database" "%new_db%" "manager_config.bkv"
) else (
    echo Database creation failed: %BKV_ERR%
)
pause
goto DATABASE_MENU

:SWITCH_DB
echo.
set /p switch_db="Enter database name to switch to: "
if "%switch_db%"=="" (
    echo Database name cannot be empty!
    pause
    goto DATABASE_MENU
)

if exist "%switch_db%" (
    set "current_db=%switch_db%"
    call Bat-KV.bat :BKV.Append "default_database" "%switch_db%" "manager_config.bkv"
    echo Switched to database: %switch_db%
) else (
    echo Database file does not exist: %switch_db%
)
pause
goto DATABASE_MENU

:DELETE_DB
echo.
echo Warning: This operation will permanently delete the database file!
set /p delete_db="Enter database name to delete: "
if "%delete_db%"=="" (
    echo Database name cannot be empty!
    pause
    goto DATABASE_MENU
)

echo Confirm deletion of database: %delete_db%
set /p confirm="Type YES to confirm deletion: "
if "%confirm%"=="YES" (
    call Bat-KV.bat :BKV.Erase "%delete_db%"
    if "%BKV_STATUS%"=="OK" (
        echo Database %delete_db% has been deleted
        if "%delete_db%"=="%current_db%" (
            set "current_db=my_data.bkv"
            call Bat-KV.bat :BKV.Append "default_database" "my_data.bkv" "manager_config.bkv"
        )
    ) else (
        echo Deletion failed: %BKV_ERR%
    )
) else (
    echo Deletion operation cancelled
)
pause
goto DATABASE_MENU

:DB_INFO
echo.
echo Database Information:
echo File name: %current_db%
if exist "%current_db%" (
    echo Status: Exists
    
    REM Count key-value pairs
    set count=0
    for /f "usebackq delims=" %%i in ("%current_db%") do (
        set /a count+=1
    )
    echo Key-value pairs: !count!
    
    REM Display file size
    for %%i in ("%current_db%") do echo File size: %%~zi bytes
) else (
    echo Status: Does not exist
)
pause
goto DATABASE_MENU

:KEYVALUE_MENU
cls
echo ================================
echo       Key-Value Management
echo ================================
echo.
echo Current database: %current_db%
echo.
echo 1. Add Key-Value Pair
echo 2. Query Key Value
echo 3. Delete Key-Value Pair
echo 4. Check if Key Exists
echo 0. Return to Main Menu
echo.
set /p kv_choice="Please select operation (0-4): "

if "%kv_choice%"=="1" goto ADD_KV
if "%kv_choice%"=="2" goto QUERY_KV
if "%kv_choice%"=="3" goto DELETE_KV
if "%kv_choice%"=="4" goto CHECK_KV
if "%kv_choice%"=="0" goto MAIN_MENU
goto KEYVALUE_MENU

:ADD_KV
echo.
set /p key="Enter key name: "
if "%key%"=="" (
    echo Key name cannot be empty!
    pause
    goto KEYVALUE_MENU
)

set /p value="Enter value: "
if "%value%"=="" (
    echo Value cannot be empty!
    pause
    goto KEYVALUE_MENU
)

call Bat-KV.bat :BKV.Append "%key%" "%value%" "%current_db%"
if "%BKV_STATUS%"=="OK" (
    echo Key-value pair added successfully: %key% = %value%
) else (
    echo Addition failed: %BKV_ERR%
)
pause
goto KEYVALUE_MENU

:QUERY_KV
echo.
set /p query_key="Enter key name to query: "
if "%query_key%"=="" (
    echo Key name cannot be empty!
    pause
    goto KEYVALUE_MENU
)

call Bat-KV.bat :BKV.Fetch "%query_key%" "%current_db%"
if "%BKV_STATUS%"=="OK" (
    if not "%BKV_RESULT%"=="" (
        echo Query result: %query_key% = %BKV_RESULT%
    ) else (
        echo Key "%query_key%" does not exist
    )
) else (
    echo Query failed: %BKV_ERR%
)
pause
goto KEYVALUE_MENU

:DELETE_KV
echo.
set /p del_key="Enter key name to delete: "
if "%del_key%"=="" (
    echo Key name cannot be empty!
    pause
    goto KEYVALUE_MENU
)

call Bat-KV.bat :BKV.Remove "%del_key%" "%current_db%"
if "%BKV_STATUS%"=="OK" (
    echo Key "%del_key%" has been deleted
) else (
    echo Deletion failed: %BKV_ERR%
)
pause
goto KEYVALUE_MENU

:CHECK_KV
echo.
set /p check_key="Enter key name to check: "
if "%check_key%"=="" (
    echo Key name cannot be empty!
    pause
    goto KEYVALUE_MENU
)

call Bat-KV.bat :BKV.Include "%check_key%" "%current_db%"
if "%BKV_STATUS%"=="OK" (
    if "%BKV_RESULT%"=="Yes" (
        echo Key "%check_key%" exists
    ) else (
        echo Key "%check_key%" does not exist
    )
) else (
    echo Check failed: %BKV_ERR%
)
pause
goto KEYVALUE_MENU

:BROWSE_MENU
cls
echo ================================
echo         Data Browsing
echo ================================
echo.
echo Current database: %current_db%

if not exist "%current_db%" (
    echo Database file does not exist!
    pause
    goto MAIN_MENU
)

echo.
echo Database content:
echo --- Start ---
type "%current_db%"
echo --- End ---
echo.

REM Statistics
set count=0
for /f "usebackq delims=" %%i in ("%current_db%") do (
    set /a count+=1
)
echo Total: !count! key-value pairs

echo.
echo Press any key to return to main menu...
pause >nul
goto MAIN_MENU

:SETTINGS_MENU
cls
echo ================================
echo      Application Settings
echo ================================
echo.
echo 1. View Application Information
echo 2. Reset Application Configuration
echo 0. Return to Main Menu
echo.
set /p setting_choice="Please select operation (0-2): "

if "%setting_choice%"=="1" goto APP_INFO
if "%setting_choice%"=="2" goto RESET_CONFIG
if "%setting_choice%"=="0" goto MAIN_MENU
goto SETTINGS_MENU

:APP_INFO
echo.
echo Application Information:
echo Program name: Bat-KV Database Manager
echo Version: 1.0
echo.

call Bat-KV.bat :BKV.Fetch "install_time" "manager_config.bkv"
if "%BKV_STATUS%"=="OK" (
    if not "%BKV_RESULT%"=="" (
        echo Install time: %BKV_RESULT%
    )
)

call Bat-KV.bat :BKV.Fetch "default_database" "manager_config.bkv"
if "%BKV_STATUS%"=="OK" (
    echo Default database: %BKV_RESULT%
)

echo Configuration file: manager_config.bkv
pause
goto SETTINGS_MENU

:RESET_CONFIG
echo.
echo Warning: This operation will reset all application configuration!
set /p reset_confirm="Type RESET to confirm: "
if "%reset_confirm%"=="RESET" (
    call Bat-KV.bat :BKV.Erase "manager_config.bkv"
    if "%BKV_STATUS%"=="OK" (
        echo Configuration has been reset, program will restart...
        pause
        goto :EOF
    ) else (
        echo Reset failed: %BKV_ERR%
    )
) else (
    echo Reset operation cancelled
)
pause
goto SETTINGS_MENU

:EXIT
cls
echo Thank you for using Bat-KV Database Manager!
echo.

REM Display exit statistics
call Bat-KV.bat :BKV.Fetch "install_time" "manager_config.bkv"
if "%BKV_STATUS%"=="OK" (
    if not "%BKV_RESULT%"=="" (
        echo Install time: %BKV_RESULT%
    )
)

echo Current database: %current_db%
echo Goodbye!
pause
exit /b 0