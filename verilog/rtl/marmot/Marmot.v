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

module Marmot
(
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

`ifndef MARMOT_EMPTY
    //------------------------------------------------------------------------------
    // Clock and Reset to MarmotCaravelChip
    wire clk;
    wire rst_n;
    reg  [31:0] reg_val;  // Wishbone register value

    assign clk   = wb_clk_i;
    assign rst_n = reg_val[0];

    //------------------------------------------------------------------------------
    // Wishbone slave port & register
    wire        valid;
    wire [3:0]  wstrb;
    reg         ready;

    assign valid = wbs_cyc_i & wbs_stb_i; 
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    assign wbs_ack_o = ready;
    assign wbs_dat_o = reg_val;

    always @(posedge clk) begin
      if (wb_rst_i) begin
        reg_val <= 32'h00000000;
        ready <= 1'b0;
      end
      else begin
        if (valid && !ready) begin
          ready <= 1'b1;
          if (wstrb[0]) reg_val[7:0]   <= wbs_dat_i[7:0];
          if (wstrb[1]) reg_val[15:8]  <= wbs_dat_i[15:8];
          if (wstrb[2]) reg_val[23:16] <= wbs_dat_i[23:16];
          if (wstrb[3]) reg_val[31:24] <= wbs_dat_i[31:24];
        end
        else begin
          ready <= 1'b0;
        end
      end
    end

    //------------------------------------------------------------------------------
    // Logic Analyzer Signals
    // la_data_out[127:32] <- 0
    //            [ 31: 0] <- gpio_out[31:0]
    assign la_data_out[127:32] = 96'd0;

    wire [127:0] la_data_input; // [127:32] -> not in use
                                // [ 31: 0] -> gpio_in[31:0]
    assign la_data_input = ~la_oenb & la_data_in;

    //------------------------------------------------------------------------------
    // IRQ
    assign user_irq = 3'b000;

    //------------------------------------------------------------------------------
    // MarmotCaravelChip
    MarmotCaravelChip MarmotCaravelChip (
     .clk(clk),
     .rst_n(rst_n),
     .io_in_0(io_in[0]),
     .io_in_1(io_in[1]),
     .io_in_2(io_in[2]),
     .io_in_3(io_in[3]),
     .io_in_4(io_in[4]),
     .io_in_5(io_in[5]),
     .io_in_6(io_in[6]),
     .io_in_7(io_in[7]),
     .io_in_8(io_in[8]),
     .io_in_9(io_in[9]),
     .io_in_10(io_in[10]),
     .io_in_11(io_in[11]),
     .io_in_12(io_in[12]),
     .io_in_13(io_in[13]),
     .io_in_14(io_in[14]),
     .io_in_15(io_in[15]),
     .io_in_16(io_in[16]),
     .io_in_17(io_in[17]),
     .io_in_18(io_in[18]),
     .io_in_19(io_in[19]),
     .io_in_20(io_in[20]),
     .io_in_21(io_in[21]),
     .io_in_22(io_in[22]),
     .io_in_23(io_in[23]),
     .io_in_24(io_in[24]),
     .io_in_25(io_in[25]),
     .io_in_26(io_in[26]),
     .io_in_27(io_in[27]),
     .io_in_28(io_in[28]),
     .io_in_29(io_in[29]),
     .io_in_30(io_in[30]),
     .io_in_31(io_in[31]),
     .io_in_32(io_in[32]),
     .io_in_33(io_in[33]),
     .io_in_34(io_in[34]),
     .io_in_35(io_in[35]),
     .io_in_36(io_in[36]),
     .io_in_37(io_in[37]),
     .io_out_0(io_out[0]),
     .io_out_1(io_out[1]),
     .io_out_2(io_out[2]),
     .io_out_3(io_out[3]),
     .io_out_4(io_out[4]),
     .io_out_5(io_out[5]),
     .io_out_6(io_out[6]),
     .io_out_7(io_out[7]),
     .io_out_8(io_out[8]),
     .io_out_9(io_out[9]),
     .io_out_10(io_out[10]),
     .io_out_11(io_out[11]),
     .io_out_12(io_out[12]),
     .io_out_13(io_out[13]),
     .io_out_14(io_out[14]),
     .io_out_15(io_out[15]),
     .io_out_16(io_out[16]),
     .io_out_17(io_out[17]),
     .io_out_18(io_out[18]),
     .io_out_19(io_out[19]),
     .io_out_20(io_out[20]),
     .io_out_21(io_out[21]),
     .io_out_22(io_out[22]),
     .io_out_23(io_out[23]),
     .io_out_24(io_out[24]),
     .io_out_25(io_out[25]),
     .io_out_26(io_out[26]),
     .io_out_27(io_out[27]),
     .io_out_28(io_out[28]),
     .io_out_29(io_out[29]),
     .io_out_30(io_out[30]),
     .io_out_31(io_out[31]),
     .io_out_32(io_out[32]),
     .io_out_33(io_out[33]),
     .io_out_34(io_out[34]),
     .io_out_35(io_out[35]),
     .io_out_36(io_out[36]),
     .io_out_37(io_out[37]),
     .io_oeb_0(io_oeb[0]),
     .io_oeb_1(io_oeb[1]),
     .io_oeb_2(io_oeb[2]),
     .io_oeb_3(io_oeb[3]),
     .io_oeb_4(io_oeb[4]),
     .io_oeb_5(io_oeb[5]),
     .io_oeb_6(io_oeb[6]),
     .io_oeb_7(io_oeb[7]),
     .io_oeb_8(io_oeb[8]),
     .io_oeb_9(io_oeb[9]),
     .io_oeb_10(io_oeb[10]),
     .io_oeb_11(io_oeb[11]),
     .io_oeb_12(io_oeb[12]),
     .io_oeb_13(io_oeb[13]),
     .io_oeb_14(io_oeb[14]),
     .io_oeb_15(io_oeb[15]),
     .io_oeb_16(io_oeb[16]),
     .io_oeb_17(io_oeb[17]),
     .io_oeb_18(io_oeb[18]),
     .io_oeb_19(io_oeb[19]),
     .io_oeb_20(io_oeb[20]),
     .io_oeb_21(io_oeb[21]),
     .io_oeb_22(io_oeb[22]),
     .io_oeb_23(io_oeb[23]),
     .io_oeb_24(io_oeb[24]),
     .io_oeb_25(io_oeb[25]),
     .io_oeb_26(io_oeb[26]),
     .io_oeb_27(io_oeb[27]),
     .io_oeb_28(io_oeb[28]),
     .io_oeb_29(io_oeb[29]),
     .io_oeb_30(io_oeb[30]),
     .io_oeb_31(io_oeb[31]),
     .io_oeb_32(io_oeb[32]),
     .io_oeb_33(io_oeb[33]),
     .io_oeb_34(io_oeb[34]),
     .io_oeb_35(io_oeb[35]),
     .io_oeb_36(io_oeb[36]),
     .io_oeb_37(io_oeb[37]),
     .gpio_out_0(la_data_out[0]),
     .gpio_out_1(la_data_out[1]),
     .gpio_out_2(la_data_out[2]),
     .gpio_out_3(la_data_out[3]),
     .gpio_out_4(la_data_out[4]),
     .gpio_out_5(la_data_out[5]),
     .gpio_out_6(la_data_out[6]),
     .gpio_out_7(la_data_out[7]),
     .gpio_out_8(la_data_out[8]),
     .gpio_out_9(la_data_out[9]),
     .gpio_out_10(la_data_out[10]),
     .gpio_out_11(la_data_out[11]),
     .gpio_out_12(la_data_out[12]),
     .gpio_out_13(la_data_out[13]),
     .gpio_out_14(la_data_out[14]),
     .gpio_out_15(la_data_out[15]),
     .gpio_out_16(la_data_out[16]),
     .gpio_out_17(la_data_out[17]),
     .gpio_out_18(la_data_out[18]),
     .gpio_out_19(la_data_out[19]),
     .gpio_out_20(la_data_out[20]),
     .gpio_out_21(la_data_out[21]),
     .gpio_out_22(la_data_out[22]),
     .gpio_out_23(la_data_out[23]),
     .gpio_out_24(la_data_out[24]),
     .gpio_out_25(la_data_out[25]),
     .gpio_out_26(la_data_out[26]),
     .gpio_out_27(la_data_out[27]),
     .gpio_out_28(la_data_out[28]),
     .gpio_out_29(la_data_out[29]),
     .gpio_out_30(la_data_out[30]),
     .gpio_out_31(la_data_out[31]),
     .gpio_in_0(la_data_input[0]),
     .gpio_in_1(la_data_input[1]),
     .gpio_in_2(la_data_input[2]),
     .gpio_in_3(la_data_input[3]),
     .gpio_in_4(la_data_input[4]),
     .gpio_in_5(la_data_input[5]),
     .gpio_in_6(la_data_input[6]),
     .gpio_in_7(la_data_input[7]),
     .gpio_in_8(la_data_input[8]),
     .gpio_in_9(la_data_input[9]),
     .gpio_in_10(la_data_input[10]),
     .gpio_in_11(la_data_input[11]),
     .gpio_in_12(la_data_input[12]),
     .gpio_in_13(la_data_input[13]),
     .gpio_in_14(la_data_input[14]),
     .gpio_in_15(la_data_input[15]),
     .gpio_in_16(la_data_input[16]),
     .gpio_in_17(la_data_input[17]),
     .gpio_in_18(la_data_input[18]),
     .gpio_in_19(la_data_input[19]),
     .gpio_in_20(la_data_input[20]),
     .gpio_in_21(la_data_input[21]),
     .gpio_in_22(la_data_input[22]),
     .gpio_in_23(la_data_input[23]),
     .gpio_in_24(la_data_input[24]),
     .gpio_in_25(la_data_input[25]),
     .gpio_in_26(la_data_input[26]),
     .gpio_in_27(la_data_input[27]),
     .gpio_in_28(la_data_input[28]),
     .gpio_in_29(la_data_input[29]),
     .gpio_in_30(la_data_input[30]),
     .gpio_in_31(la_data_input[31])
    );
`endif  // MARMOT_EMPTY

endmodule
