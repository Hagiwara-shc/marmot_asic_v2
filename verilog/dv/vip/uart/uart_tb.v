//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
 
// This testbench will exercise both the UART Tx and Rx.

`include "uart_tx.v"
`include "uart_rx.v"

`define XMODEM_SOH 8'h01
`define XMODEM_STX 8'h02
`define XMODEM_EOT 8'h04
`define XMODEM_ACK 8'h06
`define XMODEM_NAK 8'h15
`define XMODEM_CAN 8'h18
`define XMODEM_EOF 8'h1a /* Ctrl-Z */
`define XMODEM_BLOCK_SIZE 128
`define LF 8'h0a

`define PROMPT  "kzload> "
`define EXIT    "exit."
 
module uart_tb
(
  input     clk,
  input     rst,
  input     rxd,
  output    txd
);
 
  parameter CLKS_PER_BIT = 87;  // # of clocks(clk) per bit

  logic       r_Tx_DV;
  logic [7:0] r_Tx_Byte;
  logic       w_Tx_Active;
  logic       w_Tx_Done;

  logic       w_Rx_DV;
  logic [7:0] w_Rx_Byte;
  logic [8*50-1:0] recieved_data;
  logic       run;
  event       ev_prompt;
  event       ev_exit;
   
  uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) UART_RX_INST
    (.i_Clock(clk),
     .i_Rx_Serial(rxd),
     .o_Rx_DV(w_Rx_DV),
     .o_Rx_Byte(w_Rx_Byte)
    );
   
  uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) UART_TX_INST
    (.i_Clock(clk),
     .i_Tx_DV(r_Tx_DV),
     .i_Tx_Byte(r_Tx_Byte),
     .o_Tx_Active(w_Tx_Active),
     .o_Tx_Serial(txd),
     .o_Tx_Done(w_Tx_Done)
    );
 
//-------------------------------------------------------------
// Record & Display recieved data
string recieved_str;

initial begin
  recieved_str = "";
end

always @(posedge w_Rx_DV) begin
  if (~rst) begin
    recieved_str = {recieved_str, w_Rx_Byte};
    if (w_Rx_Byte == `LF) begin
      $fwrite(32'h80000002, "%s", recieved_str);
      recieved_str = "";
    end

    recieved_data = {recieved_data[8*49-1:0], w_Rx_Byte};
    //$display("[%d] recieved_data[8*8-1:0] = %s", testbench.cycle, string'(recieved_data[8*8-1:0]));
    if (recieved_data[8*8-1:0] == `PROMPT) -> ev_prompt;
    if (recieved_data[5*8-1:0] == `EXIT)   -> ev_exit;
  end
end

//-------------------------------------------------------------
// Send data
integer     i;
string      prog_hex;
integer     fd;
integer     not_eof;
string      line;
reg [31:0]  send_data;
reg [7:0]   block_number;
reg [7:0]   check_sum;

initial begin
  r_Tx_DV   = 1'b0;
  r_Tx_Byte = 8'h00;
  run = 0;

`ifdef HOGE
  if ($value$plusargs("TLRAM_PROG=%s", prog_hex)) begin
    fd = $fopen(prog_hex, "r");

    if (fd == 0) begin
      $display("Error: cannot open %s", prog_hex);
      $finish;
    end

    @ev_prompt;
    tsk_send_string("load\n");  // start XMODEM

    not_eof = 1;

    for (block_number = 1; not_eof; block_number = block_number + 1) begin
    //for (block_number = 1; block_number < 2; block_number = block_number + 1) begin
      $display("[%d] XMODEM: Sending block %d", testbench.cycle, block_number);

      if (block_number == 1) begin
        wait(recieved_data[7:0] == `XMODEM_NAK);
      end
      else begin
        wait(recieved_data[7:0] == `XMODEM_ACK);
      end

      tsk_send_byte(`XMODEM_SOH);   // SOH
      tsk_send_byte(block_number);  // block number
      tsk_send_byte(~block_number); // ~block number

      check_sum = 0;

      for (i = 0; i < `XMODEM_BLOCK_SIZE / 4; i = i + 1 ) begin  // send 1 block (128B) data
        not_eof = $fgets(line, fd);

        if (not_eof) begin
          line = line.substr(1,8);
          send_data = line.atohex;
        end
        else begin
          send_data = 0;
        end

        tsk_send_byte(send_data[7:0]);
        check_sum = check_sum + send_data[7:0];

        tsk_send_byte(send_data[15:8]);
        check_sum = check_sum + send_data[15:8];

        tsk_send_byte(send_data[23:16]);
        check_sum = check_sum + send_data[23:16];

        tsk_send_byte(send_data[31:24]);
        check_sum = check_sum + send_data[31:24];
      end

      tsk_send_byte(check_sum);     // check sum
      wait(recieved_data[7:0] == `XMODEM_ACK);
    end

    tsk_send_byte(`XMODEM_EOT); // EOT
    wait(recieved_data[7:0] == `XMODEM_ACK);

    @ev_prompt;
    tsk_send_string("run\n");  // run
    run = 1;

    @ev_exit;
    $finish;
  end

`ifdef XMODEM_SIMPLE_TEST
  @ev_prompt;
  tsk_send_string("load\n");  // start XMODEM

  wait(recieved_data[7:0] == `XMODEM_NAK);
  tsk_send_byte(`XMODEM_SOH);   // SOH
  tsk_send_byte(8'h01);         // block number
  tsk_send_byte(8'hfe);         // !(block number)

  // send 128byte data
  check_sum = 0;
  for (i = 0; i < `XMODEM_BLOCK_SIZE; i = i + 1) begin
    tsk_send_byte(i);
    check_sum = check_sum + i;
  end

  tsk_send_byte(check_sum);     // check sum
  wait(recieved_data[7:0] == `XMODEM_ACK);
  tsk_send_byte(`XMODEM_EOT);   // EOT
  wait(recieved_data[7:0] == `XMODEM_ACK);

  @ev_prompt;
  tsk_send_string("dump\n");  // dump sent data

  @ev_prompt;
  repeat (100) @(posedge clk);
  $finish;
`endif  // XMODEM_SIMPLE_TEST
`endif  // HOGE

end

`ifdef HOGE
//-------------------------------------------------------------
// Task: send string
task tsk_send_string (
  input string data
);
int i;
begin
  wait (w_Tx_Active == 1'b0);

  // send data
  for (i = 0; i < data.len(); i = i + 1) begin
    r_Tx_Byte = data[i];
    r_Tx_DV = 1'b1;
    @(posedge clk);
    r_Tx_DV = 1'b0;
    @(posedge w_Tx_Done);
    @(negedge w_Tx_Done);
  end
end
endtask

//-------------------------------------------------------------
// Task: send byte
task tsk_send_byte (
  input [7:0] data
);
begin
  wait (w_Tx_Active == 1'b0);

  // send data
  r_Tx_Byte = data;
  r_Tx_DV = 1'b1;
  @(posedge clk);
  r_Tx_DV = 1'b0;
  @(posedge w_Tx_Done);
  @(negedge w_Tx_Done);
end
endtask
`endif  // HOGE

endmodule
