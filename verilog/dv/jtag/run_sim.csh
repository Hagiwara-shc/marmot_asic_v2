#!/bin/csh -f

# RTL/GL
set sim = RTL
#set sim = GL

# Simulator
set simulator = Icarus
#set simulator = Questa

# Compile option
set mgmt_soc_prog = \\\"jtag.hex\\\"

if ($simulator == Icarus) then
  set compopt = "-DMGMT_SOC_PROG=$mgmt_soc_prog"
  set compopt = "$compopt -DPRINTF_COND=0"  # 0 = stop instruction trace
else
  set compopt = "+define+MGMT_SOC_PROG=$mgmt_soc_prog"
  set compopt = "$compopt +define+PRINTF_COND=0"  # 0 = stop instruction trace
endif

# Simulation option
set simopt =
#set simopt = "$simopt +waveform"
#set simopt = "$simopt +pc_monitor"
#set simopt = "$simopt +max_cycle=200000"

# For Questa
set doopt = ""
#set doopt = "log -r /testbench/* ;"  # waveform

make SIMULATOR=$simulator SIM=$sim USER_COMPOPT="$compopt" USER_SIMOPT="$simopt" DOOPT="$doopt" \
     |& spike-dasm | egrep -v '\[0\] pc=' | tee sim_${sim}.log

