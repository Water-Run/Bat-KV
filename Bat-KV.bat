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
:: Key naming conventions:
::   - Only supports English letters, numbers, and underscores
::   - Length should not exceed 36 characters
::   - Compatible with ANSI character set
::
:: API function list:
::   - BKV.New      : Create a new .bkv file
::   - BKV.Erase    : Delete .bkv file
::   - BKV.Append   : Add or update key-value pairs
::   - BKV.Remove   : Delete specified key-value pairs
::   - BKV.Fetch    : Read value corresponding to key
::   - BKV.Include  : Check if key exists
::   - BKV.Grep     : Match keys using regular expressions
::
:: Internal function list:
::   - BKV.Private.GetVersion     : Get version information
::   - BKV.Private.ValidateKey    : Validate if key name conforms to specifications
::   - BKV.Private.ValidateFilename : Validate if filename is legal
::   - BKV.Private.ExtractKey     : Extract key name from line
::   - BKV.Private.ExtractValue   : Extract value from line
::   - BKV.Private.UpdateKeyValue : Update existing key-value pairs
::   - BKV.Private.GetStringLength : Get string length
:: =====================================================

setlocal EnableDelayedExpansion

:: =====================================================
:: Internal variable initialization
:: =====================================================
set "BKV.Inner.Version=1.0"
set "BKV.Inner.DefaultFile=_BATKV.bkv"
set "BKV.Inner.MaxKeyLength=36"
set "BKV.Inner.DefaultStatus=NA"
set "BKV.Inner.DefaultResult=(Default)"

:: Initialize public return value variables
set "BKV.New-Status=%BKV.Inner.DefaultStatus%"
set "BKV.Erase-Status=%BKV.Inner.DefaultStatus%"
set "BKV.Append-Status=%BKV.Inner.DefaultStatus%"
set "BKV.Remove-Status=%BKV.Inner.DefaultStatus%"
set "BKV.Fetch-Status=%BKV.Inner.DefaultStatus%"
set "BKV.Fetch-Result=%BKV.Inner.DefaultResult%"
set "BKV.Include-Status=%BKV.Inner.DefaultStatus%"
set "BKV.Include-Result=%BKV.Inner.DefaultResult%"
set "BKV.Grep-Status=%BKV.Inner.DefaultStatus%"
set "BKV.Grep-Result=%BKV.Inner.DefaultResult%"

goto :EOF

:: =====================================================
:: Function Name: BKV.Private.GetVersion
:: Description : Get version information of Bat-KV database
:: Parameters  : None
:: Return Values:
::   BKV.GetVersion-Status: OK for success, NotOK for failure
::   BKV.GetVersion-Result: Version number string
:: Internal Variables:
::   BKV.Inner.TempStatus - Temporary status variable
:: Usage Example:
::   call BKV.Private.GetVersion
::   echo Current version: %BKV.GetVersion-Result%
:: =====================================================
:BKV.Private.GetVersion
:: Reset return values
set "BKV.GetVersion-Status=NotOK"
set "BKV.GetVersion-Result=%BKV.Inner.DefaultResult%"

:: Set internal temporary variable
set "BKV.Inner.TempStatus=OK"

:: Return version information
if "%BKV.Inner.TempStatus%"=="OK" (
    set "BKV.GetVersion-Result=%BKV.Inner.Version%"
    set "BKV.GetVersion-Status=OK"
)

:: Clean up internal variables
set "BKV.Inner.TempStatus="
goto :EOF

:: =====================================================
:: Function Name: BKV.New
:: Description : Create a new .bkv database file
:: Parameters  :
::   %1 - File_Name (optional): Filename, defaults to _BATKV.bkv
:: Return Values:
::   BKV.New-Status: OK for success, NotOK for failure
:: Internal Variables:
::   BKV.Inner.TargetFile - Target filename
::   BKV.Inner.ValidationResult - Filename validation result
:: Usage Example:
::   call BKV.New
::   call BKV.New "config.bkv"
:: =====================================================
:BKV.New
:: Reset return values to default state
set "BKV.New-Status=%BKV.Inner.DefaultStatus%"

:: Set internal variables
set "BKV.Inner.TargetFile=%~1"
set "BKV.Inner.ValidationResult="

:: Set default filename
if "%BKV.Inner.TargetFile%"=="" set "BKV.Inner.TargetFile=%BKV.Inner.DefaultFile%"

