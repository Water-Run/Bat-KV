# Bat-KV: Ultra-Lightweight KV Database for Windows Batch

**`Bat-KV` is an ultra-lightweight single-file KV database for Windows batch (`.bat`).**  
Its implementation is very simple, and it’s extremely easy to use—perfect for storing small data such as configuration files.  
**`Bat-KV` stores files in `.bkv` format**, which is plain text, very simple and human-readable, with the syntax `key\value`. The default path is `_BATKV.bkv` under the relative path.  
`Bat-KV` is open source on [GitHub](https://github.com/Water-Run/Bat-KV/).  

## Conventions and Standards

Before getting started, let’s define some conventions:  

### Naming Conventions

- **Private functions**: Prefixed with `BKV.Private.`, for internal use only. Do not call these externally.  
- **Private variables**: Prefixed with `BKV.Inner.`, for internal use only. Do not access or modify externally.  
- **Public API**: Prefixed with `BKV.` (e.g. `BKV.New`, `BKV.Fetch`).  
- **Return variables**: Use unified names: `BKV_STATUS`, `BKV_RESULT`, `BKV_ERR`.  

### File Format Standards

- **Database files**: `.bkv` extension (Batch Key-Value).  
- **Default filename**: `_BATKV.bkv`.  
- **Storage format**: One key-value pair per line, written as `key\value`.  
- **Character encoding**: ANSI charset for cross-platform compatibility.  

### Key Constraints

- **Allowed characters**: English letters, digits, and underscores only.  
- **Length limit**: Max 36 characters.  
- **Special characters**: Backslash (`\`) is not allowed in key names.  
- **Case sensitivity**: Keys are case-sensitive.  

### Value Constraints

- **Character support**: Any ANSI characters allowed (including spaces, punctuation, etc.).  
- **Special characters**: Values may include backslashes; escaping may be required internally.  
- **Length**: No strict limit, but keeping reasonable length is recommended for performance.  

### Line and Format Conventions

- **File structure**: One key-value pair per line; blank lines are ignored.  
- **Separator**: Backslash (`\`) separates key and value.  
- **Line ending**: Windows CRLF line breaks.  

## Importing `Bat-KV`

### Basic Installation Steps

Follow these steps to integrate `Bat-KV` into your project:

1. Download `Bat-KV.zip` from the [GitHub Release](https://github.com/Water-Run/Bat-KV/releases/tag/Bat-KV) page and extract to a proper path.  
2. Place the corresponding `Bat-KV.bat` file in an appropriate directory.  
3. Import the file in your `.bat` script.  

### Direct Call

```batch
REM Ensure Bat-KV.bat is in the current directory
call Bat-KV.bat :BKV.New
echo Status: %BKV_STATUS%

REM If Bat-KV.bat is in a subdirectory
call lib\Bat-KV.bat :BKV.New "mydata.bkv"

REM If Bat-KV.bat is in a parent directory  
call ..\Bat-KV.bat :BKV.Fetch "username"
```

### Global Usage (Environment Variable)

**Step 1: Add to environment variable**

1. Copy `Bat-KV.bat` to a fixed directory, e.g. `C:\Tools\BatKV\`.  
2. Add that directory to the system PATH environment variable.  
3. Restart Command Prompt or log in again.  

**Step 2: Use globally**

```batch
REM After PATH is set, invoke from anywhere
call Bat-KV.bat :BKV.New
call Bat-KV.bat :BKV.Append "config_path" "C:\MyApp\config.ini"
call Bat-KV.bat :BKV.Fetch "config_path"
echo Config location: %BKV_RESULT%
```

### Minimal Example

```batch
@echo off
REM Minimal Bat-KV usage example

REM Create database
call Bat-KV.bat :BKV.New
echo Create database: %BKV_STATUS%

REM Add data
call Bat-KV.bat :BKV.Append "name" "Alice"
call Bat-KV.bat :BKV.Append "age" "25"
call Bat-KV.bat :BKV.Append "city" "Beijing"

REM Read data
call Bat-KV.bat :BKV.Fetch "name"
echo Name: %BKV_RESULT%

call Bat-KV.bat :BKV.Fetch "age"  
echo Age: %BKV_RESULT%

REM Check if data exists
call Bat-KV.bat :BKV.Include "email"
if "%BKV_RESULT%"=="No" (
    echo Email not set, adding default...
    call Bat-KV.bat :BKV.Append "email" "alice@example.com"
)

REM Delete data
call Bat-KV.bat :BKV.Remove "city"
echo Remove city: %BKV_STATUS%

pause
```

> Refer to this document or read the inline docstrings in the source code—using `Bat-KV` is very easy.  

## API Reference

> **Important Convention**: Methods starting with `BKV.Private` are internal, variables starting with `BKV.Inner` are internal. Do not access them.  

### `BKV.New`

**Description:**  

Creates a `.bkv` file. If the file already exists, it will not overwrite content.  

**Parameters:**  

- **File_Name**: *(Optional)* The `.bkv` file name to create, default `_BATKV.bkv`.  

**Return Values:**  

- `BKV_STATUS`: `OK` on success, `NotOK` on failure.  
- `BKV_ERR`: Error details if failed, formatted as `Bat-KV ERR: [message]`.  

**Example:**  

```batch
REM Create default database
call Bat-KV.bat :BKV.New
echo Create status: %BKV_STATUS%

REM Create named database
call Bat-KV.bat :BKV.New "config.bkv"
if "%BKV_STATUS%"=="OK" (
    echo Database config.bkv created successfully
) else (
    echo Failed to create database: %BKV_ERR%
)
```

---

### `BKV.Erase`

**Description:**  

Deletes a `.bkv` file and all its contents.  

**Parameters:**  

- **File_Name**: *(Optional)* Database filename, default `_BATKV.bkv`.  

**Return Values:**  

- `BKV_STATUS`: `OK` on success, `NotOK` on failure.  
- `BKV_ERR`: Error details if failed.  

**Example:**  

```batch
REM Delete default DB
call Bat-KV.bat :BKV.Erase
if "%BKV_STATUS%"=="OK" (
    echo Default database deleted
)

REM Delete specified DB
call Bat-KV.bat :BKV.Erase "temp.bkv"
echo Delete operation status: %BKV_STATUS%
```

---

### `BKV.Append`

**Description:**  

Adds a key-value pair. If the key already exists, updates its value.  

**Parameters:**  

1. `Key`: Key name (must follow naming rules).  
2. `Value`: The value.  
3. `File_Name`: *(Optional)* Database filename, default `_BATKV.bkv`.  

**Return Values:**  

- `BKV_STATUS`: `OK`/`NotOK`.  
- `BKV_ERR`: Error message if failure.  

**Example:**  

```batch
REM Add username
call Bat-KV.bat :BKV.Append "username" "Alice"
echo Add username status: %BKV_STATUS%

REM Add config item
call Bat-KV.bat :BKV.Append "max_retry" "3" "config.bkv"

REM Add value with spaces
call Bat-KV.bat :BKV.Append "app_title" "My Application v1.0"
if "%BKV_STATUS%"=="OK" (
    echo Application title set successfully
) else (
    echo Failed to set title: %BKV_ERR%
)
```

---

### `BKV.Remove`

**Description:**  

Removes a key-value pair. If key does not exist, still returns success.  

**Parameters:**  

1. `Key`: Key name.  
2. `File_Name`: *(Optional)* Database filename, default `_BATKV.bkv`.  

**Return Values:**  

- `BKV_STATUS`: `OK`/`NotOK`.  
- `BKV_ERR`: Error message if failure.  

**Example:**  

```batch
REM Delete temporary config
call Bat-KV.bat :BKV.Remove "temp_setting"
echo Delete status: %BKV_STATUS%

REM Delete expired data
call Bat-KV.bat :BKV.Remove "session_id" "cache.bkv"

REM Batch delete (must call individually)
call Bat-KV.bat :BKV.Remove "old_key1"
call Bat-KV.bat :BKV.Remove "old_key2"
call Bat-KV.bat :BKV.Remove "old_key3"
echo Batch deletion completed
```

---

### `BKV.Fetch`

**Description:**  

Retrieves the value of a key-value pair. Main query method.  

**Parameters:**  

1. `Key`: Key name.  
2. `File_Name`: *(Optional)* Database filename, default `_BATKV.bkv`.  

**Return Values:**  

- `BKV_STATUS`: `OK`/`NotOK`.  
- `BKV_RESULT`: Value read (empty if key not found).  
- `BKV_ERR`: Error details if failure.  

**Example:**  

```batch
REM Read user config
call Bat-KV.bat :BKV.Fetch "username"
if "%BKV_STATUS%"=="OK" (
    if not "%BKV_RESULT%"=="" (
        echo Current user: %BKV_RESULT%
    ) else (
        echo Username not set
    )
) else (
    echo Cannot read username: %BKV_ERR%
)

REM Read numeric config and calculate
call Bat-KV.bat :BKV.Fetch "retry_count" "config.bkv"
if "%BKV_STATUS%"=="OK" (
    if not "%BKV_RESULT%"=="" (
        set /a next_retry=%BKV_RESULT%+1
        echo Next retry count: %next_retry%
    )
)

REM Read config item with default
call Bat-KV.bat :BKV.Fetch "theme"
if "%BKV_STATUS%"=="OK" (
    if "%BKV_RESULT%"=="" (
        set current_theme=default
        echo Using default theme
    ) else (
        set current_theme=%BKV_RESULT%
        echo Current theme: %current_theme%
    )
)
```

---

### `BKV.Include`

**Description:**  

Checks whether a specified key exists. Useful for verifying configuration items.  

**Parameters:**  

1. `Key`: Key name.  
2. `File_Name`: *(Optional)* Database filename, default `_BATKV.bkv`.  

**Return Values:**  

- `BKV_STATUS`: `OK`/`NotOK`.  
- `BKV_RESULT`: `Yes` if exists, `No` if not.  
- `BKV_ERR`: Error details if failure.  

**Example:**  

```batch
REM Check if DB connection set
call Bat-KV.bat :BKV.Include "db_host"
if "%BKV_STATUS%"=="OK" (
    if "%BKV_RESULT%"=="Yes" (
        echo Database configuration exists
        call Bat-KV.bat :BKV.Fetch "db_host"
        echo Database host: %BKV_RESULT%
    ) else (
        echo Please configure database connection first
        call Bat-KV.bat :BKV.Append "db_host" "localhost"
    )
) else (
    echo Failed to check configuration: %BKV_ERR%
)

REM Check initialization
call Bat-KV.bat :BKV.Include "initialized" "app.bkv"
if "%BKV_STATUS%"=="OK" (
    if "%BKV_RESULT%"=="No" (
        echo Performing first-time initialization...
        call Bat-KV.bat :BKV.Append "initialized" "true" "app.bkv"
        call Bat-KV.bat :BKV.Append "install_date" "%date%" "app.bkv"
    )
)
```

---

## Example Program

```batch
:: =====================================================
:: File      : BKV-DemoDBMS.bat
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
```
