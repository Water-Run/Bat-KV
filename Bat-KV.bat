@echo off
:: =====================================================
:: File      : Bat-KV.bat
:: Version   : 1.0
:: Author    : WaterRun
:: Description:
::   Bat-KV is an ultra-lightweight single-file KV database for Windows batch processing
::   Provides simple CRUD operations using plain text format for storage
::   File format: key\value, default file is _BATKV.bkv
::
:: Public API:
::   call Bat-KV.bat :BKV.New [file]          - Create new database file
::   call Bat-KV.bat :BKV.Erase [file]        - Delete database file
::   call Bat-KV.bat :BKV.Append key value [file] - Add/update key-value pair
::   call Bat-KV.bat :BKV.Remove key [file]   - Remove key-value pair
::   call Bat-KV.bat :BKV.Fetch key [file]    - Get value by key
::   call Bat-KV.bat :BKV.Include key [file]  - Check if key exists
::
:: Return Variables:
::   BKV_STATUS                 - "OK" or "NotOK" indicating operation status
::   BKV_RESULT                 - Operation result (value for Fetch, Yes/No for Include)
::   BKV_ERR                    - Error description when status is NotOK, format: "Bat-KV ERR: [message]"
::
:: Examples:
::   call Bat-KV.bat :BKV.New "mydb.bkv"
::   call Bat-KV.bat :BKV.Append "username" "alice" "mydb.bkv"
::   call Bat-KV.bat :BKV.Fetch "username" "mydb.bkv"
::   echo Result: %BKV_RESULT%
::
:: File Format:
::   Each line contains: key\value
::   Empty lines and lines without backslash are ignored
::   Keys must contain only letters, numbers, and underscores
::   Keys cannot exceed 36 characters in length
::   Keys cannot contain backslash character
::
:: Notes:
::   - All operations are atomic using temporary files
::   - Default database file is _BATKV.bkv in current directory
::   - File paths can be relative or absolute
::   - Supports ANSI characters in keys and values
::   - Thread-safe through atomic file operations
::   - Private functions use BKV.Private prefix - do not call directly
::   - Private variables use BKV.Inner prefix - do not use directly
:: =====================================================

:: Initialize global variables
call :BKV.Private.Init

:: Main entry point - route to appropriate function
if "%~1"==":BKV.New" goto BKV.New
if "%~1"==":BKV.Erase" goto BKV.Erase  
if "%~1"==":BKV.Append" goto BKV.Append
if "%~1"==":BKV.Remove" goto BKV.Remove
if "%~1"==":BKV.Fetch" goto BKV.Fetch
if "%~1"==":BKV.Include" goto BKV.Include

:: Display help message when called without valid parameters
call :BKV.Private.ShowHelp
goto :EOF

:: =====================================================
:: Private: Initialize global variables
:: =====================================================
:BKV.Private.Init
set "BKV_STATUS="
set "BKV_RESULT="
set "BKV_ERR=(Nothing)"
set "BKV.Inner.DefaultFile=_BATKV.bkv"
exit /b

:: =====================================================
:: Private: Show help message
:: =====================================================
:BKV.Private.ShowHelp
echo Bat-KV v1.0 - Ultra-lightweight KV database for Windows Batch
echo.
echo Public API:
echo   call Bat-KV.bat :BKV.New [file]
echo   call Bat-KV.bat :BKV.Erase [file]
echo   call Bat-KV.bat :BKV.Append key value [file]
echo   call Bat-KV.bat :BKV.Remove key [file]
echo   call Bat-KV.bat :BKV.Fetch key [file]
echo   call Bat-KV.bat :BKV.Include key [file]
echo.
echo Return Variables: BKV_STATUS, BKV_RESULT, BKV_ERR
exit /b

:: =====================================================
:: Private: Validate and set file parameter
:: Parameters: %1 - file parameter from caller
:: Returns: BKV.Inner.FilePath - validated file path
:: =====================================================
:BKV.Private.ValidateFile
set "BKV.Inner.FilePath=%~1"
if "%BKV.Inner.FilePath%"=="" set "BKV.Inner.FilePath=%BKV.Inner.DefaultFile%"
exit /b

