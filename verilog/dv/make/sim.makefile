# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

# Questa/Icarus
SIMULATOR ?= Questa

export IVERILOG_DUMPER = fst

# RTL/GL/GL_SDF
SIM?=RTL


.SUFFIXES:


ifeq ($(SIMULATOR),Icarus)
all:  ${BLOCKS:=.lst} sim_icarus
else
all:  ${BLOCKS:=.lst} sim_questa
endif

hex:  ${BLOCKS:=.hex}

#.SUFFIXES:

##############################################################################
# Comiple firmeware
##############################################################################
%.elf: %.c $(LINKER_SCRIPT) $(SOURCE_FILES)
	${GCC_PATH}/${GCC_PREFIX}-gcc -g \
	-I$(FIRMWARE_PATH) \
	-I$(VERILOG_PATH)/dv/generated \
	-I$(VERILOG_PATH)/dv/ \
	-I$(VERILOG_PATH)/common \
	  $(CPUFLAGS) \
	-Wl,-Bstatic,-T,$(LINKER_SCRIPT),--strip-debug \
	-ffreestanding -nostdlib -o $@ $(SOURCE_FILES) $<

%.lst: %.elf
	${GCC_PATH}/${GCC_PREFIX}-objdump -d -S $< > $@

%.hex: %.elf
	${GCC_PATH}/${GCC_PREFIX}-objcopy -O verilog $< $@ 
	# to fix flash base address
	sed -ie 's/@10/@00/g' $@

%.bin: %.elf
	${GCC_PATH}/${GCC_PREFIX}-objcopy -O binary $< /dev/stdout | tail -c +1048577 > $@
	
	
##############################################################################
# Runing the simulations
##############################################################################

#------------------------------------
# Icarus Veriog
#------------------------------------
ifeq ($(SIMULATOR),Icarus)

COMPOPT := -g2005-sv

%.vvp: %_tb.v %.hex

## RTL
ifeq ($(SIM),RTL)
    ifeq ($(CONFIG),caravel_user_project)
		iverilog $(COMPOPT) -Ttyp -DFUNCTIONAL -DSIM -DUSE_POWER_PINS -DUNIT_DELAY=#1 \
        -f$(VERILOG_PATH)/includes/includes.rtl.caravel \
        -f$(USER_PROJECT_VERILOG)/includes/includes.rtl.$(CONFIG) -o $@ $<
    else
		iverilog $(COMPOPT) -Ttyp -DFUNCTIONAL -DSIM -DUSE_POWER_PINS -DUNIT_DELAY=#1 \
		-f$(VERILOG_PATH)/includes/includes.rtl.$(CONFIG) \
		-f$(CARAVEL_PATH)/rtl/__user_project_wrapper.v -o $@ $<
    endif
endif 

## GL
ifeq ($(SIM),GL)
    ifeq ($(CONFIG),caravel_user_project)
		iverilog $(COMPOPT) -Ttyp -DFUNCTIONAL -DGL -DUSE_POWER_PINS -DUNIT_DELAY=#1 \
        -f$(VERILOG_PATH)/includes/includes.gl.caravel \
        -f$(USER_PROJECT_VERILOG)/includes/includes.gl.$(CONFIG) -o $@ $<
    else
		iverilog $(COMPOPT) -Ttyp -DFUNCTIONAL -DGL -DUSE_POWER_PINS -DUNIT_DELAY=#1 \
        -f$(VERILOG_PATH)/includes/includes.gl.$(CONFIG) \
		-f$(CARAVEL_PATH)/gl/__user_project_wrapper.v -o $@ $<
    endif
endif 