:: Validate filename
call :BKV.Private.ValidateFilename "%BKV.Inner.TargetFile%"
if "%BKV.Inner.ValidationResult%"=="No" (
    set "BKV.New-Status=NotOK"
    goto :BKV.New.End
)

:: Create empty file if it doesn't exist
if not exist "%BKV.Inner.TargetFile%" (
    echo. 2>nul > "%BKV.Inner.TargetFile%"
    if exist "%BKV.Inner.TargetFile%" (
        set "BKV.New-Status=OK"
    ) else (
        set "BKV.New-Status=NotOK"
    )
) else (
    :: File already exists, consider creation successful
    set "BKV.New-Status=OK"
)

:BKV.New.End
:: Clean up internal variables
set "BKV.Inner.TargetFile="
set "BKV.Inner.ValidationResult="
goto :EOF

:: =====================================================
:: Function Name: BKV.Erase
:: Description : Delete .bkv database file and all its data
:: Parameters  :
::   %1 - File_Name (optional): Filename, defaults to _BATKV.bkv
:: Return Values:
::   BKV.Erase-Status: OK for success, NotOK for failure
:: Internal Variables:
::   BKV.Inner.TargetFile - Target filename
::   BKV.Inner.ValidationResult - Filename validation result
:: Usage Example:
::   call BKV.Erase
::   call BKV.Erase "temp.bkv"
:: =====================================================
:BKV.Erase
:: Reset return values to default state
set "BKV.Erase-Status=%BKV.Inner.DefaultStatus%"

:: Set internal variables
set "BKV.Inner.TargetFile=%~1"
set "BKV.Inner.ValidationResult="

:: Set default filename
if "%BKV.Inner.TargetFile%"=="" set "BKV.Inner.TargetFile=%BKV.Inner.DefaultFile%"

:: Validate filename
call :BKV.Private.ValidateFilename "%BKV.Inner.TargetFile%"
if "%BKV.Inner.ValidationResult%"=="No" (
    set "BKV.Erase-Status=NotOK"
    goto :BKV.Erase.End
)

:: Delete file
if exist "%BKV.Inner.TargetFile%" (
    del "%BKV.Inner.TargetFile%" 2>nul
    if not exist "%BKV.Inner.TargetFile%" (
        set "BKV.Erase-Status=OK"
    ) else (
        set "BKV.Erase-Status=NotOK"
    )
) else (
    :: File doesn't exist, consider deletion successful
    set "BKV.Erase-Status=OK"
)

:BKV.Erase.End
:: Clean up internal variables
set "BKV.Inner.TargetFile="
set "BKV.Inner.ValidationResult="
goto :EOF

:: =====================================================
:: Function Name: BKV.Append
:: Description : Add new key-value pairs or update existing key-value pairs
:: Parameters  :
::   %1 - Key: Key name (must conform to naming conventions)
::   %2 - Value: Corresponding value
::   %3 - File_Name (optional): Filename, defaults to _BATKV.bkv
:: Return Values:
::   BKV.Append-Status: OK for success, NotOK for failure
:: Internal Variables:
::   BKV.Inner.TargetKey - Target key name
::   BKV.Inner.TargetValue - Target value
::   BKV.Inner.TargetFile - Target filename
::   BKV.Inner.KeyValidationResult - Key name validation result
::   BKV.Inner.FileValidationResult - Filename validation result
:: Usage Example:
::   call BKV.Append "username" "Alice"
::   call BKV.Append "max_retry" "3" "config.bkv"
:: =====================================================
:BKV.Append
:: Reset return values to default state
set "BKV.Append-Status=%BKV.Inner.DefaultStatus%"

:: Set internal variables
set "BKV.Inner.TargetKey=%~1"
set "BKV.Inner.TargetValue=%~2"
set "BKV.Inner.TargetFile=%~3"
set "BKV.Inner.KeyValidationResult="
set "BKV.Inner.FileValidationResult="

:: Validate required parameters
if "%BKV.Inner.TargetKey%"=="" (
    set "BKV.Append-Status=NotOK"
    goto :BKV.Append.End
)
if "%BKV.Inner.TargetValue%"=="" (
    set "BKV.Append-Status=NotOK"
    goto :BKV.Append.End
)

:: Set default filename
if "%BKV.Inner.TargetFile%"=="" set "BKV.Inner.TargetFile=%BKV.Inner.DefaultFile%"

