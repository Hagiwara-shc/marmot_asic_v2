#!/bin/csh -f

# RTL/GL
set sim = RTL
#set sim = GL

# Simulator
set simulator = Icarus
#set simulator = Questa

# Compile option
set compopt =
if ($simulator == Icarus) then
  set compopt = "$compopt -DPRINTF_COND=0"        # 0 = stop instruction trace
else
  set compopt = "$compopt +define+PRINTF_COND=0"  # 0 = stop instruction trace
endif

# Simulation option
set simopt =
#set simopt = "$simopt +waveform"
set simopt = "$simopt +pc_monitor"
#set simopt = "$simopt +max_cycle=200000"

# Do
#set doopt = ""
set doopt = "log -r /testbench/* ;"  # waveform for Questa

make SIMULATOR=$simulator SIM=$sim USER_COMPOPT="$compopt" USER_SIMOPT="$simopt" DOOPT="$doopt" \
     |& spike-dasm | egrep -v '\[0\] pc=' | tee sim_${sim}.log