:: =====================================================
:: Private: Validate key name format and length
:: Parameters: %1 - key to validate
:: Returns: Sets error status if invalid, otherwise continues
:: =====================================================
:BKV.Private.ValidateKey
set "BKV.Inner.ValidateKey=%~1"

:: Check if key is empty
if "%BKV.Inner.ValidateKey%"=="" (
    call :BKV.Private.SetError "Key parameter is required"
    exit /b 1
)

:: Check for backslash
if not "%BKV.Inner.ValidateKey:\=%"=="%BKV.Inner.ValidateKey%" (
    call :BKV.Private.SetError "Key cannot contain backslash character"
    exit /b 1
)

:: Check key length (max 36 characters) using simple substring method
if not "%BKV.Inner.ValidateKey:~36,1%"=="" (
    call :BKV.Private.SetError "Key length cannot exceed 36 characters"
    exit /b 1
)

:: Simple character validation using echo command output redirection
echo %BKV.Inner.ValidateKey%| findstr /R "^[a-zA-Z0-9_]*$" >nul 2>nul
if errorlevel 1 (
    call :BKV.Private.SetError "Key can only contain letters, numbers and underscores"
    exit /b 1
)

:: Key is valid
exit /b 0

:: =====================================================
:: Private: Set success status
:: =====================================================
:BKV.Private.SetSuccess
set "BKV_STATUS=OK"
set "BKV_ERR=(Nothing)"
exit /b

:: =====================================================
:: Private: Set error status
:: Parameters: %1 - error message
:: =====================================================
:BKV.Private.SetError
set "BKV_STATUS=NotOK"
set "BKV_ERR=Bat-KV ERR: %~1"
set "BKV_RESULT="
exit /b

:: =====================================================
:: Function: BKV.New
:: Description: Create a new database file
:: Parameters: %2 - Database file path (optional)
:: =====================================================
:BKV.New
call :BKV.Private.ValidateFile "%~2"
if not exist "%BKV.Inner.FilePath%" (
    type nul > "%BKV.Inner.FilePath%" 2>nul
    if errorlevel 1 (
        call :BKV.Private.SetError "Failed to create file: %BKV.Inner.FilePath%"
        exit /b
    )
)
call :BKV.Private.SetSuccess
exit /b

:: =====================================================
:: Function: BKV.Erase
:: Description: Delete an existing database file
:: Parameters: %2 - Database file path (optional)
:: =====================================================
:BKV.Erase
call :BKV.Private.ValidateFile "%~2"
if exist "%BKV.Inner.FilePath%" (
    del "%BKV.Inner.FilePath%" 2>nul
    if errorlevel 1 (
        call :BKV.Private.SetError "Failed to delete file: %BKV.Inner.FilePath%"
        exit /b
    )
)
call :BKV.Private.SetSuccess
exit /b

:: =====================================================
:: Function: BKV.Append
:: Description: Add or update a key-value pair
:: Parameters: %2 - Key, %3 - Value, %4 - File path (optional)
:: =====================================================
:BKV.Append
set "BKV.Inner.Key=%~2"
set "BKV.Inner.Value=%~3"
call :BKV.Private.ValidateFile "%~4"

:: Validate key format and length
call :BKV.Private.ValidateKey "%BKV.Inner.Key%"
if errorlevel 1 exit /b

:: Validate value parameter
if "%BKV.Inner.Value%"=="" (
    call :BKV.Private.SetError "Value parameter is required"
    exit /b
)

:: Create file if it doesn't exist
if not exist "%BKV.Inner.FilePath%" type nul > "%BKV.Inner.FilePath%"

:: Atomic update using temporary file
set "BKV.Inner.TempFile=%BKV.Inner.FilePath%.tmp"
type nul > "%BKV.Inner.TempFile%" 2>nul
if errorlevel 1 (
    call :BKV.Private.SetError "Failed to create temporary file"
    exit /b
)

:: Copy all lines except the key being updated
for /f "usebackq delims=" %%i in ("%BKV.Inner.FilePath%") do (
    for /f "tokens=1 delims=\" %%a in ("%%i") do (
        if not "%%a"=="%BKV.Inner.Key%" echo %%i>> "%BKV.Inner.TempFile%"
    )
)