:: Validate key name
call :BKV.Private.ValidateKey "%BKV.Inner.TargetKey%"
if "%BKV.Inner.KeyValidationResult%"=="No" (
    set "BKV.Append-Status=NotOK"
    goto :BKV.Append.End
)

:: Validate filename
call :BKV.Private.ValidateFilename "%BKV.Inner.TargetFile%"
if "%BKV.Inner.FileValidationResult%"=="No" (
    set "BKV.Append-Status=NotOK"
    goto :BKV.Append.End
)

:: Ensure file exists
if not exist "%BKV.Inner.TargetFile%" (
    echo. 2>nul > "%BKV.Inner.TargetFile%"
)

:: Check if key already exists
call BKV.Include "%BKV.Inner.TargetKey%" "%BKV.Inner.TargetFile%"
if "%BKV.Include-Result%"=="Yes" (
    :: Update existing key-value pair
    call :BKV.Private.UpdateKeyValue "%BKV.Inner.TargetKey%" "%BKV.Inner.TargetValue%" "%BKV.Inner.TargetFile%"
) else (
    :: Add new key-value pair
    echo %BKV.Inner.TargetKey%\%BKV.Inner.TargetValue% >> "%BKV.Inner.TargetFile%"
    set "BKV.Append-Status=OK"
)

:BKV.Append.End
:: Clean up internal variables
set "BKV.Inner.TargetKey="
set "BKV.Inner.TargetValue="
set "BKV.Inner.TargetFile="
set "BKV.Inner.KeyValidationResult="
set "BKV.Inner.FileValidationResult="
goto :EOF

:: =====================================================
:: Function Name: BKV.Remove
:: Description : Delete specified key-value pairs
:: Parameters  :
::   %1 - Key: Key name to delete
::   %2 - File_Name (optional): Filename, defaults to _BATKV.bkv
:: Return Values:
::   BKV.Remove-Status: OK for success, NotOK for failure
:: Internal Variables:
::   BKV.Inner.TargetKey - Target key name
::   BKV.Inner.TargetFile - Target filename
::   BKV.Inner.TempFile - Temporary filename
::   BKV.Inner.CurrentLine - Current line being processed
::   BKV.Inner.ExtractedKey - Key name extracted from line
::   BKV.Inner.KeyValidationResult - Key name validation result
::   BKV.Inner.FileValidationResult - Filename validation result
:: Usage Example:
::   call BKV.Remove "temp_setting"
::   call BKV.Remove "session_id" "cache.bkv"
:: =====================================================
:BKV.Remove
:: Reset return values to default state
set "BKV.Remove-Status=%BKV.Inner.DefaultStatus%"

:: Set internal variables
set "BKV.Inner.TargetKey=%~1"
set "BKV.Inner.TargetFile=%~2"
set "BKV.Inner.TempFile="
set "BKV.Inner.CurrentLine="
set "BKV.Inner.ExtractedKey="
set "BKV.Inner.KeyValidationResult="
set "BKV.Inner.FileValidationResult="

:: Validate required parameters
if "%BKV.Inner.TargetKey%"=="" (
    set "BKV.Remove-Status=NotOK"
    goto :BKV.Remove.End
)

:: Set default filename
if "%BKV.Inner.TargetFile%"=="" set "BKV.Inner.TargetFile=%BKV.Inner.DefaultFile%"

:: Validate key name
call :BKV.Private.ValidateKey "%BKV.Inner.TargetKey%"
if "%BKV.Inner.KeyValidationResult%"=="No" (
    set "BKV.Remove-Status=NotOK"
    goto :BKV.Remove.End
)

:: Validate filename
call :BKV.Private.ValidateFilename "%BKV.Inner.TargetFile%"
if "%BKV.Inner.FileValidationResult%"=="No" (
    set "BKV.Remove-Status=NotOK"
    goto :BKV.Remove.End
)

:: Check if file exists
if not exist "%BKV.Inner.TargetFile%" (
    set "BKV.Remove-Status=OK"
    goto :BKV.Remove.End
)

:: Create temporary file, copy all lines except target key
set "BKV.Inner.TempFile=%BKV.Inner.TargetFile%.tmp"
if exist "%BKV.Inner.TempFile%" del "%BKV.Inner.TempFile%" 2>nul

