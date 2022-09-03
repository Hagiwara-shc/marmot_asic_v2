#!/bin/csh -f

#set prot = io_ports
#set prog = la_test2
set prog = marmot_test1

set sim = RTL
#set sim = GL
#set sim = GL_SDF

if ($sim == RTL) then
  set target = verify-${prog}-rtl
else if ($sim == GL) then
  set target = verify-${prog}-gl
else if ($sim == GL_SDF) then
  set target = verify-${prog}-gl-sdf
endif

rm -f verilog/dv/$prog/$prog.vcd

make SIM=$sim $target |& egrep -v '\[0\] pc=' | spike-dasm | tee sim.log

