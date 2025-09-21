# Bat-KV: 为Windows批处理提供的超轻量级KV数据库

**`Bat-KV`是一个面向Windows批处理(`.bat`)的超轻量级单文件KV数据库.**  
`Bat-KV`的实现很简单,使用也非常的容易上手,很适合存储一些简单的数据,如配置文件等.  
**`Bat-KV`的文件存储在`.bkv`中**,是一种纯文本形式的,非常简单易读的格式,语法为`键\值`.默认路径在相对路径下的`_BATKV.bkv`.  
`Bat-KV`开源于[GitHub](https://github.com/Water-Run/Bat-KV/).  

## 约定和规范

在开始之前,让我们先约定一些规范:  

### 命名约定

- **私有函数**: 以`BKV.Private.`为前缀,仅供内部使用,不要在外部代码中直接调用
- **私有变量**: 以`BKV.Inner.`为前缀,仅供内部使用,不要在外部代码中访问或修改
- **公共API**: 以`BKV.`为前缀(如`BKV.New`, `BKV.Fetch`等)
- **返回变量**: 使用统一的`BKV_STATUS`, `BKV_RESULT`, `BKV_ERR`

### 文件格式规范

- **数据库文件**: 使用`.bkv`扩展名(Batch Key-Value)
- **默认文件名**: `_BATKV.bkv`
- **存储格式**: 每行一个键值对,格式为`key\value`
- **字符编码**: 支持ANSI字符集,确保跨平台兼容性

### 键名约束

- **字符限制**: 键名只能包含英文字母、数字和下划线
- **长度限制**: 键名不超过36个字符
- **特殊字符**: 键名不能包含反斜杠(`\`)字符
- **大小写**: 键名区分大小写

### 值的约束

- **字符支持**: 值可以包含任意ANSI字符(包括空格、标点符号等)
- **特殊字符**: 值可以包含反斜杠,但在内部处理时需要注意转义
- **长度**: 理论上无限制,但建议保持合理长度以确保性能

### 换行和格式约定

- **文件结构**: 每行一个键值对,空行会被忽略
- **分隔符**: 键和值之间使用反斜杠(`\`)分隔
- **行结束**: 使用Windows标准的CRLF换行符

## 引入`Bat-KV`

### 基本安装步骤

按照以下顺序操作即可在项目中引入`Bat-KV`:

1. 从[GitHub Release](https://github.com/Water-Run/Bat-KV/releases/tag/Bat-KV)页面下载`Bat-KV.zip`,并解压到合适的路径
2. 将对应的`Bat-KV.bat`放到合适的路径之中
3. 在你的`.bat`中导入该文件

### 直接调用

```batch
REM 确保Bat-KV.bat文件在当前目录
call Bat-KV.bat :BKV.New
echo Status: %BKV_STATUS%

REM 如果Bat-KV.bat在子目录中
call lib\Bat-KV.bat :BKV.New "mydata.bkv"

REM 如果Bat-KV.bat在上级目录中  
call ..\Bat-KV.bat :BKV.Fetch "username"
```

### 全局使用(环境变量)  

**步骤1: 添加到环境变量**

1. 将`Bat-KV.bat`复制到一个固定目录,如`C:\Tools\BatKV\`
2. 将该目录添加到系统的PATH环境变量中
3. 重启命令提示符或重新登录

**步骤2: 全局使用**

```batch
REM 配置环境变量后,可以在任何位置直接调用
call Bat-KV.bat :BKV.New
call Bat-KV.bat :BKV.Append "config_path" "C:\MyApp\config.ini"
call Bat-KV.bat :BKV.Fetch "config_path"
echo Config location: %BKV_RESULT%
```

### 最基础的使用示例

```batch
@echo off
REM 最简单的Bat-KV使用示例

REM 创建数据库
call Bat-KV.bat :BKV.New
echo Create database: %BKV_STATUS%

REM 添加数据
call Bat-KV.bat :BKV.Append "name" "Alice"
call Bat-KV.bat :BKV.Append "age" "25"
call Bat-KV.bat :BKV.Append "city" "Beijing"

REM 读取数据
call Bat-KV.bat :BKV.Fetch "name"
echo Name: %BKV_RESULT%

call Bat-KV.bat :BKV.Fetch "age"  
echo Age: %BKV_RESULT%

REM 检查数据是否存在
call Bat-KV.bat :BKV.Include "email"
if "%BKV_RESULT%"=="No" (
    echo Email not set, adding default...
    call Bat-KV.bat :BKV.Append "email" "alice@example.com"
)

REM 删除数据
call Bat-KV.bat :BKV.Remove "city"
echo Remove city: %BKV_STATUS%

pause
```

> 参考本文档或阅读源码中的文档字符串,上手`Bat-KV`非常容易

## API参考

> **重要约定**: `BKV.Private`开头的是内部方法,`BKV.Inner`开头的是内部变量.不要访问这些内容

### `BKV.New`

**说明:**

新建一个`.bkv`文件,如果文件已存在则不会覆盖现有内容.

***参数:***

1. **File_Name**: *(可选)* 创建的`.bkv`文件名称,缺省为`_BATKV.bkv`

***返回值:***

- `BKV_STATUS`: 执行成功为`OK`,失败为`NotOK`
- `BKV_ERR`: 失败时包含错误描述,格式为`Bat-KV ERR: [错误信息]`

*示例:*

```batch
REM 创建默认的数据库文件
call Bat-KV.bat :BKV.New
echo Create status: %BKV_STATUS%

REM 创建指定名称的数据库文件
call Bat-KV.bat :BKV.New "config.bkv"
if "%BKV_STATUS%"=="OK" (
    echo Database config.bkv created successfully
) else (
    echo Failed to create database: %BKV_ERR%
)
```

### `BKV.Erase`

**说明:**

删除一个`.bkv`文件,包括文件中的所有数据.

***参数:***

1. **File_Name**: *(可选)* 删除的`.bkv`文件名称,缺省为`_BATKV.bkv`

***返回值:***

- `BKV_STATUS`: 执行成功为`OK`,失败为`NotOK`
- `BKV_ERR`: 失败时包含错误描述,格式为`Bat-KV ERR: [错误信息]`

*示例:*

```batch
REM 删除默认数据库文件
call Bat-KV.bat :BKV.Erase
if "%BKV_STATUS%"=="OK" (
    echo Default database deleted
)

REM 删除指定的数据库文件
call Bat-KV.bat :BKV.Erase "temp.bkv"
echo Delete operation status: %BKV_STATUS%
```

### `BKV.Append`

**说明:**

增加一个键值对.如果键已存在,则更新对应的值.

***参数:***

1. `Key`: 增加的键名(必须符合命名规范)
2. `Value`: 对应的值
3. `File_Name`: *(可选)* 目标`.bkv`文件名称,缺省为`_BATKV.bkv`

***返回值:***

- `BKV_STATUS`: 执行成功为`OK`,失败为`NotOK`
- `BKV_ERR`: 失败时包含错误描述,格式为`Bat-KV ERR: [错误信息]`

*示例:*

```batch
REM 向默认数据库添加用户名
call Bat-KV.bat :BKV.Append "username" "Alice"
echo Add username status: %BKV_STATUS%

REM 向指定数据库添加配置项
call Bat-KV.bat :BKV.Append "max_retry" "3" "config.bkv"

REM 添加包含空格的值
call Bat-KV.bat :BKV.Append "app_title" "My Application v1.0"
if "%BKV_STATUS%"=="OK" (
    echo Application title set successfully
) else (
    echo Failed to set title: %BKV_ERR%
)
```

### `BKV.Remove`

**说明:**

删除一个键值对.如果键不存在,操作仍然返回成功状态.

***参数:***

1. `Key`: 删除的键名
2. `File_Name`: *(可选)* 目标`.bkv`文件名称,缺省为`_BATKV.bkv`

***返回值:***

- `BKV_STATUS`: 执行成功为`OK`,失败为`NotOK`
- `BKV_ERR`: 失败时包含错误描述,格式为`Bat-KV ERR: [错误信息]`

*示例:*

```batch
REM 从默认数据库删除临时配置
call Bat-KV.bat :BKV.Remove "temp_setting"
echo Delete status: %BKV_STATUS%

REM 从指定数据库删除过期数据
call Bat-KV.bat :BKV.Remove "session_id" "cache.bkv"

REM 批量删除示例(需要逐个调用)
call Bat-KV.bat :BKV.Remove "old_key1"
call Bat-KV.bat :BKV.Remove "old_key2"
call Bat-KV.bat :BKV.Remove "old_key3"
echo Batch deletion completed
```

### `BKV.Fetch`

**说明:**

读取一个键值对的值.这是查询数据的主要方法.

***参数:***

1. `Key`: 查找的键名
2. `File_Name`: *(可选)* 目标`.bkv`文件名称,缺省为`_BATKV.bkv`

***返回值:***

- `BKV_STATUS`: 执行成功为`OK`,失败为`NotOK`
- `BKV_RESULT`: 读取到的对应值.如果键不存在则为空字符串
- `BKV_ERR`: 失败时包含错误描述,格式为`Bat-KV ERR: [错误信息]`

*示例:*

```batch
REM 读取用户配置
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

REM 读取数值配置并进行计算
call Bat-KV.bat :BKV.Fetch "retry_count" "config.bkv"
if "%BKV_STATUS%"=="OK" (
    if not "%BKV_RESULT%"=="" (
        set /a next_retry=%BKV_RESULT%+1
        echo Next retry count: %next_retry%
    )
)

REM 读取配置项并设置默认值
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

### `BKV.Include`

**说明:**

判断文件中是否存在指定的键.用于检查配置项是否已设置.

***参数:***

1. `Key`: 被判断的键名
2. `File_Name`: *(可选)* 目标`.bkv`文件名称,缺省为`_BATKV.bkv`

***返回值:***

- `BKV_STATUS`: 执行成功为`OK`,失败为`NotOK`
- `BKV_RESULT`: 判断的结果.存在为`Yes`,不存在为`No`
- `BKV_ERR`: 失败时包含错误描述,格式为`Bat-KV ERR: [错误信息]`

*示例:*

```batch
REM 检查是否已配置数据库连接
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

REM 检查初始化状态
call Bat-KV.bat :BKV.Include "initialized" "app.bkv"
if "%BKV_STATUS%"=="OK" (
    if "%BKV_RESULT%"=="No" (
        echo Performing first-time initialization...
        call Bat-KV.bat :BKV.Append "initialized" "true" "app.bkv"
        call Bat-KV.bat :BKV.Append "install_date" "%date%" "app.bkv"
    )
)
```

## 示例程序

```batch
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
```