for /f "usebackq delims=" %%i in ("%BKV.Inner.TargetFile%") do (
    set "BKV.Inner.CurrentLine=%%i"
    call :BKV.Private.ExtractKey "!BKV.Inner.CurrentLine!"
    if not "!BKV.Inner.ExtractedKey!"=="%BKV.Inner.TargetKey%" (
        echo %%i >> "%BKV.Inner.TempFile%"
    )
)

:: Replace original file
if exist "%BKV.Inner.TempFile%" (
    move "%BKV.Inner.TempFile%" "%BKV.Inner.TargetFile%" >nul 2>nul
    set "BKV.Remove-Status=OK"
) else (
    :: If temporary file doesn't exist, all lines were deleted
    echo. 2>nul > "%BKV.Inner.TargetFile%"
    set "BKV.Remove-Status=OK"
)

:BKV.Remove.End
:: Clean up internal variables
set "BKV.Inner.TargetKey="
set "BKV.Inner.TargetFile="
set "BKV.Inner.TempFile="
set "BKV.Inner.CurrentLine="
set "BKV.Inner.ExtractedKey="
set "BKV.Inner.KeyValidationResult="
set "BKV.Inner.FileValidationResult="
goto :EOF

:: =====================================================
:: Function Name: BKV.Fetch
:: Description : Read value corresponding to specified key
:: Parameters  :
::   %1 - Key: Key name to search for
::   %2 - File_Name (optional): Filename, defaults to _BATKV.bkv
:: Return Values:
::   BKV.Fetch-Status: OK for success, NotOK for failure
::   BKV.Fetch-Result: Retrieved value, empty if key doesn't exist
:: Internal Variables:
::   BKV.Inner.TargetKey - Target key name
::   BKV.Inner.TargetFile - Target filename
::   BKV.Inner.CurrentLine - Current line being processed
::   BKV.Inner.ExtractedKey - Key name extracted from line
::   BKV.Inner.ExtractedValue - Value extracted from line
::   BKV.Inner.KeyValidationResult - Key name validation result
::   BKV.Inner.FileValidationResult - Filename validation result
:: Usage Example:
::   call BKV.Fetch "username"
::   call BKV.Fetch "retry_count" "config.bkv"
:: =====================================================
:BKV.Fetch
:: Reset return values to default state
set "BKV.Fetch-Status=%BKV.Inner.DefaultStatus%"
set "BKV.Fetch-Result="

:: Set internal variables
set "BKV.Inner.TargetKey=%~1"
set "BKV.Inner.TargetFile=%~2"
set "BKV.Inner.CurrentLine="
set "BKV.Inner.ExtractedKey="
set "BKV.Inner.ExtractedValue="
set "BKV.Inner.KeyValidationResult="
set "BKV.Inner.FileValidationResult="

:: Validate required parameters
if "%BKV.Inner.TargetKey%"=="" (
    set "BKV.Fetch-Status=NotOK"
    goto :BKV.Fetch.End
)

:: Set default filename
if "%BKV.Inner.TargetFile%"=="" set "BKV.Inner.TargetFile=%BKV.Inner.DefaultFile%"

:: Validate key name
call :BKV.Private.ValidateKey "%BKV.Inner.TargetKey%"
if "%BKV.Inner.KeyValidationResult%"=="No" (
    set "BKV.Fetch-Status=NotOK"
    goto :BKV.Fetch.End
)

:: Validate filename
call :BKV.Private.ValidateFilename "%BKV.Inner.TargetFile%"
if "%BKV.Inner.FileValidationResult%"=="No" (
    set "BKV.Fetch-Status=NotOK"
    goto :BKV.Fetch.End
)

:: Check if file exists
if not exist "%BKV.Inner.TargetFile%" (
    set "BKV.Fetch-Status=OK"
    goto :BKV.Fetch.End
)

:: Search for key-value pair in file
for /f "usebackq delims=" %%i in ("%BKV.Inner.TargetFile%") do (
    set "BKV.Inner.CurrentLine=%%i"
    call :BKV.Private.ExtractKey "!BKV.Inner.CurrentLine!"
    if "!BKV.Inner.ExtractedKey!"=="%BKV.Inner.TargetKey%" (
        call :BKV.Private.ExtractValue "!BKV.Inner.CurrentLine!"
        set "BKV.Fetch-Result=!BKV.Inner.ExtractedValue!"
        set "BKV.Fetch-Status=OK"
        goto :BKV.Fetch.End
    )
)