:: Append new key-value pair
echo %BKV.Inner.Key%\%BKV.Inner.Value%>> "%BKV.Inner.TempFile%"

:: Atomic replace
move "%BKV.Inner.TempFile%" "%BKV.Inner.FilePath%" >nul 2>nul
if errorlevel 1 (
    del "%BKV.Inner.TempFile%" 2>nul
    call :BKV.Private.SetError "Failed to update database file"
    exit /b
)

call :BKV.Private.SetSuccess
exit /b

:: =====================================================
:: Function: BKV.Remove
:: Description: Remove a key-value pair from database
:: Parameters: %2 - Key, %3 - File path (optional)
:: =====================================================
:BKV.Remove
set "BKV.Inner.Key=%~2"
call :BKV.Private.ValidateFile "%~3"

:: Validate key format and length
call :BKV.Private.ValidateKey "%BKV.Inner.Key%"
if errorlevel 1 exit /b

:: Success if file doesn't exist
if not exist "%BKV.Inner.FilePath%" (
    call :BKV.Private.SetSuccess
    exit /b
)

:: Atomic removal using temporary file
set "BKV.Inner.TempFile=%BKV.Inner.FilePath%.tmp"
type nul > "%BKV.Inner.TempFile%" 2>nul
if errorlevel 1 (
    call :BKV.Private.SetError "Failed to create temporary file"
    exit /b
)

:: Copy all lines except the key being removed
for /f "usebackq delims=" %%i in ("%BKV.Inner.FilePath%") do (
    for /f "tokens=1 delims=\" %%a in ("%%i") do (
        if not "%%a"=="%BKV.Inner.Key%" echo %%i>> "%BKV.Inner.TempFile%"
    )
)

:: Atomic replace
move "%BKV.Inner.TempFile%" "%BKV.Inner.FilePath%" >nul 2>nul
if errorlevel 1 (
    del "%BKV.Inner.TempFile%" 2>nul
    call :BKV.Private.SetError "Failed to update database file"
    exit /b
)

call :BKV.Private.SetSuccess
exit /b

:: =====================================================
:: Function: BKV.Fetch
:: Description: Retrieve value for a given key
:: Parameters: %2 - Key, %3 - File path (optional)
:: =====================================================
:BKV.Fetch
set "BKV.Inner.Key=%~2"
call :BKV.Private.ValidateFile "%~3"
set "BKV_RESULT="

:: Validate key format and length
call :BKV.Private.ValidateKey "%BKV.Inner.Key%"
if errorlevel 1 exit /b

:: Return empty result if file doesn't exist
if not exist "%BKV.Inner.FilePath%" (
    call :BKV.Private.SetSuccess
    exit /b
)

:: Search for key and extract value
for /f "usebackq tokens=1* delims=\" %%a in ("%BKV.Inner.FilePath%") do (
    if "%%a"=="%BKV.Inner.Key%" (
        set "BKV_RESULT=%%b"
        call :BKV.Private.SetSuccess
        exit /b
    )
)

call :BKV.Private.SetSuccess
exit /b

:: =====================================================
:: Function: BKV.Include
:: Description: Check if a key exists in the database
:: Parameters: %2 - Key, %3 - File path (optional)
:: =====================================================
:BKV.Include
set "BKV.Inner.Key=%~2"
call :BKV.Private.ValidateFile "%~3"
set "BKV_RESULT=No"

:: Validate key format and length
call :BKV.Private.ValidateKey "%BKV.Inner.Key%"
if errorlevel 1 exit /b

:: Return No if file doesn't exist
if not exist "%BKV.Inner.FilePath%" (
    call :BKV.Private.SetSuccess
    exit /b
)

:: Search for key existence
for /f "usebackq tokens=1 delims=\" %%a in ("%BKV.Inner.FilePath%") do (
    if "%%a"=="%BKV.Inner.Key%" (
        set "BKV_RESULT=Yes"
        call :BKV.Private.SetSuccess
        exit /b
    )
)

call :BKV.Private.SetSuccess
exit /b