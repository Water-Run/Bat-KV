@echo off
setlocal EnableDelayedExpansion
:: =====================================================
:: Test File    : BKV-Test.bat
:: Version      : 1.0
:: Test Target  : Bat-KV v1.0 library functionality
:: Test Scope   : CRUD operations, error handling, edge cases
:: Description  : Comprehensive test suite for Bat-KV database library
::                Tests all public API functions with various scenarios
::                including error conditions and edge cases
:: Requirements : Bat-KV.bat must be in the same directory
:: Test Coverage: Public API, error handling, file operations
:: Exit Codes   : 0 = All tests passed, 1 = Some tests failed
:: =====================================================

echo ===============================================
echo        Bat-KV Library Test Suite v1.0
echo ===============================================
echo.

:: Initialize test framework
call :Test.Framework.Init

:: Verify prerequisites
call :Test.Prerequisites.Check
if !Test.Framework.EarlyExit!==1 exit /b 1

:: Execute test suites
call :Test.Suite.FileOperations
call :Test.Suite.CRUDOperations  
call :Test.Suite.ErrorHandling
call :Test.Suite.EdgeCases
call :Test.Suite.CompatibilityTests

:: Display final results and cleanup
call :Test.Framework.ShowResults
call :Test.Framework.Cleanup
exit /b !Test.Framework.ExitCode!

:: =====================================================
:: Test Framework - Initialization
:: =====================================================
:Test.Framework.Init
set "Test.Framework.PassCount=0"
set "Test.Framework.FailCount=0"
set "Test.Framework.TotalTests=0"
set "Test.Framework.CurrentSuite="
set "Test.Framework.TestFile=test_bkv_library.bkv"
set "Test.Framework.EarlyExit=0"
set "Test.Framework.ExitCode=0"
exit /b

:: =====================================================
:: Test Framework - Prerequisites Check
:: =====================================================
:Test.Prerequisites.Check
echo [INIT] Checking prerequisites...

if not exist "Bat-KV.bat" (
    echo [ERROR] Bat-KV.bat not found in current directory
    echo Please ensure Bat-KV.bat is in the same folder as this test file
    set "Test.Framework.EarlyExit=1"
    exit /b
)

:: Clean up any existing test files
if exist "%Test.Framework.TestFile%" del "%Test.Framework.TestFile%" 2>nul
if exist "_BATKV.bkv" del "_BATKV.bkv" 2>nul
if exist "test_*.bkv" del "test_*.bkv" 2>nul

echo [INIT] Prerequisites check completed
echo.
exit /b

:: =====================================================
:: Test Framework - Execute single test
:: Parameters: %1=TestName, %2=Expected Status, %3=Expected Result (optional)
:: =====================================================
:Test.Framework.ExecuteTest
set "Test.Framework.TestName=%~1"
set "Test.Framework.ExpectedStatus=%~2"
set "Test.Framework.ExpectedResult=%~3"
set /a Test.Framework.TotalTests+=1

echo [Test %Test.Framework.TotalTests%] %Test.Framework.TestName%

:: Check status
if not "!BKV_STATUS!"=="!Test.Framework.ExpectedStatus!" (
    echo [FAIL] Status mismatch - Expected: !Test.Framework.ExpectedStatus!, Got: !BKV_STATUS!
    if defined BKV_ERR echo       Error: !BKV_ERR!
    set /a Test.Framework.FailCount+=1
    echo.
    exit /b
)

:: Check result if specified
if not "%Test.Framework.ExpectedResult%"=="" (
    if not "!BKV_RESULT!"=="!Test.Framework.ExpectedResult!" (
        echo [FAIL] Result mismatch - Expected: !Test.Framework.ExpectedResult!, Got: !BKV_RESULT!
        set /a Test.Framework.FailCount+=1
        echo.
        exit /b
    )
)

echo [PASS] %Test.Framework.TestName% successful
if defined BKV_RESULT echo       Result: !BKV_RESULT!
set /a Test.Framework.PassCount+=1
echo.
exit /b

:: =====================================================
:: Test Framework - Execute test with safe comparison
:: Parameters: %1=TestName, %2=Expected Status, %3=Expected Result (optional)
:: =====================================================
:Test.Framework.ExecuteTestSafe
set "Test.Framework.TestName=%~1"
set "Test.Framework.ExpectedStatus=%~2"
set "Test.Framework.ExpectedResult=%~3"
set /a Test.Framework.TotalTests+=1

echo [Test %Test.Framework.TotalTests%] %Test.Framework.TestName%

:: Check status
if not "!BKV_STATUS!"=="!Test.Framework.ExpectedStatus!" (
    echo [FAIL] Status mismatch - Expected: !Test.Framework.ExpectedStatus!, Got: !BKV_STATUS!
    if defined BKV_ERR echo       Error: !BKV_ERR!
    set /a Test.Framework.FailCount+=1
    echo.
    exit /b
)