:: If we reach here, key doesn't exist
set "BKV.Fetch-Status=OK"

:BKV.Fetch.End
:: Clean up internal variables
set "BKV.Inner.TargetKey="
set "BKV.Inner.TargetFile="
set "BKV.Inner.CurrentLine="
set "BKV.Inner.ExtractedKey="
set "BKV.Inner.ExtractedValue="
set "BKV.Inner.KeyValidationResult="
set "BKV.Inner.FileValidationResult="
goto :EOF

:: =====================================================
:: Function Name: BKV.Include
:: Description : Check if specified key exists in database
:: Parameters  :
::   %1 - Key: Key name to check
::   %2 - File_Name (optional): Filename, defaults to _BATKV.bkv
:: Return Values:
::   BKV.Include-Status: OK for success, NotOK for failure
::   BKV.Include-Result: Yes if exists, No if doesn't exist
:: Internal Variables:
::   BKV.Inner.TargetKey - Target key name
::   BKV.Inner.TargetFile - Target filename
::   BKV.Inner.CurrentLine - Current line being processed
::   BKV.Inner.ExtractedKey - Key name extracted from line
::   BKV.Inner.KeyValidationResult - Key name validation result
::   BKV.Inner.FileValidationResult - Filename validation result
:: Usage Example:
::   call BKV.Include "db_host"
::   call BKV.Include "initialized" "app.bkv"
:: =====================================================
:BKV.Include
:: Reset return values to default state
set "BKV.Include-Status=%BKV.Inner.DefaultStatus%"
set "BKV.Include-Result=No"

:: Set internal variables
set "BKV.Inner.TargetKey=%~1"
set "BKV.Inner.TargetFile=%~2"
set "BKV.Inner.CurrentLine="
set "BKV.Inner.ExtractedKey="
set "BKV.Inner.KeyValidationResult="
set "BKV.Inner.FileValidationResult="

:: Validate required parameters
if "%BKV.Inner.TargetKey%"=="" (
    set "BKV.Include-Status=NotOK"
    goto :BKV.Include.End
)

:: Set default filename
if "%BKV.Inner.TargetFile%"=="" set "BKV.Inner.TargetFile=%BKV.Inner.DefaultFile%"

:: Validate key name
call :BKV.Private.ValidateKey "%BKV.Inner.TargetKey%"
if "%BKV.Inner.KeyValidationResult%"=="No" (
    set "BKV.Include-Status=NotOK"
    goto :BKV.Include.End
)

:: Validate filename
call :BKV.Private.ValidateFilename "%BKV.Inner.TargetFile%"
if "%BKV.Inner.FileValidationResult%"=="No" (
    set "BKV.Include-Status=NotOK"
    goto :BKV.Include.End
)

:: Check if file exists
if not exist "%BKV.Inner.TargetFile%" (
    set "BKV.Include-Status=OK"
    goto :BKV.Include.End
)

:: Search for key in file
for /f "usebackq delims=" %%i in ("%BKV.Inner.TargetFile%") do (
    set "BKV.Inner.CurrentLine=%%i"
    call :BKV.Private.ExtractKey "!BKV.Inner.CurrentLine!"
    if "!BKV.Inner.ExtractedKey!"=="%BKV.Inner.TargetKey%" (
        set "BKV.Include-Result=Yes"
        set "BKV.Include-Status=OK"
        goto :BKV.Include.End
    )
)

:: If we reach here, key doesn't exist
set "BKV.Include-Status=OK"

:BKV.Include.End
:: Clean up internal variables
set "BKV.Inner.TargetKey="
set "BKV.Inner.TargetFile="
set "BKV.Inner.CurrentLine="
set "BKV.Inner.ExtractedKey="
set "BKV.Inner.KeyValidationResult="
set "BKV.Inner.FileValidationResult="
goto :EOF

:: =====================================================
:: Function Name: BKV.Grep
:: Description : Match keys using regular expressions, return list of matching key-value pairs
:: Parameters  :
::   %1 - Match_Regex: Regular expression for matching
::   %2 - File_Name (optional): Filename, defaults to _BATKV.bkv
:: Return Values:
::   BKV.Grep-Status: OK for success, NotOK for failure
::   BKV.Grep-Result: List of matching key-value pairs, format is key\value, multiple lines
:: Internal Variables:
::   BKV.Inner.TargetRegex - Target regular expression
::   BKV.Inner.TargetFile - Target filename
::   BKV.Inner.TempResult - Temporary result storage
::   BKV.Inner.FileValidationResult - Filename validation result
:: Usage Example:
::   call BKV.Grep "^user"
::   call BKV.Grep "temp" "cache.bkv"
:: =====================================================
:BKV.Grep
:: Reset return values to default state
set "BKV.Grep-Status=%BKV.Inner.DefaultStatus%"
set "BKV.Grep-Result="

