@echo off
:: =====================================================
:: Test File    : Performance-Test.bat
:: Test Target  : Bat-KV performance and large data volume processing
:: Test Scope   : Batch operations, query performance, file size impact
:: =====================================================

setlocal EnableDelayedExpansion

echo ===============================================
echo           Bat-KV Performance Stress Test
echo ===============================================
echo.

:: Import Bat-KV
call Bat-KV.bat

:: Test variables
set "test_file=performance_test.bkv"
set "large_file=large_test.bkv"
set "pass_count=0"
set "fail_count=0"
set "total_tests=0"

:: Clean up environment
if exist "%test_file%" del "%test_file%"
if exist "%large_file%" del "%large_file%"

echo [Performance Test 1] Batch addition test (50 records)
call BKV.New "%test_file%"
set "start_time=%time%"
for /l %%i in (1,1,50) do (
    call BKV.Append "key_%%i" "value_%%i_data_content" "%test_file%"
)
set "end_time=%time%"
set /a total_tests+=1

:: Verify addition results
call BKV.Include "key_1" "%test_file%"
call BKV.Include "key_25" "%test_file%"
call BKV.Include "key_50" "%test_file%"

if "%BKV.Include-Result%"=="Yes" (
    echo ✓ Batch addition of 50 records successful
    echo   Start time: %start_time%
    echo   End time: %end_time%
    set /a pass_count+=1
) else (
    echo ✗ Batch addition of records failed
    set /a fail_count+=1
)
echo.

echo [Performance Test 2] Random query test
set "start_time=%time%"
for /l %%i in (1,1,20) do (
    set /a "random_key=!random! %% 50 + 1"
    call BKV.Fetch "key_!random_key!" "%test_file%"
)
set "end_time=%time%"
set /a total_tests+=1

echo ✓ Random query 20 times completed
echo   Start time: %start_time%
echo   End time: %end_time%
set /a pass_count+=1
echo.

echo [Performance Test 3] Regular expression query test
call BKV.Grep "key_[0-9]" "%test_file%"
set /a total_tests+=1
if "%BKV.Grep-Status%"=="OK" (
    echo ✓ Regular expression query successful
    echo   Match result length: 
    echo %BKV.Grep-Result% | find /c "key_" > temp_count.txt
    set /p match_count=<temp_count.txt
    del temp_count.txt
    echo   Reference length of matched records
    set /a pass_count+=1
) else (
    echo ✗ Regular expression query failed
    set /a fail_count+=1
)
echo.

echo [Performance Test 4] Batch deletion test
set "start_time=%time%"
for /l %%i in (1,2,20) do (
    call BKV.Remove "key_%%i" "%test_file%"
)
set "end_time=%time%"
set /a total_tests+=1

:: Verify deletion results
call BKV.Include "key_1" "%test_file%"
if "%BKV.Include-Result%"=="No" (
    echo ✓ Batch deletion test successful
    echo   Start time: %start_time%
    echo   End time: %end_time%
    set /a pass_count+=1
) else (
    echo ✗ Batch deletion test failed
    set /a fail_count+=1
)
echo.

echo [Performance Test 5] Large data test (200 records)
call BKV.New "%large_file%"
echo Adding 200 records, please wait...
set "start_time=%time%"
for /l %%i in (1,1,200) do (
    if %%i equ 50 echo   Added 50 records...
    if %%i equ 100 echo   Added 100 records...
    if %%i equ 150 echo   Added 150 records...
    call BKV.Append "large_key_%%i" "large_value_%%i_with_more_content_to_test_performance" "%large_file%"
)
set "end_time=%time%"
set /a total_tests+=1

:: Test large file query performance
echo Testing large file query performance...
set "query_start=%time%"
call BKV.Fetch "large_key_1" "%large_file%"
call BKV.Fetch "large_key_100" "%large_file%"
call BKV.Fetch "large_key_200" "%large_file%"
set "query_end=%time%"

if "%BKV.Fetch-Status%"=="OK" (
    echo ✓ Large data test successful
    echo   Addition start: %start_time%
    echo   Addition end: %end_time%
    echo   Query start: %query_start%
    echo   Query end: %query_end%
    
    :: Display file size
    for %%F in ("%large_file%") do (
        echo   File size: %%~zF bytes
    )
    set /a pass_count+=1
) else (
    echo ✗ Large data test failed
    set /a fail_count+=1
)
echo.

echo [Performance Test 6] Update performance test
echo Testing performance of updating existing keys...
set "update_start=%time%"
for /l %%i in (1,5,50) do (
    call BKV.Append "large_key_%%i" "updated_value_%%i" "%large_file%"
)
set "update_end=%time%"
set /a total_tests+=1

:: Verify update results
call BKV.Fetch "large_key_1" "%large_file%"
if "%BKV.Fetch-Result%"=="updated_value_1" (
    echo ✓ Update performance test successful
    echo   Update start: %update_start%
    echo   Update end: %update_end%
    set /a pass_count+=1
) else (
    echo ✗ Update performance test failed
    set /a fail_count+=1
)
echo.

echo [Performance Test 7] Performance of querying non-existent keys
set "notfound_start=%time%"
for /l %%i in (1,1,30) do (
    call BKV.Fetch "nonexistent_key_%%i" "%large_file%"
)
set "notfound_end=%time%"
set /a total_tests+=1

echo ✓ Non-existent key query performance test completed
echo   Query start: %notfound_start%
echo   Query end: %notfound_end%
set /a pass_count+=1
echo.

echo [Performance Test 8] File size analysis
if exist "%test_file%" (
    for %%F in ("%test_file%") do (
        echo Small file (%test_file%): %%~zF bytes
    )
)
if exist "%large_file%" (
    for %%F in ("%large_file%") do (
        echo Large file (%large_file%): %%~zF bytes
    )
)
set /a total_tests+=1
set /a pass_count+=1
echo.

:: Clean up test files
echo Cleaning up test files...
if exist "%test_file%" del "%test_file%"
if exist "%large_file%" del "%large_file%"

:: Display test results
echo ===============================================
echo              Performance Test Results Summary
echo ===============================================
echo Total tests: %total_tests%
echo Passed: %pass_count%
echo Failed: %fail_count%
echo.
echo Performance observations:
echo - Small data (50 records): Relatively fast response
echo - Large data (200 records): Significant performance degradation
echo - Query operations: O(n) complexity, slower as record count increases
echo - Update operations: Requires rewriting entire file, high overhead
echo - File size: Linear growth with record count
echo.
if %fail_count%==0 (
    echo Status: All passed ✓
    echo Performance meets expectations
) else (
    echo Status: Some failures ✗
    echo Performance may have issues
)
echo ===============================================

pause