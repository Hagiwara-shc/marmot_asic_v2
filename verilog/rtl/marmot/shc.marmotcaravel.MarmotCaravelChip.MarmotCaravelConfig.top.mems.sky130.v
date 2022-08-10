`ifndef VERBOSE
  `define VERBOSE 0
`endif

//-----------------------------------------------------------------------
// D-Cache Data RAM
//-----------------------------------------------------------------------
module data_arrays_0_ext(
  input  [9:0]  RW0_addr,
  input         RW0_clk,
  input  [31:0] RW0_wdata,
  output [31:0] RW0_rdata,
  input         RW0_en,
  input         RW0_wmode,
  input  [3:0]  RW0_wmask
);

  wire [1:0]  ram_clk;
  wire [1:0]  ram_csb0;
  wire [1:0]  ram_web0;
  wire [3:0]  ram_wmask0[1:0];
  wire [8:0]  ram_addr0[1:0];
  wire [31:0] ram_din0[1:0];
  wire [31:0] ram_dout0[1:0];
  wire [1:0]  ram_csb1;
  wire [8:0]  ram_addr1[1:0];
  reg  [1:0]  ram_dout0_sel;

  // RAM read data select
  always @(posedge RW0_clk) begin
    ram_dout0_sel <= ~ram_csb0;
  end

  assign RW0_rdata = ram_dout0_sel[0] ? ram_dout0[0] :
                                        ram_dout0[1];

  // RAM macros
  genvar i;
  for (i = 0; i < 2; i = i + 1) begin : g_ram
    assign ram_clk[i]    = RW0_clk;
    assign ram_csb0[i]   = ~(RW0_en & (RW0_addr[9] == i));
    assign ram_web0[i]   = ~RW0_wmode;
    assign ram_wmask0[i] = RW0_wmask;
    assign ram_addr0[i]  = RW0_addr[8:0];
    assign ram_din0[i]   = RW0_wdata;
    assign ram_csb1[i]   = 1'b1;
    assign ram_addr1[i]  = 9'h1ff;
  end

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) ram0 (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (ram_clk[0]),     // clock 0
      .csb0   (ram_csb0[0]),    // active low chip select 0
      .web0   (ram_web0[0]),    // active low write control 0
      .wmask0 (ram_wmask0[0]),  // write mask 0
      .addr0  (ram_addr0[0]),   // address 0
      .din0   (ram_din0[0]),    // write data 0
      .dout0  (ram_dout0[0]),   // read data 0
      .clk1   (ram_clk[0]),     // clock 1
      .csb1   (ram_csb1[0]),    // active low chip select 1
      .addr1  (ram_addr1[0]),   // address 1
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()                // read data 1
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) ram1 (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (ram_clk[1]),     // clock 0
      .csb0   (ram_csb0[1]),    // active low chip select 0
      .web0   (ram_web0[1]),    // active low write control 0
      .wmask0 (ram_wmask0[1]),  // write mask 0
      .addr0  (ram_addr0[1]),   // address 0
      .din0   (ram_din0[1]),    // write data 0
      .dout0  (ram_dout0[1]),   // read data 0
      .clk1   (ram_clk[1]),     // clock 1
      .csb1   (ram_csb1[1]),    // active low chip select 1
      .addr1  (ram_addr1[1]),   // address 1
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()                // read data 1
      /* verilator lint_on PINCONNECTEMPTY */
    );  
endmodule

//-----------------------------------------------------------------------
// D-Cache Tag RAM
//-----------------------------------------------------------------------
module tag_array_ext(
  input  [5:0]  RW0_addr,
  input         RW0_clk,
  input  [20:0] RW0_wdata,
  output [20:0] RW0_rdata,
  input         RW0_en,
  input         RW0_wmode
);

  wire        ram_clk    = RW0_clk;
  wire        ram_csb0   = ~RW0_en;
  wire        ram_web0   = ~RW0_wmode;
  wire [3:0]  ram_wmask0 = {4{RW0_wmode}};
  wire [7:0]  ram_addr0  = {2'b00, RW0_addr};
  wire [31:0] ram_din0   = {11'd0, RW0_wdata};
  wire [31:0] ram_dout0;
  wire        ram_csb1   = 1'b1;
  wire [7:0]  ram_addr1  = 8'hff;

  // RAM read data
  assign RW0_rdata = ram_dout0[20:0];

  // RAM macros
  sky130_sram_1kbyte_1rw1r_32x256_8 #(.VERBOSE(`VERBOSE)) ram (
`ifdef USE_POWER_PINS
    .vccd1  (vccd1),
    .vssd1  (vssd1),
`endif
    .clk0   (ram_clk),     // clock 0
    .csb0   (ram_csb0),    // active low chip select 0
    .web0   (ram_web0),    // active low write control 0
    .wmask0 (ram_wmask0),  // write mask 0
    .addr0  (ram_addr0),   // address 0
    .din0   (ram_din0),    // write data 0
    .dout0  (ram_dout0),   // read data 0
    .clk1   (ram_clk),     // clock 1
    .csb1   (ram_csb1),    // active low chip select 1
    .addr1  (ram_addr1),   // address 1
    /* verilator lint_off PINCONNECTEMPTY */
    .dout1  ()             // read data 1
    /* verilator lint_on PINCONNECTEMPTY */
  );  
