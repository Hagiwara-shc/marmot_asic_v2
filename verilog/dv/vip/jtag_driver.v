`timescale 1ns/10ps

module jtag_driver (
  output reg tck,
  output reg tms,
  output reg tdi,
  input wire tdo
);

  parameter TCK_PERIOD = 250;
  parameter IR_LEN = 5;

  // TCK free run
  reg tck_free;
  initial begin
    tck_free = 1'b0;
    forever #(TCK_PERIOD/2) tck_free = ~tck_free;
  end

  initial begin
    tck = 1'b0;
    tms = 1'b0;
    tdi = 1'b0;
  end

  // Drive TMS and TDI
  task drive;
    input      tms_i;
    input      tdi_i;
    output reg tdo_o;
    begin
      @(negedge tck_free);
      tck = 1'b0;
      tms = tms_i;
      tdi = tdi_i;
      @(posedge tck_free);
      tdo_o = tdo;
      tck = 1'b1;
    end
  endtask

  // Set TCK, TMS and TDI to 0
  task stop;
    begin
      @(negedge tck_free);
      tck = 1'b0;
      tms = 1'b0;
      tdi = 1'b0;
    end
  endtask

  // Test-Loggic-Reset
  task test_logic_reset;
    reg tdo_o;
    begin
      repeat (6) drive(1,0,tdo_o);
    end
  endtask

  // Run-Test-Idle
  task run_test_idle;
    reg tdo_o;
    begin
      test_logic_reset();
      drive(0,0,tdo_o);
    end
  endtask

  // Shift-IR (must be in Run-Teset/Idle state before calling this task)
  task shift_ir;
    input      [IR_LEN-1:0] ir_i;
    output reg [IR_LEN-1:0] ir_o;
    reg tdo_o;
    integer i;
    begin
      ir_o = 0;
      drive(0,0,tdo_o);           // Run-Test-Idle  -> Run-Test-Idle
      drive(1,0,tdo_o);           // Run-Test-Idle  -> Slect-DR-Scan
      drive(1,0,tdo_o);           // Select-DR-Scan -> Select-IR-Scan
      drive(0,0,tdo_o);           // Select-IR-Scan -> Capture-IR
      drive(0,0,tdo_o);           // Capture-IR     -> Shift-IR
      for (i = 0; i < IR_LEN-1; i = i + 1) begin
        drive(0,ir_i[i],ir_o[i]); // Shift-IR -> Shift-IR
      end
      drive(1,ir_i[IR_LEN-1],ir_o[IR_LEN-1]); // Shift-IR -> Exit1-IR
      drive(1,0,tdo_o);           // Exit1-IR  -> Update-IR
      drive(0,0,tdo_o);           // Update-IR -> Run-Test-Idle
      stop();                     // Run-Test-Idle
    end
  endtask

  // Shift-DR (must be in Run-Teset/Idle state before calling this task)
  task shift_dr;
    input      [5:0]  dr_len;
    input      [63:0] dr_i;
    output reg [63:0] dr_o;
    reg tdo_o;
    integer i;
    begin
      dr_o = 0;
      drive(0,0,tdo_o);           // Run-Test-Idle  -> Run-Test-Idle
      drive(1,0,tdo_o);           // Run-Test-Idle  -> Slect-DR-Scan
      drive(0,0,tdo_o);           // Select-DR-Scan -> Capture-DR
      drive(0,0,tdo_o);           // Capture-DR     -> Shift-DR
      for (i = 0; i < dr_len-1; i = i + 1) begin
        drive(0,dr_i[i],dr_o[i]); // Shift-DR -> Shift-DR
      end
      drive(1,dr_i[dr_len-1],dr_o[dr_len-1]); // Shift-DR -> Exit1-DR
      drive(1,0,tdo_o);           // Exit1-DR  -> Update-DR
      drive(0,0,tdo_o);           // Update-DR -> Run-Test-Idle
      stop();                     // Run-Test-Idle
    end
  endtask

endmodule

