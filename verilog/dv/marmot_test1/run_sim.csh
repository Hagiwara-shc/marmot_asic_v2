#!/bin/csh -f

#set sim = RTL
set sim = GL

set simopt =
#set simopt = "$simopt +waveform"
set simopt = "$simopt +pc_monitor"
#set simopt = "$simopt +max_cycle=200000"

if ($sim == RTL) then
  make SIM=$sim SIMOPT="$simopt" |& spike-dasm | egrep -v '\[0\] pc=' | tee sim_${sim}.log
else
  make SIM=$sim SIMOPT="$simopt" |& tee sim_${sim}.log
endif