:: Set internal variables
set "BKV.Inner.TargetRegex=%~1"
set "BKV.Inner.TargetFile=%~2"
set "BKV.Inner.TempResult="
set "BKV.Inner.FileValidationResult="

:: Validate required parameters
if "%BKV.Inner.TargetRegex%"=="" (
    set "BKV.Grep-Status=NotOK"
    goto :BKV.Grep.End
)

:: Set default filename
if "%BKV.Inner.TargetFile%"=="" set "BKV.Inner.TargetFile=%BKV.Inner.DefaultFile%"

:: Validate filename
call :BKV.Private.ValidateFilename "%BKV.Inner.TargetFile%"
if "%BKV.Inner.FileValidationResult%"=="No" (
    set "BKV.Grep-Status=NotOK"
    goto :BKV.Grep.End
)

:: Check if file exists
if not exist "%BKV.Inner.TargetFile%" (
    set "BKV.Grep-Status=OK"
    goto :BKV.Grep.End
)

:: Use findstr to find matching lines
for /f "usebackq delims=" %%i in (`findstr /r "%BKV.Inner.TargetRegex%" "%BKV.Inner.TargetFile%" 2^>nul`) do (
    if "!BKV.Inner.TempResult!"=="" (
        set "BKV.Inner.TempResult=%%i"
    ) else (
        set "BKV.Inner.TempResult=!BKV.Inner.TempResult!%%i"
    )
)

set "BKV.Grep-Result=%BKV.Inner.TempResult%"
set "BKV.Grep-Status=OK"

:BKV.Grep.End
:: Clean up internal variables
set "BKV.Inner.TargetRegex="
set "BKV.Inner.TargetFile="
set "BKV.Inner.TempResult="
set "BKV.Inner.FileValidationResult="
goto :EOF

:: =====================================================
:: Internal helper function implementations
:: =====================================================

:: =====================================================
:: Function Name: BKV.Private.ValidateKey
:: Description : Validate if key name conforms to Bat-KV naming conventions
:: Parameters  :
::   %1 - Key: Key name to validate
:: Return Values:
::   BKV.Inner.KeyValidationResult: Yes for valid, No for invalid
:: Internal Variables:
::   BKV.Inner.KeyToValidate - Key name to validate
::   BKV.Inner.KeyLength - Key name length
:: Validation Rules:
::   - Key name cannot be empty
::   - Key name length should not exceed 36 characters
::   - Key name cannot contain backslash (used as separator)
:: Usage Example:
::   call :BKV.Private.ValidateKey "username"
::   if "%BKV.Inner.KeyValidationResult%"=="Yes" echo Key name is valid
:: =====================================================
:BKV.Private.ValidateKey
set "BKV.Inner.KeyValidationResult=Yes"
set "BKV.Inner.KeyToValidate=%~1"
set "BKV.Inner.KeyLength=0"

:: Check if key name is empty
if "%BKV.Inner.KeyToValidate%"=="" (
    set "BKV.Inner.KeyValidationResult=No"
    goto :BKV.Private.ValidateKey.End
)

:: Check key name length
call :BKV.Private.GetStringLength "%BKV.Inner.KeyToValidate%" BKV.Inner.KeyLength
if %BKV.Inner.KeyLength% GTR %BKV.Inner.MaxKeyLength% (
    set "BKV.Inner.KeyValidationResult=No"
    goto :BKV.Private.ValidateKey.End
)

:: Check key name characters (check for backslash)
echo "%BKV.Inner.KeyToValidate%" | findstr /C:"\" >nul 2>nul
if not errorlevel 1 (
    set "BKV.Inner.KeyValidationResult=No"
    goto :BKV.Private.ValidateKey.End
)

:BKV.Private.ValidateKey.End
:: Clean up internal variables
set "BKV.Inner.KeyToValidate="
set "BKV.Inner.KeyLength="
goto :EOF

