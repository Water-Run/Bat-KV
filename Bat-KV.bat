@echo off
:: =====================================================
:: File      : Bat-KV.bat
:: Version   : 2.0
:: Author    : WaterRun
:: Description:
::   Bat-KV is an ultra-lightweight single-file KV database for Windows batch processing
::   Provides simple CRUD operations using plain text format for storage
::   File format: key + backslash padding (36 chars total) + value
::   Default file is _BATKV.bkv
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
:: File Format (v2.0):
::   Each line: [key][backslash padding to 36 chars][value]
::   Example: username\\\\\\\\\\\\\\\\\\\\\\\\\\\\Alice
::   Keys occupy exactly 36 characters (padded with backslashes)
::   Value starts at position 37, can be empty or contain any character
::
:: Breaking Change from v1.x:
::   File format changed - v1.x files are not compatible
::
:: Examples:
::   call Bat-KV.bat :BKV.New "mydb.bkv"
::   call Bat-KV.bat :BKV.Append "username" "alice" "mydb.bkv"
::   call Bat-KV.bat :BKV.Fetch "username" "mydb.bkv"
::   echo Result: %BKV_RESULT%
::
:: Notes:
::   - All operations are atomic using temporary files
::   - Default database file is _BATKV.bkv in current directory
::   - File paths can be relative or absolute
::   - Supports ANSI characters in values (including backslashes)
::   - Empty values are supported
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
echo Bat-KV v2.0 - Ultra-lightweight KV database for Windows Batch
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
echo.
echo File Format: [key padded to 36 chars with backslashes][value]
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
:: Private: Pad key to 36 characters with backslashes
:: Parameters: %1 - key to pad
:: Returns: BKV.Inner.PaddedKey - padded key (36 chars)
:: =====================================================
:BKV.Private.PadKey
setlocal EnableDelayedExpansion
set "BKV.Inner.TempKey=%~1"
set "BKV.Inner.Padding=\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"

:: Calculate key length
set "BKV.Inner.KeyLen=0"
set "BKV.Inner.TempCalc=%BKV.Inner.TempKey%"
:BKV.Private.PadKey.CountLoop
if defined BKV.Inner.TempCalc (
    set "BKV.Inner.TempCalc=!BKV.Inner.TempCalc:~1!"
    set /a "BKV.Inner.KeyLen+=1"
    goto :BKV.Private.PadKey.CountLoop
)

:: Calculate padding needed (36 - key length)
set /a "BKV.Inner.PadLen=36-!BKV.Inner.KeyLen!"
set "BKV.Inner.ResultKey=%BKV.Inner.TempKey%!BKV.Inner.Padding:~0,%BKV.Inner.PadLen%!"

endlocal & set "BKV.Inner.PaddedKey=%BKV.Inner.ResultKey%"
exit /b

:: =====================================================
:: Private: Extract key from padded line (remove trailing backslashes)
:: Parameters: %1 - first 36 characters of line
:: Returns: BKV.Inner.ExtractedKey - actual key without padding
:: =====================================================
:BKV.Private.ExtractKey
setlocal EnableDelayedExpansion
set "BKV.Inner.TempPadded=%~1"
set "BKV.Inner.ExtractResult="

:: Remove trailing backslashes
:BKV.Private.ExtractKey.Loop
if defined BKV.Inner.TempPadded (
    if "!BKV.Inner.TempPadded:~-1!"=="\" (
        set "BKV.Inner.TempPadded=!BKV.Inner.TempPadded:~0,-1!"
        goto :BKV.Private.ExtractKey.Loop
    )
)
set "BKV.Inner.ExtractResult=!BKV.Inner.TempPadded!"

endlocal & set "BKV.Inner.ExtractedKey=%BKV.Inner.ExtractResult%"
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
:: Parameters: %2 - Key, %3 - Value (can be empty), %4 - File path (optional)
:: =====================================================
:BKV.Append
setlocal EnableDelayedExpansion
set "BKV.Inner.Key=%~2"
set "BKV.Inner.Value=%~3"
call :BKV.Private.ValidateFile "%~4"