## GL+SDF
ifeq ($(SIM),GL_SDF)
    ifeq ($(CONFIG),caravel_user_project)
		cvc64  +interp \
		+define+SIM +define+FUNCTIONAL +define+GL +define+USE_POWER_PINS +define+UNIT_DELAY +define+ENABLE_SDF \
		+change_port_type +dump2fst +fst+parallel2=on   +nointeractive +notimingchecks +mipdopt \
		-f $(VERILOG_PATH)/includes/includes.gl+sdf.caravel \
		-f $(USER_PROJECT_VERILOG)/includes/includes.gl+sdf.$(CONFIG) $<
	else
		cvc64  +interp \
		+define+SIM +define+FUNCTIONAL +define+GL +define+USE_POWER_PINS +define+UNIT_DELAY +define+ENABLE_SDF \
		+change_port_type +dump2fst +fst+parallel2=on   +nointeractive +notimingchecks +mipdopt \
		-f $(VERILOG_PATH)/includes/includes.gl+sdf.$(CONFIG) \
		-f $CARAVEL_PATH/gl/__user_project_wrapper.v $<
    endif
endif

sim_icarus: ${BLOCKS:=.vvp}
	vvp $< $(SIMOPT)

# twinwave: RTL-%.vcd GL-%.vcd
#     twinwave RTL-$@ * + GL-$@ *

#------------------------------------
# Questa
#------------------------------------
else

COMPOPT := -64 -work work -sv -sv12compat -mfcu -suppress vlog-2892,vlog-2388,vlog-2248 +acc=lprn
COMPOPT += ../vip/APM_APS6404L-3SQN_SQPI_PSRAM_model_v2.9_encrypt.vp_modelsim
SIMOPT := -64 -c -suppress vsim-3009 -debugDB $(USER_SIMOPT)

sim_questa:
## RTL
ifeq ($(SIM),RTL)
	rm -rf work
	vlib work
  ifeq ($(CONFIG),caravel_user_project)
	  vlog $(COMPOPT) +define+SIMULATOR_QUESTA +define+FUNCTIONAL +define+SIM +define+USE_POWER_PINS +define+UNIT_DELAY=#1 \
	    -f $(VERILOG_PATH)/includes/includes.rtl.caravel \
	    -f $(USER_PROJECT_VERILOG)/includes/includes.rtl.$(CONFIG) \
	    ${BLOCKS:=_tb.v}
	  vsim work.testbench $(SIMOPT) -do "$(DOOPT) run -all; quit;"
  else
	  echo "CONFIG = $(CONFIG): not supported."
	  exit
  endif
endif

## GL
ifeq ($(SIM),GL)
	rm -rf work
	vlib work
  ifeq ($(CONFIG),caravel_user_project)
	  vlog $(COMPOPT) +define+SIMULATOR_QUESTA +define+FUNCTIONAL +define+GL +define+USE_POWER_PINS +define+UNIT_DELAY=#1 \
	    -f $(VERILOG_PATH)/includes/includes.gl.caravel \
	    -f $(USER_PROJECT_VERILOG)/includes/includes.gl.$(CONFIG) \
	    ${BLOCKS:=_tb.v}
	  vsim work.testbench $(SIMOPT) -do "$(DOOPT) run -all; quit;"
  else
	  echo "CONFIG = $(CONFIG): not supported."
	  exit
  endif
endif
endif

check-env:
ifndef PDK_ROOT
	$(error PDK_ROOT is undefined, please export it before running make)
endif
ifeq (,$(wildcard $(PDK_ROOT)/$(PDK)))
	$(error $(PDK_ROOT)/$(PDK) not found, please install pdk before running make)
endif
ifeq (,$(wildcard $(GCC_PATH)/$(GCC_PREFIX)-gcc ))
	$(error $(GCC_PATH)/$(GCC_PREFIX)-gcc is not found, please export GCC_PATH and GCC_PREFIX before running make)
endif
# check for efabless style installation
ifeq (,$(wildcard $(PDK_ROOT)/$(PDK)/libs.ref/*/verilog))
SIM_DEFINES := ${SIM_DEFINES} -DEF_STYLE
endif


# ---- Clean ----

clean:
	rm -rf *.elf *.hex *.bin *.vvp *.log *.vcd* *.lst *.hexe *.err *.dbg *.wlf transcript work

.PHONY: clean hex all

