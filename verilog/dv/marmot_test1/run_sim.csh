#!/bin/csh -f

# RTL/GL
set sim = RTL
#set sim = GL

# Simulator
#set simulator = Icarus
set simulator = Questa

# Compile option
set compopt =
set compopt = "$compopt +define+PRINTF_COND=0"  # 0 = stop instruction trace

# Simulation option
set simopt =
#set simopt = "$simopt +waveform"
set simopt = "$simopt +pc_monitor"
#set simopt = "$simopt +max_cycle=200000"

if ($sim == RTL) then
  make SIMULATOR=$simulator SIM=$sim USER_COMPOPT="$compopt" USER_SIMOPT="$simopt" |& spike-dasm | egrep -v '\[0\] pc=' | tee sim_${sim}.log
else
  make SIMULATOR=$simulator SIM=$sim USER_COMPOPT="$compopt" USER_SIMOPT="$simopt" |& tee sim_${sim}.log
endif

