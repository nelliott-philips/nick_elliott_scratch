@echo off
setlocal enabledelayedexpansion

rem ============================================================
rem run_fast_axi_rw.bat
rem
rem Runs fast_axi_rw.tcl through xsct (falls back to xsdb) against
rem a given address, logging all output to a timestamped file.
rem
rem Usage:
rem   run_fast_axi_rw.bat [addr] [count] [delay_ms] [mode] [pattern] [target]
rem
rem   addr      default 0x70000040
rem   count     default 1000
rem   delay_ms  default 0
rem   mode      write | read | rw     (default rw)
rem   pattern   32-bit hex value, or the word inc for an incrementing
rem             counter                (default 0xA5A5A5A5)
rem   target    xsct/xsdb target index to select explicitly, e.g. the
rem             "MicroBlaze #0 (Running)" entry in `targets` output
rem             (default 3 - adjust to match your `targets` listing;
rem             pass "" to fall back to auto-selecting by name instead)
rem
rem Example:
rem   run_fast_axi_rw.bat 0x70000040 5000 0 rw inc 3
rem
rem Edit XSCT_EXE below if xsct.bat / xsdb.bat isn't on PATH.
rem ============================================================

set "ADDR=%~1"
if "%ADDR%"=="" set "ADDR=0x70000040"

set "COUNT=%~2"
if "%COUNT%"=="" set "COUNT=1000"

set "DELAY_MS=%~3"
if "%DELAY_MS%"=="" set "DELAY_MS=0"

set "MODE=%~4"
if "%MODE%"=="" set "MODE=rw"

set "PATTERN=%~5"
if "%PATTERN%"=="" set "PATTERN=0xA5A5A5A5"

set "TARGET=%~6"
if "%TARGET%"=="" set "TARGET=3"

rem --- locate the xsct/xsdb launcher -------------------------------
rem Prefer xsct.bat (Vitis/SDK) or xsdb.bat (Vivado) if already on
rem PATH; otherwise try a couple of common Xilinx install locations.
rem Adjust these two fallback paths to match your install if needed.

set "XSCT_EXE="
where xsct.bat >nul 2>&1 && set "XSCT_EXE=xsct.bat"
if "%XSCT_EXE%"=="" (
    where xsdb.bat >nul 2>&1 && set "XSCT_EXE=xsdb.bat"
)
if "%XSCT_EXE%"=="" (
    if exist "C:\Xilinx\Vitis\2019.2\bin\xsct.bat" (
        set "XSCT_EXE=C:\Xilinx\Vitis\2019.2\bin\xsct.bat"
    ) else if exist "C:\Xilinx\Vivado\2024.1\bin\xsdb.bat" (
        set "XSCT_EXE=C:\Xilinx\Vivado\2024.1\bin\xsdb.bat"
    )
)

if "%XSCT_EXE%"=="" (
    echo ERROR: could not find xsct.bat or xsdb.bat on PATH or in the
    echo default install locations. Edit run_fast_axi_rw.bat to point
    echo XSCT_EXE at your installed launcher, e.g.:
    echo   C:\Xilinx\Vitis\<version>\bin\xsct.bat
    echo   C:\Xilinx\Vivado\<version>\bin\xsdb.bat
    exit /b 1
)

rem --- build a timestamped log filename ----------------------------
for /f "tokens=1-4 delims=/ " %%a in ("%date%") do set "DSTAMP=%%c-%%a-%%b"
set "TSTAMP=%time::=-%"
set "TSTAMP=%TSTAMP: =0%"
set "LOGFILE=fast_axi_rw_%DSTAMP%_%TSTAMP%.log"
set "LOGFILE=%LOGFILE:.=-%"
set "LOGFILE=%LOGFILE:~0,-4%.log"

echo Using launcher : %XSCT_EXE%
echo Address        : %ADDR%
echo Count          : %COUNT%
echo Delay (ms)     : %DELAY_MS%
echo Mode           : %MODE%
echo Pattern        : %PATTERN%
echo Target         : %TARGET%
echo Log file       : %LOGFILE%
echo.

rem --- run it -------------------------------------------------------
rem The Tcl script defines the proc; -eval sources it then invokes it
rem with the requested arguments in the same xsct/xsdb session.

set "TCL_CMD=source fast_axi_rw.tcl; fast_axi_rw %ADDR% %COUNT% %DELAY_MS% %MODE% %PATTERN% %TARGET%"

"%XSCT_EXE%" -eval "%TCL_CMD%" > "%LOGFILE%" 2>&1

set "RC=%ERRORLEVEL%"

echo.
echo ------------------------------------------------------------
echo Finished with exit code %RC%. Full output logged to:
echo   %LOGFILE%
echo ------------------------------------------------------------
type "%LOGFILE%"

endlocal
exit /b %RC%