:: Validate key format and length
call :BKV.Private.ValidateKey "%BKV.Inner.Key%"
if errorlevel 1 (
    for /f "tokens=1,2,3,4,5,6,7,8,9,10 delims=" %%a in ("!BKV_STATUS!") do endlocal & set "BKV_STATUS=%%a"
    exit /b
)

:: Create file if it doesn't exist
if not exist "%BKV.Inner.FilePath%" type nul > "%BKV.Inner.FilePath%"

:: Pad key to 36 characters
call :BKV.Private.PadKey "%BKV.Inner.Key%"

:: Atomic update using temporary file
set "BKV.Inner.TempFile=%BKV.Inner.FilePath%.tmp"
type nul > "%BKV.Inner.TempFile%" 2>nul
if errorlevel 1 (
    endlocal
    set "BKV_STATUS=NotOK"
    set "BKV_ERR=Bat-KV ERR: Failed to create temporary file"
    set "BKV_RESULT="
    exit /b
)

:: Copy all lines except the key being updated
for /f "usebackq delims=" %%i in ("%BKV.Inner.FilePath%") do (
    set "BKV.Inner.Line=%%i"
    set "BKV.Inner.LineKey=!BKV.Inner.Line:~0,36!"
    call :BKV.Private.ExtractKey "!BKV.Inner.LineKey!"
    if not "!BKV.Inner.ExtractedKey!"=="!BKV.Inner.Key!" (
        echo !BKV.Inner.Line!>> "%BKV.Inner.TempFile%"
    )
)

:: Append new key-value pair (padded key + value)
echo !BKV.Inner.PaddedKey!!BKV.Inner.Value!>> "%BKV.Inner.TempFile%"

:: Atomic replace
move "%BKV.Inner.TempFile%" "%BKV.Inner.FilePath%" >nul 2>nul
if errorlevel 1 (
    del "%BKV.Inner.TempFile%" 2>nul
    endlocal
    set "BKV_STATUS=NotOK"
    set "BKV_ERR=Bat-KV ERR: Failed to update database file"
    set "BKV_RESULT="
    exit /b
)

endlocal
call :BKV.Private.SetSuccess
exit /b

:: =====================================================
:: Function: BKV.Remove
:: Description: Remove a key-value pair from database
:: Parameters: %2 - Key, %3 - File path (optional)
:: =====================================================
:BKV.Remove
setlocal EnableDelayedExpansion
set "BKV.Inner.Key=%~2"
call :BKV.Private.ValidateFile "%~3"

:: Validate key format and length
call :BKV.Private.ValidateKey "%BKV.Inner.Key%"
if errorlevel 1 (
    for /f "tokens=1,2,3,4,5,6,7,8,9,10 delims=" %%a in ("!BKV_STATUS!") do endlocal & set "BKV_STATUS=%%a"
    exit /b
)

:: Success if file doesn't exist
if not exist "%BKV.Inner.FilePath%" (
    endlocal
    call :BKV.Private.SetSuccess
    exit /b
)

:: Atomic removal using temporary file
set "BKV.Inner.TempFile=%BKV.Inner.FilePath%.tmp"
type nul > "%BKV.Inner.TempFile%" 2>nul
if errorlevel 1 (
    endlocal
    set "BKV_STATUS=NotOK"
    set "BKV_ERR=Bat-KV ERR: Failed to create temporary file"
    set "BKV_RESULT="
    exit /b
)

:: Copy all lines except the key being removed
for /f "usebackq delims=" %%i in ("%BKV.Inner.FilePath%") do (
    set "BKV.Inner.Line=%%i"
    set "BKV.Inner.LineKey=!BKV.Inner.Line:~0,36!"
    call :BKV.Private.ExtractKey "!BKV.Inner.LineKey!"
    if not "!BKV.Inner.ExtractedKey!"=="!BKV.Inner.Key!" (
        echo !BKV.Inner.Line!>> "%BKV.Inner.TempFile%"
    )
)

