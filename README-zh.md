# Bat-KV: 为Windows批处理提供的简易KV数据库  

**`Bat-KV`是一个面向Windows批处理(`.bat`)的超轻量级单文件KV数据库.**  
`Bat-KV`的实现很简单,使用也非常的容易上手,很适合存储一些简单的数据,如配置文件等.  
**`Bat-KV`的文件存储在`.bkv`中**,是一种纯文本形式的,非常简单易读的格式,语法为`键\值`.默认路径在相对路径下的`_BATKV.bkv`.  
`Bat-KV`对**键的约束为:纯英文,数字或下划线,且不超过36个字符**.**兼容性考虑,`Bat-KV`对键和值应兼容对应平台的`ANSI`字符.**  
`Bat-KV`开源于[GitHub]().  

## 引入`Bat-KV`  

按照以下顺序操作即可在项目中引入`Bat-KV`:  

1. 从[GitHub Release]()页面下载`Bat-KV(1.0).zip`,并解压到合适的路径  
2. 将对应的`Bat-KV.bat`放到合适的路径之中  
3. 在你的`.bat`中导入该文件:  

```batch
REM 导入Bat-KV数据库功能
REM 确保Bat-KV.bat文件在当前目录或PATH环境变量指定的路径中
call Bat-KV.bat
```

> 参考本文档或阅读源码中的文档字符串,上手`Bat-KV`非常容易  

## API参考  

> 约定: `BKV.Private`开头的是内部方法,`BKV.Inner`开头的是内部变量.不要访问这些内容  

### `BKV.New`  

**说明:**  

新建一个`.bkv`文件,如果文件已存在则不会覆盖现有内容.  

***参数:***  

1. **File_Name**: *(可选)* 创建的`.bkv`文件名称,缺省为`_BATKV.bkv`  

***返回值:***  

- `BKV.New-Status`: 执行成功为`OK`,失败为`NotOK`.缺省值为`NA`.  

*示例:*  

```batch
REM 创建默认的数据库文件
call BKV.New
echo 创建状态: %BKV.New-Status%

REM 创建指定名称的数据库文件
call BKV.New "config.bkv"
if "%BKV.New-Status%"=="OK" (
    echo 数据库文件 config.bkv 创建成功
) else (
    echo 数据库文件创建失败
)
```

### `BKV.Erase`  

**说明:**  

删除一个`.bkv`文件,包括文件中的所有数据.  

***参数:***  

1. **File_Name**: *(可选)* 删除的`.bkv`文件名称,缺省为`_BATKV.bkv`  

***返回值:***  

- `BKV.Erase-Status`: 执行成功为`OK`,失败为`NotOK`.缺省值为`NA`.  

*示例:*  

```batch
REM 删除默认数据库文件
call BKV.Erase
if "%BKV.Erase-Status%"=="OK" (
    echo 默认数据库已删除
)

REM 删除指定的数据库文件
call BKV.Erase "temp.bkv"
echo 删除操作状态: %BKV.Erase-Status%
```

### `BKV.Append`  

**说明:**  

增加一个键值对.如果键已存在,则更新对应的值.  

***参数:***  

1. `Key`: 增加的键名(必须符合命名规范)  
2. `Value`: 对应的值  
3. `File_Name`: *(可选)* 目标`.bkv`文件名称,缺省为`_BATKV.bkv`  

***返回值:***  

- `BKV.Append-Status`: 执行成功为`OK`,失败为`NotOK`.缺省值为`NA`.  

*示例:*  

```batch
REM 向默认数据库添加用户名
call BKV.Append "username" "Alice"
echo 添加用户名状态: %BKV.Append-Status%

REM 向指定数据库添加配置项
call BKV.Append "max_retry" "3" "config.bkv"

REM 添加包含空格的值
call BKV.Append "app_title" "My Application v1.0"
if "%BKV.Append-Status%"=="OK" (
    echo 应用标题设置成功
)
```

### `BKV.Remove`  

**说明:**  

删除一个键值对.如果键不存在,操作仍然返回成功状态.  