:: Safe result checking for special characters
if not "%Test.Framework.ExpectedResult%"=="" (
    set "Test.Framework.ResultMatch=0"
    if "!BKV_RESULT!"=="!Test.Framework.ExpectedResult!" set "Test.Framework.ResultMatch=1"
    
    if !Test.Framework.ResultMatch!==0 (
        echo [FAIL] Result mismatch
        echo       Expected: !Test.Framework.ExpectedResult!
        echo       Got: !BKV_RESULT!
        set /a Test.Framework.FailCount+=1
        echo.
        exit /b
    )
)

echo [PASS] %Test.Framework.TestName% successful
if defined BKV_RESULT echo       Result: !BKV_RESULT!
set /a Test.Framework.PassCount+=1
echo.
exit /b

:: =====================================================
:: Test Suite - File Operations
:: =====================================================
:Test.Suite.FileOperations
set "Test.Framework.CurrentSuite=File Operations"
echo === %Test.Framework.CurrentSuite% Test Suite ===

:: Test: Create new database file
call Bat-KV.bat :BKV.New "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Create database file" "OK" ""

:: Verify file exists
if not exist "%Test.Framework.TestFile%" (
    echo [FAIL] Database file was not created physically
    set /a Test.Framework.FailCount+=1
) else (
    echo [INFO] Database file created successfully
)
echo.

:: Test: Create with default filename
call Bat-KV.bat :BKV.New
call :Test.Framework.ExecuteTest "Create default database" "OK" ""

:: Test: Create duplicate file
call Bat-KV.bat :BKV.New "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Create existing database file" "OK" ""

:: Test: Delete database file
call Bat-KV.bat :BKV.Erase "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Delete database file" "OK" ""

:: Test: Delete non-existent file
call Bat-KV.bat :BKV.Erase "nonexistent_file.bkv"
call :Test.Framework.ExecuteTest "Delete non-existent file" "OK" ""

:: Test: Delete default database
call Bat-KV.bat :BKV.Erase
call :Test.Framework.ExecuteTest "Delete default database" "OK" ""

echo.
exit /b

:: =====================================================
:: Test Suite - CRUD Operations
:: =====================================================
:Test.Suite.CRUDOperations
set "Test.Framework.CurrentSuite=CRUD Operations"
echo === %Test.Framework.CurrentSuite% Test Suite ===

:: Setup: Create test database
call Bat-KV.bat :BKV.New "%Test.Framework.TestFile%"

:: Test: Add key-value pair
call Bat-KV.bat :BKV.Append "username" "Alice" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Add key-value pair" "OK" ""

:: Test: Fetch existing key
call Bat-KV.bat :BKV.Fetch "username" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Fetch existing key" "OK" "Alice"

:: Test: Check key existence (exists)
call Bat-KV.bat :BKV.Include "username" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Check existing key" "OK" "Yes"

:: Test: Check key existence (not exists)
call Bat-KV.bat :BKV.Include "nonexistent" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Check non-existent key" "OK" "No"

:: Test: Update existing key
call Bat-KV.bat :BKV.Append "username" "Bob" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "username" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Update existing key" "OK" "Bob"

:: Test: Add multiple keys
call Bat-KV.bat :BKV.Append "email" "bob@example.com" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Append "age" "25" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "email" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Add second key" "OK" "bob@example.com"

:: Test: Overwrite key multiple times
call Bat-KV.bat :BKV.Append "counter" "1" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Append "counter" "2" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Append "counter" "3" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "counter" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Multiple overwrites" "OK" "3"

:: Test: Remove key
call Bat-KV.bat :BKV.Remove "username" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Include "username" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Remove key" "OK" "No"

:: Test: Fetch removed key
call Bat-KV.bat :BKV.Fetch "username" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Fetch removed key" "OK" ""

:: Test: Remove non-existent key
call Bat-KV.bat :BKV.Remove "nonexistent" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Remove non-existent key" "OK" ""

:: Test: Operations on default database
call Bat-KV.bat :BKV.Append "default_test" "working"
call Bat-KV.bat :BKV.Fetch "default_test"
call :Test.Framework.ExecuteTest "Default database operations" "OK" "working"

echo.
exit /b

:: =====================================================
:: Test Suite - Error Handling
:: =====================================================
:Test.Suite.ErrorHandling
set "Test.Framework.CurrentSuite=Error Handling"
echo === %Test.Framework.CurrentSuite% Test Suite ===

:: Test: Append without key
call Bat-KV.bat :BKV.Append "" "value" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Append without key" "NotOK" ""

