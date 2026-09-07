# fast_axi_rw.tcl
#
# Fast repeated read/write access to a fixed address via xsdb, intended
# for exercising/verifying an AXI-mapped register (e.g. 0x70000040)
# once JTAG/AXI connectivity to the target is confirmed.
#
# Usage (from inside xsdb):
#   xsdb% source fast_axi_rw.tcl
#   xsdb% fast_axi_rw 0x70000040 1000 0 write
#
# Usage (non-interactive, from a shell / batch file):
#   xsdb -eval "source fast_axi_rw.tcl; fast_axi_rw 0x70000040 1000 0 write"
#
# Arguments to fast_axi_rw:
#   addr        target address, e.g. 0x70000040                 (required)
#   count       number of iterations                            (default 1000)
#   delay_ms    delay between iterations in milliseconds, 0 = as
#               fast as xsdb/JTAG will go                       (default 0)
#   mode        one of: write | read | rw                       (default rw)
#                 write - write an incrementing/fixed pattern, read back
#                         and flag on mismatch
#                 read  - read-only, just logs values/timing
#                 rw    - alternate: write pattern, then read it back
#   pattern     32-bit value to write when mode is write/rw.
#               Use the literal string "inc" to write an incrementing
#               counter value each iteration instead of a fixed value.
#               (default 0xA5A5A5A5)
#
# Notes:
#  - Assumes a target is already selected (see connect_target below,
#    called automatically if no target is currently active).
#  - True microsecond-level pacing isn't achievable through xsdb/Tcl;
#    delay_ms below 1 is rounded up by Tcl's `after`. For true
#    back-to-back speed, use delay_ms 0 and read the reported
#    ops/sec from the summary rather than assuming a fixed rate.

proc connect_target {{target_num ""}} {
    # Only issue 'connect' if nothing is currently connected.
    if {[catch {targets} result]} {
        puts "connect_target: issuing 'connect' ..."
        connect
    }
    puts "connect_target: available targets:"
    puts [targets]

    if {$target_num ne ""} {
        # Explicit target index requested (e.g. 3 for "MicroBlaze #0").
        if {[catch {targets -set $target_num} errmsg]} {
            puts "connect_target: ERROR selecting target #${target_num}: ${errmsg}"
        } else {
            puts "connect_target: selected target #${target_num}"
        }
        return
    }

    # No explicit index given: try to auto-select a MicroBlaze target.
    # If more than one matches (e.g. the Debug Module *and* the core
    # itself both match "*MicroBlaze*"), this intentionally falls
    # through rather than guessing - pass an explicit target_num to
    # fast_axi_rw instead.
    if {[catch {
        targets -set -filter {name =~ "*MicroBlaze*"}
        puts "connect_target: selected MicroBlaze target -> [targets -target-properties]"
    } errmsg]} {
        puts "connect_target: no MicroBlaze target auto-selected (${errmsg});"
        puts "connect_target: using whatever target is currently active."
    }
}


proc test_appease {addr {count 1000} {delay_ms 0} {mode "rw"} {pattern "0xA5A5A5A5"} {target "3"}} {

    set WD_EN_MSK [expr {0x0001 << 0}]
    set WD_APPEASE_WD [expr {0x0001 << 1}]
    set WD_INTRPT_EN [expr {0x0001 << 2}]
    set WD_PULL_DWN_EARLY_WARN_INT [expr {0x0001 << 3}]
    set WD_HAS_TIMED_OUT [expr {0x0001 << 4}]
    set WD_IS_SHUTDOWN [expr {0x0001 << 5}]
    set WD_FORCE_SHUTDOWN [expr {0x0001 << 6}]
    set WD_EARLY_WARN_POLL_STATUS [expr {0x0001 << 7}]
    
    # Test for initial state, if not in desired state reset be disabling WD and re-enabling

    # Always (re)assert the target selection, even if a session is
    # already connected, since the desired target index still needs
    # to be selected explicitly when multiple candidates match.
    connect_target $target

    set addr [expr {$addr}]
    set errors 0
    set use_inc [expr {[string tolower $pattern] eq "inc"}]
    set fixed_val [expr {$use_inc ? 0 : $pattern}]

    puts "----------------------------------------------------------"
    puts [format "fast_axi_rw: addr=0x%08X count=%d delay_ms=%d mode=%s pattern=%s" \
        $addr $count $delay_ms $mode [expr {$use_inc ? "incrementing" : $pattern}]]
    puts "----------------------------------------------------------"

    set t0 [clock milliseconds]

    puts "CLEARING/APPEASING!!!"

    if {[catch {set rval [mrd -value $addr]} err]} {
        puts [format {  [%6d] READ FAILED at 0x%08X: %s} $i $addr $err]
        incr errors
    } else {
	if ( $rval == "0x00000000" ) {
	    puts [format {  [%6d] read 0x%08X -> 0x%08X} 0 $addr $rval]
	} elseif ( $rval == "0x00000001") {
	    
	}
    }
    

    # Test for appeasement functionality

      # run for 10 timeout intervals with appease being written

    # Test for timeout
      # run timeout 3 times and clear each time
}

proc test_timeout {addr {count 1000} {delay_ms 0} {mode "rw"} {pattern "0xA5A5A5A5"} {target "3"}} {
    
    set WD_EN_MSK [expr {0x0001 << 0}]
    set WD_APPEASE_WD [expr {0x0001 << 1}]
    set WD_INTRPT_EN [expr {0x0001 << 2}]
    set WD_PULL_DWN_EARLY_WARN_INT [expr {0x0001 << 3}]
    set WD_HAS_TIMED_OUT [expr {0x0001 << 4}]
    set WD_IS_SHUTDOWN [expr {0x0001 << 5}]
    set WD_FORCE_SHUTDOWN [expr {0x0001 << 6}]
    set WD_EARLY_WARN_POLL_STATUS [expr {0x0001 << 7}]

}


