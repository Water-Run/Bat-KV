# Bat-KV: Simple KV Database for Windows Batch

**`Bat-KV` is an ultra-lightweight single-file KV database for Windows batch (`.bat`) files.**  
`Bat-KV` is simple to implement and very easy to use, making it ideal for storing simple data such as configuration files.  
**`Bat-KV` files are stored in `.bkv`** format, which is a plain text, very simple and readable format with the syntax `key\value`. The default path is `_BATKV.bkv` under the relative path.  
`Bat-KV` has **key constraints: pure English, numbers or underscores only, and no more than 36 characters**. **For compatibility considerations, `Bat-KV` keys and values should be compatible with the corresponding platform's `ANSI` characters.**  
`Bat-KV` is open source on [GitHub]().  

## Importing `Bat-KV`

Follow these steps to import `Bat-KV` into your project:

1. Download `Bat-KV(1.0).zip` from the [GitHub Release]() page and extract it to an appropriate path  
2. Place the corresponding `Bat-KV.bat` in an appropriate path  
3. Import the file in your `.bat`:  

```batch
REM Import Bat-KV database functionality
REM Ensure Bat-KV.bat file is in the current directory or a path specified by the PATH environment variable
call Bat-KV.bat
```

> Refer to this documentation or read the docstrings in the source code - getting started with `Bat-KV` is very easy  

## API Reference

> Convention: Methods starting with `BKV.Private` are internal methods, and variables starting with `BKV.Inner` are internal variables. Do not access these contents  

### `BKV.New`

**Description:**

Creates a new `.bkv` file. If the file already exists, it will not overwrite existing content.

***Parameters:***

1. **File_Name**: *(Optional)* Name of the `.bkv` file to create, defaults to `_BATKV.bkv`

***Return Values:***

- `BKV.New-Status`: `OK` for successful execution, `NotOK` for failure. Default value is `NA`.

*Example:*

```batch
REM Create default database file
call BKV.New
echo Creation status: %BKV.New-Status%

REM Create database file with specified name
call BKV.New "config.bkv"
if "%BKV.New-Status%"=="OK" (
    echo Database file config.bkv created successfully
) else (
    echo Database file creation failed
)
```

### `BKV.Erase`

**Description:**

Deletes a `.bkv` file, including all data in the file.

***Parameters:***

1. **File_Name**: *(Optional)* Name of the `.bkv` file to delete, defaults to `_BATKV.bkv`

***Return Values:***

- `BKV.Erase-Status`: `OK` for successful execution, `NotOK` for failure. Default value is `NA`.

*Example:*

```batch
REM Delete default database file
call BKV.Erase
if "%BKV.Erase-Status%"=="OK" (
    echo Default database has been deleted
)

REM Delete specified database file
call BKV.Erase "temp.bkv"
echo Delete operation status: %BKV.Erase-Status%
```

### `BKV.Append`

**Description:**

Adds a key-value pair. If the key already exists, updates the corresponding value.

***Parameters:***

1. `Key`: The key name to add (must comply with naming conventions)
2. `Value`: The corresponding value
3. `File_Name`: *(Optional)* Target `.bkv` file name, defaults to `_BATKV.bkv`

***Return Values:***

- `BKV.Append-Status`: `OK` for successful execution, `NotOK` for failure. Default value is `NA`.

*Example:*

```batch
REM Add username to default database
call BKV.Append "username" "Alice"
echo Add username status: %BKV.Append-Status%

REM Add configuration item to specified database
call BKV.Append "max_retry" "3" "config.bkv"

REM Add value containing spaces
call BKV.Append "app_title" "My Application v1.0"
if "%BKV.Append-Status%"=="OK" (
    echo Application title set successfully
)
```

### `BKV.Remove`

**Description:**

Deletes a key-value pair. If the key does not exist, the operation still returns success status.

***Parameters:***

1. `Key`: The key name to delete
2. `File-Name`: *(Optional)* Target `.bkv` file name, defaults to `_BATKV.bkv`

***Return Values:***

- `BKV.Remove-Status`: `OK` for successful execution, `NotOK` for failure. Default value is `NA`.

*Example:*

```batch
REM Delete temporary configuration from default database
call BKV.Remove "temp_setting"
echo Delete status: %BKV.Remove-Status%

REM Delete expired data from specified database
call BKV.Remove "session_id" "cache.bkv"

REM Batch delete example (requires individual calls)
call BKV.Remove "old_key1"
call BKV.Remove "old_key2"
call BKV.Remove "old_key3"
echo Batch deletion completed
```

### `BKV.Fetch`

**Description:**

Reads the value of a key-value pair. This is the primary method for querying data.

***Parameters:***

1. `Key`: The key name to search for
2. `File-Name`: *(Optional)* Target `.bkv` file name, defaults to `_BATKV.bkv`

***Return Values:***