endmodule

//-----------------------------------------------------------------------
// I-Cache Tag RAM
//-----------------------------------------------------------------------
module tag_array_0_ext(
  input  [6:0]  RW0_addr,
  input         RW0_clk,
  input  [37:0] RW0_wdata,
  output [37:0] RW0_rdata,
  input         RW0_en,
  input         RW0_wmode,
  input  [1:0]  RW0_wmask
);

  wire        ram_clk     = RW0_clk;
  wire        ram_csb0    = ~RW0_en;
  wire        ram_web0    = ~RW0_wmode;
  wire [7:0]  ram_wmask0  = {{4{RW0_wmask[1]}}, {4{RW0_wmask[0]}}};
  wire [7:0]  ram_addr0   = {1'b0, RW0_addr};
  wire [63:0] ram_din0    = {{13'd0, RW0_wdata[37:19]}, {13'd0, RW0_wdata[18:0]}};
  wire [63:0] ram_dout0;
  wire        ram_csb1    = 1'b1;
  wire [7:0]  ram_addr1   = 8'hff;

  // RAM read data
  assign RW0_rdata = {ram_dout0[50:32], ram_dout0[18:0]};

  // RAM macros
  sky130_sram_1kbyte_1rw1r_32x256_8 #(.VERBOSE(`VERBOSE)) raml (
`ifdef USE_POWER_PINS
    .vccd1  (vccd1),
    .vssd1  (vssd1),
`endif
    .clk0   (ram_clk),        // clock 0
    .csb0   (ram_csb0),       // active low chip select 0
    .web0   (ram_web0),       // active low write control 0
    .wmask0 (ram_wmask0[3:0]),// write mask 0
    .addr0  (ram_addr0),      // address 0
    .din0   (ram_din0[31:0]), // write data 0
    .dout0  (ram_dout0[31:0]),// read data 0
    .clk1   (ram_clk),        // clock 1
    .csb1   (ram_csb1),       // active low chip select 1
    .addr1  (ram_addr1),      // address 1
    /* verilator lint_off PINCONNECTEMPTY */
    .dout1  ()                // read data 1
    /* verilator lint_on PINCONNECTEMPTY */
  );  

  sky130_sram_1kbyte_1rw1r_32x256_8 #(.VERBOSE(`VERBOSE)) ramh (
`ifdef USE_POWER_PINS
    .vccd1  (vccd1),
    .vssd1  (vssd1),
`endif
    .clk0   (ram_clk),        // clock 0
    .csb0   (ram_csb0),       // active low chip select 0
    .web0   (ram_web0),       // active low write control 0
    .wmask0 (ram_wmask0[7:4]),// write mask 0
    .addr0  (ram_addr0),      // address 0
    .din0   (ram_din0[63:32]),// write data 0
    .dout0  (ram_dout0[63:32]),// read data 0
    .clk1   (ram_clk),        // clock 1
    .csb1   (ram_csb1),       // active low chip select 1
    .addr1  (ram_addr1),      // address 1
    /* verilator lint_off PINCONNECTEMPTY */
    .dout1  ()                // read data 1
    /* verilator lint_on PINCONNECTEMPTY */
  );  
