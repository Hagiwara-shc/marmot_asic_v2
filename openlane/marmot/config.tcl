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
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper/fixed_wrapper_cfgs.tcl
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper/default_wrapper_cfgs.tcl
set ::env(PDK) $::env(PDK)
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"


set ::env(DESIGN_NAME) Marmot

set ::env(FP_PDN_CHECK_NODES) 0
set ::env(FP_PDN_ENABLE_RAILS) 1 

set ::env(CLOCK_PORT) "wb_clk_i"

set ::env(CLOCK_PERIOD) "40"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 2880 3480"

#set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 0
set ::env(DIODE_INSERTION_STRATEGY) 5

set ::env(MAGIC_WRITE_FULL_LEF) 0

set ::env(SYNTH_FLAT_TOP) 1
#set ::env(SYNTH_NO_FLAT) 1
set ::env(CLOCK_TREE_SYNTH) 1
set ::env(DESIGN_IS_CORE) 1
set ::env(FP_PDN_CORE_RING) 0
set ::env(STA_REPORT_POWER) 0
set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"
set ::env(VDD_NETS) {vccd1 }
set ::env(GND_NETS) {vssd1 }
set ::env(VDD_PIN) "vccd1"
set ::env(GND_PIN) "vssd1"
set ::env(PL_TARGET_DENSITY) 0.25
set ::env(PL_SKIP_INITIAL_PLACEMENT) 1
set ::env(DECAP_CELL) {sky130_ef_sc_hd__decap_*  sky130_fd_sc_hd__decap_*}
#set ::env(FILL_CELL) {sky130_fd_sc_hd__fill_}
#set ::env(CTS_TARGET_SKEW) 200
#set ::env(CTS_SINK_CLUSTERING_SIZE) 100
#set ::env(CTS_SINK_CLUSTERING_MAX_DIAMETER) 1000
set ::env(FP_IO_VLENGTH) 1
set ::env(FP_IO_HLENGTH) 1
set ::env(ROUTING_CORES) 4
set ::env(GLB_RT_ALLOW_CONGESTION) 1
#set ::env(GLB_RT_MAXLAYER) 5
#set ::env(RT_MAX_LAYER) {met4}
set ::env(FP_PDN_CHECK_NODES) 0
set ::env(RUN_KLAYOUT_XOR) 0
set ::env(KLAYOUT_XOR_GDS) 0
set ::env(KLAYOUT_XOR_XML) 0
set ::env(FP_PDN_IRDROP) 0
set ::env(RUN_CVC) 0
set ::env(RUN_MAGIC_DRC) 0
#set ::env(TAKE_LAYOUT_SCROT) 1


## Source Verilog Files
set ::env(SYNTH_DEFINES) "SYNTHESIS"
set ::env(SYNTH_READ_BLACKBOX_LIB) 1

set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../../verilog/rtl/marmot]
set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	[glob $script_dir/../../../verilog/rtl/marmot/*.v]"

## SDC
set ::env(IO_PCT)     0.2
set ::env(IO_PCT_RAM) 0.3
set ::env(BASE_SDC_FILE) $script_dir/../../../openlane/marmot/base.sdc


## Internal Macros
### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
  $::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
  $::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_sram_macros/verilog/sky130_sram_2kbyte_1rw1r_32x512_8.v \
  $::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_sram_macros/verilog/sky130_sram_1kbyte_1rw1r_32x256_8.v"

set ::env(EXTRA_LEFS) "\
  $::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_sram_macros/lef/sky130_sram_2kbyte_1rw1r_32x512_8.lef \
  $::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef"

set ::env(EXTRA_GDS_FILES) "\
  $::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_sram_macros/gds/sky130_sram_2kbyte_1rw1r_32x512_8.gds \
  $::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_sram_macros/gds/sky130_sram_1kbyte_1rw1r_32x256_8.gds"

set ::env(EXTRA_LIBS) "\
  $::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_sram_macros/lib/sky130_sram_1kbyte_1rw1r_32x256_8_TT_1p8V_25C.lib \
  $::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_sram_macros/lib/sky130_sram_2kbyte_1rw1r_32x512_8_TT_1p8V_25C.lib"

### Macro Placement
set ::env(MACRO_PLACEMENT_CFG) $script_dir/../../../openlane/marmot/macro.cfg

### Macro PDN Connections
source $script_dir/../../../openlane/marmot/macro_pdn.tcl

### Obstruction over SRAMs
#source $script_dir/../../../openlane/marmot/macro_obs.tcl

# Pin order
set ::env(FP_PIN_ORDER_CFG) $script_dir/../../../openlane/marmot/pin_order.cfg