- `BKV.Fetch-Status`: `OK` for successful execution, `NotOK` for failure. Default value is `NA`.
- `BKV.Fetch-Result`: The corresponding value read. Empty if key does not exist, default value is `(Default)`.

*Example:*

```batch
REM Read user configuration
call BKV.Fetch "username"
if "%BKV.Fetch-Status%"=="OK" (
    echo Current user: %BKV.Fetch-Result%
) else (
    echo Unable to read username
)

REM Read numeric configuration and perform calculation
call BKV.Fetch "retry_count" "config.bkv"
if not "%BKV.Fetch-Result%"=="" (
    set /a next_retry=%BKV.Fetch-Result%+1
    echo Next retry count: %next_retry%
)

REM Read configuration item and set default value
call BKV.Fetch "theme"
if "%BKV.Fetch-Result%"=="" (
    set current_theme=default
    echo Using default theme
) else (
    set current_theme=%BKV.Fetch-Result%
    echo Current theme: %current_theme%
)
```

### `BKV.Include`

**Description:**

Determines whether a specified key exists in the file. Used to check if configuration items have been set.

***Parameters:***

1. `Key`: The key name to check
2. `File-Name`: *(Optional)* Target `.bkv` file name, defaults to `_BATKV.bkv`

***Return Values:***

- `BKV.Include-Status`: `OK` for successful execution, `NotOK` for failure. Default value is `NA`.
- `BKV.Include-Result`: The result of the check. `Yes` if exists, `No` if not exists, default value is `(Default)`.

*Example:*

```batch
REM Check if database connection has been configured
call BKV.Include "db_host"
if "%BKV.Include-Result%"=="Yes" (
    echo Database configuration exists
    call BKV.Fetch "db_host"
    echo Database host: %BKV.Fetch-Result%
) else (
    echo Please configure database connection first
    call BKV.Append "db_host" "localhost"
)

REM Check initialization status
call BKV.Include "initialized" "app.bkv"
if "%BKV.Include-Status%"=="OK" (
    if "%BKV.Include-Result%"=="No" (
        echo Performing first-time initialization...
        call BKV.Append "initialized" "true" "app.bkv"
        call BKV.Append "install_date" "%date%" "app.bkv"
    )
)
```

### `BKV.Grep`

**Description:**

Matches keys that conform to a regular expression, returning a list of key-value pairs. Suitable for batch queries and fuzzy searches.

> **Regular expressions are implemented using `findstr`**, which is not a complete regex implementation but supports basic pattern matching

> Format description of the returned key-value pair list (implemented as a string): (essentially **consistent with the text content stored in the `.bkv` file**)
>> [key1]\[value1]
>> [key2]\[value2]
>> ...
>> [last key]\[last value]

***Parameters:***

1. `Match-Regex`: The regular expression to match
2. `File-Name`: *(Optional)* Target `.bkv` file name, defaults to `_BATKV.bkv`

***Return Values:***

- `BKV.Grep-Result`: Matched key-value pairs in the format described above. Default value is `(Default)`.
- `BKV.Grep-Status`: `OK` for successful execution, `NotOK` for failure. Default value is `NA`.

*Example:*

```batch
REM Find all configuration items starting with "user"
call BKV.Grep "^user"
if "%BKV.Grep-Status%"=="OK" (
    echo User-related configurations:
    echo %BKV.Grep-Result%
)

REM Find all keys containing "temp"
call BKV.Grep "temp" "cache.bkv"
echo Temporary data: %BKV.Grep-Result%

REM Find all keys ending with numbers (using findstr regex syntax)
call BKV.Grep "[0-9]$"
if not "%BKV.Grep-Result%"=="" (
    echo Found keys ending with numbers:
    echo %BKV.Grep-Result%
) else (
    echo No matching keys found
)

REM Save matching results to temporary file for further processing
call BKV.Grep "config_" > temp_config.txt
echo Configuration items exported to temp_config.txt
```

## Demo Program

```batch
:: =====================================================
:: File      : Demo-Batch.bat
:: Author    : WaterRun
:: Description:
::   Bat-KV sample program: A simple plain text reader with history functionality.
::   Supports setting software users and retrieving recent file load times and other historical information
::   
::   Features:
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
    echo Username setting failed!
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

REM Update total read count
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

echo File has been read, access record saved
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
echo --- All History Records ---
REM Use regular expression to find all count records
call BKV.Grep "^count_" "reader_app.bkv"
if "%BKV.Grep-Status%"=="OK" (
    if not "%BKV.Grep-Result%"=="" (
        echo %BKV.Grep-Result%
    ) else (
        echo No detailed records available
    )
) else (
    echo Unable to retrieve history records
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
        echo User setting time: %BKV.Fetch-Result%
    )
)

REM Display total read count
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
        echo Data clearing failed
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
    echo Total files read this session: %BKV.Fetch-Result%
)

echo Goodbye!
pause
exit /b 0
```