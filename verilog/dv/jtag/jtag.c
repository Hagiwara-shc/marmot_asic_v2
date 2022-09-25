/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include <defs.h>
#include <stub.c>

#define MARMOT_ICACHE_TAG_RAM_CLK_DELAY   2
#define MARMOT_ICACHE_DATA_RAM0_CLK_DELAY 5
#define MARMOT_ICACHE_DATA_RAM1_CLK_DELAY 4
#define MARMOT_ICACHE_DATA_RAM2_CLK_DELAY 1
#define MARMOT_ICACHE_DATA_RAM3_CLK_DELAY 3

void main()
{
  /* 
  IO Control Registers
  | DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
  | 3-bits | 1-bit | 1-bit | 1-bit  | 1-bit  | 1-bit | 1-bit   | 1-bit   | 1-bit | 1-bit | 1-bit   |
  Output: 0000_0110_0000_1110  (0x1808) = GPIO_MODE_USER_STD_OUTPUT
  | DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
  | 110    | 0     | 0     | 0      | 0      | 0     | 0       | 1       | 0     | 0     | 0       |
  
   
  Input: 0000_0001_0000_1111 (0x0402) = GPIO_MODE_USER_STD_INPUT_NOPULL
  | DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
  | 001    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 1     | 0       |
  */

  /* Set up the housekeeping SPI to be connected internally so  */
  /* that external pin changes don't affect it.     */

  reg_spi_enable = 1;
  reg_wb_enable = 1;
  //reg_spimaster_config = 0xa002; // Enable, prescaler = 2,
                                        // connect to housekeeping SPI

  // Connect the housekeeping SPI to the SPI master
  // so that the CSB line is not left floating.  This allows
  // all of the GPIO pins to be used for user functions.

  // All GPIO pins are configured to be bi-directional for Marmot use
  reg_mprj_io_37 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_36 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_35 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_34 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_33 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_32 = GPIO_MODE_USER_STD_BIDIRECTIONAL;

#if 0
  // For actual use
  reg_mprj_io_31 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_30 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_29 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_28 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
#else
  // For simulation
  reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
#endif

  reg_mprj_io_27 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_26 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_25 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_24 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_23 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_22 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_21 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_20 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_19 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_18 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_17 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_16 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_15 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_14 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_13 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_12 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_11 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_10 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_9  = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_8  = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_7  = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_6  = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_5  = GPIO_MODE_USER_STD_BIDIRECTIONAL;
  reg_mprj_io_4  = GPIO_MODE_USER_STD_BIDIRECTIONAL;  // TCK
  reg_mprj_io_3  = GPIO_MODE_USER_STD_BIDIRECTIONAL;  // TMS
  reg_mprj_io_2  = GPIO_MODE_USER_STD_BIDIRECTIONAL;  // TDI
  reg_mprj_io_1  = GPIO_MODE_USER_STD_BIDIRECTIONAL;  // TDO
  //reg_mprj_io_0  = GPIO_MODE_USER_STD_BIDIRECTIONAL;

  /* Apply configuration */
  reg_mprj_xfer = 1;
  while (reg_mprj_xfer == 1);

  // Initialize LA probes [127:0]
  //  Input:
  //    [31: 0] <- Marmot.gpio_out[31:0]
  //  Output:
  //    [31: 0] -> Marmot.gpio_in[31:0]
  //    [63:32] -> Marmot.ram_clk_delay_sel[31:0]
  //                                       [ 4: 0] -> u_clk_skew_adjust_0.sel[4:0] (I-$ Tag RAM)
  //                                       [ 9: 5] -> u_clk_skew_adjust_1.sel[4:0] (I-$ Data RAM0)
  //                                       [14:10] -> u_clk_skew_adjust_1.sel[4:0] (I-$ Data RAM1)
  //                                       [19:15] -> u_clk_skew_adjust_1.sel[4:0] (I-$ Data RAM2)
  //                                       [24:20] -> u_clk_skew_adjust_1.sel[4:0] (I-$ Data RAM3)

  reg_la0_oenb = reg_la0_iena = 0xffffffff; // [31:0]
  reg_la1_oenb = reg_la1_iena = 0xffffffff; // [63:32]
  reg_la2_oenb = reg_la2_iena = 0xffffffff; // [95:64]
  reg_la3_oenb = reg_la3_iena = 0xffffffff; // [127:96]
  reg_la0_data = 0xffffffff;
  reg_la1_data = 0xffffffff;
  reg_la2_data = 0xffffffff;
  reg_la3_data = 0xffffffff;
  reg_la0_data = 0x00000000;
  reg_la1_data = 0x00000000;
  reg_la2_data = 0x00000000;
  reg_la3_data = 0x00000000;

  // Configure LA probes [31:0] as inputs to mgmt_soc
  reg_la0_iena = 0x00000000; // [31:0] <- Marmot.gpio_out[31:0]

  // Set clock delay for Marmot RAMs
  reg_la1_data =   (MARMOT_ICACHE_TAG_RAM_CLK_DELAY)
                 | (MARMOT_ICACHE_DATA_RAM0_CLK_DELAY << 5)
                 | (MARMOT_ICACHE_DATA_RAM1_CLK_DELAY << 10)
                 | (MARMOT_ICACHE_DATA_RAM2_CLK_DELAY << 15)
                 | (MARMOT_ICACHE_DATA_RAM3_CLK_DELAY << 20);

  // Start Marmot
  reg_mprj_slave = 0x00000001;

  // Wait for Marmot to finish and check result
  while (1) {
    reg_la0_data ^= 0xffffffff;

    if ((reg_la0_data_in & 0xc0000000) != 0x0) {
      if ((reg_la0_data_in & 0xc0000000) == 0x80000000) {
        reg_mprj_datal = 0x12340000;  // Pass
      } else {
        reg_mprj_datal = 0xdead0000;  // Fail
      }
      break;
    }
  }
}
