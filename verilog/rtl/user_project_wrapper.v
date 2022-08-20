// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
    parameter BITS = 32
) (
`ifdef USE_POWER_PINS
    inout vdda1,  // User area 1 3.3V supply
    inout vdda2,  // User area 2 3.3V supply
    inout vssa1,  // User area 1 analog ground
    inout vssa2,  // User area 2 analog ground
    inout vccd1,  // User area 1 1.8V supply
    inout vccd2,  // User area 2 1.8v supply
    inout vssd1,  // User area 1 digital ground
    inout vssd2,  // User area 2 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

/*--------------------------------------*/
/* User project is instantiated  here   */
/*--------------------------------------*/
`ifdef RAM_ON_TOP
    wire        tag_array_ext_ram_clk;
    wire        tag_array_ext_ram_csb0;
    wire        tag_array_ext_ram_web0;
    wire [3:0]  tag_array_ext_ram_wmask0;
    wire [7:0]  tag_array_ext_ram_addr0;
    wire [31:0] tag_array_ext_ram_din0;
    wire [31:0] tag_array_ext_ram_dout0;
    wire        tag_array_ext_ram_csb1;
    wire [7:0]  tag_array_ext_ram_addr1;

    wire [1:0]  data_arrays_0_ext_ram_clk;
    wire [1:0]  data_arrays_0_ext_ram_csb0;
    wire [1:0]  data_arrays_0_ext_ram_web0;
    wire [3:0]  data_arrays_0_ext_ram_wmask00;
    wire [3:0]  data_arrays_0_ext_ram_wmask01;
    wire [8:0]  data_arrays_0_ext_ram_addr00;
    wire [8:0]  data_arrays_0_ext_ram_addr01;
    wire [31:0] data_arrays_0_ext_ram_din00;
    wire [31:0] data_arrays_0_ext_ram_din01;
    wire [31:0] data_arrays_0_ext_ram_dout00;
    wire [31:0] data_arrays_0_ext_ram_dout01;
    wire [1:0]  data_arrays_0_ext_ram_csb1;
    wire [8:0]  data_arrays_0_ext_ram_addr10;
    wire [8:0]  data_arrays_0_ext_ram_addr11;

    wire        tag_array_0_ext_ram_clk;
    wire        tag_array_0_ext_ram_csb0;
    wire        tag_array_0_ext_ram_web0;
    wire [7:0]  tag_array_0_ext_ram_wmask0;
    wire [7:0]  tag_array_0_ext_ram_addr0;
    wire [63:0] tag_array_0_ext_ram_din0;
    wire [63:0] tag_array_0_ext_ram_dout0;
    wire        tag_array_0_ext_ram_csb1;
    wire [7:0]  tag_array_0_ext_ram_addr1;

    wire [3:0]  data_arrays_0_0_ext_ram_clk;
    wire [3:0]  data_arrays_0_0_ext_ram_csb0;
    wire [3:0]  data_arrays_0_0_ext_ram_web0;
    wire [7:0]  data_arrays_0_0_ext_ram_wmask00;
    wire [7:0]  data_arrays_0_0_ext_ram_wmask01;
    wire [7:0]  data_arrays_0_0_ext_ram_wmask02;
    wire [7:0]  data_arrays_0_0_ext_ram_wmask03;
    wire [8:0]  data_arrays_0_0_ext_ram_addr00;
    wire [8:0]  data_arrays_0_0_ext_ram_addr01;
    wire [8:0]  data_arrays_0_0_ext_ram_addr02;
    wire [8:0]  data_arrays_0_0_ext_ram_addr03;
    wire [63:0] data_arrays_0_0_ext_ram_din00;
    wire [63:0] data_arrays_0_0_ext_ram_din01;
    wire [63:0] data_arrays_0_0_ext_ram_din02;
    wire [63:0] data_arrays_0_0_ext_ram_din03;
    wire [63:0] data_arrays_0_0_ext_ram_dout00;
    wire [63:0] data_arrays_0_0_ext_ram_dout01;
    wire [63:0] data_arrays_0_0_ext_ram_dout02;
    wire [63:0] data_arrays_0_0_ext_ram_dout03;
    wire [3:0]  data_arrays_0_0_ext_ram_csb1;
    wire [8:0]  data_arrays_0_0_ext_ram_addr10;
    wire [8:0]  data_arrays_0_0_ext_ram_addr11;
    wire [8:0]  data_arrays_0_0_ext_ram_addr12;
    wire [8:0]  data_arrays_0_0_ext_ram_addr13;
`endif  // RAM_ON_TOP

Marmot Marmot (
`ifdef USE_POWER_PINS
    .vdda1(vdda1),  // User area 1 3.3V supply
    .vdda2(vdda2),  // User area 2 3.3V supply
    .vssa1(vssa1),  // User area 1 analog ground
    .vssa2(vssa2),  // User area 2 analog ground
    .vccd1(vccd1),  // User area 1 1.8V supply
    .vccd2(vccd2),  // User area 2 1.8v supply
    .vssd1(vssd1),  // User area 1 digital ground
    .vssd2(vssd2),  // User area 2 digital ground
`endif
    // Clock and Reset
    .wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),
    // MGMT SoC Wishbone Slave
    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(wbs_cyc_i),
    .wbs_we_i(wbs_we_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_ack_o(wbs_ack_o),
    .wbs_dat_o(wbs_dat_o),
    // Logic Analyzer
    .la_data_in(la_data_in),
    .la_data_out(la_data_out),
    .la_oenb(la_oenb),
    // IO Pads
    .io_in(io_in),
    .io_out(io_out),
    .io_oeb(io_oeb),
    // Analog
    .analog_io(analog_io),
    // Independent clock
    .user_clock2(user_clock2),
    // IRQ
    .user_irq(user_irq)
`ifdef RAM_ON_TOP
    // RAM signals
  , .tag_array_ext_ram_clk(tag_array_ext_ram_clk),
    .tag_array_ext_ram_csb0(tag_array_ext_ram_csb0),
    .tag_array_ext_ram_web0(tag_array_ext_ram_web0),
    .tag_array_ext_ram_wmask0(tag_array_ext_ram_wmask0),
    .tag_array_ext_ram_addr0(tag_array_ext_ram_addr0),
    .tag_array_ext_ram_din0(tag_array_ext_ram_din0),
    .tag_array_ext_ram_dout0(tag_array_ext_ram_dout0),
    .tag_array_ext_ram_csb1(tag_array_ext_ram_csb1),
    .tag_array_ext_ram_addr1(tag_array_ext_ram_addr1),
    .data_arrays_0_ext_ram_clk(data_arrays_0_ext_ram_clk),
    .data_arrays_0_ext_ram_csb0(data_arrays_0_ext_ram_csb0),
    .data_arrays_0_ext_ram_web0(data_arrays_0_ext_ram_web0),
    .data_arrays_0_ext_ram_wmask00(data_arrays_0_ext_ram_wmask00),
    .data_arrays_0_ext_ram_wmask01(data_arrays_0_ext_ram_wmask01),
    .data_arrays_0_ext_ram_addr00(data_arrays_0_ext_ram_addr00),
    .data_arrays_0_ext_ram_addr01(data_arrays_0_ext_ram_addr01),
    .data_arrays_0_ext_ram_din00(data_arrays_0_ext_ram_din00),
    .data_arrays_0_ext_ram_din01(data_arrays_0_ext_ram_din01),
    .data_arrays_0_ext_ram_dout00(data_arrays_0_ext_ram_dout00),
    .data_arrays_0_ext_ram_dout01(data_arrays_0_ext_ram_dout01),
    .data_arrays_0_ext_ram_csb1(data_arrays_0_ext_ram_csb1),
    .data_arrays_0_ext_ram_addr10(data_arrays_0_ext_ram_addr10),
    .data_arrays_0_ext_ram_addr11(data_arrays_0_ext_ram_addr11),
    .tag_array_0_ext_ram_clk(tag_array_0_ext_ram_clk),
    .tag_array_0_ext_ram_csb0(tag_array_0_ext_ram_csb0),
    .tag_array_0_ext_ram_web0(tag_array_0_ext_ram_web0),
    .tag_array_0_ext_ram_wmask0(tag_array_0_ext_ram_wmask0),
    .tag_array_0_ext_ram_addr0(tag_array_0_ext_ram_addr0),
    .tag_array_0_ext_ram_din0(tag_array_0_ext_ram_din0),
    .tag_array_0_ext_ram_dout0(tag_array_0_ext_ram_dout0),
    .tag_array_0_ext_ram_csb1(tag_array_0_ext_ram_csb1),
    .tag_array_0_ext_ram_addr1(tag_array_0_ext_ram_addr1),
    .data_arrays_0_0_ext_ram_clk(data_arrays_0_0_ext_ram_clk),
    .data_arrays_0_0_ext_ram_csb0(data_arrays_0_0_ext_ram_csb0),
    .data_arrays_0_0_ext_ram_web0(data_arrays_0_0_ext_ram_web0),
    .data_arrays_0_0_ext_ram_wmask00(data_arrays_0_0_ext_ram_wmask00),
    .data_arrays_0_0_ext_ram_wmask01(data_arrays_0_0_ext_ram_wmask01),
    .data_arrays_0_0_ext_ram_wmask02(data_arrays_0_0_ext_ram_wmask02),
    .data_arrays_0_0_ext_ram_wmask03(data_arrays_0_0_ext_ram_wmask03),
    .data_arrays_0_0_ext_ram_addr00(data_arrays_0_0_ext_ram_addr00),
    .data_arrays_0_0_ext_ram_addr01(data_arrays_0_0_ext_ram_addr01),
    .data_arrays_0_0_ext_ram_addr02(data_arrays_0_0_ext_ram_addr02),
    .data_arrays_0_0_ext_ram_addr03(data_arrays_0_0_ext_ram_addr03),
    .data_arrays_0_0_ext_ram_din00(data_arrays_0_0_ext_ram_din00),
    .data_arrays_0_0_ext_ram_din01(data_arrays_0_0_ext_ram_din01),
    .data_arrays_0_0_ext_ram_din02(data_arrays_0_0_ext_ram_din02),
    .data_arrays_0_0_ext_ram_din03(data_arrays_0_0_ext_ram_din03),
    .data_arrays_0_0_ext_ram_dout00(data_arrays_0_0_ext_ram_dout00),
    .data_arrays_0_0_ext_ram_dout01(data_arrays_0_0_ext_ram_dout01),
    .data_arrays_0_0_ext_ram_dout02(data_arrays_0_0_ext_ram_dout02),
    .data_arrays_0_0_ext_ram_dout03(data_arrays_0_0_ext_ram_dout03),
    .data_arrays_0_0_ext_ram_csb1(data_arrays_0_0_ext_ram_csb1),
    .data_arrays_0_0_ext_ram_addr10(data_arrays_0_0_ext_ram_addr10),
    .data_arrays_0_0_ext_ram_addr11(data_arrays_0_0_ext_ram_addr11),
    .data_arrays_0_0_ext_ram_addr12(data_arrays_0_0_ext_ram_addr12),
    .data_arrays_0_0_ext_ram_addr13(data_arrays_0_0_ext_ram_addr13)
`endif  // RAM_ON_TOP
);

`ifdef RAM_ON_TOP
  `ifndef VERBOSE
    `define VERBOSE 0
  `endif

  //-----------------------------------------------------------------------
  // D-Cache data
  sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) data_arrays_0_ext_ram0 (
`ifdef USE_POWER_PINS
    .vccd1  (vccd1),
    .vssd1  (vssd1),
`endif
    .clk0   (data_arrays_0_ext_ram_clk[0]),
    .csb0   (data_arrays_0_ext_ram_csb0[0]),
    .web0   (data_arrays_0_ext_ram_web0[0]),
    .wmask0 (data_arrays_0_ext_ram_wmask00),
    .addr0  (data_arrays_0_ext_ram_addr00),
    .din0   (data_arrays_0_ext_ram_din00),
    .dout0  (data_arrays_0_ext_ram_dout00),
    .clk1   (data_arrays_0_ext_ram_clk[0]),
    .csb1   (data_arrays_0_ext_ram_csb1[0]),
    .addr1  (data_arrays_0_ext_ram_addr10),
    /* verilator lint_off PINCONNECTEMPTY */
    .dout1  ()
    /* verilator lint_on PINCONNECTEMPTY */
  );  

  sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) data_arrays_0_ext_ram1 (
`ifdef USE_POWER_PINS
    .vccd1  (vccd1),
    .vssd1  (vssd1),
`endif
    .clk0   (data_arrays_0_ext_ram_clk[1]),
    .csb0   (data_arrays_0_ext_ram_csb0[1]),
    .web0   (data_arrays_0_ext_ram_web0[1]),
    .wmask0 (data_arrays_0_ext_ram_wmask01),
    .addr0  (data_arrays_0_ext_ram_addr01),
    .din0   (data_arrays_0_ext_ram_din01),
    .dout0  (data_arrays_0_ext_ram_dout01),
    .clk1   (data_arrays_0_ext_ram_clk[1]),
    .csb1   (data_arrays_0_ext_ram_csb1[1]),
    .addr1  (data_arrays_0_ext_ram_addr11),
    /* verilator lint_off PINCONNECTEMPTY */
    .dout1  ()
    /* verilator lint_on PINCONNECTEMPTY */
  );  

  //-----------------------------------------------------------------------
  // D-Cache tag
  sky130_sram_1kbyte_1rw1r_32x256_8 #(.VERBOSE(`VERBOSE)) tag_array_ext_ram (
`ifdef USE_POWER_PINS
    .vccd1  (vccd1),
    .vssd1  (vssd1),
`endif
    .clk0   (tag_array_ext_ram_clk),
    .csb0   (tag_array_ext_ram_csb0),
    .web0   (tag_array_ext_ram_web0),
    .wmask0 (tag_array_ext_ram_wmask0),
    .addr0  (tag_array_ext_ram_addr0),
    .din0   (tag_array_ext_ram_din0),
    .dout0  (tag_array_ext_ram_dout0),
    .clk1   (tag_array_ext_ram_clk),
    .csb1   (tag_array_ext_ram_csb1),
    .addr1  (tag_array_ext_ram_addr1),
    /* verilator lint_off PINCONNECTEMPTY */
    .dout1  ()
    /* verilator lint_on PINCONNECTEMPTY */
  );  

  //-----------------------------------------------------------------------
  // I-Cache tag
  sky130_sram_1kbyte_1rw1r_32x256_8 #(.VERBOSE(`VERBOSE)) tag_array_0_ext_raml (