:: Atomic replace
move "%BKV.Inner.TempFile%" "%BKV.Inner.FilePath%" >nul 2>nul
if errorlevel 1 (
    del "%BKV.Inner.TempFile%" 2>nul
    endlocal
    set "BKV_STATUS=NotOK"
    set "BKV_ERR=Bat-KV ERR: Failed to update database file"
    set "BKV_RESULT="
    exit /b
)

endlocal
call :BKV.Private.SetSuccess
exit /b

:: =====================================================
:: Function: BKV.Fetch
:: Description: Retrieve value for a given key
:: Parameters: %2 - Key, %3 - File path (optional)
:: =====================================================
:BKV.Fetch
setlocal EnableDelayedExpansion
set "BKV.Inner.Key=%~2"
call :BKV.Private.ValidateFile "%~3"
set "BKV.Inner.ResultValue="

:: Validate key format and length
call :BKV.Private.ValidateKey "%BKV.Inner.Key%"
if errorlevel 1 (
    for /f "tokens=1,2,3,4,5,6,7,8,9,10 delims=" %%a in ("!BKV_STATUS!") do endlocal & set "BKV_STATUS=%%a"
    exit /b
)

:: Return empty result if file doesn't exist
if not exist "%BKV.Inner.FilePath%" (
    endlocal
    set "BKV_RESULT="
    call :BKV.Private.SetSuccess
    exit /b
)

:: Search for key and extract value
for /f "usebackq delims=" %%i in ("%BKV.Inner.FilePath%") do (
    set "BKV.Inner.Line=%%i"
    set "BKV.Inner.LineKey=!BKV.Inner.Line:~0,36!"
    call :BKV.Private.ExtractKey "!BKV.Inner.LineKey!"
    if "!BKV.Inner.ExtractedKey!"=="!BKV.Inner.Key!" (
        set "BKV.Inner.ResultValue=!BKV.Inner.Line:~36!"
        goto :BKV.Fetch.Found
    )
)

:: Key not found
endlocal
set "BKV_RESULT="
call :BKV.Private.SetSuccess
exit /b

:BKV.Fetch.Found
endlocal & set "BKV_RESULT=%BKV.Inner.ResultValue%"
call :BKV.Private.SetSuccess
exit /b

:: =====================================================
:: Function: BKV.Include
:: Description: Check if a key exists in the database
:: Parameters: %2 - Key, %3 - File path (optional)
:: =====================================================
:BKV.Include
setlocal EnableDelayedExpansion
set "BKV.Inner.Key=%~2"
call :BKV.Private.ValidateFile "%~3"

:: Validate key format and length
call :BKV.Private.ValidateKey "%BKV.Inner.Key%"
if errorlevel 1 (
    for /f "tokens=1,2,3,4,5,6,7,8,9,10 delims=" %%a in ("!BKV_STATUS!") do endlocal & set "BKV_STATUS=%%a"
    exit /b
)

:: Return No if file doesn't exist
if not exist "%BKV.Inner.FilePath%" (
    endlocal
    set "BKV_RESULT=No"
    call :BKV.Private.SetSuccess
    exit /b
)

:: Search for key existence
for /f "usebackq delims=" %%i in ("%BKV.Inner.FilePath%") do (
    set "BKV.Inner.Line=%%i"
    set "BKV.Inner.LineKey=!BKV.Inner.Line:~0,36!"
    call :BKV.Private.ExtractKey "!BKV.Inner.LineKey!"
    if "!BKV.Inner.ExtractedKey!"=="!BKV.Inner.Key!" (
        endlocal
        set "BKV_RESULT=Yes"
        call :BKV.Private.SetSuccess
        exit /b
    )
)

endlocal
set "BKV_RESULT=No"
call :BKV.Private.SetSuccess
exit /b