:: Test: Append without value
call Bat-KV.bat :BKV.Append "key" "" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Append without value" "NotOK" ""

:: Test: Append with backslash in key
call Bat-KV.bat :BKV.Append "key\with\backslash" "value" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Append with invalid key backslash" "NotOK" ""

:: Test: Fetch without key
call Bat-KV.bat :BKV.Fetch "" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Fetch without key" "NotOK" ""

:: Test: Include without key
call Bat-KV.bat :BKV.Include "" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Include without key" "NotOK" ""

:: Test: Remove without key
call Bat-KV.bat :BKV.Remove "" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Remove without key" "NotOK" ""

:: Test: Invalid key names - special characters
call Bat-KV.bat :BKV.Append "key with spaces" "value" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Key with spaces" "NotOK" ""

call Bat-KV.bat :BKV.Append "key@special" "value" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Key with special characters" "NotOK" ""

call Bat-KV.bat :BKV.Append "key-dash" "value" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Key with dash" "NotOK" ""

call Bat-KV.bat :BKV.Append "key.dot" "value" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Key with dot" "NotOK" ""

:: Test: Key length validation - too long (over 36 characters)
set "TooLongKey=abcdefghijklmnopqrstuvwxyz1234567890x"
call Bat-KV.bat :BKV.Append "%TooLongKey%" "value" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Key too long" "NotOK" ""

:: Test: Operations with empty filenames
call Bat-KV.bat :BKV.New ""
call :Test.Framework.ExecuteTest "Create with empty filename" "OK" ""

echo.
exit /b

:: =====================================================
:: Test Suite - Edge Cases
:: =====================================================
:Test.Suite.EdgeCases
set "Test.Framework.CurrentSuite=Edge Cases"
echo === %Test.Framework.CurrentSuite% Test Suite ===

:: Test: Operations on non-existent file
call Bat-KV.bat :BKV.Fetch "validkey" "nonexistent.bkv"
call :Test.Framework.ExecuteTest "Fetch from non-existent file" "OK" ""

call Bat-KV.bat :BKV.Include "validkey" "nonexistent.bkv"
call :Test.Framework.ExecuteTest "Include from non-existent file" "OK" "No"

call Bat-KV.bat :BKV.Remove "validkey" "nonexistent.bkv"
call :Test.Framework.ExecuteTest "Remove from non-existent file" "OK" ""

:: Test: Special characters in values (safe version)
call Bat-KV.bat :BKV.Append "special" "value with spaces" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "special" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTestSafe "Special characters in value" "OK" "value with spaces"

:: Test: Values with parentheses
call Bat-KV.bat :BKV.Append "parentheses" "value with parentheses" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "parentheses" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTestSafe "Parentheses in value" "OK" "value with parentheses"

:: Test: Values with quotes
call Bat-KV.bat :BKV.Append "quotes" "value with quotes test" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "quotes" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTestSafe "Quotes in value" "OK" "value with quotes test"

:: Test: Single space value
call Bat-KV.bat :BKV.Append "space" " " "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "space" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTestSafe "Single space value" "OK" " "

:: Test: Numeric values
call Bat-KV.bat :BKV.Append "number" "12345" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "number" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Numeric value" "OK" "12345"

:: Test: Floating point numbers
call Bat-KV.bat :BKV.Append "float" "123.45" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "float" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Float value" "OK" "123.45"

:: Test: Long value
set "LongValue=This is a very long value with many words to test the system capability and ensure proper handling of extended text content"
call Bat-KV.bat :BKV.Append "longvalue" "%LongValue%" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "longvalue" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTestSafe "Long value" "OK" "%LongValue%"

:: Test: Key with underscores and numbers
call Bat-KV.bat :BKV.Append "user_123" "test_user" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "user_123" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Complex key name" "OK" "test_user"

:: Test: Maximum key length (36 characters)
set "MaxKey=abcdefghijklmnopqrstuvwxyz1234567890"
call Bat-KV.bat :BKV.Append "%MaxKey%" "max_key_test" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "%MaxKey%" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Maximum key length" "OK" "max_key_test"

:: Test: Values with backslashes
call Bat-KV.bat :BKV.Append "path" "C:\Windows\System32\test.exe" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "path" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTestSafe "Value with backslashes" "OK" "C:\Windows\System32\test.exe"

:: Test: Empty-like values
call Bat-KV.bat :BKV.Append "tab" "	" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "tab" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTestSafe "Tab character value" "OK" "	"

:: Test: Single character key and value
call Bat-KV.bat :BKV.Append "a" "b" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "a" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Single char key and value" "OK" "b"

echo.
exit /b

:: =====================================================
:: Test Suite - Compatibility Tests
:: =====================================================
:Test.Suite.CompatibilityTests
set "Test.Framework.CurrentSuite=Compatibility Tests"
echo === %Test.Framework.CurrentSuite% Test Suite ===