:: =====================================================
:: Function Name: BKV.Private.ValidateFilename
:: Description : Validate if filename is legal, avoiding characters not supported by Windows file system
:: Parameters  :
::   %1 - Filename: Filename to validate
:: Return Values:
::   BKV.Inner.FileValidationResult: Yes for valid, No for invalid
:: Internal Variables:
::   BKV.Inner.FilenameToValidate - Filename to validate
:: Validation Rules:
::   - Filename cannot be empty
::   - Filename cannot contain illegal characters: < > |
:: Usage Example:
::   call :BKV.Private.ValidateFilename "config.bkv"
::   if "%BKV.Inner.FileValidationResult%"=="Yes" echo Filename is valid
:: =====================================================
:BKV.Private.ValidateFilename
set "BKV.Inner.FileValidationResult=Yes"
set "BKV.Inner.FilenameToValidate=%~1"

:: Check if filename is empty
if "%BKV.Inner.FilenameToValidate%"=="" (
    set "BKV.Inner.FileValidationResult=No"
    goto :BKV.Private.ValidateFilename.End
)

:: Check if filename contains illegal characters
echo "%BKV.Inner.FilenameToValidate%" | findstr /C:"<" >nul 2>nul
if not errorlevel 1 set "BKV.Inner.FileValidationResult=No"
echo "%BKV.Inner.FilenameToValidate%" | findstr /C:">" >nul 2>nul
if not errorlevel 1 set "BKV.Inner.FileValidationResult=No"
echo "%BKV.Inner.FilenameToValidate%" | findstr /C:"|" >nul 2>nul
if not errorlevel 1 set "BKV.Inner.FileValidationResult=No"

:BKV.Private.ValidateFilename.End
:: Clean up internal variables
set "BKV.Inner.FilenameToValidate="
goto :EOF

:: =====================================================
:: Function Name: BKV.Private.ExtractKey
:: Description : Extract key name portion from key-value pair line
:: Parameters  :
::   %1 - Line: Complete line containing key-value pair, format "key\value"
:: Return Values:
::   BKV.Inner.ExtractedKey: Extracted key name
:: Internal Variables:
::   BKV.Inner.FullLine - Complete line to process
:: Processing Logic:
::   Use backslash as separator, extract first part as key name
:: Usage Example:
::   call :BKV.Private.ExtractKey "username\Alice"
::   echo Key name: %BKV.Inner.ExtractedKey%
:: =====================================================
:BKV.Private.ExtractKey
set "BKV.Inner.FullLine=%~1"
set "BKV.Inner.ExtractedKey="

if "%BKV.Inner.FullLine%"=="" goto :BKV.Private.ExtractKey.End

:: Find position of first backslash, extract key name
for /f "tokens=1 delims=\" %%a in ("%BKV.Inner.FullLine%") do (
    set "BKV.Inner.ExtractedKey=%%a"
)

:BKV.Private.ExtractKey.End
:: Clean up internal variables
set "BKV.Inner.FullLine="
goto :EOF

:: =====================================================
:: Function Name: BKV.Private.ExtractValue
:: Description : Extract value portion from key-value pair line
:: Parameters  :
::   %1 - Line: Complete line containing key-value pair, format "key\value"
:: Return Values:
::   BKV.Inner.ExtractedValue: Extracted value
:: Internal Variables:
::   BKV.Inner.FullLine - Complete line to process
:: Processing Logic:
::   Use backslash as separator, extract second part and all subsequent content as value
:: Usage Example:
::   call :BKV.Private.ExtractValue "username\Alice"
::   echo Value: %BKV.Inner.ExtractedValue%
:: =====================================================
:BKV.Private.ExtractValue
set "BKV.Inner.FullLine=%~1"
set "BKV.Inner.ExtractedValue="

if "%BKV.Inner.FullLine%"=="" goto :BKV.Private.ExtractValue.End

:: Remove key name and first backslash, remaining part is the value
for /f "tokens=1* delims=\" %%a in ("%BKV.Inner.FullLine%") do (
    set "BKV.Inner.ExtractedValue=%%b"
)

:BKV.Private.ExtractValue.End
:: Clean up internal variables
set "BKV.Inner.FullLine="
goto :EOF

