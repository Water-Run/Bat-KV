@echo off
:: =====================================================
:: Test File    : Basic-Test.bat
:: Test Target  : Bat-KV basic CRUD functionality
:: Test Scope   : Create, add, query, delete, file operations
:: =====================================================

setlocal EnableDelayedExpansion

echo ===============================================
echo           Bat-KV Basic Functionality Test
echo ===============================================
echo.

:: Import Bat-KV
call Bat-KV.bat

:: Test variables
set "test_file=basic_test.bkv"
set "pass_count=0"
set "fail_count=0"
set "total_tests=0"

:: Clean up environment
if exist "%test_file%" del "%test_file%"

echo [Test 1] Create database file
call BKV.New "%test_file%"
set /a total_tests+=1
if "%BKV.New-Status%"=="OK" (
    echo ✓ Database creation successful
    set /a pass_count+=1
) else (
    echo ✗ Database creation failed
    set /a fail_count+=1
)
echo.

echo [Test 2] Add key-value pair
call BKV.Append "username" "Alice" "%test_file%"
set /a total_tests+=1
if "%BKV.Append-Status%"=="OK" (
    echo ✓ Key-value pair addition successful
    set /a pass_count+=1
) else (
    echo ✗ Key-value pair addition failed
    set /a fail_count+=1
)
echo.

echo [Test 3] Query key-value pair
call BKV.Fetch "username" "%test_file%"
set /a total_tests+=1
if "%BKV.Fetch-Status%"=="OK" (
    if "%BKV.Fetch-Result%"=="Alice" (
        echo ✓ Key-value pair query successful: %BKV.Fetch-Result%
        set /a pass_count+=1
    ) else (
        echo ✗ Query result error: Expected 'Alice', actual '%BKV.Fetch-Result%'
        set /a fail_count+=1
    )
) else (
    echo ✗ Key-value pair query failed
    set /a fail_count+=1
)
echo.

echo [Test 4] Check if key exists
call BKV.Include "username" "%test_file%"
set /a total_tests+=1
if "%BKV.Include-Status%"=="OK" (
    if "%BKV.Include-Result%"=="Yes" (
        echo ✓ Key existence check successful
        set /a pass_count+=1
    ) else (
        echo ✗ Key existence check failed: Expected 'Yes', actual '%BKV.Include-Result%'
        set /a fail_count+=1
    )
) else (
    echo ✗ Key existence check operation failed
    set /a fail_count+=1
)
echo.

echo [Test 5] Check non-existent key
call BKV.Include "nonexistent" "%test_file%"
set /a total_tests+=1
if "%BKV.Include-Status%"=="OK" (
    if "%BKV.Include-Result%"=="No" (
        echo ✓ Non-existent key check successful
        set /a pass_count+=1
    ) else (
        echo ✗ Non-existent key check failed: Expected 'No', actual '%BKV.Include-Result%'
        set /a fail_count+=1
    )
) else (
    echo ✗ Non-existent key check operation failed
    set /a fail_count+=1
)
echo.

echo [Test 6] Update existing key
call BKV.Append "username" "Bob" "%test_file%"
call BKV.Fetch "username" "%test_file%"
set /a total_tests+=1
if "%BKV.Fetch-Result%"=="Bob" (
    echo ✓ Key-value update successful: %BKV.Fetch-Result%
    set /a pass_count+=1
) else (
    echo ✗ Key-value update failed: Expected 'Bob', actual '%BKV.Fetch-Result%'
    set /a fail_count+=1
)
echo.

echo [Test 7] Delete key-value pair
call BKV.Remove "username" "%test_file%"
call BKV.Include "username" "%test_file%"
set /a total_tests+=1
if "%BKV.Include-Result%"=="No" (
    echo ✓ Key-value pair deletion successful
    set /a pass_count+=1
) else (
    echo ✗ Key-value pair deletion failed
    set /a fail_count+=1
)
echo.

echo [Test 8] Delete database file
call BKV.Erase "%test_file%"
set /a total_tests+=1
if "%BKV.Erase-Status%"=="OK" (
    if not exist "%test_file%" (
        echo ✓ Database file deletion successful
        set /a pass_count+=1
    ) else (
        echo ✗ Database file deletion failed: File still exists
        set /a fail_count+=1
    )
) else (
    echo ✗ Database file deletion operation failed
    set /a fail_count+=1
)
echo.

:: Display test results
echo ===============================================
echo                Test Results Summary
echo ===============================================
echo Total tests: %total_tests%
echo Passed: %pass_count%
echo Failed: %fail_count%
if %fail_count%==0 (
    echo Status: All passed ✓
) else (
    echo Status: Some failures ✗
)
echo ===============================================

pause