***参数:***  

1. `Key`: 删除的键名  
2. `File-Name`: *(可选)* 目标`.bkv`文件名称,缺省为`_BATKV.bkv`  

***返回值:***  

- `BKV.Remove-Status`: 执行成功为`OK`,失败为`NotOK`.缺省值为`NA`.  

*示例:*  

```batch
REM 从默认数据库删除临时配置
call BKV.Remove "temp_setting"
echo 删除状态: %BKV.Remove-Status%

REM 从指定数据库删除过期数据
call BKV.Remove "session_id" "cache.bkv"

REM 批量删除示例(需要逐个调用)
call BKV.Remove "old_key1"
call BKV.Remove "old_key2"
call BKV.Remove "old_key3"
echo 批量删除完成
```

### `BKV.Fetch`  

**说明:**  

读取一个键值对的值.这是查询数据的主要方法.  

***参数:***  

1. `Key`: 查找的键名  
2. `File-Name`: *(可选)* 目标`.bkv`文件名称,缺省为`_BATKV.bkv`  

***返回值:***  

- `BKV.Fetch-Status`: 执行成功为`OK`,失败为`NotOK`.缺省值为`NA`.  
- `BKV.Fetch-Result`: 读取到的对应值.如果键不存在则为空,缺省值为`(Default)`.  

*示例:*  

```batch
REM 读取用户配置
call BKV.Fetch "username"
if "%BKV.Fetch-Status%"=="OK" (
    echo 当前用户: %BKV.Fetch-Result%
) else (
    echo 无法读取用户名
)

REM 读取数值配置并进行计算
call BKV.Fetch "retry_count" "config.bkv"
if not "%BKV.Fetch-Result%"=="" (
    set /a next_retry=%BKV.Fetch-Result%+1
    echo 下次重试次数: %next_retry%
)

REM 读取配置项并设置默认值
call BKV.Fetch "theme"
if "%BKV.Fetch-Result%"=="" (
    set current_theme=default
    echo 使用默认主题
) else (
    set current_theme=%BKV.Fetch-Result%
    echo 当前主题: %current_theme%
)
```

### `BKV.Include`  

**说明:**  

判断文件中是否存在指定的键.用于检查配置项是否已设置.  

***参数:***  

1. `Key`: 被判断的键名  
2. `File-Name`: *(可选)* 目标`.bkv`文件名称,缺省为`_BATKV.bkv`  

***返回值:***  

- `BKV.Include-Status`: 执行成功为`OK`,失败为`NotOK`.缺省值为`NA`.  
- `BKV.Include-Result`: 判断的结果.存在为`Yes`,不存在为`No`,缺省值为`(Default)`.  

*示例:*  

```batch
REM 检查是否已配置数据库连接
call BKV.Include "db_host"
if "%BKV.Include-Result%"=="Yes" (
    echo 数据库配置已存在
    call BKV.Fetch "db_host"
    echo 数据库主机: %BKV.Fetch-Result%
) else (
    echo 请先配置数据库连接
    call BKV.Append "db_host" "localhost"
)

REM 检查初始化状态
call BKV.Include "initialized" "app.bkv"
if "%BKV.Include-Status%"=="OK" (
    if "%BKV.Include-Result%"=="No" (
        echo 执行首次初始化...
        call BKV.Append "initialized" "true" "app.bkv"
        call BKV.Append "install_date" "%date%" "app.bkv"
    )
)
```

### `BKV.Grep`  

**说明:**  

匹配符合正则表达式的键,返回键值对列表.适用于批量查询和模糊搜索.  

> **正则表达式使用`findstr`实现**,正则表达式为非完整实现,支持基本的模式匹配  

> 返回的键值对列表(以字符串形式实现)格式说明:(本质上**和存储在`.bkv`内的文本内容一致**)  
>> [键1]\[值1]  
>> [键2]\[值2]  
>> ...  
>> [最后一个键]\[最后一个值]

***参数:***  