`ifdef USE_POWER_PINS
    .vccd1  (vccd1),
    .vssd1  (vssd1),
`endif
    .clk0   (tag_array_0_ext_ram_clk),
    .csb0   (tag_array_0_ext_ram_csb0),
    .web0   (tag_array_0_ext_ram_web0),
    .wmask0 (tag_array_0_ext_ram_wmask0[3:0]),
    .addr0  (tag_array_0_ext_ram_addr0),
    .din0   (tag_array_0_ext_ram_din0[31:0]),
    .dout0  (tag_array_0_ext_ram_dout0[31:0]),
    .clk1   (tag_array_0_ext_ram_clk),
    .csb1   (tag_array_0_ext_ram_csb1),
    .addr1  (tag_array_0_ext_ram_addr1),
    /* verilator lint_off PINCONNECTEMPTY */
    .dout1  ()
    /* verilator lint_on PINCONNECTEMPTY */
  );  

  sky130_sram_1kbyte_1rw1r_32x256_8 #(.VERBOSE(`VERBOSE)) tag_array_0_ext_ramh (
`ifdef USE_POWER_PINS
    .vccd1  (vccd1),
    .vssd1  (vssd1),
`endif
    .clk0   (tag_array_0_ext_ram_clk),
    .csb0   (tag_array_0_ext_ram_csb0),
    .web0   (tag_array_0_ext_ram_web0),
    .wmask0 (tag_array_0_ext_ram_wmask0[7:4]),
    .addr0  (tag_array_0_ext_ram_addr0),
    .din0   (tag_array_0_ext_ram_din0[63:32]),
    .dout0  (tag_array_0_ext_ram_dout0[63:32]),
    .clk1   (tag_array_0_ext_ram_clk),
    .csb1   (tag_array_0_ext_ram_csb1),
    .addr1  (tag_array_0_ext_ram_addr1),
    /* verilator lint_off PINCONNECTEMPTY */
    .dout1  ()
    /* verilator lint_on PINCONNECTEMPTY */
  );  

  //-----------------------------------------------------------------------
  // I-Cache data
    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) data_arrays_0_0_ext_ram0l (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (data_arrays_0_0_ext_ram_clk[0]),
      .csb0   (data_arrays_0_0_ext_ram_csb0[0]),
      .web0   (data_arrays_0_0_ext_ram_web0[0]),
      .wmask0 (data_arrays_0_0_ext_ram_wmask00[3:0]),
      .addr0  (data_arrays_0_0_ext_ram_addr00),
      .din0   (data_arrays_0_0_ext_ram_din00[31:0]),
      .dout0  (data_arrays_0_0_ext_ram_dout00[31:0]),
      .clk1   (data_arrays_0_0_ext_ram_clk[0]),
      .csb1   (data_arrays_0_0_ext_ram_csb1[0]),
      .addr1  (data_arrays_0_0_ext_ram_addr10),
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) data_arrays_0_0_ext_ram0h (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (data_arrays_0_0_ext_ram_clk[0]),
      .csb0   (data_arrays_0_0_ext_ram_csb0[0]),
      .web0   (data_arrays_0_0_ext_ram_web0[0]),
      .wmask0 (data_arrays_0_0_ext_ram_wmask00[7:4]),
      .addr0  (data_arrays_0_0_ext_ram_addr00),
      .din0   (data_arrays_0_0_ext_ram_din00[63:32]),
      .dout0  (data_arrays_0_0_ext_ram_dout00[63:32]),
      .clk1   (data_arrays_0_0_ext_ram_clk[0]),
      .csb1   (data_arrays_0_0_ext_ram_csb1[0]),
      .addr1  (data_arrays_0_0_ext_ram_addr10),
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) data_arrays_0_0_ext_ram1l (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (data_arrays_0_0_ext_ram_clk[1]),
      .csb0   (data_arrays_0_0_ext_ram_csb0[1]),
      .web0   (data_arrays_0_0_ext_ram_web0[1]),
      .wmask0 (data_arrays_0_0_ext_ram_wmask01[3:0]),
      .addr0  (data_arrays_0_0_ext_ram_addr01),
      .din0   (data_arrays_0_0_ext_ram_din01[31:0]),
      .dout0  (data_arrays_0_0_ext_ram_dout01[31:0]),
      .clk1   (data_arrays_0_0_ext_ram_clk[1]),
      .csb1   (data_arrays_0_0_ext_ram_csb1[1]),
      .addr1  (data_arrays_0_0_ext_ram_addr11),
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) data_arrays_0_0_ext_ram1h (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (data_arrays_0_0_ext_ram_clk[1]),
      .csb0   (data_arrays_0_0_ext_ram_csb0[1]),
      .web0   (data_arrays_0_0_ext_ram_web0[1]),
      .wmask0 (data_arrays_0_0_ext_ram_wmask01[7:4]),
      .addr0  (data_arrays_0_0_ext_ram_addr01),
      .din0   (data_arrays_0_0_ext_ram_din01[63:32]),
      .dout0  (data_arrays_0_0_ext_ram_dout01[63:32]),
      .clk1   (data_arrays_0_0_ext_ram_clk[1]),
      .csb1   (data_arrays_0_0_ext_ram_csb1[1]),
      .addr1  (data_arrays_0_0_ext_ram_addr11),
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) data_arrays_0_0_ext_ram2l (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (data_arrays_0_0_ext_ram_clk[2]),
      .csb0   (data_arrays_0_0_ext_ram_csb0[2]),
      .web0   (data_arrays_0_0_ext_ram_web0[2]),
      .wmask0 (data_arrays_0_0_ext_ram_wmask02[3:0]),
      .addr0  (data_arrays_0_0_ext_ram_addr02),
      .din0   (data_arrays_0_0_ext_ram_din02[31:0]),
      .dout0  (data_arrays_0_0_ext_ram_dout02[31:0]),
      .clk1   (data_arrays_0_0_ext_ram_clk[2]),
      .csb1   (data_arrays_0_0_ext_ram_csb1[2]),
      .addr1  (data_arrays_0_0_ext_ram_addr12),
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) data_arrays_0_0_ext_ram2h (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (data_arrays_0_0_ext_ram_clk[2]),
      .csb0   (data_arrays_0_0_ext_ram_csb0[2]),
      .web0   (data_arrays_0_0_ext_ram_web0[2]),
      .wmask0 (data_arrays_0_0_ext_ram_wmask02[7:4]),
      .addr0  (data_arrays_0_0_ext_ram_addr02),
      .din0   (data_arrays_0_0_ext_ram_din02[63:32]),
      .dout0  (data_arrays_0_0_ext_ram_dout02[63:32]),
      .clk1   (data_arrays_0_0_ext_ram_clk[2]),
      .csb1   (data_arrays_0_0_ext_ram_csb1[2]),
      .addr1  (data_arrays_0_0_ext_ram_addr12),
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) data_arrays_0_0_ext_ram3l (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (data_arrays_0_0_ext_ram_clk[3]),
      .csb0   (data_arrays_0_0_ext_ram_csb0[3]),
      .web0   (data_arrays_0_0_ext_ram_web0[3]),
      .wmask0 (data_arrays_0_0_ext_ram_wmask03[3:0]),
      .addr0  (data_arrays_0_0_ext_ram_addr03),
      .din0   (data_arrays_0_0_ext_ram_din03[31:0]),
      .dout0  (data_arrays_0_0_ext_ram_dout03[31:0]),
      .clk1   (data_arrays_0_0_ext_ram_clk[3]),
      .csb1   (data_arrays_0_0_ext_ram_csb1[3]),
      .addr1  (data_arrays_0_0_ext_ram_addr13),
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) data_arrays_0_0_ext_ram3h (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (data_arrays_0_0_ext_ram_clk[3]),
      .csb0   (data_arrays_0_0_ext_ram_csb0[3]),
      .web0   (data_arrays_0_0_ext_ram_web0[3]),
      .wmask0 (data_arrays_0_0_ext_ram_wmask03[7:4]),
      .addr0  (data_arrays_0_0_ext_ram_addr03),
      .din0   (data_arrays_0_0_ext_ram_din03[63:32]),
      .dout0  (data_arrays_0_0_ext_ram_dout03[63:32]),
      .clk1   (data_arrays_0_0_ext_ram_clk[3]),
      .csb1   (data_arrays_0_0_ext_ram_csb1[3]),
      .addr1  (data_arrays_0_0_ext_ram_addr13),
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()
      /* verilator lint_on PINCONNECTEMPTY */
    );  
`endif  // data_arrays_0_0_ext_ram_ON_TOP

endmodule // user_project_wrapper

`default_nettype wire
