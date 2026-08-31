#!/usr/bin/env bash
#
# run_fast_axi_rw.sh
#
# Git Bash (MSYS) equivalent of run_fast_axi_rw.bat. Runs
# fast_axi_rw.tcl through xsct (falls back to xsdb), streams output
# live to the terminal via `tee`, and also logs it to a timestamped
# file.
#
# Usage:
#   ./run_fast_axi_rw.sh [addr] [count] [delay_ms] [mode] [pattern] [target]
#
#   addr      default 0x70000040
#   count     default 1000
#   delay_ms  default 0
#   mode      write | read | rw          (default rw)
#   pattern   32-bit hex value, or "inc" for an incrementing counter
#             (default 0xA5A5A5A5)
#   target    xsct/xsdb target index to select explicitly, e.g. the
#             "MicroBlaze #0 (Running)" entry in `targets` output
#             (default 3 - adjust to match your `targets` listing;
#             pass "" to fall back to auto-selecting by name instead)
#
# Example:
#   ./run_fast_axi_rw.sh 0x70000040 5000 0 rw inc 3
#
# If xsct/xsdb aren't on PATH, edit the FALLBACK_PATHS array below to
# point at your install (Git Bash style paths, e.g. /c/Xilinx/...).

set -uo pipefail

#ADDR="${1:-0x70000040}"
#COUNT="${2:-1000}"
#DELAY_MS="${3:-0}"
#MODE="${4:-rw}"
#PATTERN="${5:-0xA5A5A5A5}"
#TARGET="${6:-3}"

ADDR="${1:-0x70000040}"
COUNT="${2:-64}"
DELAY_MS="${3:-10}"
MODE="${4:-read}"
PATTERN="${5:-0xA0000000}"
TARGET="${6:-3}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || { echo "ERROR: could not cd to script directory"; exit 1; }

if [ ! -f "fast_axi_rw.tcl" ]; then
    echo "ERROR: fast_axi_rw.tcl not found in $SCRIPT_DIR"
    echo "       Place it alongside this script, or edit SCRIPT_DIR handling."
    exit 1
fi

# --- locate the xsct/xsdb launcher ---------------------------------
# Adjust these fallback paths to match your install if xsct/xsdb
# aren't already on PATH inside Git Bash.
FALLBACK_PATHS=(
    "/c/Xilinx/Vitis/2019.2/bin/xsct.bat"
    "/c/Xilinx/Vivado/2024.1/bin/xsdb.bat"
)

XSCT_EXE=""
if command -v xsct.bat >/dev/null 2>&1; then
    XSCT_EXE="$(command -v xsct.bat)"
elif command -v xsct >/dev/null 2>&1; then
    XSCT_EXE="$(command -v xsct)"
elif command -v xsdb.bat >/dev/null 2>&1; then
    XSCT_EXE="$(command -v xsdb.bat)"
elif command -v xsdb >/dev/null 2>&1; then
    XSCT_EXE="$(command -v xsdb)"
else
    for p in "${FALLBACK_PATHS[@]}"; do
        if [ -f "$p" ]; then
            XSCT_EXE="$p"
            break
        fi
    done
fi

if [ -z "$XSCT_EXE" ]; then
    echo "ERROR: could not find xsct.bat/xsct or xsdb.bat/xsdb on PATH or in"
    echo "       the fallback paths in this script. Edit FALLBACK_PATHS to"
    echo "       point at your install, e.g.:"
    echo "         /c/Xilinx/Vitis/<version>/bin/xsct.bat"
    echo "         /c/Xilinx/Vivado/<version>/bin/xsdb.bat"
    exit 1
fi

# --- build a timestamped log filename -------------------------------
TSTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
LOGFILE="fast_axi_rw_${TSTAMP}.log"

echo "Using launcher : $XSCT_EXE"
echo "Address        : $ADDR"
echo "Count          : $COUNT"
echo "Delay (ms)     : $DELAY_MS"
echo "Mode           : $MODE"
echo "Pattern        : $PATTERN"
echo "Target         : $TARGET"
echo "Log file       : $LOGFILE"
echo

# --- run it -----------------------------------------------------------
# Sources the proc definition then calls it with the requested args,
# all in one xsct/xsdb session. Output is tee'd so you see it live
# AND get a saved log.
TCL_CMD="source fast_axi_rw.tcl; fast_axi_rw ${ADDR} ${COUNT} ${DELAY_MS} ${MODE} ${PATTERN} ${TARGET}"

"$XSCT_EXE" -eval "$TCL_CMD" 2>&1 | tee "$LOGFILE"
RC=${PIPESTATUS[0]}

echo
echo "------------------------------------------------------------"
echo "Finished with exit code ${RC}. Full output logged to:"
echo "  $LOGFILE"
echo "------------------------------------------------------------"

exit "$RC"