1. `Match-Regex`: 匹配的正则表达式  
2. `File-Name`: *(可选)* 目标`.bkv`文件名称,缺省为`_BATKV.bkv`  

***返回值:***  

- `BKV.Grep-Result`: 匹配到的键值对,以前文所述的格式表示.缺省值为`(Default)`.  
- `BKV.Grep-Status`: 执行成功为`OK`,失败为`NotOK`.缺省值为`NA`.  

*示例:*  

```batch
REM 查找所有以"user"开头的配置项
call BKV.Grep "^user"
if "%BKV.Grep-Status%"=="OK" (
    echo 用户相关配置:
    echo %BKV.Grep-Result%
)

REM 查找包含"temp"的所有键
call BKV.Grep "temp" "cache.bkv"
echo 临时数据: %BKV.Grep-Result%

REM 查找所有数字结尾的键(使用findstr正则语法)
call BKV.Grep "[0-9]$"
if not "%BKV.Grep-Result%"=="" (
    echo 找到以数字结尾的键:
    echo %BKV.Grep-Result%
) else (
    echo 未找到匹配的键
)

REM 将匹配结果保存到临时文件进行进一步处理
call BKV.Grep "config_" > temp_config.txt
echo 配置项已导出到 temp_config.txt
```

## 示例程序  

