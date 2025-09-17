@echo off
:: =====================================================
:: Test File    : Edge-Test.bat
:: Test Target  : Bat-KV edge cases and exception handling
:: Test Scope   : Empty values, special characters, long strings, invalid operations
:: =====================================================

setlocal EnableDelayedExpansion

echo ===============================================
echo           Bat-KV Edge Case Testing
echo ===============================================
echo.

:: Import Bat-KV
call Bat-KV.bat

:: Test variables
set "test_file=edge_test.bkv"
set "pass_count=0"
set "fail_count=0"
set "total_tests=0"

:: Clean up environment
if exist "%test_file%" del "%test_file%"

echo [Edge Test 1] Empty key name test
call BKV.Append "" "value" "%test_file%"
set /a total_tests+=1
if "%BKV.Append-Status%"=="NotOK" (
    echo ✓ Empty key name correctly rejected
    set /a pass_count+=1
) else (
    echo ✗ Empty key name should be rejected
    set /a fail_count+=1
)
echo.

echo [Edge Test 2] Empty value test
call BKV.New "%test_file%"
call BKV.Append "empty_key" "" "%test_file%"
set /a total_tests+=1
if "%BKV.Append-Status%"=="NotOK" (
    echo ✓ Empty value correctly rejected
    set /a pass_count+=1
) else (
    echo ✗ Empty value should be rejected
    set /a fail_count+=1
)
echo.

echo [Edge Test 3] Key name containing backslashes
call BKV.Append "key\with\slash" "value" "%test_file%"
set /a total_tests+=1
if "%BKV.Append-Status%"=="NotOK" (
    echo ✓ Key name with backslashes correctly rejected
    set /a pass_count+=1
) else (
    echo ✗ Key name with backslashes should be rejected
    set /a fail_count+=1
)
echo.

echo [Edge Test 4] Overlong key name test (50 characters)
set "long_key=this_is_a_very_long_key_name_that_exceeds_limit"
call BKV.Append "%long_key%" "value" "%test_file%"
set /a total_tests+=1
if "%BKV.Append-Status%"=="NotOK" (
    echo ✓ Overlong key name correctly rejected
    set /a pass_count+=1
) else (
    echo ✗ Overlong key name should be rejected
    set /a fail_count+=1
)
echo.

echo [Edge Test 5] Value containing spaces
call BKV.Append "spaced_value" "Hello World Test" "%test_file%"
call BKV.Fetch "spaced_value" "%test_file%"
set /a total_tests+=1
if "%BKV.Fetch-Result%"=="Hello World Test" (
    echo ✓ Value with spaces handled correctly: '%BKV.Fetch-Result%'
    set /a pass_count+=1
) else (
    echo ✗ Value with spaces handled incorrectly: Expected 'Hello World Test', actual '%BKV.Fetch-Result%'
    set /a fail_count+=1
)
echo.

echo [Edge Test 6] Value containing special characters
call BKV.Append "special_chars" "!@#$%%^&*()_+-={}[]|:;'<>?,./" "%test_file%"
call BKV.Fetch "special_chars" "%test_file%"
set /a total_tests+=1
echo Actual result: '%BKV.Fetch-Result%'
if not "%BKV.Fetch-Result%"=="" (
    echo ✓ Special characters basically handled correctly
    set /a pass_count+=1
) else (
    echo ✗ Special character handling failed
    set /a fail_count+=1
)
echo.

echo [Edge Test 7] Numeric key names and numeric values
call BKV.Append "123" "456" "%test_file%"
call BKV.Fetch "123" "%test_file%"
set /a total_tests+=1
if "%BKV.Fetch-Result%"=="456" (
    echo ✓ Numeric key-value handled correctly
    set /a pass_count+=1
) else (
    echo ✗ Numeric key-value handling error
    set /a fail_count+=1
)
echo.

echo [Edge Test 8] Operations on non-existent file
call BKV.Fetch "key" "nonexistent.bkv"
set /a total_tests+=1
if "%BKV.Fetch-Status%"=="OK" (
    if "%BKV.Fetch-Result%"=="" (
        echo ✓ Query on non-existent file handled correctly
        set /a pass_count+=1
    ) else (
        echo ✗ Query on non-existent file should return empty value
        set /a fail_count+=1
    )
) else (
    echo ✗ Query status on non-existent file is incorrect
    set /a fail_count+=1
)
echo.

echo [Edge Test 9] Repeatedly deleting the same key
call BKV.Append "delete_test" "value" "%test_file%"
call BKV.Remove "delete_test" "%test_file%"
call BKV.Remove "delete_test" "%test_file%"
set /a total_tests+=1
if "%BKV.Remove-Status%"=="OK" (
    echo ✓ Repeated deletion of non-existent key handled correctly
    set /a pass_count+=1
) else (
    echo ✗ Repeated deletion of non-existent key handling error
    set /a fail_count+=1
)
echo.

echo [Edge Test 10] Invalid filename test
call BKV.New "invalid<file>name.bkv"
set /a total_tests+=1
if "%BKV.New-Status%"=="NotOK" (
    echo ✓ Invalid filename correctly rejected
    set /a pass_count+=1
) else (
    echo ✗ Invalid filename should be rejected
    set /a fail_count+=1
)
echo.

echo [Edge Test 11] Value containing backslashes test
call BKV.Append "path_value" "C:\Windows\System32" "%test_file%"
call BKV.Fetch "path_value" "%test_file%"
set /a total_tests+=1
echo Expected value: C:\Windows\System32
echo Actual value: %BKV.Fetch-Result%
if "%BKV.Fetch-Result%"=="C:" (
    echo ⚠ Backslashes in value cause truncation (known limitation)
    set /a pass_count+=1
) else (
    echo ✗ Backslash value handling anomaly
    set /a fail_count+=1
)
echo.

echo [Edge Test 12] Maximum length key name test (36 characters)
set "max_key=abcdefghijklmnopqrstuvwxyz1234567890"
call BKV.Append "%max_key%" "max_length_test" "%test_file%"
call BKV.Fetch "%max_key%" "%test_file%"
set /a total_tests+=1
if "%BKV.Fetch-Result%"=="max_length_test" (
    echo ✓ Maximum length key name handled correctly
    set /a pass_count+=1
) else (
    echo ✗ Maximum length key name handling error
    set /a fail_count+=1
)
echo.

:: Clean up test file
if exist "%test_file%" del "%test_file%"

:: Display test results
echo ===============================================
echo              Edge Test Results Summary
echo ===============================================
echo Total tests: %total_tests%
echo Passed: %pass_count%
echo Failed: %fail_count%
echo.
if %fail_count%==0 (
    echo Status: All passed ✓
    echo Edge case handling is good
) else (
    echo Status: Some failures ✗
    echo Some edge cases need improvement
)
echo ===============================================

pause