endmodule

//-----------------------------------------------------------------------
// I-Cache Data RAM
//-----------------------------------------------------------------------
module data_arrays_0_0_ext(
  input  [10:0] RW0_addr,
  input         RW0_clk,
  input  [63:0] RW0_wdata,
  output [63:0] RW0_rdata,
  input         RW0_en,
  input         RW0_wmode,
  input  [1:0]  RW0_wmask
);

  wire [3:0]  ram_clk;
  wire [3:0]  ram_csb0;
  wire [3:0]  ram_web0;
  wire [7:0]  ram_wmask0[3:0];
  wire [8:0]  ram_addr0[3:0];
  wire [63:0] ram_din0[3:0];
  wire [63:0] ram_dout0[3:0];
  wire [3:0]  ram_csb1;
  wire [8:0]  ram_addr1[3:0];
  reg  [3:0]  ram_dout0_sel;

  // RAM read data select
  always @(posedge RW0_clk) begin
    ram_dout0_sel <= ~ram_csb0;
  end

  assign RW0_rdata = ram_dout0_sel[0] ? ram_dout0[0] :
                     ram_dout0_sel[1] ? ram_dout0[1] :
                     ram_dout0_sel[2] ? ram_dout0[2] :
                                        ram_dout0[3];

  // RAM macros
  genvar i;
  for (i = 0; i < 4; i = i + 1) begin : g_ram
    assign ram_clk[i]    = RW0_clk;
    assign ram_csb0[i]   = ~(RW0_en & (RW0_addr[10:9] == i));
    assign ram_web0[i]   = ~RW0_wmode;
    assign ram_wmask0[i] = {{4{RW0_wmask[1]}}, {4{RW0_wmask[0]}}};
    assign ram_addr0[i]  = RW0_addr[8:0];
    assign ram_din0[i]   = RW0_wdata;
    assign ram_csb1[i]   = 1'b1;
    assign ram_addr1[i]  = 9'h1ff;
  end

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) ram0l (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (ram_clk[0]),         // clock 0
      .csb0   (ram_csb0[0]),        // active low chip select 0
      .web0   (ram_web0[0]),        // active low write control 0
      .wmask0 (ram_wmask0[0][3:0]), // write mask 0
      .addr0  (ram_addr0[0]),       // address 0
      .din0   (ram_din0[0][31:0]),  // write data 0
      .dout0  (ram_dout0[0][31:0]), // read data 0
      .clk1   (ram_clk[0]),         // clock 1
      .csb1   (ram_csb1[0]),        // active low chip select 1
      .addr1  (ram_addr1[0]),       // address 1
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()                    // read data 1
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) ram0h (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (ram_clk[0]),         // clock 0
      .csb0   (ram_csb0[0]),        // active low chip select 0
      .web0   (ram_web0[0]),        // active low write control 0
      .wmask0 (ram_wmask0[0][7:4]), // write mask 0
      .addr0  (ram_addr0[0]),       // address 0
      .din0   (ram_din0[0][63:32]), // write data 0
      .dout0  (ram_dout0[0][63:32]),// read data 0
      .clk1   (ram_clk[0]),         // clock 1
      .csb1   (ram_csb1[0]),        // active low chip select 1
      .addr1  (ram_addr1[0]),       // address 1
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()                    // read data 1
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) ram1l (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (ram_clk[1]),         // clock 0
      .csb0   (ram_csb0[1]),        // active low chip select 0
      .web0   (ram_web0[1]),        // active low write control 0
      .wmask0 (ram_wmask0[1][3:0]), // write mask 0
      .addr0  (ram_addr0[1]),       // address 0
      .din0   (ram_din0[1][31:0]),  // write data 0
      .dout0  (ram_dout0[1][31:0]), // read data 0
      .clk1   (ram_clk[1]),         // clock 1
      .csb1   (ram_csb1[1]),        // active low chip select 1
      .addr1  (ram_addr1[1]),       // address 1
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()                    // read data 1
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) ram1h (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (ram_clk[1]),         // clock 0
      .csb0   (ram_csb0[1]),        // active low chip select 0
      .web0   (ram_web0[1]),        // active low write control 0
      .wmask0 (ram_wmask0[1][7:4]), // write mask 0
      .addr0  (ram_addr0[1]),       // address 0
      .din0   (ram_din0[1][63:32]), // write data 0
      .dout0  (ram_dout0[1][63:32]),// read data 0
      .clk1   (ram_clk[1]),         // clock 1
      .csb1   (ram_csb1[1]),        // active low chip select 1
      .addr1  (ram_addr1[1]),       // address 1
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()                    // read data 1
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) ram2l (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (ram_clk[2]),         // clock 0
      .csb0   (ram_csb0[2]),        // active low chip select 0
      .web0   (ram_web0[2]),        // active low write control 0
      .wmask0 (ram_wmask0[2][3:0]), // write mask 0
      .addr0  (ram_addr0[2]),       // address 0
      .din0   (ram_din0[2][31:0]),  // write data 0
      .dout0  (ram_dout0[2][31:0]), // read data 0
      .clk1   (ram_clk[2]),         // clock 1
      .csb1   (ram_csb1[2]),        // active low chip select 1
      .addr1  (ram_addr1[2]),       // address 1
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()                    // read data 1
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) ram2h (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (ram_clk[2]),         // clock 0
      .csb0   (ram_csb0[2]),        // active low chip select 0
      .web0   (ram_web0[2]),        // active low write control 0
      .wmask0 (ram_wmask0[2][7:4]), // write mask 0
      .addr0  (ram_addr0[2]),       // address 0
      .din0   (ram_din0[2][63:32]), // write data 0
      .dout0  (ram_dout0[2][63:32]),// read data 0
      .clk1   (ram_clk[2]),         // clock 1
      .csb1   (ram_csb1[2]),        // active low chip select 1
      .addr1  (ram_addr1[2]),       // address 1
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()                    // read data 1
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) ram3l (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (ram_clk[3]),         // clock 0
      .csb0   (ram_csb0[3]),        // active low chip select 0
      .web0   (ram_web0[3]),        // active low write control 0
      .wmask0 (ram_wmask0[3][3:0]), // write mask 0
      .addr0  (ram_addr0[3]),       // address 0
      .din0   (ram_din0[3][31:0]),  // write data 0
      .dout0  (ram_dout0[3][31:0]), // read data 0
      .clk1   (ram_clk[3]),         // clock 1
      .csb1   (ram_csb1[3]),        // active low chip select 1
      .addr1  (ram_addr1[3]),       // address 1
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()                    // read data 1
      /* verilator lint_on PINCONNECTEMPTY */
    );  

    sky130_sram_2kbyte_1rw1r_32x512_8 #(.VERBOSE(`VERBOSE)) ram3h (
  `ifdef USE_POWER_PINS
      .vccd1  (vccd1),
      .vssd1  (vssd1),
  `endif
      .clk0   (ram_clk[3]),         // clock 0
      .csb0   (ram_csb0[3]),        // active low chip select 0
      .web0   (ram_web0[3]),        // active low write control 0
      .wmask0 (ram_wmask0[3][7:4]), // write mask 0
      .addr0  (ram_addr0[3]),       // address 0
      .din0   (ram_din0[3][63:32]), // write data 0
      .dout0  (ram_dout0[3][63:32]),// read data 0
      .clk1   (ram_clk[3]),         // clock 1
      .csb1   (ram_csb1[3]),        // active low chip select 1
      .addr1  (ram_addr1[3]),       // address 1
      /* verilator lint_off PINCONNECTEMPTY */
      .dout1  ()                    // read data 1
      /* verilator lint_on PINCONNECTEMPTY */
    );  
endmodule
