#!/bin/csh -f

set testcase_dir = /home/shc/Development/RISC-V/freedom/sim/testcase

#cp -p $testcase_dir/dhrystone-2.1/gcc_dry2reg_flash.mem .
cp -p $testcase_dir/hello/spi_flash.mem hello_flash.mem

$testcase_dir/../../script/mk_init_ff.py $MARMOT_ROOT/verilog/gl/Marmot.v > init_ff.v