proc fast_axi_rw {addr {count 1000} {delay_ms 0} {mode "rw"} {pattern "0xA5A5A5A5"} {target "3"}} {

    set WD_EN_MSK [expr {0x0001 << 0}]
    set WD_APPEASE_WD [expr {0x0001 << 1}]
    set WD_INTRPT_EN [expr {0x0001 << 2}]
    set WD_PULL_DWN_EARLY_WARN_INT [expr {0x0001 << 3}]
    set WD_HAS_TIMED_OUT [expr {0x0001 << 4}]
    set WD_IS_SHUTDOWN [expr {0x0001 << 5}]
    set WD_FORCE_SHUTDOWN [expr {0x0001 << 6}]
    set WD_EARLY_WARN_POLL_STATUS [expr {0x0001 << 7}]
    
    # Always (re)assert the target selection, even if a session is
    # already connected, since the desired target index still needs
    # to be selected explicitly when multiple candidates match.
    connect_target $target

    set addr [expr {$addr}]
    set errors 0
    set use_inc [expr {[string tolower $pattern] eq "inc"}]
    set fixed_val [expr {$use_inc ? 0 : $pattern}]

    puts "----------------------------------------------------------"
    puts [format "fast_axi_rw: addr=0x%08X count=%d delay_ms=%d mode=%s pattern=%s" \
        $addr $count $delay_ms $mode [expr {$use_inc ? "incrementing" : $pattern}]]
    puts "----------------------------------------------------------"

    set t0 [clock milliseconds]

    puts "CLEARING/APPEASING!!!"

    if {[catch {set rval [mrd -value $addr]} err]} {
        puts [format {  [%6d] READ FAILED at 0x%08X: %s} $i $addr $err]
        incr errors
    } else {
      puts [format {  [%6d] read 0x%08X -> 0x%08X} 0 $addr $rval]

    }

    mwr $addr $WD_APPEASE_WD

    if {[catch {set rval [mrd -value $addr]} err]} {
        puts [format {  [%6d] READ FAILED at 0x%08X: %s} $i $addr $err]
        incr errors
    } else {
      puts [format {  [%6d] read 0x%08X -> 0x%08X} 0 $addr $rval]

    }

    for {set i 0} {$i < $count} {incr i} {

        set wval [expr {$use_inc ? $i : $fixed_val}]

        switch -- $mode {
            write {
                if {[catch {mwr $addr $wval} err]} {
                    puts [format {  [%6d] WRITE FAILED at 0x%08X: %s} $i $addr $err]
                    incr errors
                }
            }
            read {
                if {[catch {set rval [mrd -value $addr]} err]} {
                    puts [format {  [%6d] READ FAILED at 0x%08X: %s} $i $addr $err]
                    incr errors
                } else {
                    if {$i < 5 || ($i % 100) == 0} {
                        puts [format {  [%6d] read 0x%08X -> 0x%08X} $i $addr $rval]
                    }
                }
            }
            override {
                if {[catch {set rval [mrd -value $addr]} err]} {
                    puts [format {  [%6d] READ FAILED at 0x%08X: %s} $i $addr $err]
                    incr errors
                } else {
                    if {$i == 0} {
                        puts [format {  [%6d] read 0x%08X -> 0x%08X} $i $addr $rval]
			mwr $addr 0x1
                    } elseif {$i < 512 || ($i % 100) == 0} {
                        puts [format {  [%6d] read 0x%08X -> 0x%08X} $i $addr $rval]
                    }
                }
            }
            rw -
            default {
                if {[catch {mwr $addr $wval} err]} {
                    puts [format {  [%6d] WRITE FAILED at 0x%08X: %s} $i $addr $err]
                    incr errors
                    continue
                }
                if {[catch {set rval [mrd -value $addr]} err]} {
                    puts [format {  [%6d] READ-BACK FAILED at 0x%08X: %s} $i $addr $err]
                    incr errors
                    continue
                }
                if {$rval != $wval} {
                    puts [format {  [%6d] MISMATCH at 0x%08X: wrote 0x%08X, read 0x%08X} \
                        $i $addr $wval $rval]
                    incr errors
                } elseif {$i < 5 || ($i % 100) == 0} {
                    puts [format {  [%6d] ok 0x%08X == 0x%08X} $i $wval $rval]
                }
            }
        }

        if {$delay_ms > 0} {
            after $delay_ms
        }
    }

    set t1 [clock milliseconds]
    set elapsed_ms [expr {$t1 - $t0}]
    set elapsed_s [expr {$elapsed_ms / 1000.0}]
    set ops [expr {$mode eq "rw" ? $count * 2 : $count}]
    set rate [expr {$elapsed_s > 0 ? $ops / $elapsed_s : 0}]

    puts "----------------------------------------------------------"
    puts [format "fast_axi_rw: done. %d iterations, %d errors, %.3f s elapsed, %.1f ops/sec" \
        $count $errors $elapsed_s $rate]
    puts "----------------------------------------------------------"

    return $errors
}

# If this file is sourced non-interactively with arguments already
# baked into a wrapping -eval string, fast_axi_rw is called explicitly
# there. Sourcing alone just defines the procs above without running
# anything, so it's safe to `source` this from an interactive xsdb
# session and then call fast_axi_rw yourself with whatever arguments
# you want.
