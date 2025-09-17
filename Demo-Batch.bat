:: =====================================================
:: File      : Demo-Batch.bat
:: Author    : WaterRun
:: Description:
::   Bat-KV example program: A simple plain text reader with history functionality.
::   Supports setting software users and retrieving recent file loading time and other historical information
::   
::   Feature description:
::   1. User management: Set and display current username
::   2. File history: Record recently opened files and access times
::   3. Reading statistics: Count user's file reading frequency
::   4. Configuration management: Save user preference settings
:: =====================================================

@echo off
setlocal EnableDelayedExpansion

REM Import Bat-KV database functionality
call Bat-KV.bat

REM Initialize application database file
call BKV.New "reader_app.bkv"

:MAIN_MENU
cls
echo ================================
echo    Plain Text Reader v1.0
echo    Powered by Bat-KV Database
echo ================================
echo.

REM Display current user information
call BKV.Fetch "current_user" "reader_app.bkv"
if "%BKV.Fetch-Status%"=="OK" (
    if not "%BKV.Fetch-Result%"=="" (
        echo Current user: %BKV.Fetch-Result%
    ) else (
        echo Current user: Not set
    )
) else (
    echo Current user: Not set
)

echo.
echo 1. Set username
echo 2. Open file for reading
echo 3. View reading history
echo 4. View reading statistics
echo 5. Clear all data
echo 0. Exit program
echo.
set /p choice="Please select operation (0-5): "

if "%choice%"=="1" goto SET_USER
if "%choice%"=="2" goto READ_FILE
if "%choice%"=="3" goto VIEW_HISTORY
if "%choice%"=="4" goto VIEW_STATS
if "%choice%"=="5" goto CLEAR_DATA
if "%choice%"=="0" goto EXIT
goto MAIN_MENU

:SET_USER
cls
echo ================================
echo         Set Username
echo ================================
echo.
set /p username="Please enter username: "

REM Validate username is not empty
if "%username%"=="" (
    echo Username cannot be empty!
    pause
    goto MAIN_MENU
)

REM Save username to database
call BKV.Append "current_user" "%username%" "reader_app.bkv"
if "%BKV.Append-Status%"=="OK" (
    echo Username set successfully: %username%
    
    REM Record user setting time
    call BKV.Append "user_set_time" "%date% %time%" "reader_app.bkv"
) else (
    echo Failed to set username!
)
pause
goto MAIN_MENU

:READ_FILE
cls
echo ================================
echo         Open File for Reading
echo ================================
echo.
set /p filename="Please enter file path: "

REM Check if file exists
if not exist "%filename%" (
    echo File does not exist: %filename%
    pause
    goto MAIN_MENU
)

REM Display file content
echo.
echo --- File Content ---
type "%filename%"
echo.
echo --- End of File ---
echo.

REM Record file access history
call BKV.Append "last_file" "%filename%" "reader_app.bkv"
call BKV.Append "last_access_time" "%date% %time%" "reader_app.bkv"

REM Update access count for this file
call BKV.Fetch "count_%filename: =_%" "reader_app.bkv"
if "%BKV.Fetch-Status%"=="OK" (
    if "%BKV.Fetch-Result%"=="" (
        set file_count=1
    ) else (
        set /a file_count=%BKV.Fetch-Result%+1
    )
) else (
    set file_count=1
)
call BKV.Append "count_%filename: =_%" "%file_count%" "reader_app.bkv"

REM Update total reading count
call BKV.Fetch "total_reads" "reader_app.bkv"
if "%BKV.Fetch-Status%"=="OK" (
    if "%BKV.Fetch-Result%"=="" (
        set total_reads=1
    ) else (
        set /a total_reads=%BKV.Fetch-Result%+1
    )
) else (
    set total_reads=1
)
call BKV.Append "total_reads" "%total_reads%" "reader_app.bkv"

echo File has been read successfully, access record has been saved
pause
goto MAIN_MENU

:VIEW_HISTORY
cls
echo ================================
echo         Reading History
echo ================================
echo.

REM Display last accessed file
call BKV.Fetch "last_file" "reader_app.bkv"
if "%BKV.Fetch-Status%"=="OK" (
    if not "%BKV.Fetch-Result%"=="" (
        echo Last read file: %BKV.Fetch-Result%
        
        REM Display access time
        call BKV.Fetch "last_access_time" "reader_app.bkv"
        if not "%BKV.Fetch-Result%"=="" (
            echo Access time: %BKV.Fetch-Result%
        )
        
        REM Display access count for this file
        call BKV.Fetch "count_%BKV.Fetch-Result: =_%" "reader_app.bkv"
        if not "%BKV.Fetch-Result%"=="" (
            echo File access count: %BKV.Fetch-Result%
        )
    ) else (
        echo No reading history available
    )
) else (
    echo No reading history available
)

echo.
echo --- All Historical Records ---
REM Use regular expression to find all count records
call BKV.Grep "^count_" "reader_app.bkv"
if "%BKV.Grep-Status%"=="OK" (
    if not "%BKV.Grep-Result%"=="" (
        echo %BKV.Grep-Result%
    ) else (
        echo No detailed records available
    )
) else (
    echo Unable to retrieve historical records
)

pause
goto MAIN_MENU

:VIEW_STATS
cls
echo ================================
echo         Reading Statistics
echo ================================
echo.

REM Display current user
call BKV.Fetch "current_user" "reader_app.bkv"
if not "%BKV.Fetch-Result%"=="" (
    echo User: %BKV.Fetch-Result%
    
    REM Display user setting time
    call BKV.Fetch "user_set_time" "reader_app.bkv"
    if not "%BKV.Fetch-Result%"=="" (
        echo User set time: %BKV.Fetch-Result%
    )
)

REM Display total reading count
call BKV.Fetch "total_reads" "reader_app.bkv"
if "%BKV.Fetch-Status%"=="OK" (
    if not "%BKV.Fetch-Result%"=="" (
        echo Total reads: %BKV.Fetch-Result%
    ) else (
        echo Total reads: 0
    )
) else (
    echo Total reads: 0
)

REM Display last access information
call BKV.Fetch "last_access_time" "reader_app.bkv"
if not "%BKV.Fetch-Result%"=="" (
    echo Last access time: %BKV.Fetch-Result%
)

echo.
echo --- Detailed Statistics ---
REM Display all configuration information
call BKV.Grep "." "reader_app.bkv"
if "%BKV.Grep-Status%"=="OK" (
    echo All records in database:
    echo %BKV.Grep-Result%
)

pause
goto MAIN_MENU

:CLEAR_DATA
cls
echo ================================
echo         Clear All Data
echo ================================
echo.
echo Warning: This operation will delete all user data and reading records!
set /p confirm="Confirm deletion? (y/N): "

if /i "%confirm%"=="y" (
    call BKV.Erase "reader_app.bkv"
    if "%BKV.Erase-Status%"=="OK" (
        echo All data has been cleared
        
        REM Recreate empty database file
        call BKV.New "reader_app.bkv"
    ) else (
        echo Failed to clear data
    )
) else (
    echo Operation cancelled
)

pause
goto MAIN_MENU

:EXIT
cls
echo Thank you for using Plain Text Reader!
echo.

REM Display exit statistics
call BKV.Fetch "total_reads" "reader_app.bkv"
if not "%BKV.Fetch-Result%"=="" (
    echo Total files read in this session: %BKV.Fetch-Result%
)

echo Goodbye!
pause
exit /b 0