```batch
:: =====================================================
:: File      : Demo-Batch.bat
:: Author    : WaterRun
:: Description:
::   Bat-KV示例程序: 一个带历史记录功能的简单纯文本阅读器.
::   支持设置软件的使用者,以及获取最近对应文件载入时间等历史信息
::   
::   功能说明:
::   1. 用户管理: 设置和显示当前用户名
::   2. 文件历史: 记录最近打开的文件及访问时间
::   3. 阅读统计: 统计用户的文件阅读次数
::   4. 配置管理: 保存用户偏好设置
:: =====================================================

@echo off
setlocal EnableDelayedExpansion

REM 导入Bat-KV数据库功能
call Bat-KV.bat

REM 初始化应用数据库文件
call BKV.New "reader_app.bkv"

:MAIN_MENU
cls
echo ================================
echo    纯文本阅读器 v1.0
echo    Powered by Bat-KV Database
echo ================================
echo.

REM 显示当前用户信息
call BKV.Fetch "current_user" "reader_app.bkv"
if "%BKV.Fetch-Status%"=="OK" (
    if not "%BKV.Fetch-Result%"=="" (
        echo 当前用户: %BKV.Fetch-Result%
    ) else (
        echo 当前用户: 未设置
    )
) else (
    echo 当前用户: 未设置
)

echo.
echo 1. 设置用户名
echo 2. 打开文件阅读
echo 3. 查看阅读历史
echo 4. 查看阅读统计
echo 5. 清除所有数据
echo 0. 退出程序
echo.
set /p choice="请选择操作 (0-5): "

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
echo         设置用户名
echo ================================
echo.
set /p username="请输入用户名: "

REM 验证用户名不为空
if "%username%"=="" (
    echo 用户名不能为空!
    pause
    goto MAIN_MENU
)

REM 保存用户名到数据库
call BKV.Append "current_user" "%username%" "reader_app.bkv"
if "%BKV.Append-Status%"=="OK" (
    echo 用户名设置成功: %username%
    
    REM 记录用户设置时间
    call BKV.Append "user_set_time" "%date% %time%" "reader_app.bkv"
) else (
    echo 用户名设置失败!
)
pause
goto MAIN_MENU

:READ_FILE
cls
echo ================================
echo         打开文件阅读
echo ================================
echo.
set /p filename="请输入文件路径: "

REM 检查文件是否存在
if not exist "%filename%" (
    echo 文件不存在: %filename%
    pause
    goto MAIN_MENU
)

REM 显示文件内容
echo.
echo --- 文件内容 ---
type "%filename%"
echo.
echo --- 文件结束 ---
echo.

REM 记录文件访问历史
call BKV.Append "last_file" "%filename%" "reader_app.bkv"
call BKV.Append "last_access_time" "%date% %time%" "reader_app.bkv"

REM 更新该文件的访问次数
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

REM 更新总阅读次数
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

echo 文件已读取完毕, 访问记录已保存
pause
goto MAIN_MENU

:VIEW_HISTORY
cls
echo ================================
echo         阅读历史记录
echo ================================
echo.

REM 显示最后访问的文件
call BKV.Fetch "last_file" "reader_app.bkv"
if "%BKV.Fetch-Status%"=="OK" (
    if not "%BKV.Fetch-Result%"=="" (
        echo 最后阅读文件: %BKV.Fetch-Result%
        
        REM 显示访问时间
        call BKV.Fetch "last_access_time" "reader_app.bkv"
        if not "%BKV.Fetch-Result%"=="" (
            echo 访问时间: %BKV.Fetch-Result%
        )
        
        REM 显示该文件的访问次数
        call BKV.Fetch "count_%BKV.Fetch-Result: =_%" "reader_app.bkv"
        if not "%BKV.Fetch-Result%"=="" (
            echo 该文件访问次数: %BKV.Fetch-Result%
        )
    ) else (
        echo 暂无阅读历史
    )
) else (
    echo 暂无阅读历史
)

echo.
echo --- 所有历史记录 ---
REM 使用正则表达式查找所有计数记录
call BKV.Grep "^count_" "reader_app.bkv"
if "%BKV.Grep-Status%"=="OK" (
    if not "%BKV.Grep-Result%"=="" (
        echo %BKV.Grep-Result%
    ) else (
        echo 暂无详细记录
    )
) else (
    echo 无法获取历史记录
)

pause
goto MAIN_MENU

:VIEW_STATS
cls
echo ================================
echo         阅读统计信息
echo ================================
echo.

REM 显示当前用户
call BKV.Fetch "current_user" "reader_app.bkv"
if not "%BKV.Fetch-Result%"=="" (
    echo 用户: %BKV.Fetch-Result%
    
    REM 显示用户设置时间
    call BKV.Fetch "user_set_time" "reader_app.bkv"
    if not "%BKV.Fetch-Result%"=="" (
        echo 用户设置时间: %BKV.Fetch-Result%
    )
)

REM 显示总阅读次数
call BKV.Fetch "total_reads" "reader_app.bkv"
if "%BKV.Fetch-Status%"=="OK" (
    if not "%BKV.Fetch-Result%"=="" (
        echo 总阅读次数: %BKV.Fetch-Result%
    ) else (
        echo 总阅读次数: 0
    )
) else (
    echo 总阅读次数: 0
)

REM 显示最后访问信息
call BKV.Fetch "last_access_time" "reader_app.bkv"
if not "%BKV.Fetch-Result%"=="" (
    echo 最后访问时间: %BKV.Fetch-Result%
)

echo.
echo --- 详细统计 ---
REM 显示所有配置信息
call BKV.Grep "." "reader_app.bkv"
if "%BKV.Grep-Status%"=="OK" (
    echo 数据库中的所有记录:
    echo %BKV.Grep-Result%
)

pause
goto MAIN_MENU

:CLEAR_DATA
cls
echo ================================
echo         清除所有数据
echo ================================
echo.
echo 警告: 此操作将删除所有用户数据和阅读记录!
set /p confirm="确认删除吗? (y/N): "

if /i "%confirm%"=="y" (
    call BKV.Erase "reader_app.bkv"
    if "%BKV.Erase-Status%"=="OK" (
        echo 所有数据已清除
        
        REM 重新创建空的数据库文件
        call BKV.New "reader_app.bkv"
    ) else (
        echo 数据清除失败
    )
) else (
    echo 操作已取消
)

pause
goto MAIN_MENU

:EXIT
cls
echo 谢谢使用纯文本阅读器!
echo.

REM 显示退出统计
call BKV.Fetch "total_reads" "reader_app.bkv"
if not "%BKV.Fetch-Result%"=="" (
    echo 本次会话总计阅读: %BKV.Fetch-Result% 个文件
)

echo 再见!
pause
exit /b 0
```
