#!/bin/csh -f

# RTL/GL
set sim = RTL
#set sim = GL

# Simulator (Questa is needed for AP Memory's encrypted QSPI-PSRAM model)
set simulator = Questa

# Compile option
set mgmt_soc_prog = \\\"dhrystone.hex\\\"
set compopt = "+define+MGMT_SOC_PROG=$mgmt_soc_prog"
set compopt = "$compopt +define+PRINTF_COND=0"  # 0 = stop instruction trace

# Simulation option
set simopt =
#set simopt = "$simopt +waveform"
set simopt = "$simopt +pc_monitor"
#set simopt = "$simopt +max_cycle=200000"

# Do
set doopt = ""
#set doopt = "log -r /testbench/* ;"  # waveform

make SIMULATOR=$simulator SIM=$sim USER_COMPOPT="$compopt" USER_SIMOPT="$simopt" DOOPT="$doopt" \
     |& spike-dasm | egrep -v '\[0\] pc=' | tee sim_${sim}.log