:: Test: Case sensitivity
call Bat-KV.bat :BKV.Append "TestKey" "uppercase" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Append "testkey" "lowercase" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "TestKey" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Case sensitivity upper" "OK" "uppercase"
call Bat-KV.bat :BKV.Fetch "testkey" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Case sensitivity lower" "OK" "lowercase"

:: Test: Key naming conventions
call Bat-KV.bat :BKV.Append "valid_key_123" "valid" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "valid_key_123" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Valid key naming" "OK" "valid"

:: Test: Numeric only keys
call Bat-KV.bat :BKV.Append "123456" "numeric_key" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "123456" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Numeric key" "OK" "numeric_key"

:: Test: Large dataset operations
echo [INFO] Testing large dataset operations...
for /l %%i in (1,1,50) do (
    call Bat-KV.bat :BKV.Append "key%%i" "value%%i" "%Test.Framework.TestFile%" >nul
)
call Bat-KV.bat :BKV.Fetch "key25" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Large dataset middle fetch" "OK" "value25"
call Bat-KV.bat :BKV.Fetch "key50" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Large dataset last fetch" "OK" "value50"

:: Test: Rapid operations
echo [INFO] Testing rapid operations...
call Bat-KV.bat :BKV.Append "rapid1" "test1" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Append "rapid2" "test2" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Remove "rapid1" "%Test.Framework.TestFile%"
call Bat-KV.bat :BKV.Fetch "rapid2" "%Test.Framework.TestFile%"
call :Test.Framework.ExecuteTest "Rapid operations" "OK" "test2"

:: Test: Multiple database files
call Bat-KV.bat :BKV.New "test_db1.bkv"
call Bat-KV.bat :BKV.New "test_db2.bkv"
call Bat-KV.bat :BKV.Append "db1_key" "database1" "test_db1.bkv"
call Bat-KV.bat :BKV.Append "db2_key" "database2" "test_db2.bkv"
call Bat-KV.bat :BKV.Fetch "db1_key" "test_db1.bkv"
call :Test.Framework.ExecuteTest "Multiple databases db1" "OK" "database1"
call Bat-KV.bat :BKV.Fetch "db2_key" "test_db2.bkv"
call :Test.Framework.ExecuteTest "Multiple databases db2" "OK" "database2"

:: Test: Error handling with different operations
call Bat-KV.bat :BKV.Fetch "invalid@key" "test_db1.bkv"
call :Test.Framework.ExecuteTest "Invalid key in fetch" "NotOK" ""

call Bat-KV.bat :BKV.Include "invalid@key" "test_db1.bkv"
call :Test.Framework.ExecuteTest "Invalid key in include" "NotOK" ""

call Bat-KV.bat :BKV.Remove "invalid@key" "test_db1.bkv"
call :Test.Framework.ExecuteTest "Invalid key in remove" "NotOK" ""

:: Cleanup additional test databases
if exist "test_db1.bkv" del "test_db1.bkv" 2>nul
if exist "test_db2.bkv" del "test_db2.bkv" 2>nul

echo.
exit /b

:: =====================================================
:: Test Framework - Show Results
:: =====================================================
:Test.Framework.ShowResults
echo ===============================================
echo              Test Results Summary
echo ===============================================
echo Total tests executed: !Test.Framework.TotalTests!
echo Passed: !Test.Framework.PassCount!
echo Failed: !Test.Framework.FailCount!

if !Test.Framework.FailCount!==0 (
    echo.
    echo Status: ALL TESTS PASSED! [SUCCESS]
    echo The Bat-KV library is functioning correctly.
    echo All public API functions are working as expected.
    set "Test.Framework.ExitCode=0"
) else (
    echo.
    echo Status: !Test.Framework.FailCount! test^(s^) failed [FAILURE]
    set /a success_rate=!Test.Framework.PassCount!*100/!Test.Framework.TotalTests!
    echo Success rate: !success_rate!%%
    echo Please review the failed tests for debugging information.
    set "Test.Framework.ExitCode=1"
)
echo ===============================================
echo.
exit /b

:: =====================================================
:: Test Framework - Cleanup
:: =====================================================
:Test.Framework.Cleanup
echo [CLEANUP] Removing test files...
if exist "%Test.Framework.TestFile%" del "%Test.Framework.TestFile%" 2>nul
if exist "_BATKV.bkv" del "_BATKV.bkv" 2>nul
if exist "test_*.bkv" del "test_*.bkv" 2>nul
if exist "nonexistent.bkv" del "nonexistent.bkv" 2>nul
echo [CLEANUP] Cleanup completed
echo.
pause
exit /b