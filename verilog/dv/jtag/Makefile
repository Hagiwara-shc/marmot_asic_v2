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

# RTL/GL/GL_SDF
export SIM ?= RTL

# Questa only
SIMULATOR = Questa

export TARGET_PATH = $(MARMOT_ROOT)
export DESIGNS = $(TARGET_PATH)
export CARAVEL_ROOT = $(TARGET_PATH)/caravel
export MCW_ROOT = $(TARGET_PATH)/mgmt_core_wrapper
export CORE_VERILOG_PATH = $(MCW_ROOT)/verilog
#export PDK_ROOT = $(PDK_ROOT)
#export PDK = $(PDK)
export TOOLS = $(RISCV)
export GCC_PREFIX = riscv64-unknown-linux-gnu

TESTCASE_DIR = $(HOME)/Development/RISC-V/chipyard/vlsi/sim/testcase

PWDD := $(shell pwd)
BLOCKS := $(shell basename $(PWDD))

# ---- Include Partitioned Makefiles ----

CONFIG = caravel_user_project

include $(MCW_ROOT)/verilog/dv/make/env.makefile
include $(MCW_ROOT)/verilog/dv/make/var.makefile
include $(MCW_ROOT)/verilog/dv/make/cpu.makefile
include ../make/sim.makefile

setup:
	echo "// $(TESTCASE_DIR)/jtag/spi_flash.mem" > spi_flash.mem
	cat $(TESTCASE_DIR)/jtag/spi_flash.mem >> spi_flash.mem
	cp $(TESTCASE_DIR)/jtag/spi_flash.lis spi_flash.lis

wave:
	vsim -gui vsim.wlf -do wave.do &

