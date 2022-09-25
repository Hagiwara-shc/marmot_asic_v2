  localparam IR_IDCODE = 5'b00001;
  localparam IR_DTMCS  = 5'b10000;
  localparam IR_DMI    = 5'b10001;

  localparam DM_DMCONTROL = 7'h10;
  localparam DM_DMSTATUS  = 7'h11;

  localparam IDCODE_EX = 32'h20000913;
  localparam DTMCS_EX  = 32'h00005071;

  reg [4:0]  ir_o;
  reg [63:0] dr_i;
  reg [63:0] dr_o;
  reg [6:0]  abits;

  initial begin
    jtag_driver.stop();
    while (`CORE.reset === 1'b1) begin
      jtag_driver.test_logic_reset();
    end
    jtag_driver.stop();
    jtag_driver.run_test_idle();

    // IDCODE
    jtag_driver.shift_ir(IR_IDCODE, ir_o);
    jtag_driver.shift_dr(32, 0, dr_o);
    $display("[%t] IDCODE = 0x%08x", $time, dr_o[31:0]);
    $display("     Version    = 0x%x",   dr_o[31:28]);
    $display("     PartNumber = 0x%04x", dr_o[27:12]);
    $display("     ManufId    = 0x%03x", dr_o[11:1]);
/*
    if (dr_o !== IDCODE_EX) begin
      $display("[%t] Error: IDCODE 0x%08x != 0x%08x", $time, dr_o[31:0], IDCODE_EX);
      $display("\n*** Test Fail ***");
      repeat (100) @(posedge clock);
      $finish;
    end
*/

    // DTMCS
    jtag_driver.shift_ir(IR_DTMCS, ir_o);
    jtag_driver.shift_dr(32, 0, dr_o);
    $display("[%t] DTMCS = 0x%08x", $time, dr_o[31:0]);
    $display("     dmihardreset = 0b%b", dr_o[17]);
    $display("     dmireset     = 0b%b", dr_o[16]);
    $display("     idle         = 0x%x", dr_o[14:12]);
    $display("     dmistat      = 0x%x", dr_o[11:10]);
    $display("     abits        = 0x%02x", dr_o[9:4]);
    $display("     version      = 0x%x", dr_o[3:0]);
    abits = dr_o[9:4];

    if (dr_o !== DTMCS_EX) begin
      $display("[%t] Error: DTMCS 0x%08x != 0x%08x", $time, dr_o[31:0], DTMCS_EX);
      $display("\n*** Test Fail ***");
      repeat (100) @(posedge clock);
      $finish;
    end

    // Activate Debug Module(?)
    dr_i = DM_DMCONTROL << 34 | (1 << 0) << 2 | 2;  // DMCONTROL.dmactive = 1
    jtag_driver.shift_ir(IR_DMI, ir_o);
    jtag_driver.shift_dr(abits+34, dr_i, dr_o);

    // Halt CPU
    $display("[%t] Halt CPU", $time);
    dr_i = DM_DMCONTROL << 34 | (1 << 31) << 2 | 2; // DMCONTROL.haltreq = 1
    jtag_driver.shift_ir(IR_DMI, ir_o);
    jtag_driver.shift_dr(abits+34, dr_i, dr_o);
/*
    // Wait until CPU halts
    dr_i = DM_DMSTATUS << 34 | 1;
    dr_o = 0;
    while (dr_o[9+2] !== 1'b1) begin                // DMSTATUS.allhalted == 1 ?
      jtag_driver.shift_ir(IR_DMI, ir_o);
      jtag_driver.shift_dr(abits+34, dr_i, dr_o);
    end

    $display("[%t] CPU halted", $time);
    dr_i = DM_DMCONTROL << 34 | (0 << 31) << 2 | 2; // DMCONTROL.haltreq = 0
    jtag_driver.shift_ir(IR_DMI, ir_o);
    jtag_driver.shift_dr(abits+34, dr_i, dr_o);
*/
    // Resume CPU
    $display("[%t] Resume CPU", $time);
    dr_i = DM_DMCONTROL << 34 | (1 << 30) << 2 | 2; // DMCONTROL.resumereq = 1
    jtag_driver.shift_ir(IR_DMI, ir_o);
    jtag_driver.shift_dr(abits+34, dr_i, dr_o);

    // Wait until CPU resumes
    dr_i = DM_DMSTATUS << 34 | 1;
    dr_o = 0;
    while (dr_o[9+2] !== 1'b0) begin                // DMSTATUS.allhalted == 0 ?
      jtag_driver.shift_ir(IR_DMI, ir_o);
      jtag_driver.shift_dr(abits+34, dr_i, dr_o);
    end
    $display("[%t] CPU resumed", $time);

    jtag_driver.stop();

    $display("\n*** Test Pass ***");
    repeat (100) @(posedge clock);
    $finish;
  end

