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
  input  [3:0]  RW0_wmask,
  output [1:0]  ram_clk,
  output [1:0]  ram_csb0,
  output [1:0]  ram_web0,
  output [3:0]  ram_wmask00,
  output [3:0]  ram_wmask01,
  output [8:0]  ram_addr00,
  output [8:0]  ram_addr01,
  output [31:0] ram_din00,
  output [31:0] ram_din01,
  input  [31:0] ram_dout00,
  input  [31:0] ram_dout01,
  output [1:0]  ram_csb1,
  output [8:0]  ram_addr10,
  output [8:0]  ram_addr11
);

  wire [3:0]  ram_wmask0[1:0];
  wire [8:0]  ram_addr0[1:0];
  wire [31:0] ram_din0[1:0];
  wire [8:0]  ram_addr1[1:0];
  reg  [1:0]  ram_dout0_sel;

  // RAM input signals
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

  assign ram_wmask00 = ram_wmask0[0];
  assign ram_wmask01 = ram_wmask0[1];
  assign ram_addr00 = ram_addr0[0];
  assign ram_addr01 = ram_addr0[1];
  assign ram_din00 = ram_din0[0];
  assign ram_din01 = ram_din0[1];
  assign ram_addr10 = ram_addr1[0];
  assign ram_addr11 = ram_addr1[1];

  // RAM read data select
  always @(posedge RW0_clk) begin
    ram_dout0_sel <= ~ram_csb0;
  end

  assign RW0_rdata = ram_dout0_sel[0] ? ram_dout00 :
                                        ram_dout01;
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
  input         RW0_wmode,
  output        ram_clk,
  output        ram_csb0,
  output        ram_web0,
  output [3:0]  ram_wmask0,
  output [7:0]  ram_addr0,
  output [31:0] ram_din0,
  input  [31:0] ram_dout0,
  output        ram_csb1,
  output [7:0]  ram_addr1
);

  // RAM input signals
  assign ram_clk    = RW0_clk;
  assign ram_csb0   = ~RW0_en;
  assign ram_web0   = ~RW0_wmode;
  assign ram_wmask0 = {4{RW0_wmode}};
  assign ram_addr0  = {2'b00, RW0_addr};
  assign ram_din0   = {11'd0, RW0_wdata};
  assign ram_csb1   = 1'b1;
  assign ram_addr1  = 8'hff;

  // RAM read data
  assign RW0_rdata = ram_dout0[20:0];
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
  input  [1:0]  RW0_wmask,
  output        ram_clk,
  output        ram_csb0,
  output        ram_web0,
  output [7:0]  ram_wmask0,
  output [7:0]  ram_addr0,
  output [63:0] ram_din0,
  input  [63:0] ram_dout0,
  output        ram_csb1,
  output [7:0]  ram_addr1
);

  // RAM input signals
  assign ram_clk     = RW0_clk;
  assign ram_csb0    = ~RW0_en;
  assign ram_web0    = ~RW0_wmode;
  assign ram_wmask0  = {{4{RW0_wmask[1]}}, {4{RW0_wmask[0]}}};
  assign ram_addr0   = {1'b0, RW0_addr};
  assign ram_din0    = {{13'd0, RW0_wdata[37:19]}, {13'd0, RW0_wdata[18:0]}};
  assign ram_csb1    = 1'b1;
  assign ram_addr1   = 8'hff;

  // RAM read data
  assign RW0_rdata = {ram_dout0[50:32], ram_dout0[18:0]};
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
  input  [1:0]  RW0_wmask,
  output [3:0]  ram_clk,
  output [3:0]  ram_csb0,
  output [3:0]  ram_web0,
  output [7:0]  ram_wmask00,
  output [7:0]  ram_wmask01,
  output [7:0]  ram_wmask02,
  output [7:0]  ram_wmask03,
  output [8:0]  ram_addr00,
  output [8:0]  ram_addr01,
  output [8:0]  ram_addr02,
  output [8:0]  ram_addr03,
  output [63:0] ram_din00,
  output [63:0] ram_din01,
  output [63:0] ram_din02,
  output [63:0] ram_din03,
  input  [63:0] ram_dout00,
  input  [63:0] ram_dout01,
  input  [63:0] ram_dout02,
  input  [63:0] ram_dout03,
  output [3:0]  ram_csb1,
  output [8:0]  ram_addr10,
  output [8:0]  ram_addr11,
  output [8:0]  ram_addr12,
  output [8:0]  ram_addr13
);

  wire [7:0]  ram_wmask0[3:0];
  wire [8:0]  ram_addr0[3:0];
  wire [63:0] ram_din0[3:0];
  wire [8:0]  ram_addr1[3:0];
  reg  [3:0]  ram_dout0_sel;

  // RAM input signals
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

  assign ram_wmask00 = ram_wmask0[0];
  assign ram_wmask01 = ram_wmask0[1];
  assign ram_wmask02 = ram_wmask0[2];
  assign ram_wmask03 = ram_wmask0[3];
  assign ram_addr00 = ram_addr0[0];
  assign ram_addr01 = ram_addr0[1];
  assign ram_addr02 = ram_addr0[2];
  assign ram_addr03 = ram_addr0[3];
  assign ram_din00 = ram_din0[0];
  assign ram_din01 = ram_din0[1];
  assign ram_din02 = ram_din0[2];
  assign ram_din03 = ram_din0[3];
  assign ram_addr10 = ram_addr1[0];
  assign ram_addr11 = ram_addr1[1];
  assign ram_addr12 = ram_addr1[2];
  assign ram_addr13 = ram_addr1[3];

  // RAM read data2select
  always @(posedge RW0_clk) begin
    ram_dout0_sel <= ~ram_csb0;
  end

  assign RW0_rdata = ram_dout0_sel[0] ? ram_dout00 :
                     ram_dout0_sel[1] ? ram_dout01 :
                     ram_dout0_sel[2] ? ram_dout02 :
                                        ram_dout03;
endmodule