:: =====================================================
:: Function Name: BKV.Private.UpdateKeyValue
:: Description : Update existing key-value pairs in file
:: Parameters  :
::   %1 - Key: Key name to update
::   %2 - Value: New value
::   %3 - Filename: Target filename
:: Return Values:
::   Returns operation status through BKV.Append-Status
:: Internal Variables:
::   BKV.Inner.UpdateKey - Key name to update
::   BKV.Inner.UpdateValue - New value
::   BKV.Inner.UpdateFilename - Target filename
::   BKV.Inner.UpdateTempFile - Temporary filename
::   BKV.Inner.UpdateCurrentLine - Current line being processed
::   BKV.Inner.UpdateExtractedKey - Key name extracted from line
:: Processing Logic:
::   Create temporary file, copy original file content line by line, replace target key's value
:: Usage Example:
::   call :BKV.Private.UpdateKeyValue "username" "Bob" "config.bkv"
:: =====================================================
:BKV.Private.UpdateKeyValue
set "BKV.Inner.UpdateKey=%~1"
set "BKV.Inner.UpdateValue=%~2"
set "BKV.Inner.UpdateFilename=%~3"
set "BKV.Inner.UpdateTempFile=%BKV.Inner.UpdateFilename%.tmp"
set "BKV.Inner.UpdateCurrentLine="
set "BKV.Inner.UpdateExtractedKey="

if exist "%BKV.Inner.UpdateTempFile%" del "%BKV.Inner.UpdateTempFile%" 2>nul

:: Copy file, replace target key's value
for /f "usebackq delims=" %%i in ("%BKV.Inner.UpdateFilename%") do (
    set "BKV.Inner.UpdateCurrentLine=%%i"
    call :BKV.Private.ExtractKey "!BKV.Inner.UpdateCurrentLine!"
    if "!BKV.Inner.ExtractedKey!"=="%BKV.Inner.UpdateKey%" (
        echo %BKV.Inner.UpdateKey%\%BKV.Inner.UpdateValue% >> "%BKV.Inner.UpdateTempFile%"
    ) else (
        echo %%i >> "%BKV.Inner.UpdateTempFile%"
    )
)

:: Replace original file
if exist "%BKV.Inner.UpdateTempFile%" (
    move "%BKV.Inner.UpdateTempFile%" "%BKV.Inner.UpdateFilename%" >nul 2>nul
    set "BKV.Append-Status=OK"
) else (
    set "BKV.Append-Status=NotOK"
)

:: Clean up internal variables
set "BKV.Inner.UpdateKey="
set "BKV.Inner.UpdateValue="
set "BKV.Inner.UpdateFilename="
set "BKV.Inner.UpdateTempFile="
set "BKV.Inner.UpdateCurrentLine="
set "BKV.Inner.UpdateExtractedKey="
goto :EOF

:: =====================================================
:: Function Name: BKV.Private.GetStringLength
:: Description : Get string length (simplified implementation for batch environment)
:: Parameters  :
::   %1 - String: String to calculate length for
::   %2 - ReturnVar: Variable name to return length value
:: Return Values:
::   Returns string length through specified variable name
:: Internal Variables:
::   BKV.Inner.StringToMeasure - String to measure
::   BKV.Inner.StringLength - String length counter
:: Processing Logic:
::   Remove characters one by one and count until string is empty or reaches maximum limit
:: Limitation Note:
::   To avoid infinite loops, maximum measurement length is limited to 50 characters
:: Usage Example:
::   call :BKV.Private.GetStringLength "hello" result_var
::   echo String length: %result_var%
:: =====================================================
:BKV.Private.GetStringLength
set "BKV.Inner.StringToMeasure=%~1"
set "BKV.Inner.StringLength=0"

if "%BKV.Inner.StringToMeasure%"=="" goto :BKV.Private.GetStringLength.End

:BKV.Private.GetStringLength.Loop
if "%BKV.Inner.StringToMeasure%"=="" goto :BKV.Private.GetStringLength.End
set "BKV.Inner.StringToMeasure=%BKV.Inner.StringToMeasure:~1%"
set /a "BKV.Inner.StringLength+=1"
if %BKV.Inner.StringLength% GEQ 50 goto :BKV.Private.GetStringLength.End
goto :BKV.Private.GetStringLength.Loop

:BKV.Private.GetStringLength.End
if "%~2" NEQ "" set "%~2=%BKV.Inner.StringLength%"

:: Clean up internal variables
set "BKV.Inner.StringToMeasure="
set "BKV.Inner.StringLength="
goto :EOF