// *============================================================================================== 
// *
// *   MX25U3235F.v - 32M-BIT CMOS Serial Flash Memory
// *
// *           COPYRIGHT 2018 Macronix International Co., Ltd.
// *
// * Security Level: Macronix Proprietary
// *----------------------------------------------------------------------------------------------
// * Environment  : Cadence NC-Verilog
// * Reference Doc: MX25U3235F REV.1.6,JUL.12,2017
// * Creation Date: @(#)$Date: 2017/07/17 08:43:16 $
// * Version      : @(#)$Revision: 1.21 $
// * Description  : There is only one module in this file
// *                module MX25U3235F->behavior model for the 32M-Bit flash
// *----------------------------------------------------------------------------------------------
// * Note 1:model can load initial flash data from file when parameter Init_File = "xxx" was defined; 
// *        xxx: initial flash data file name;default value xxx = "none", initial flash data is "FF".
// * Note 2:power setup time is tVSL = 800_000 ns, so after power up, chip can be enable.
// * Note 3:because it is not checked during the Board system simulation the tCLQX timing is not
// *        inserted to the read function flow temporarily.
// * Note 4:more than one values (min. typ. max. value) are defined for some AC parameters in the
// *        datasheet, but only one of them is selected in the behavior model, e.g. program and
// *        erase cycle time is typical value. For the detailed information of the parameters,
// *        please refer to datasheet and contact with Macronix.
// * Note 5:If you have any question and suggestion, please send your mail to following email address :
// *                                    flash_model@mxic.com.tw
// *============================================================================================== 
// * timescale define
// *============================================================================================== 
`timescale 1ns / 100ps

// *============================================================================================== 
// * product parameter define
// *============================================================================================== 
    /*----------------------------------------------------------------------*/
    /* all the parameters users may need to change                          */
    /*----------------------------------------------------------------------*/
        `define Vtclqv 6  //30pf:8ns, 15pf:6ns
        `define File_Name         "none"     // Flash data file name for normal array
        `define File_Name_Secu    "none"     // Flash data file name for security region
        `define File_Name_SFDP    "none"     // Flash data file name for SFDP region
        `define VSEC_Pro_Reg      ~1'b0      // for protect
        `define VSEC_Pro_Reg_TOP  16'hffff   // for top protect
        `define VSEC_Pro_Reg_BOT  16'hffff   // for bottom protect
        `define VSecur_Reg1_0     2'b00      // security register[1:0]
        `define VSecur_Reg7       1'b0       // security register[7]
        `define VStatus_Reg7_2    6'b0       // status register[7:2] are non-volatile bits
    /*----------------------------------------------------------------------*/
    /* Define controller STATE                                              */
    /*----------------------------------------------------------------------*/
        `define         STANDBY_STATE           0
        `define         CMD_STATE               1
        `define         BAD_CMD_STATE           2


module MX25U3235F( SCLK, 
                    CS, 
                    SI, 
                    SO, 
                    WP, 
                    SIO3 );

// *============================================================================================== 
// * Declaration of ports (input, output, inout)
// *============================================================================================== 
    input  SCLK;    // Signal of Clock Input
    input  CS;      // Chip select (Low active)
    inout  SI;      // Serial Input/Output SIO0
    inout  SO;      // Serial Input/Output SIO1
    inout  WP;      // Hardware write protection or Serial Input/Output SIO2
    inout  SIO3;    // Serial Input/Output SIO3

// *============================================================================================== 
// * Declaration of parameter (parameter)
// *============================================================================================== 
    parameter   VERBOSE = 0;
    /*----------------------------------------------------------------------*/
    /* Density STATE parameter                                              */                  
    /*----------------------------------------------------------------------*/
    parameter   A_MSB           = 21,            
                TOP_Add         = 22'h3fffff,
                A_MSB_OTP       = 8,                
                Secur_TOP_Add   = 9'h1ff,
                Sector_MSB      = 9,
                A_MSB_SFDP       = 6,
                SFDP_TOP_Add     = 7'h7f,
                Buffer_Num      = 256,
                Block_MSB       = 5,
                Block_NUM       = 64;
  
    /*----------------------------------------------------------------------*/
    /* Define ID Parameter                                                  */
    /*----------------------------------------------------------------------*/
    parameter   ID_MXIC         = 8'hc2,
                ID_Device       = 8'h36,
                Memory_Type     = 8'h25,
                Memory_Density  = 8'h36;

    /*----------------------------------------------------------------------*/
    /* Define Initial Memory File Name                                      */
    /*----------------------------------------------------------------------*/
    parameter   Init_File       = `File_Name;      // initial flash data
    parameter   Init_File_Secu  = `File_Name_Secu; // initial flash data for security
    parameter   Init_File_SFDP  = `File_Name_SFDP;  // initial flash data for SFDP

    /*----------------------------------------------------------------------*/
    /* AC Characters Parameter                                              */
    /*----------------------------------------------------------------------*/
    parameter   tSHQZ           = 8,        // CS High to SO Float Time [ns]
                tCLQV           = `Vtclqv,          // Clock Low to Output Valid
                tCLQX           = 0,        // Output hold time
                tBP             = 12_000,      //  Byte program time
                tSE             = 35_000_000,      // Sector erase time  
                tBE             = 350_000_000,      // Block erase time
                tBE32           = 200_000_000,    // Block 32KB erase time
                tCE             = 25_000,      // unit is ms instead of ns  
                tPP             = 500_000,      // Program time
                tW              = 40_000_000,       // Write Status time 
                tWPS            = 12_000,     // Write Protection Select time
                tWP_SRAM        = 1_000, // Write protection sram time
                tRCR            = 20_000,     // reset time from read
                tRCP            = 20_000,     // reset time from program
                tRCE            = 12_000_000,     // reset time from erase
                tRHRL_E        = 12_000_000, // hardware reset recovery time for ers
                                                // in operation phase
                tRHRL_RP         = 20_000,  // hardware reset recovery time for
                                                // read/pgm phase or instruction coding phase
`ifdef SPEEDSIM
                tVSL            = 10_000;      // Time delay to chip select allowed
`else
                tVSL            = 800_000;     // Time delay to chip select allowed
`endif

    parameter   tPGM_CHK        = 2_000, // 2 us
                tERS_CHK        = 100_000; // 100 us
    parameter   tESL            = 20_000,       // delay after erase suspend command
                tPSL            = 20_000,       // delay after program suspend command
                tPRS            = 100_000,      // latency between program resume and next suspend
                tERS            = 400_000;      // latency between erase resume and next suspend

    /*----------------------------------------------------------------------*/
    /* Internal counter parameter                                           */
    /*----------------------------------------------------------------------*/
    parameter  Clock             = 50,      // Internal clock cycle = 100ns
               ERS_Count_BE32K   = tBE32 / (Clock*2) / 500,   // Internal clock cycle = 50us
               ERS_Count_SE      = tSE / (Clock*2) / 500,     // Internal clock cycle = 50us
               ERS_Count_BE      = tBE / (Clock*2) / 500,     // Internal clock cycle = 50us
               Echip_Count       = tCE  / (Clock*2) * 2000; 


    specify
        specparam   tSCLK   = 9.6,    // Clock Cycle Time [ns]
                    fSCLK   = 104,    // Clock Frequence except READ instruction
                    tTSCLK  = 11.9,    // Clock Cycle Time for 2XI/O READ instruction
                    fTSCLK  = 84,    // Clock Frequence for 2XI/O READ instruction
                    tTSCLK2 = 9.6,    // Clock Cycle Time for DREAD instruction
                    fTSCLK2 = 104,    // Clock Frequence for  DREAD instruction
                    tQSCLK  = 9.6,    // Clock Cycle Time for 4XI/O READ instruction
                    fQSCLK  = 104,    // Clock Frequence for 4XI/O READ instruction
                    tQSCLK2 = 11.9,   // Clock Cycle Time for 4XI/O READ instruction
                    fQSCLK2 = 84,   // Clock Frequence for 4XI/O READ instruction
                    tQSCLK3 = 9.6,   // Clock Cycle Time for QREAD instruction
                    fQSCLK3 = 104,   // Clock Frequence for  QREAD instruction
                    tRSCLK  = 18.5,   // Clock Cycle Time for READ instruction
                    fRSCLK  = 54,   // Clock Frequence for READ instruction
                    tCH     = 4.5,      // Clock High Time (min) [ns]
                    tCL     = 4.5,      // Clock Low  Time (min) [ns]
                    tCH_R   = 9,      // Clock High Time (min) [ns]
                    tCL_R   = 9,      // Clock Low  Time (min) [ns]
                    tSLCH   = 5,    // CS# Active Setup Time (relative to SCLK) (min) [ns]
                    tCHSL   = 5,    // CS# Not Active Hold Time (relative to SCLK)(min) [ns]
                    tSHSL_R = 5,    // CS High Time for read instruction (min) [ns]
                    tSHSL_W = 30,    // CS High Time for write instruction (min) [ns]
                    tDVCH   = 2,    // SI Setup Time (min) [ns]
                    tCHDX   = 3,    // SI Hold  Time (min) [ns]
                    tCHSH   = 2,    // CS# Active Hold Time (relative to SCLK) (min) [ns]
                    tSHCH   = 3,    // CS# Not Active Setup Time (relative to SCLK) (min) [ns]
                    tWHSL   = 10,    // Write Protection Setup Time                
                    tSHWL   = 10,    // Write Protection Hold  Time   
                    tRLRH   = 1_000,   // hardware reset pulse
                    tRS     = 15,     // reset setup time
                    tRH     = 15,     // reset hold time
                    tDP     = 10_000,
                    tRES1   = 30_000,
                    tRES2   = 30_000;
     endspecify

    /*----------------------------------------------------------------------*/
    /* Define Command Parameter                                             */
    /*----------------------------------------------------------------------*/
    parameter   WREN        = 8'h06, // WriteEnable   
                WRDI        = 8'h04, // WriteDisable  
                RDID        = 8'h9F, // ReadID    
                RDSR        = 8'h05, // ReadStatus        
                WRSR        = 8'h01, // WriteStatus   
                READ1X      = 8'h03, // ReadData          
                FASTREAD1X  = 8'h0b, // FastReadData  
                SE          = 8'h20, // SectorErase   
                BE2         = 8'h52, // 32k block erase
                CE1         = 8'h60, // ChipErase         
                CE2         = 8'hc7, // ChipErase         
                PP          = 8'h02, // PageProgram   
                DP          = 8'hb9, // DeepPowerDown
                RDP         = 8'hab, // ReleaseFromDeepPowerDown 
                RES         = 8'hab, // ReadElectricID 
                REMS        = 8'h90, // ReadElectricManufacturerDeviceID
                BE          = 8'hd8, // BlockErase        
                READ2X      = 8'hbb, // 2X Read 
                ENSO        = 8'hb1, // Enter secured OTP;
                EXSO        = 8'hc1, // Exit  secured OTP;
                RDSCUR      = 8'h2b, // Read  security  register;
                WRSCUR      = 8'h2f, // Write security  register;
                READ4X      = 8'heb, // 4XI/O Read;
                FIOPGM0     = 8'h38, // 4I Page Pgm load address and data all 4io
                SFDP_READ   = 8'h5a, // enter SFDP read mode
                DREAD       = 8'h3b, // Fastread dual output;
                QREAD       = 8'h6b, // Fastread quad output 1I/4O
                WPSEL       = 8'h68, // write protection selection
                SBLK        = 8'h36, // single block lock
                SBULK       = 8'h39, // single block unlock
                RDBLOCK     = 8'h3c, // block protect read
                GBLK        = 8'h7e, // gang block lock
                GBULK       = 8'h98; // gang block unlock
    parameter   EQIO        = 8'h35, // enable quad I/O
                RSTQIO      = 8'hf5, // reset quad I/O
                QPIID       = 8'haf, // QPI ID read
                W4READ      = 8'he7, // enable wrap quad read
                NOP         = 8'h00, // no operation
                RSTEN       = 8'h66, // reset enable
                RST         = 8'h99, // reset memory
                SUSP        = 8'hb0,
                RESU        = 8'h30,
                SBL         = 8'hc0; // set burst length

    /*----------------------------------------------------------------------*/
    /* Declaration of internal-signal                                       */
    /*----------------------------------------------------------------------*/
    reg  [7:0]           ARRAY[0:TOP_Add];  // memory array
    reg  [7:0]           Status_Reg;        // Status Register
    reg  [7:0]           CMD_BUS;
    reg  [23:0]          SI_Reg;            // temp reg to store serial in
    reg  [7:0]           Dummy_A[0:255];    // page size
    reg  [A_MSB:0]       Address;           
    reg  [Sector_MSB:0]  Sector;          
    reg  [Block_MSB:0]   Block;    
    reg  [Block_MSB+1:0] Block2;           
    reg  [2:0]           STATE;
    reg  [7:0]           SFDP_ARRAY[0:SFDP_TOP_Add];
    reg  [15:0] SEC_Pro_Reg_TOP;
    reg  [15:0] SEC_Pro_Reg_BOT;
    reg  [Block_NUM - 2:1] SEC_Pro_Reg;

    reg     SIO0_Reg;
    reg     SIO1_Reg;
    reg     SIO2_Reg;
    reg     SIO3_Reg;
    reg     SIO0_Out_Reg;
    reg     SIO1_Out_Reg;
    reg     SIO2_Out_Reg;
    reg     SIO3_Out_Reg;
    
    reg     Chip_EN;
    reg     DP_Mode;        // deep power down mode
    reg     Read_Mode;
    reg     Read_1XIO_Mode;
    reg     Read_1XIO_Chk;

    reg     tDP_Chk;
    reg     tRES1_Chk;
    reg     tRES2_Chk;

    reg     RDID_Mode;
    reg     RDSR_Mode;
    reg     RDSCUR_Mode;
    reg     FastRD_1XIO_Mode;   
    reg     PP_1XIO_Mode;
    reg     SE_4K_Mode;
    reg     BE_Mode;
    reg     BE32K_Mode;
    reg     BE64K_Mode;
    reg     CE_Mode;
    reg     WRSR_Mode;
    reg     RES_Mode;
    reg     REMS_Mode;
    reg     SCLK_EN;
    reg     SO_OUT_EN;   // for SO
    reg     SI_IN_EN;    // for SI
    reg     SFDP_Mode;
    reg     SEC_PROVFY_Mode;
    reg     RST_CMD_EN;
    reg     WRSCUR_Mode;
    reg     WR_WPSEL_Mode;
    reg     EN_Burst;
    reg     W4Read_Mode;
    reg     During_Susp_Wait;
    reg     Susp_Ready;
    reg     Susp_Trig;
    reg     Resume_Trig;
    reg     ERS_CLK;                  // internal clock register for erase timer
    reg     PGM_CLK;                  // internal clock register for program timer
    reg     WR2Susp;

    wire    CS_INT;
    wire    WP_B_INT;
    wire    RESETB_INT;
    wire    SCLK; 
    wire    WIP;
    wire    ESB;
    wire    PSB;
    wire    EPSUSP;
    wire    WEL;
    wire    SRWD;
    wire    Dis_CE, Dis_WRSR;  
    wire    WPSEL_Mode;
    wire    Norm_Array_Mode;

    wire    Pgm_Mode;
    wire    Ers_Mode;

    event   Resume_Event; 
    event   Susp_Event; 
    event   WRSR_Event; 
    event   BE_Event;
    event   SE_4K_Event;
    event   CE_Event;
    event   PP_Event;
    event   BE32K_Event;
    event   WPSEL_Event;
    event   SBLK_Event;
    event   SBULK_Event;
    event   GBLK_Event;
    event   GBULK_Event;
    event   RST_Event;
    event   RST_EN_Event;
    event   HDRST_Event;

    integer i;
    integer j;
    integer Bit; 
    integer Bit_Tmp; 
    integer Start_Add;
    integer End_Add;
    integer tWRSR;
    integer Burst_Length;
//    time    tRES;
    time    ERS_Time;
    time    tPP_Real;   //program time according to programmed byte number
    reg Read_SHSL;
    wire Write_SHSL;

    reg  [7:0]           Secur_ARRAY[0:Secur_TOP_Add]; // Secured OTP 
    reg  [7:0]           Secur_Reg;         // security register

    reg     Secur_Mode;     // enter secured mode
    reg     Read_2XIO_Mode;
    reg     Read_2XIO_Chk;
    reg     Byte_PGM_Mode;          
    reg     SI_OUT_EN;   // for SI
    reg     SO_IN_EN;    // for SO
    event   WRSCUR_Event;
   
    reg     Read_4XIO_Mode;
    reg     READ4X_Mode;
    reg     FREAD4X_Mode;
    reg     Read_4XIO_Chk;
    reg     FastRD_2XIO_Mode;
    reg     FastRD_2XIO_Chk;
    reg     FastRD_4XIO_Mode;
    reg     FastRD_4XIO_Chk;
    reg     PP_4XIO_Mode;
    reg     PP_4XIO_Load;
    reg     PP_4XIO_Chk;
    reg     EN4XIO_Read_Mode;
    reg     Set_4XIO_Enhance_Mode;
    reg     WP_OUT_EN;   // for WP pin
    reg     SIO3_OUT_EN; // for SIO3 pin
    reg     WP_IN_EN;    // for WP pin
    reg     SIO3_IN_EN;  // for SIO3 pin
    reg     ENQUAD;
    reg     During_RST_REC;
    wire    HPM_RD;
    wire    SIO3;
    wire    fQ_84M;
    wire    fQ_104M;
    assign  fQ_84M  = ((CMD_BUS == FASTREAD1X & ENQUAD ) | (CMD_BUS == W4READ) )& Read_4XIO_Chk;
    assign  fQ_104M = !fQ_84M && Read_4XIO_Chk;
    /*----------------------------------------------------------------------*/
    /* initial variable value                                               */
    /*----------------------------------------------------------------------*/
    initial begin
        
        Chip_EN         = 1'b0;
        Secur_Reg       = {`VSecur_Reg7,5'b0_0000,`VSecur_Reg1_0};
        Status_Reg      = {`VStatus_Reg7_2,2'b00};
        READ4X_Mode     = 1'b0;
        reset_sm;
    end   

    task reset_sm; 
        begin
            SEC_Pro_Reg[Block_NUM - 2:1] = `VSEC_Pro_Reg;
            SEC_Pro_Reg_TOP[15:0] = `VSEC_Pro_Reg_TOP;
            SEC_Pro_Reg_BOT[15:0] = `VSEC_Pro_Reg_BOT;
            During_RST_REC  = 1'b0;
            WRSCUR_Mode     = 1'b0;
            WR_WPSEL_Mode   = 1'b0;
            SIO0_Reg        = 1'b1;
            SIO1_Reg        = 1'b1;
            SIO2_Reg        = 1'b1;
            SIO3_Reg        = 1'b1;
            SIO0_Out_Reg    = 1'b1;
            SIO1_Out_Reg    = 1'b1;
            SIO2_Out_Reg    = 1'b1;
            SIO3_Out_Reg    = 1'b1;
            RST_CMD_EN      = 1'b0;
            ENQUAD          = 1'b0;
            SO_OUT_EN       = 1'b0; // SO output enable
            SI_IN_EN        = 1'b0; // SI input enable
            CMD_BUS         = 8'b0000_0000;
            Address         = 0;
            i               = 0;
            j               = 0;
            Bit             = 0;
            Bit_Tmp         = 0;
            Start_Add       = 0;
            End_Add         = 0;
            DP_Mode         = 1'b0;
            SCLK_EN         = 1'b1;
            Read_Mode       = 1'b0;
            Read_1XIO_Mode  = 1'b0;
            Read_1XIO_Chk   = 1'b0;
            tDP_Chk         = 1'b0;
            tRES1_Chk       = 1'b0;
            tRES2_Chk       = 1'b0;

            RDID_Mode       = 1'b0;
            RDSR_Mode       = 1'b0;
            RDSCUR_Mode     = 1'b0;

            PP_1XIO_Mode    = 1'b0;
            SE_4K_Mode      = 1'b0;
            BE_Mode         = 1'b0;
            BE32K_Mode      = 1'b0;
            BE64K_Mode      = 1'b0;
            CE_Mode         = 1'b0;
            WRSR_Mode       = 1'b0;
            RES_Mode        = 1'b0;
            REMS_Mode       = 1'b0;
            Read_SHSL       = 1'b0;
            FastRD_1XIO_Mode  = 1'b0;
            FastRD_2XIO_Mode  = 1'b0;
            FastRD_2XIO_Chk = 1'b0;
            FastRD_4XIO_Mode  = 1'b0;
            FastRD_4XIO_Chk = 1'b0;
            SI_OUT_EN       = 1'b0; // SI output enable
            SO_IN_EN        = 1'b0; // SO input enable
            Secur_Mode      = 1'b0;
            Read_2XIO_Mode  = 1'b0;
            Read_2XIO_Chk   = 1'b0;
            Byte_PGM_Mode   = 1'b0;
            WP_OUT_EN       = 1'b0; // for WP pin output enable
            SIO3_OUT_EN     = 1'b0; // for SIO3 pin output enable
            WP_IN_EN        = 1'b0; // for WP pin input enable
            SIO3_IN_EN      = 1'b0; // for SIO3 pin input enable
            Read_4XIO_Mode  = 1'b0;
            W4Read_Mode     = 1'b0;
            FREAD4X_Mode    = 1'b0;
            Read_4XIO_Chk   = 1'b0;
            PP_4XIO_Mode    = 1'b0;
            PP_4XIO_Load    = 1'b0;
            PP_4XIO_Chk     = 1'b0;
            EN4XIO_Read_Mode  = 1'b0;
            Set_4XIO_Enhance_Mode = 1'b0;
            SFDP_Mode = 1'b0;
            SEC_PROVFY_Mode   = 1'b0;
            EN_Burst          = 1'b0;
            Burst_Length      = 8;
            During_Susp_Wait  = 0;
            Susp_Ready        = 1'b1;
            Susp_Trig         = 1'b0;
            Resume_Trig       = 1'b0;
            ERS_CLK           = 1'b0;
            PGM_CLK           = 1'b0;
            WR2Susp          = 1'b0;
        end
    endtask // reset_sm
    
    /*----------------------------------------------------------------------*/
    /* initial flash data                                                   */
    /*----------------------------------------------------------------------*/
    initial 
    begin : memory_initialize
        for ( i = 0; i <=  TOP_Add; i = i + 1 )
            ARRAY[i] = 8'hff; 
        if ( Init_File != "none" )
            $readmemh(Init_File,ARRAY) ;
        for( i = 0; i <=  Secur_TOP_Add; i = i + 1 ) begin
            Secur_ARRAY[i]=8'hff;
        end
        if ( Init_File_Secu != "none" )
            $readmemh(Init_File_Secu,Secur_ARRAY) ;
        for( i = 0; i <=  SFDP_TOP_Add; i = i + 1 ) begin
            SFDP_ARRAY[i] = 8'hff;
        end
        if ( Init_File_SFDP != "none" )
            $readmemh(Init_File_SFDP,SFDP_ARRAY) ;
        // define SFDP code
        SFDP_ARRAY[8'h0] =  8'h53;
        SFDP_ARRAY[8'h1] =  8'h46;
        SFDP_ARRAY[8'h2] =  8'h44;
        SFDP_ARRAY[8'h3] =  8'h50;
        SFDP_ARRAY[8'h4] =  8'h00;
        SFDP_ARRAY[8'h5] =  8'h01;
        SFDP_ARRAY[8'h6] =  8'h01;
        SFDP_ARRAY[8'h7] =  8'hff;
        SFDP_ARRAY[8'h8] =  8'h00;
        SFDP_ARRAY[8'h9] =  8'h00;
        SFDP_ARRAY[8'ha] =  8'h01;
        SFDP_ARRAY[8'hb] =  8'h09;
        SFDP_ARRAY[8'hc] =  8'h30;
        SFDP_ARRAY[8'hd] =  8'h00;
        SFDP_ARRAY[8'he] =  8'h00;
        SFDP_ARRAY[8'hf] =  8'hff;
        SFDP_ARRAY[8'h10] =  8'hc2;
        SFDP_ARRAY[8'h11] =  8'h00;
        SFDP_ARRAY[8'h12] =  8'h01;
        SFDP_ARRAY[8'h13] =  8'h04;
        SFDP_ARRAY[8'h14] =  8'h60;
        SFDP_ARRAY[8'h15] =  8'h00;
        SFDP_ARRAY[8'h16] =  8'h00;
        SFDP_ARRAY[8'h17] =  8'hff;
        SFDP_ARRAY[8'h18] =  8'hff;
        SFDP_ARRAY[8'h19] =  8'hff;
        SFDP_ARRAY[8'h1a] =  8'hff;
        SFDP_ARRAY[8'h1b] =  8'hff;
        SFDP_ARRAY[8'h1c] =  8'hff;
        SFDP_ARRAY[8'h1d] =  8'hff;
        SFDP_ARRAY[8'h1e] =  8'hff;
        SFDP_ARRAY[8'h1f] =  8'hff;
        SFDP_ARRAY[8'h20] =  8'hff;
        SFDP_ARRAY[8'h21] =  8'hff;
        SFDP_ARRAY[8'h22] =  8'hff;
        SFDP_ARRAY[8'h23] =  8'hff;
        SFDP_ARRAY[8'h24] =  8'hff;
        SFDP_ARRAY[8'h25] =  8'hff;
        SFDP_ARRAY[8'h26] =  8'hff;
        SFDP_ARRAY[8'h27] =  8'hff;
        SFDP_ARRAY[8'h28] =  8'hff;
        SFDP_ARRAY[8'h29] =  8'hff;
        SFDP_ARRAY[8'h2a] =  8'hff;
        SFDP_ARRAY[8'h2b] =  8'hff;
        SFDP_ARRAY[8'h2c] =  8'hff;
        SFDP_ARRAY[8'h2d] =  8'hff;
        SFDP_ARRAY[8'h2e] =  8'hff;
        SFDP_ARRAY[8'h2f] =  8'hff;
        SFDP_ARRAY[8'h30] =  8'he5;
        SFDP_ARRAY[8'h31] =  8'h20;
        SFDP_ARRAY[8'h32] =  8'hf1;
        SFDP_ARRAY[8'h33] =  8'hff;
        SFDP_ARRAY[8'h34] =  8'hff;
        SFDP_ARRAY[8'h35] =  8'hff;
        SFDP_ARRAY[8'h36] =  8'hff;
        SFDP_ARRAY[8'h37] =  8'h01;
        SFDP_ARRAY[8'h38] =  8'h44;
        SFDP_ARRAY[8'h39] =  8'heb;
        SFDP_ARRAY[8'h3a] =  8'h08;
        SFDP_ARRAY[8'h3b] =  8'h6b;
        SFDP_ARRAY[8'h3c] =  8'h08;
        SFDP_ARRAY[8'h3d] =  8'h3b;
        SFDP_ARRAY[8'h3e] =  8'h04;
        SFDP_ARRAY[8'h3f] =  8'hbb;
        SFDP_ARRAY[8'h40] =  8'hfe;
        SFDP_ARRAY[8'h41] =  8'hff;
        SFDP_ARRAY[8'h42] =  8'hff;
        SFDP_ARRAY[8'h43] =  8'hff;
        SFDP_ARRAY[8'h44] =  8'hff;
        SFDP_ARRAY[8'h45] =  8'hff;
        SFDP_ARRAY[8'h46] =  8'h00;
        SFDP_ARRAY[8'h47] =  8'hff;
        SFDP_ARRAY[8'h48] =  8'hff;
        SFDP_ARRAY[8'h49] =  8'hff;
        SFDP_ARRAY[8'h4a] =  8'h44;
        SFDP_ARRAY[8'h4b] =  8'heb;
        SFDP_ARRAY[8'h4c] =  8'h0c;
        SFDP_ARRAY[8'h4d] =  8'h20;
        SFDP_ARRAY[8'h4e] =  8'h0f;
        SFDP_ARRAY[8'h4f] =  8'h52;
        SFDP_ARRAY[8'h50] =  8'h10;
        SFDP_ARRAY[8'h51] =  8'hd8;
        SFDP_ARRAY[8'h52] =  8'h00;
        SFDP_ARRAY[8'h53] =  8'hff;
        SFDP_ARRAY[8'h54] =  8'hff;
        SFDP_ARRAY[8'h55] =  8'hff;
        SFDP_ARRAY[8'h56] =  8'hff;
        SFDP_ARRAY[8'h57] =  8'hff;
        SFDP_ARRAY[8'h58] =  8'hff;
        SFDP_ARRAY[8'h59] =  8'hff;
        SFDP_ARRAY[8'h5a] =  8'hff;
        SFDP_ARRAY[8'h5b] =  8'hff;
        SFDP_ARRAY[8'h5c] =  8'hff;
        SFDP_ARRAY[8'h5d] =  8'hff;
        SFDP_ARRAY[8'h5e] =  8'hff;
        SFDP_ARRAY[8'h5f] =  8'hff;
        SFDP_ARRAY[8'h60] =  8'h00;
        SFDP_ARRAY[8'h61] =  8'h20;
        SFDP_ARRAY[8'h62] =  8'h50;
        SFDP_ARRAY[8'h63] =  8'h16;
        SFDP_ARRAY[8'h64] =  8'h9d;
        SFDP_ARRAY[8'h65] =  8'hf9;
        SFDP_ARRAY[8'h66] =  8'hc0;
        SFDP_ARRAY[8'h67] =  8'h64;
        SFDP_ARRAY[8'h68] =  8'hd9;
        SFDP_ARRAY[8'h69] =  8'hc8;
        SFDP_ARRAY[8'h6a] =  8'hff;
        SFDP_ARRAY[8'h6b] =  8'hff;
        SFDP_ARRAY[8'h6c] =  8'hff;
        SFDP_ARRAY[8'h6d] =  8'hff;
        SFDP_ARRAY[8'h6e] =  8'hff;
        SFDP_ARRAY[8'h6f] =  8'hff;
    end

// *============================================================================================== 
// * Input/Output bus operation 
// *============================================================================================== 
    assign   CS_INT     = ( During_RST_REC == 1'b0 && RESETB_INT == 1'b1 && Chip_EN ) ? CS : 1'b1;
    assign   WP_B_INT   = (Status_Reg[6] == 1'b0 && !ENQUAD) ? WP : 1'b1;
    assign   SO         = SO_OUT_EN ? SIO1_Out_Reg : 1'bz ;
    assign   SI         = SI_OUT_EN ? SIO0_Out_Reg : 1'bz ;
    assign   WP         = WP_OUT_EN   ? SIO2_Out_Reg : 1'bz ;
    assign   SIO3       = SIO3_OUT_EN ? SIO3_Out_Reg : 1'bz ;
    assign   RESETB_INT = (Status_Reg[6] == 1'b0 && ENQUAD == 1'b0)? ((SIO3 === 1'b1 || SIO3 === 1'b0) ? SIO3 : 1'b1): 1'b1;

    /*----------------------------------------------------------------------*/
    /* output buffer                                                        */
    /*----------------------------------------------------------------------*/
    always @( SIO3_Reg or SIO2_Reg or SIO1_Reg or SIO0_Reg ) begin
        if ( SIO3_OUT_EN && WP_OUT_EN && SO_OUT_EN && SI_OUT_EN ) begin
            SIO3_Out_Reg <= #tCLQV SIO3_Reg;
            SIO2_Out_Reg <= #tCLQV SIO2_Reg;
            SIO1_Out_Reg <= #tCLQV SIO1_Reg;
            SIO0_Out_Reg <= #tCLQV SIO0_Reg;
        end
        else if ( SO_OUT_EN && SI_OUT_EN ) begin
            SIO1_Out_Reg <= #tCLQV SIO1_Reg;
            SIO0_Out_Reg <= #tCLQV SIO0_Reg;
        end
        else if ( SO_OUT_EN ) begin
            SIO1_Out_Reg <= #tCLQV SIO1_Reg;
        end
    end

// *============================================================================================== 
// * Finite State machine to control Flash operation
// *============================================================================================== 
    /*----------------------------------------------------------------------*/
    /* power on                                                             */
    /*----------------------------------------------------------------------*/
    initial begin 
        Chip_EN   <= #tVSL 1'b1;// Time delay to chip select allowed 
    end
    
    /*----------------------------------------------------------------------*/
    /* Command Decode                                                       */
    /*----------------------------------------------------------------------*/
    assign ESB      = Secur_Reg[3] ;
    assign PSB      = Secur_Reg[2] ;
    assign EPSUSP   = ESB | PSB ;
    assign WIP      = Status_Reg[0] ;
    assign WEL      = Status_Reg[1] ;
    assign SRWD     = Status_Reg[7] ;
    assign Dis_CE   = Status_Reg[5] == 1'b1 || Status_Reg[4] == 1'b1 ||
                      Status_Reg[3] == 1'b1 || Status_Reg[2] == 1'b1;
    assign HPM_RD   = EN4XIO_Read_Mode == 1'b1 ;  
    assign Norm_Array_Mode = ~Secur_Mode;
    assign Dis_WRSR = (WP_B_INT == 1'b0 && Status_Reg[7] == 1'b1) || (!Norm_Array_Mode);
    assign Pgm_Mode = PP_1XIO_Mode || PP_4XIO_Mode;
    assign Ers_Mode = SE_4K_Mode || BE_Mode;
    assign WPSEL_Mode = Secur_Reg[7];
     
    always @ ( negedge CS_INT ) begin
        SI_IN_EN = 1'b1; 
        if ( ENQUAD ) begin
            SO_IN_EN    = 1'b1;
            SI_IN_EN    = 1'b1;
            WP_IN_EN    = 1'b1;
            SIO3_IN_EN  = 1'b1;
        end
        if ( EN4XIO_Read_Mode == 1'b1 ) begin
            if (VERBOSE) $display( $time, " Enter READX4 Function ..." );
            Read_SHSL = 1'b1;
            STATE   <= `CMD_STATE;
            Read_4XIO_Mode = 1'b1; 
        end
        if ( HPM_RD == 1'b0 ) begin
            Read_SHSL <= #1 1'b0;   
        end
        #1;
        tDP_Chk = 1'b0;
        tRES1_Chk = 1'b0;
        tRES2_Chk = 1'b0;
    end


    always @ ( posedge SCLK or posedge CS_INT ) begin
        #0;  
        if ( CS_INT == 1'b0 ) begin
            if ( ENQUAD ) begin
                Bit_Tmp = Bit_Tmp + 4;
                Bit     = Bit_Tmp - 1;
            end
            else begin
                Bit_Tmp = Bit_Tmp + 1;
                Bit     = Bit_Tmp - 1;
            end
            if ( SI_IN_EN == 1'b1 && SO_IN_EN == 1'b1 && WP_IN_EN == 1'b1 && SIO3_IN_EN == 1'b1 ) begin
                SI_Reg[23:0] = {SI_Reg[19:0], SIO3, WP, SO, SI};
            end 
            else  if ( SI_IN_EN == 1'b1 && SO_IN_EN == 1'b1 ) begin
                SI_Reg[23:0] = {SI_Reg[21:0], SO, SI};
            end
            else begin 
                SI_Reg[23:0] = {SI_Reg[22:0], SI};
            end

            if ( (EN4XIO_Read_Mode == 1'b1 && ((Bit == 5 && !ENQUAD) || (Bit == 23 && ENQUAD))) ) begin
                Address = SI_Reg[A_MSB:0];
                load_address(Address);
            end  
        end     
  
        if ( Bit == 7 && CS_INT == 1'b0 && ~HPM_RD ) begin
            STATE = `CMD_STATE;
            CMD_BUS = SI_Reg[7:0];
            if (VERBOSE) $display( $time," SI_Reg[7:0]= %h ", SI_Reg[7:0] );
            if ( During_RST_REC )
                $display ($time," During reset recovery time, there is command. \n");
        end

        if ( (EN4XIO_Read_Mode && (Bit == 1 || ENQUAD && Bit==7)) && CS_INT == 1'b0
             && HPM_RD && (SI_Reg[7:0]== RSTEN || SI_Reg[7:0]== RST)) begin
            CMD_BUS = SI_Reg[7:0];
            if (VERBOSE) $display( $time," SI_Reg[7:0]= %h ", SI_Reg[7:0] );
        end

        if ( CS == 1'b1 && RST_CMD_EN &&
             ( (Bit+1)%8 == 0 || (EN4XIO_Read_Mode && !ENQUAD && (Bit+1)%2 == 0) ) ) begin
            RST_CMD_EN <= #1 1'b0;
        end
        
        case ( STATE )
            `STANDBY_STATE: 
                begin
                end
        
            `CMD_STATE: 
                begin
                    case ( CMD_BUS ) 
                    WREN: 
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !PSB ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 ) begin 
                                    // $display( $time, " Enter Write Enable Function ..." );
                                    write_enable;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE; 
                            end 
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE; 
                        end
                     
                    WRDI:   
                        begin
                            if ( !DP_Mode && ( !WIP || During_Susp_Wait ) && Chip_EN && ~HPM_RD ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 ) begin 
                                    // $display( $time, " Enter Write Disable Function ..." );
                                    write_disable;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE; 
                            end 
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE; 
                        end 

                  RDID:
                      begin
                          if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD ) begin
                              if (VERBOSE) $display( $time, " Enter Read ID Function ..." );
                               Read_SHSL = 1'b1;
                               RDID_Mode = 1'b1;
                           end
                          else if ( Bit == 7 )
                              STATE <= `BAD_CMD_STATE;
                        end

                   QPIID:
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && ENQUAD ) begin
                                if (VERBOSE) $display( $time, " Enter Read ID Function ..." );
                                Read_SHSL = 1'b1;
                                RDID_Mode = 1'b1;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                      
                    RDSR:
                        begin 
                            if ( !DP_Mode && Chip_EN && ~HPM_RD) begin 
                                if (VERBOSE) $display( $time, " Enter Read Status Function ..." );
                                Read_SHSL = 1'b1;
                                RDSR_Mode = 1'b1 ;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;        
                        end

           
                    WRSR:
                        begin
                            if ( !DP_Mode && !WIP && WEL && Chip_EN && ~HPM_RD && !EPSUSP ) begin
                                if ( CS_INT == 1'b1 && Bit == 15 ) begin
                                    if ( Dis_WRSR ) begin 
                                        Status_Reg[1] = 1'b0; 
                                    end
                                    else begin 
                                        if (VERBOSE) $display( $time, " Enter Write Status Function ..." ); 
                                        ->WRSR_Event;
                                        WRSR_Mode = 1'b1;
                                    end                  
                                end    
                                else if ( CS_INT == 1'b1 && Bit < 15 || Bit > 15 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end 
                      
                    SBL:
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) begin  // no WEL
                                if ( CS_INT == 1'b1 && Bit == 15 ) begin
                                    if (VERBOSE) $display( $time, " Enter Set Burst Length Function ..." );
                                    EN_Burst = !SI_Reg[4];
                                    if ( SI_Reg[7:5]==3'b000 && SI_Reg[3:2]==2'b00 ) begin
                                        if ( SI_Reg[1:0]==2'b00 )
                                            Burst_Length = 8;
                                        else if ( SI_Reg[1:0]==2'b01 )
                                            Burst_Length = 16;
                                        else if ( SI_Reg[1:0]==2'b10 )
                                            Burst_Length = 32;
                                        else if ( SI_Reg[1:0]==2'b11 )
                                            Burst_Length = 64;
                                    end
                                    else begin
                                        Burst_Length = 8;
                                    end
                                end
                                else if ( CS_INT == 1'b1 && Bit < 15 || Bit > 15 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    READ1X: 
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD ) begin
                                if (VERBOSE) $display( $time, " Enter Read Data Function ..." );
                                Read_SHSL = 1'b1;
                                if ( Bit == 31 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                    load_address(Address);
                                end
                                Read_1XIO_Mode = 1'b1;
                            end 
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;                                
                        end

                    W4READ:
                        begin
                            if ( !DP_Mode && !WIP && Status_Reg[6] && Chip_EN && ~HPM_RD && !ENQUAD ) begin
                                if (VERBOSE) $display( $time, " Enter Quad I/O Read Data Function ..." );
                                Read_SHSL = 1'b1;
                                if ( Bit == 13 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                    load_address(Address);
                                end
                                Read_4XIO_Mode = 1'b1;
                                W4Read_Mode = 1'b1;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end
                     
                    FASTREAD1X:
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) begin
                                if (VERBOSE) $display( $time, " Enter Fast Read Data Function ..." );
                                Read_SHSL = 1'b1;
                                if ( Bit == 31 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                    load_address(Address);
                                end
                                if (ENQUAD) begin
                                    Read_4XIO_Mode = 1'b1;
                                    FREAD4X_Mode   = 1'b1;
                                end
                                else begin
                                    FastRD_1XIO_Mode = 1'b1;
                                end
                            end 
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;                                
                        end
                    SE: 
                        begin
                            if ( !DP_Mode && !WIP && WEL && !Secur_Mode &&  Chip_EN && ~HPM_RD && !EPSUSP ) begin
                                if ( Bit == 31 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                end
                                if ( CS_INT == 1'b1 && Bit == 31 ) begin
                                    if (VERBOSE) $display( $time, " Enter Sector Erase Function ..." );
                                    ->SE_4K_Event;
                                    SE_4K_Mode = 1'b1;
                                end
                                else if ( CS_INT == 1'b1 && Bit < 31 || Bit > 31 )
                                     STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    BE: 
                        begin
                            if ( !DP_Mode && !WIP && WEL && !Secur_Mode &&  Chip_EN && ~HPM_RD && !EPSUSP ) begin
                                if ( Bit == 31 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                end
                                if ( CS_INT == 1'b1 && Bit == 31 ) begin
                                    if (VERBOSE) $display( $time, " Enter Block Erase Function ..." );
                                    ->BE_Event;
                                    BE_Mode = 1'b1;
                                    BE64K_Mode = 1'b1;
                                end 
                                else if ( CS_INT == 1'b1 && Bit < 31 || Bit > 31 )
                                    STATE <= `BAD_CMD_STATE;
                            end 
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    BE2:
                        begin
                            if ( !DP_Mode && !WIP && WEL && !Secur_Mode && Chip_EN && ~HPM_RD && !EPSUSP ) begin
                                if ( Bit == 31 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                end
                                if ( CS_INT == 1'b1 && Bit == 31  ) begin
                                    if (VERBOSE) $display( $time, " Enter Block 32K Erase Function ..." );
                                    ->BE32K_Event;
                                    BE_Mode = 1'b1;
                                    BE32K_Mode = 1'b1;
                                end
                                else if ( CS_INT == 1'b1 && Bit < 31 || Bit > 31 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    SUSP:
                        begin
                            if ( !DP_Mode && !Secur_Mode &&  Chip_EN && ~HPM_RD && !EPSUSP ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 ) begin
                                    if (VERBOSE) $display( $time, " Enter Suspend Function ..." );
                                    ->Susp_Event;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    RESU:
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && EPSUSP ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 ) begin
                                    if (VERBOSE) $display( $time, " Enter Resume Function ..." );
                                    Secur_Mode = 1'b0;
                                    ->Resume_Event;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end
                      
                    CE1, CE2:
                        begin
                            if ( !DP_Mode && !WIP && WEL && !Secur_Mode && Chip_EN && ~HPM_RD && !EPSUSP) begin
                                if ( CS_INT == 1'b1 && Bit == 7 ) begin
                                    if (VERBOSE) $display( $time, " Enter Chip Erase Function ..." );
                                    ->CE_Event;
                                    CE_Mode = 1'b1 ;
                                end 
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 ) 
                                STATE <= `BAD_CMD_STATE;
                        end
                      
                    PP: 
                        begin
                            if ( !DP_Mode && !WIP && WEL && Chip_EN && ~HPM_RD && !PSB) begin
                                if ( Bit == 31 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                    load_address(Address);
                                end

                                if ( Bit == 31 ) begin
                                    if (VERBOSE) $display( $time, " Enter Page Program Function ..." );
                                    if ( CS_INT == 1'b0 ) begin
                                        ->PP_Event;
                                        PP_1XIO_Mode = 1'b1;
                                    end  
                                end
                                else if ( CS_INT == 1 && (Bit < 31 || ((Bit + 1) % 8 !== 0)))
                                    STATE <= `BAD_CMD_STATE;
                                end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    SFDP_READ:
                        begin
                            if ( !DP_Mode && !Secur_Mode && !WIP && Chip_EN ) begin
                                if (VERBOSE) $display( $time, " Enter SFDP read mode ..." );
                                if ( Bit == 31 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                    load_address(Address);
                                end
                                if ( Bit == 7 ) begin
                                    SFDP_Mode = 1;
                                    if (ENQUAD) begin
                                        Read_4XIO_Mode = 1'b1;
                                    end
                                    else begin
                                        FastRD_1XIO_Mode = 1'b1;
                                    end
                                    Read_SHSL = 1'b1;
                                end
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    WPSEL:
                        begin
                            if ( !DP_Mode && !WIP && WEL && Norm_Array_Mode && Chip_EN && !EPSUSP ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 ) begin
                                    if (VERBOSE) $display( $time, " Enter Write Protection Selection Function ..." );
                                    ->WPSEL_Event;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    SBLK:
                        begin
                            if ( !DP_Mode && !WIP && WEL && Norm_Array_Mode && WPSEL_Mode && Chip_EN && !EPSUSP ) begin
                                if ( Bit == 31 ) begin
                                    Address = SI_Reg[A_MSB:0] ;
                                end
                                if ( CS_INT == 1'b1 && Bit == 31 ) begin
                                    if (VERBOSE) $display( $time, " Enter Sector Protection Function ..." );
                                    ->SBLK_Event;
                                end
                                else if ( CS_INT == 1'b1 && Bit < 31 || Bit > 31 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    SBULK:
                        begin
                            if ( !DP_Mode && !WIP && WEL && Norm_Array_Mode && WPSEL_Mode && Chip_EN && !EPSUSP ) begin
                                if ( Bit == 31 ) begin
                                    Address = SI_Reg[A_MSB:0] ;
                                end
                                if ( CS_INT == 1'b1 && Bit == 31 ) begin
                                    if (VERBOSE) $display( $time, " Enter Sector Unprotection Function ..." );
                                    ->SBULK_Event;
                                end
                                else if ( CS_INT == 1'b1 && Bit < 31 || Bit > 31 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    RDBLOCK:
                        begin
                            if ( !DP_Mode && !WIP && WPSEL_Mode && Chip_EN ) begin
                                if (VERBOSE) $display( $time, " Enter Sector protection Read Function ..." );
                                if ( Bit == 31 ) begin
                                    Address = SI_Reg[A_MSB:0];
                                end
                                if ( Bit == 7 ) begin
                                    SEC_PROVFY_Mode = 1'b1;
                                    Read_SHSL = 1'b1;
                                end
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    GBLK:
                        begin
                            if ( !DP_Mode && !WIP && WEL && Norm_Array_Mode && WPSEL_Mode && Chip_EN && !EPSUSP ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 ) begin
                                    if (VERBOSE) $display( $time, " Enter Chip Protection Function ..." );
                                    ->GBLK_Event;
                                end
                                else if ( CS_INT == 1'b1 && Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    GBULK:
                        begin
                            if ( !DP_Mode && !WIP && WEL && Norm_Array_Mode && WPSEL_Mode && Chip_EN && !EPSUSP ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 ) begin
                                    if (VERBOSE) $display( $time, " Enter Chip Unprotection Function ..." );
                                    ->GBULK_Event;
                                end
                                else if ( CS_INT == 1'b1 && Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    DP:
                        begin
                            if ( !WIP && Chip_EN && ~HPM_RD && !EPSUSP ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 && DP_Mode == 1'b0 ) begin
                                    if (VERBOSE) $display( $time, " Enter Deep Power Down Function ..." );
                                    tDP_Chk = 1'b1;
                                    DP_Mode = 1'b1;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    RDP, RES:
                        begin
                            if ( ( !WIP || During_Susp_Wait ) && Chip_EN && ~HPM_RD ) begin
                                // $display( $time, " Enter Release from Deep Power Down Function ..." );
                                RES_Mode = 1'b1;
                                Read_SHSL = 1'b1;
                                if ( CS_INT == 1'b1 && SCLK == 1'b0 && tRES1_Chk &&
                                   ((Bit >= 38 && !ENQUAD) || (Bit >=38 && ENQUAD)) ) begin
                                    tRES1_Chk = 1'b0;
                                    tRES2_Chk = 1'b1;
                                    DP_Mode = 1'b0;
                                end
                                else if ( CS_INT == 1'b1 && SCLK == 1'b1 && tRES1_Chk &&
                                        ((Bit >= 39 && !ENQUAD) || (Bit >=39 && ENQUAD)) ) begin
                                    tRES1_Chk = 1'b0;
                                    tRES2_Chk = 1'b1;
                                    DP_Mode = 1'b0;
                                end
                                else if ( CS_INT == 1'b1 && Bit > 0 && DP_Mode ) begin
                                    tRES1_Chk = 1'b1;
                                    DP_Mode = 1'b0;
                                end
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end



                    REMS:
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD) begin
                                if ( Bit == 31 ) begin
                                    Address = SI_Reg[A_MSB:0] ;
                                end
                                if (VERBOSE) $display( $time, " Enter Read Electronic Manufacturer & ID Function ..." );
                                Read_SHSL = 1'b1;
                                REMS_Mode = 1'b1;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;                            
                        end

                    READ2X: 
                        begin 
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD ) begin
                                if (VERBOSE) $display( $time, " Enter READX2 Function ..." );
                                Read_SHSL = 1'b1;
                                if ( Bit == 19 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                    load_address(Address);
                                end
                                Read_2XIO_Mode = 1'b1;
                            end 
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;                                
                        end     

                    ENSO: 
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 ) begin  
                                    if (VERBOSE) $display( $time, " Enter ENSO  Function ..." );
                                    enter_secured_otp;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end
                      
                    EXSO: 
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 ) begin  
                                    if (VERBOSE) $display( $time, " Enter EXSO  Function ..." );
                                    exit_secured_otp;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end
                      
                    RDSCUR: 
                        begin
                            if ( !DP_Mode && Chip_EN && ~HPM_RD) begin 
                                // $display( $time, " Enter Read Secur_Register Function ..." );
                                Read_SHSL = 1'b1;
                                RDSCUR_Mode = 1'b1;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;                                
                        end
                      
                      
                    WRSCUR: 
                        begin
                            if ( !DP_Mode && !WIP && WEL && !Secur_Mode && Chip_EN && ~HPM_RD && !EPSUSP ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 ) begin  
                                    if (VERBOSE) $display( $time, " Enter WRSCUR Secur_Register Function ..." );
                                    ->WRSCUR_Event;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end
                      
                    READ4X:
                        begin
                            if ( !DP_Mode && !WIP && (Status_Reg[6]|ENQUAD) && Chip_EN && ~HPM_RD ) begin
                                if (VERBOSE) $display( $time, " Enter READX4 Function ..." );
                                Read_SHSL = 1'b1;
                                if ( (Bit == 13 && !ENQUAD) || (Bit == 31 && ENQUAD) ) begin
                                    Address = SI_Reg [A_MSB:0];
                                    load_address(Address);
                                end
                                Read_4XIO_Mode = 1'b1;
                                READ4X_Mode    = 1'b1;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;                            

                        end

                    DREAD:
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD ) begin
                                if (VERBOSE) $display( $time, " Enter Fast Read dual output Function ..." );
                                Read_SHSL = 1'b1;
                                if ( Bit == 31 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                    load_address(Address);
                                end
                                FastRD_2XIO_Mode =1'b1;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;                            
                        end

                    QREAD:
                        begin
                            if ( !DP_Mode && !WIP && Status_Reg[6] && Chip_EN && ~HPM_RD && !ENQUAD ) begin
                                if (VERBOSE) $display( $time, " Enter Fast Read quad output Function ..." );
                                Read_SHSL = 1'b1;
                                if ( Bit == 31 ) begin
                                    Address = SI_Reg[A_MSB:0] ;
                                    load_address(Address);
                                end
                                FastRD_4XIO_Mode =1'b1;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end
                      
                    FIOPGM0: 
                        begin
                            if ( !DP_Mode && !WIP && WEL && Status_Reg[6] && Chip_EN && ~HPM_RD && !ENQUAD && !PSB) begin
                                if ( Bit == 13 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                    load_address(Address);
                                end
                                PP_4XIO_Load= 1'b1;
                                SO_IN_EN    = 1'b1;
                                SI_IN_EN    = 1'b1;
                                WP_IN_EN    = 1'b1;
                                SIO3_IN_EN  = 1'b1;
                                if ( Bit == 13 ) begin
                                    if (VERBOSE) $display( $time, " Enter 4io Page Program Function ..." );
                                    ->PP_Event;
                                    PP_4XIO_Mode= 1'b1;
                                end
                                else if ( CS_INT == 1 && (Bit < 15 || (Bit + 1)%2 !== 0 ))begin
                                    STATE <= `BAD_CMD_STATE;
                                end    
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    EQIO:
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 ) begin
                                    if (VERBOSE) $display( $time, " Enable Quad I/O Function ..." );
                                    ENQUAD = 1'b1;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    RSTQIO:
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && ENQUAD ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 ) begin
                                    if (VERBOSE) $display( $time, " Exiting QPI mode ..." );
                                    ENQUAD = 1'b0;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    RSTEN:
                        begin
                            if ( Chip_EN ) begin
                                if ( CS_INT == 1'b1 && (Bit == 7 || (EN4XIO_Read_Mode && Bit == 1)) ) begin
                                    if (VERBOSE) $display( $time, " Reset enable ..." );
                                    ->RST_EN_Event;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    RST:
                        begin
                            if ( Chip_EN && RST_CMD_EN ) begin
                                if ( CS_INT == 1'b1 && (Bit == 7 || (EN4XIO_Read_Mode && Bit == 1)) ) begin
                                    if (VERBOSE) $display( $time, " Reset memory ..." );
                                    ->RST_Event;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                    NOP:
                        begin
                        end

                    default: 
                        begin
                            STATE <= `BAD_CMD_STATE;
                        end
                    endcase
                end
                 
            `BAD_CMD_STATE: 
                begin
                end
            
            default: 
                begin
                STATE =  `STANDBY_STATE;
                end
        endcase

        if ( CS_INT == 1'b1 ) begin

        end
    end

    always @ (posedge CS_INT) begin
            SIO0_Reg <= #tSHQZ 1'bx;
            SIO1_Reg <= #tSHQZ 1'bx;
            SIO2_Reg <= #tSHQZ 1'bx;
            SIO3_Reg <= #tSHQZ 1'bx;
            SIO0_Out_Reg <= #tSHQZ 1'bx;
            SIO1_Out_Reg <= #tSHQZ 1'bx;
            SIO2_Out_Reg <= #tSHQZ 1'bx;
            SIO3_Out_Reg <= #tSHQZ 1'bx;
           
            SO_OUT_EN    <= #tSHQZ 1'b0;
            SI_OUT_EN    <= #tSHQZ 1'b0;
            WP_OUT_EN    <= #tSHQZ 1'b0;
            SIO3_OUT_EN  <= #tSHQZ 1'b0;

            #1;
            Bit         = 1'b0;
            Bit_Tmp     = 1'b0;
           
            SO_IN_EN    = 1'b0;
            SI_IN_EN    = 1'b0;
            WP_IN_EN    = 1'b0;
            SIO3_IN_EN  = 1'b0;

            RDID_Mode   = 1'b0;
            RDSR_Mode   = 1'b0;
            RDSCUR_Mode = 1'b0;
            Read_Mode   = 1'b0;
            RES_Mode    = 1'b0;
            REMS_Mode   = 1'b0;
            SFDP_Mode    = 1'b0;
            Read_1XIO_Mode  = 1'b0;
            Read_2XIO_Mode  = 1'b0;
            Read_4XIO_Mode  = 1'b0;
            Read_1XIO_Chk   = 1'b0;
            Read_2XIO_Chk   = 1'b0;
            Read_4XIO_Chk   = 1'b0;
            FastRD_1XIO_Mode= 1'b0;
            FastRD_2XIO_Mode= 1'b0;
            FastRD_2XIO_Chk= 1'b0;
            FastRD_4XIO_Mode= 1'b0;
            FastRD_4XIO_Chk= 1'b0;
            PP_4XIO_Load    = 1'b0;
            PP_4XIO_Chk     = 1'b0;
            STATE <=  `STANDBY_STATE;
            SEC_PROVFY_Mode = 1'b0;

            disable read_id;
            disable read_status;
            disable read_Secur_Register;
            disable read_1xio;
            disable read_2xio;
            disable read_4xio;
            disable fastread_1xio;
            disable fastread_2xio;
            disable fastread_4xio;
            disable read_electronic_id;
            disable read_electronic_manufacturer_device_id;
            disable read_function;
            disable dummy_cycle;
        end

    always @ (posedge CS_INT) begin 

        if ( Set_4XIO_Enhance_Mode) begin
            EN4XIO_Read_Mode = 1'b1;
        end
        else begin
            EN4XIO_Read_Mode = 1'b0;
            W4Read_Mode      = 1'b0;
            FREAD4X_Mode     = 1'b0;
        end
    end 

    /*----------------------------------------------------------------------*/
    /*  ALL function trig action                                            */
    /*----------------------------------------------------------------------*/
    always @ ( posedge Read_1XIO_Mode
            or posedge FastRD_1XIO_Mode
            or posedge REMS_Mode
            or posedge RES_Mode
            or posedge Read_2XIO_Mode
            or posedge Read_4XIO_Mode 
            or posedge PP_4XIO_Load
            or posedge FastRD_2XIO_Mode
            or posedge FastRD_4XIO_Mode
           ) begin:read_function 
        wait ( SCLK == 1'b0 );
        if ( Read_1XIO_Mode == 1'b1 ) begin
            Read_1XIO_Chk = 1'b1;
            read_1xio;
        end
        else if ( FastRD_1XIO_Mode == 1'b1 ) begin
            fastread_1xio;
        end
        else if ( FastRD_2XIO_Mode == 1'b1 ) begin
            FastRD_2XIO_Chk = 1'b1;
            fastread_2xio;
        end
        else if ( FastRD_4XIO_Mode == 1'b1 ) begin
            FastRD_4XIO_Chk = 1'b1;
            fastread_4xio;
        end
        else if ( REMS_Mode == 1'b1 ) begin
            read_electronic_manufacturer_device_id;
        end 
        else if ( RES_Mode == 1'b1 ) begin
            read_electronic_id;
        end
        else if ( Read_2XIO_Mode == 1'b1 ) begin
            Read_2XIO_Chk = 1'b1;
            read_2xio;
        end
        else if ( Read_4XIO_Mode == 1'b1 ) begin
            Read_4XIO_Chk = 1'b1;
            read_4xio;
        end   
        else if ( PP_4XIO_Load == 1'b1 ) begin
            PP_4XIO_Chk = 1'b1;
        end
    end

    always @ ( RST_EN_Event ) begin
        RST_CMD_EN = #2 1'b1;
    end 
    
    always @ ( RST_Event ) begin
        During_RST_REC = 1;
        if ( BE_Mode || SE_4K_Mode || CE_Mode ) begin
            #tRCE;
        end
        else if ( WRSR_Mode || WRSCUR_Mode || WR_WPSEL_Mode || PP_4XIO_Mode || PP_1XIO_Mode ) begin
            #tRCP;
        end
        else if ( DP_Mode == 1'b1 ) begin
            #tRES2;
        end
        else begin
            #tRCR;
        end
        disable write_status;
        disable write_protection_select;
        disable block_erase_32k;
        disable single_block_lock;
        disable single_block_unlock;
        disable chip_lock;
        disable chip_unlock;
        disable sector_protection_read;
        disable block_erase;
        disable sector_erase_4k;
        disable chip_erase;
        disable page_program; // can deleted
        disable update_array;
        disable read_Secur_Register;
        disable write_secur_register;
        disable read_id;
        disable read_status;
        disable suspend_write;
        disable resume_write;
        disable er_timer;
        disable pg_timer;
        disable stimeout_cnt;
        disable rtimeout_cnt;

        disable read_1xio;
        disable read_2xio;
        disable read_4xio;
        disable fastread_1xio;
        disable fastread_2xio;
        disable fastread_4xio;
        disable read_electronic_id;
        disable read_electronic_manufacturer_device_id;
        disable read_function;
        disable dummy_cycle;

        reset_sm;
        READ4X_Mode = 1'b0;
        Secur_Reg[6:2]  = 5'b0;
        Status_Reg[1:0] = 2'b0;

    end

// *==============================================================================================
// * Hardware Reset Function description
// * =============================================================================================
    always @ ( negedge RESETB_INT ) begin
        if (RESETB_INT == 1'b0) begin
            disable hd_reset;
            #0;
            -> HDRST_Event;
        end
    end
    always @ ( HDRST_Event ) begin: hd_reset
      if (RESETB_INT == 1'b0) begin
        During_RST_REC = 1;
        wait ( RESETB_INT == 1'b1 );
        if (WRSR_Mode && tWRSR==tW) begin
            #(tRHRL_RP);
        end
        else if (WRSR_Mode && tWRSR==tBP) begin
            #(tRHRL_RP);
        end

        else if ( WR_WPSEL_Mode || WRSCUR_Mode ||  PP_4XIO_Mode || PP_1XIO_Mode ) begin
            #(tRHRL_RP);
        end
        else if (SE_4K_Mode || BE32K_Mode || BE64K_Mode || CE_Mode ) begin
            #(tRHRL_E);
        end

        else if ( DP_Mode == 1'b1 ) begin
            #(tRES2);
        end
        else begin
            #(tRHRL_RP);
        end
        disable write_status;
        disable write_protection_select;
        disable block_erase_32k;
        disable single_block_lock;
        disable single_block_unlock;
        disable chip_lock;
        disable chip_unlock;
        disable sector_protection_read;
        disable block_erase;
        disable sector_erase_4k;
        disable chip_erase;
        disable page_program; // can deleted
        disable update_array;
        disable read_Secur_Register;
        disable write_secur_register;
        disable read_id;
        disable read_status;
        disable suspend_write;
        disable resume_write;
        disable er_timer;
        disable pg_timer;
        disable stimeout_cnt;
        disable rtimeout_cnt;

        disable read_1xio;
        disable read_2xio;
        disable read_4xio;
        disable fastread_1xio;
        disable fastread_2xio;
        disable fastread_4xio;
        disable read_electronic_id;
        disable read_electronic_manufacturer_device_id;
        disable read_function;
        disable dummy_cycle;

        reset_sm;
        READ4X_Mode = 1'b0;
        FREAD4X_Mode = 1'b0;
        Secur_Reg[6:2]  = 5'b0;
        Status_Reg[1:0] = 2'b0;
      end
    end


    always @ ( posedge Susp_Trig ) begin:stimeout_cnt
        Susp_Trig <= #1 1'b0;
    end

    always @ ( posedge Resume_Trig ) begin:rtimeout_cnt
        Resume_Trig <= #1 1'b0;
    end

    always @ ( posedge W4Read_Mode or posedge FREAD4X_Mode ) begin
        READ4X_Mode = 1'b0;
    end

    always @ ( WRSR_Event ) begin
        write_status;
    end

    always @ ( BE_Event ) begin
        block_erase;
    end

    always @ ( CE_Event ) begin
        chip_erase;
    end
    
    always @ ( PP_Event ) begin:page_program_mode
        page_program( Address );
    end
   
    always @ ( SE_4K_Event ) begin
        sector_erase_4k;
    end

    always @ ( posedge RDID_Mode ) begin
        read_id;
    end

    always @ ( posedge RDSR_Mode ) begin
        read_status;
    end

    always @ ( posedge RDSCUR_Mode ) begin
        read_Secur_Register;
    end

    always @ ( WRSCUR_Event ) begin
        write_secur_register;
    end

    always @ ( Susp_Event ) begin
        suspend_write;
    end

    always @ ( Resume_Event ) begin
        resume_write;
    end

    always @ ( BE32K_Event ) begin
        block_erase_32k;
    end

    always @ ( SBLK_Event ) begin
        single_block_lock;
    end

    always @ ( SBULK_Event ) begin
        single_block_unlock;
    end

    always @ ( GBLK_Event ) begin
        chip_lock;
    end

    always @ ( GBULK_Event ) begin
        chip_unlock;
    end

    always @ ( WPSEL_Event ) begin
        write_protection_select;
    end

    always @ ( posedge SEC_PROVFY_Mode ) begin
        sector_protection_read;
    end

// *========================================================================================== 
// * Module Task Declaration
// *========================================================================================== 
    /*----------------------------------------------------------------------*/
    /*  Description: define a wait dummy cycle task                         */
    /*  INPUT                                                               */
    /*      Cnum: cycle number                                              */
    /*----------------------------------------------------------------------*/
    task dummy_cycle;
        input [31:0] Cnum;
        begin
            repeat( Cnum ) begin
                @ ( posedge SCLK );
            end
        end
    endtask // dummy_cycle

    /*----------------------------------------------------------------------*/
    /*  Description: define a write enable task                             */
    /*----------------------------------------------------------------------*/
    task write_enable;
        begin
            if (VERBOSE) $display( $time, " Old Status Register = %b", Status_Reg );
            Status_Reg[1] = 1'b1; 
            // $display( $time, " New Status Register = %b", Status_Reg );
        end
    endtask // write_enable
    
    /*----------------------------------------------------------------------*/
    /*  Description: define a write disable task (WRDI)                     */
    /*----------------------------------------------------------------------*/
    task write_disable;
        begin
            if (VERBOSE) $display( $time, " Old Status Register = %b", Status_Reg );
            Status_Reg[1]  = 1'b0;
            if (VERBOSE) $display( $time, " New Status Register = %b", Status_Reg );
        end
    endtask // write_disable
    
    /*----------------------------------------------------------------------*/
    /*  Description: define a read id task (RDID)                           */
    /*----------------------------------------------------------------------*/
    task read_id;
        reg  [23:0] Dummy_ID;
        integer Dummy_Count;
        begin
            Dummy_ID    = {ID_MXIC, Memory_Type, Memory_Density};
            Dummy_Count = 0;
            forever begin
                @ ( negedge SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_id;
                end
                else begin
                    if (ENQUAD) begin
                        SI_OUT_EN    = 1'b1;
                        WP_OUT_EN    = 1'b1;
                        SIO3_OUT_EN  = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    WP_IN_EN  = 1'b0;
                    SIO3_IN_EN= 1'b0;
                    if (ENQUAD)
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg, Dummy_ID} <=  {Dummy_ID, Dummy_ID[23:20]};
                    else
                        {SIO1_Reg, Dummy_ID} <=  {Dummy_ID, Dummy_ID[23]};
                end
            end  // end forever
        end
    endtask // read_id
    
    /*----------------------------------------------------------------------*/
    /*  Description: define a read status task (RDSR)                       */
    /*----------------------------------------------------------------------*/
    task read_status;
        reg [7:0] Status_Reg_Int;
        integer Dummy_Count;
        begin
            Status_Reg_Int = Status_Reg;
            if (ENQUAD) begin
                Dummy_Count = 2;
            end
            else begin
                Dummy_Count = 8;
            end
            forever begin
                @ ( negedge SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_status;
                end
                else begin
                    if (ENQUAD) begin
                        SI_OUT_EN    = 1'b1;
                        WP_OUT_EN    = 1'b1;
                        SIO3_OUT_EN  = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    WP_IN_EN  = 1'b0;
                    SIO3_IN_EN= 1'b0;
                    if ( Dummy_Count ) begin
                        Dummy_Count = Dummy_Count - 1;
                        if (ENQUAD) begin
                            {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <=  Dummy_Count ?
                                                          Status_Reg_Int[7:4] : Status_Reg_Int[3:0];
                        end
                        else begin
                            SIO1_Reg    <=  Status_Reg_Int[Dummy_Count];
                        end
                    end
                    else begin
                        if (ENQUAD) begin
                            Dummy_Count = 1;
                            Status_Reg_Int = Status_Reg;
                            {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <=  Status_Reg_Int[7:4];
                        end
                        else begin
                            Dummy_Count = 7;
                            Status_Reg_Int = Status_Reg;
                            SIO1_Reg    <=  Status_Reg_Int[Dummy_Count];
                        end
                    end          
                end
            end  // end forever
        end
    endtask // read_status

    /*----------------------------------------------------------------------*/
    /*  Description: define a write status task                             */
    /*----------------------------------------------------------------------*/
    task write_status;
    reg [7:0] Status_Reg_Up;
        begin
            if (VERBOSE) $display( $time, " Old Status Register = %b", Status_Reg );
            Status_Reg_Up = SI_Reg[7:0] ;
                tWRSR = tW;
                Secur_Reg[5] = 1'b0;
                if ( (Status_Reg[7] == 1'b1 && Status_Reg_Up[7] == 1'b0 ) ||
                     (Status_Reg[6] == 1'b1 && Status_Reg_Up[6] == 1'b0 ) ||
                     (Status_Reg[5] == 1'b1 && Status_Reg_Up[5] == 1'b0 ) ||
                     (Status_Reg[4] == 1'b1 && Status_Reg_Up[4] == 1'b0 ) ||
                     (Status_Reg[3] == 1'b1 && Status_Reg_Up[3] == 1'b0 ) ||
                     (Status_Reg[2] == 1'b1 && Status_Reg_Up[2] == 1'b0 ))
                begin
                    Secur_Reg[6] = 1'b0;
                end
                //SRWD:Status Register Write Protect
                Status_Reg[0]   = 1'b1;
                #tWRSR;
                Status_Reg[7]   =  Status_Reg_Up[7];
                Status_Reg[6:2] =  Status_Reg_Up[6:2];
                //WIP : write in process Bit
                Status_Reg[0]   = 1'b0;
                //WEL:Write Enable Latch
                Status_Reg[1]   = 1'b0;
                WRSR_Mode       = 1'b0;
        end
    endtask // write_status
   
    /*----------------------------------------------------------------------*/
    /*  Description: define a read data task                                */
    /*               03 AD1 AD2 AD3 X                                       */
    /*----------------------------------------------------------------------*/
    task read_1xio;
        integer Dummy_Count, Tmp_Int;
        reg  [7:0]       OUT_Buf;
        begin
            Dummy_Count = 8;
            dummy_cycle(24);
            #1; 
            read_array(Address, OUT_Buf);
            forever begin
                @ ( negedge SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_1xio;
                end 
                else  begin 
                    Read_Mode   = 1'b1;
                    SO_OUT_EN   = 1'b1;
                    SI_IN_EN    = 1'b0;
                    if ( Dummy_Count ) begin
                        {SIO1_Reg, OUT_Buf} <=  {OUT_Buf, OUT_Buf[7]};
                        Dummy_Count = Dummy_Count - 1;
                    end
                    else begin
                        Address = Address + 1;
                        load_address(Address);
                        read_array(Address, OUT_Buf);
                        {SIO1_Reg, OUT_Buf} <=   {OUT_Buf, OUT_Buf[7]};
                        Dummy_Count = 7 ;
                    end
                end 
            end  // end forever
        end   
    endtask // read_1xio

    /*----------------------------------------------------------------------*/
    /*  Description: define a fast read data task                           */
    /*               0B AD1 AD2 AD3 X                                       */
    /*----------------------------------------------------------------------*/
    task fastread_1xio;
        integer Dummy_Count, Tmp_Int;
        reg  [7:0]       OUT_Buf;
        begin
            Dummy_Count = 8;
            dummy_cycle(32);
            read_array(Address, OUT_Buf);
            forever begin
                @ ( negedge SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable fastread_1xio;
                end 
                else begin 
                    Read_Mode = 1'b1;
                    SO_OUT_EN = 1'b1;
                    SI_IN_EN  = 1'b0;
                    if ( Dummy_Count ) begin
                        {SIO1_Reg, OUT_Buf} <=  {OUT_Buf, OUT_Buf[7]};
                        Dummy_Count = Dummy_Count - 1;
                    end
                    else begin
                        Address = Address + 1;
                        load_address(Address);
                        read_array(Address, OUT_Buf);
                        {SIO1_Reg, OUT_Buf} <=  {OUT_Buf, OUT_Buf[7]};
                        Dummy_Count = 7 ;
                    end
                end    
            end  // end forever
        end   
    endtask // fastread_1xio

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Write protection select                        */
    /*----------------------------------------------------------------------*/
    task write_protection_select;
        begin
            Secur_Reg [5] = 1'b0;
            WR_WPSEL_Mode = 1'b1;
            Status_Reg[0] = 1'b1;
            #tWPS;
            WR_WPSEL_Mode = 1'b0;
            Secur_Reg [7] = 1'b1;
            Status_Reg[0] = 1'b0;
            Status_Reg[1] = 1'b0;
            Status_Reg[7] = 1'b0;
        end
    endtask // write_protection_select

    /*----------------------------------------------------------------------*/
    /*  Description: define a block erase task                              */
    /*               52 AD1 AD2 AD3                                         */
    /*----------------------------------------------------------------------*/
    task block_erase_32k;
        integer i, i_tmp;
        //time ERS_Time;
        integer Start_Add;
        integer End_Add;
        begin
            Block       =  Address[A_MSB:16];
            Block2      =  Address[A_MSB:15];
            Start_Add   = (Address[A_MSB:15]<<15) + 16'h0;
            End_Add     = (Address[A_MSB:15]<<15) + 16'h7fff;
            //WIP : write in process Bit
            Status_Reg[0] =  1'b1;
            Secur_Reg[6]  =  1'b0;
            if ( write_protect(Address) == 1'b0 &&
                 !(WPSEL_Mode == 1'b1 && Block[Block_MSB:0] == 0 && ((Address[15]&&SEC_Pro_Reg_BOT[15:8]) || (!Address[15]&&SEC_Pro_Reg_BOT[7:0]))) &&
                 !(WPSEL_Mode == 1'b1 && Block[Block_MSB:0]  == Block_NUM-1 && ((Address[15]&&SEC_Pro_Reg_TOP[15:8]) || (!Address[15]&&SEC_Pro_Reg_TOP[7:0]))) ) begin
               for( i = Start_Add; i <= End_Add; i = i + 1 )
               begin
                   ARRAY[i] = 8'hxx;
               end
               ERS_Time = ERS_Count_BE32K;
               fork
                   er_timer;
                   begin
                       for( i = 0; i < ERS_Time; i = i + 1 ) begin
                           @ ( negedge ERS_CLK or posedge Susp_Trig );
                           if ( Susp_Trig == 1'b1 ) begin
                               if( Susp_Ready == 0 ) i = i_tmp;
                               i_tmp = i;
                               wait( Resume_Trig );
                               $display ( $time, " Resume BE32K Erase ..." );
                           end
                       end
                       //#tBE32 ;
                       for( i = Start_Add; i <= End_Add; i = i + 1 )
                       begin
                           ARRAY[i] = 8'hff;
                       end
                       disable er_timer;
                       disable resume_write;
                       Susp_Ready = 1'b1;
                   end
               join
               //WIP : write in process Bit
               Status_Reg[0] =  1'b0;//WIP
               //WEL : write enable latch
               Status_Reg[1] =  1'b0;//WEL
               BE_Mode = 1'b0;
               BE32K_Mode = 1'b0;
            end
            else begin
                #tERS_CHK;
                Secur_Reg[6]  = 1'b1;
                Status_Reg[0] = 1'b0;//WIP
                Status_Reg[1] = 1'b0;//WEL
                BE_Mode = 1'b0;
                BE32K_Mode = 1'b0;
            end
        end
    endtask // block_erase_32k

    /*----------------------------------------------------------------------*/
    /*  Description: define an suspend task                                 */
    /*----------------------------------------------------------------------*/
    task suspend_write;
        begin
            disable resume_write;
            Susp_Ready = 1'b1;

            if ( Pgm_Mode ) begin
                Susp_Trig = 1;
                During_Susp_Wait = 1'b1;
                #tPSL;
                $display ( $time, " Suspend Program ..." );
                Secur_Reg[2]  = 1'b1;//PSB
                Status_Reg[0] = 1'b0;//WIP
                Status_Reg[1] = 1'b0;//WEL
                WR2Susp = 0;
                During_Susp_Wait = 1'b0;
            end
            else if ( Ers_Mode ) begin
                Susp_Trig = 1;
                During_Susp_Wait = 1'b1;
                #tESL;
                $display ( $time, " Suspend Erase ..." );
                Secur_Reg[3]  = 1'b1;//ESB
                Status_Reg[0] = 1'b0;//WIP
                Status_Reg[1] = 1'b0;//WEL
                WR2Susp = 0;
                During_Susp_Wait = 1'b0;
            end
        end
    endtask // suspend_write

    /*----------------------------------------------------------------------*/
    /*  Description: define an resume task                                  */
    /*----------------------------------------------------------------------*/
    task resume_write;
        begin
            if ( Pgm_Mode ) begin
                Susp_Ready    = 1'b0;
                Status_Reg[0] = 1'b1;//WIP
                Status_Reg[1] = 1'b1;//WEL
                Secur_Reg[2]  = 1'b0;//PSB
                Resume_Trig = 1;
                #tPRS;
                Susp_Ready    = 1'b1;
            end
            else if ( Ers_Mode ) begin
                Susp_Ready    = 1'b0;
                Status_Reg[0] = 1'b1;//WIP
                Status_Reg[1] = 1'b1;//WEL
                Secur_Reg[3]  = 1'b0;//ESB
                Resume_Trig = 1;
                #tERS;
                Susp_Ready    = 1'b1;
            end
        end
    endtask // resume_write

    /*----------------------------------------------------------------------*/
    /*  Description: define a timer to count erase time                     */
    /*----------------------------------------------------------------------*/
    task er_timer;
        begin
            ERS_CLK = 1'b0;
            forever
                begin
                    #(Clock*500) ERS_CLK = ~ERS_CLK;    // erase timer period is 50us
                end
        end
    endtask // er_timer

    /*----------------------------------------------------------------------*/
    /*  Description: Execute  Single Block Lock                             */
    /*----------------------------------------------------------------------*/
    task single_block_lock;
        reg [A_MSB:0] Address_Int;
        reg  [Block_MSB:0] Block;          
        begin
            Address_Int = Address;
            Block  =  Address_Int [A_MSB:16];
            Status_Reg[0] = 1'b1;
            #tWP_SRAM;
            if (Block[Block_MSB:0] == 0) begin
                SEC_Pro_Reg_BOT[Address_Int[15:12]] = 1'b1;
            end
            else if (Block[Block_MSB:0] == (Block_NUM-1)) begin
                SEC_Pro_Reg_TOP[Address_Int[15:12]] = 1'b1;
            end
            else
                SEC_Pro_Reg[Block] = 1'b1;
            Status_Reg[0] = 1'b0;
            Status_Reg[1] = 1'b0;
        end
    endtask // single_block_lock

    /*----------------------------------------------------------------------*/
    /*  Description: Execute  Single Block Unlock                           */
    /*----------------------------------------------------------------------*/
    task single_block_unlock;
        reg [A_MSB:0] Address_Int;
        reg  [Block_MSB:0] Block;          
        begin
            Address_Int = Address;
            Block  =  Address_Int [A_MSB:16];
            Status_Reg[0] = 1'b1;
            #tWP_SRAM;
            if (Block[Block_MSB:0] == 0) begin
                SEC_Pro_Reg_BOT[Address_Int[15:12]] = 1'b0;
            end
            else if (Block[Block_MSB:0] == (Block_NUM-1)) begin
                SEC_Pro_Reg_TOP[Address_Int[15:12]] = 1'b0;
            end
            else
                SEC_Pro_Reg[Block] = 1'b0;
            Status_Reg[0] = 1'b0;
            Status_Reg[1] = 1'b0;
        end
    endtask // single_block_unlock

    /*----------------------------------------------------------------------*/
    /*  Description: Execute  Chip Lock                                     */
    /*----------------------------------------------------------------------*/
    task chip_lock;
        begin
            Status_Reg[0] = 1'b1;
            //#(tWP_SRAM*Block_NUM);
            #(tWP_SRAM);
            SEC_Pro_Reg   = ~1'b0;
            SEC_Pro_Reg_BOT = ~1'b0;
            SEC_Pro_Reg_TOP = ~1'b0;
            Status_Reg[0] = 1'b0;
            Status_Reg[1] = 1'b0;
        end
    endtask // chip_lock

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Chip Block Unlock                              */
    /*----------------------------------------------------------------------*/
    task chip_unlock;
        begin
            Status_Reg[0] = 1'b1;
            #(tWP_SRAM);
            SEC_Pro_Reg   = 1'b0;
            SEC_Pro_Reg_BOT = 1'b0;
            SEC_Pro_Reg_TOP = 1'b0;
            Status_Reg[0] = 1'b0;
            Status_Reg[1] = 1'b0;
        end
    endtask // chip_unlock

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Block Lock  Protection Read                    */
    /*----------------------------------------------------------------------*/
    task sector_protection_read;
        reg [Block_MSB:0] Block;
        begin
            if (ENQUAD) begin
                dummy_cycle(6);
            end
            else begin
                dummy_cycle(24);
            end
            #1;
            Block    =  Address[A_MSB:16];
            forever begin
                @ ( negedge SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable sector_protection_read;
                end
                else begin
                    if (ENQUAD) begin
                        SI_OUT_EN    = 1'b1;
                        WP_OUT_EN    = 1'b1;
                        SIO3_OUT_EN  = 1'b1;
                    end
                    SO_OUT_EN   = 1'b1;
                    SO_IN_EN    = 1'b0;
                    SI_IN_EN    = 1'b0;
                    WP_IN_EN    = 1'b0;
                    SIO3_IN_EN  = 1'b0;
                    if (Block[Block_MSB:0] == 0) begin
                        {SIO3_Reg,SIO2_Reg,SIO1_Reg,SIO0_Reg} <=  {4{SEC_Pro_Reg_BOT[Address[15:12]]}} ;
                    end
                    else if (Block[Block_MSB:0] == (Block_NUM-1)) begin
                        {SIO3_Reg,SIO2_Reg,SIO1_Reg,SIO0_Reg} <=  {4{SEC_Pro_Reg_TOP[Address[15:12]]}} ;
                    end
                    else
                        {SIO3_Reg,SIO2_Reg,SIO1_Reg,SIO0_Reg} <=  {4{SEC_Pro_Reg[Block]}} ;
                end
            end  // end forever
        end
     endtask // sector_protection_read

    /*----------------------------------------------------------------------*/
    /*  Description: define a block erase task                              */
    /*               D8 AD1 AD2 AD3                                         */
    /*----------------------------------------------------------------------*/
    task block_erase;
        integer i, i_tmp;
        //time ERS_Time;
        integer Start_Add;
        integer End_Add;
        begin
            Block       =  Address[A_MSB:16];
            Block2      =  Address[A_MSB:15];
            Start_Add   = (Address[A_MSB:16]<<16) + 16'h0;
            End_Add     = (Address[A_MSB:16]<<16) + 16'hffff;
            //WIP : write in process Bit
            Status_Reg[0] =  1'b1;
            Secur_Reg[6]  =  1'b0;
            if ( write_protect(Address) == 1'b0 &&
                 !(WPSEL_Mode == 1'b1 && Block[Block_MSB:0] == 0 && SEC_Pro_Reg_BOT) &&
                 !(WPSEL_Mode == 1'b1 && Block[Block_MSB:0] == Block_NUM-1 && SEC_Pro_Reg_TOP) ) begin
               for( i = Start_Add; i <= End_Add; i = i + 1 )
               begin
                   ARRAY[i] = 8'hxx;
               end
               ERS_Time = ERS_Count_BE;
               fork
                   er_timer;
                   begin
                       for( i = 0; i < ERS_Time; i = i + 1 ) begin
                           @ ( negedge ERS_CLK or posedge Susp_Trig );
                           if ( Susp_Trig == 1'b1 ) begin
                               if( Susp_Ready == 0 ) i = i_tmp;
                               i_tmp = i;
                               wait( Resume_Trig );
                               $display ( $time, " Resume BE Erase ..." );
                           end
                       end
                       //#tBE ;
                       for( i = Start_Add; i <= End_Add; i = i + 1 )
                       begin
                           ARRAY[i] = 8'hff;
                       end
                       disable er_timer;
                       disable resume_write;
                       Susp_Ready = 1'b1;
                   end
               join
            end
            else begin
                #tERS_CHK;
                Secur_Reg[6] = 1'b1;
            end   
                //WIP : write in process Bit
                Status_Reg[0] =  1'b0;//WIP
                //WEL : write enable latch
                Status_Reg[1] =  1'b0;//WEL
                BE_Mode = 1'b0;
                BE64K_Mode = 1'b0;
        end
    endtask // block_erase

    /*----------------------------------------------------------------------*/
    /*  Description: define a sector 4k erase task                          */
    /*               20 AD1 AD2 AD3                                         */
    /*----------------------------------------------------------------------*/
    task sector_erase_4k;
        integer i, i_tmp;
        //time ERS_Time;
        integer Start_Add;
        integer End_Add;
        begin
            Sector      =  Address[A_MSB:12]; 
            Start_Add   = (Address[A_MSB:12]<<12) + 12'h000;
            End_Add     = (Address[A_MSB:12]<<12) + 12'hfff;          
            //WIP : write in process Bit
            Status_Reg[0] =  1'b1;
            Secur_Reg[6]  =  1'b0;
            if ( write_protect(Address) == 1'b0 ) begin
               for( i = Start_Add; i <= End_Add; i = i + 1 )
               begin
                   ARRAY[i] = 8'hxx;
               end
               ERS_Time = ERS_Count_SE;
               fork
                   er_timer;
                   begin
                       for( i = 0; i < ERS_Time; i = i + 1 ) begin
                           @ ( negedge ERS_CLK or posedge Susp_Trig );
                           if ( Susp_Trig == 1'b1 ) begin
                               if( Susp_Ready == 0 ) i = i_tmp;
                               i_tmp = i;
                               wait( Resume_Trig );
                               $display ( $time, " Resume SE Erase ..." );
                           end
                       end
                       for( i = Start_Add; i <= End_Add; i = i + 1 )
                       begin
                           ARRAY[i] = 8'hff;
                       end
                       disable er_timer;
                       disable resume_write;
                       Susp_Ready = 1'b1;
                   end
               join
            end
            else begin
                #tERS_CHK;
                Secur_Reg[6] = 1'b1;
            end
                //WIP : write in process Bit
                Status_Reg[0] = 1'b0;//WIP
                //WEL : write enable latch
                Status_Reg[1] = 1'b0;//WEL
                SE_4K_Mode = 1'b0;
         end
    endtask // sector_erase_4k
    
    /*----------------------------------------------------------------------*/
    /*  Description: define a chip erase task                               */
    /*               60(C7)                                                 */
    /*----------------------------------------------------------------------*/
    task chip_erase;
        reg [A_MSB:0] Address_Int;
        integer i;
        begin
            Address_Int = Address;
            Status_Reg[0] =  1'b1;
            Secur_Reg[6]  =  1'b0;
            if ( (Dis_CE == 1'b1 && WPSEL_Mode == 1'b0) ||
                ((SEC_Pro_Reg || SEC_Pro_Reg_BOT || SEC_Pro_Reg_TOP || (WP_B_INT == 1'b0)) && WPSEL_Mode == 1'b1)) begin
                #tERS_CHK;
                Secur_Reg[6] = 1'b1;
            end
            else begin
                for ( i = 0;i<tCE/100;i = i + 1) begin
                    #100_000_000;
                end
                for( i = 0; i <Block_NUM; i = i+1 ) begin
                    Address_Int = (i<<16) + 16'h0;
                    Start_Add = (i<<16) + 16'h0;
                    End_Add   = (i<<16) + 16'hffff;     
                    for( j = Start_Add; j <=End_Add; j = j + 1 )
                    begin
                        ARRAY[j] =  8'hff;
                    end
                end
            end
            //WIP : write in process Bit
            Status_Reg[0] = 1'b0;//WIP
            //WEL : write enable latch
            Status_Reg[1] = 1'b0;//WEL
            CE_Mode = 1'b0;
        end
    endtask // chip_erase       

    /*----------------------------------------------------------------------*/
    /*  Description: define a page program task                             */
    /*               02 AD1 AD2 AD3                                         */
    /*----------------------------------------------------------------------*/
    task page_program;
        input  [A_MSB:0]  Address;
        reg    [7:0]      Offset;
        integer Dummy_Count, Tmp_Int, i;
        begin
            Dummy_Count = Buffer_Num;    // page size
            Tmp_Int = 0;
            Offset  = Address[7:0];
            /*------------------------------------------------*/
            /*  Store 256 bytes into a temp buffer - Dummy_A  */
            /*------------------------------------------------*/
            for (i = 0; i < Dummy_Count ; i = i + 1 ) begin
                Dummy_A[i]  = 8'hff;
            end
            forever begin
                @ ( posedge SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    if ( (Tmp_Int % 8 !== 0) || (Tmp_Int == 1'b0) ) begin
                        PP_4XIO_Mode = 0;
                        PP_1XIO_Mode = 0;
                        disable page_program;
                    end
                    else begin
                        tPP_Real = pgm_time_cal(Tmp_Int/8);

                        if ( Tmp_Int > 8 )
                            Byte_PGM_Mode = 1'b0;
                        else 
                            Byte_PGM_Mode = 1'b1;
                        update_array ( Address );
                    end
                    disable page_program;
                end
                else begin  // count how many Bits been shifted
                    Tmp_Int = ( PP_4XIO_Mode | ENQUAD ) ? Tmp_Int + 4 : Tmp_Int + 1;
                    if ( Tmp_Int % 8 == 0) begin
                        #1;
                        Dummy_A[Offset] = SI_Reg [7:0];
                        Offset = Offset + 1;   
                        Offset = Offset[7:0];   
                    end  
                end
            end  // end forever
        end
    endtask // page_program

    /*----------------------------------------------------------------------*/
    /*  Description: define a program time calculation function             */
    /*  INPUT: program number                                               */
    /*----------------------------------------------------------------------*/ 
    function time pgm_time_cal;
        input pgm_num;
        integer pgm_num;
        time  pgm_time_tmp;

        begin
            pgm_time_tmp = ( 8 + pgm_num * 4 ) * 1000;

            if ( pgm_num == 1 ) begin
                pgm_time_cal = tBP;
            end
            else if ( pgm_num >= Buffer_Num || pgm_time_tmp > tPP ) begin
                pgm_time_cal = tPP;
            end
            else begin
                pgm_time_cal = pgm_time_tmp;
            end
        end
    endfunction

    
    /*----------------------------------------------------------------------*/
    /*  Description: define a read electronic ID (RES)                      */
    /*               AB X X X                                               */
    /*----------------------------------------------------------------------*/
    task read_electronic_id;
        reg  [7:0] Dummy_ID;
        begin
            if (VERBOSE) $display( $time, " Old DP Mode Register = %b", DP_Mode );
            if (ENQUAD) begin
                dummy_cycle(5);
            end
            else begin
                dummy_cycle(23);
            end
            Dummy_ID = ID_Device;
            dummy_cycle(1);

            forever begin
                @ ( negedge SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_electronic_id;
                end 
                else begin  
                    if (ENQUAD) begin
                        SI_OUT_EN    = 1'b1;
                        WP_OUT_EN    = 1'b1;
                        SIO3_OUT_EN  = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    WP_IN_EN  = 1'b0;
                    SIO3_IN_EN= 1'b0;
                    if (ENQUAD) begin
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg, Dummy_ID} <=   {Dummy_ID, Dummy_ID[7:4]};
                    end
                    else begin
                        {SIO1_Reg, Dummy_ID} <=   {Dummy_ID, Dummy_ID[7]};
                    end
                end
            end // end forever   
        end
    endtask // read_electronic_id
            
    /*----------------------------------------------------------------------*/
    /*  Description: define a read electronic manufacturer & device ID      */
    /*----------------------------------------------------------------------*/
    task read_electronic_manufacturer_device_id;
        reg  [15:0] Dummy_ID;
        integer Dummy_Count;
        begin
            dummy_cycle(24);
            #1;
            if ( Address[0] == 1'b0 ) begin
                Dummy_ID = {ID_MXIC,ID_Device};
            end
            else begin
                Dummy_ID = {ID_Device,ID_MXIC};
            end
            Dummy_Count = 0;
            forever begin
                @ ( negedge SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_electronic_manufacturer_device_id;
                end
                else begin
                    SO_OUT_EN =  1'b1;
                    SI_IN_EN  =  1'b0;
                    {SIO1_Reg, Dummy_ID} <=   {Dummy_ID, Dummy_ID[15]};
                end
            end // end forever
        end
    endtask // read_electronic_manufacturer_device_id

    /*----------------------------------------------------------------------*/
    /*  Description: define a program chip task                             */
    /*  INPUT:address                                                       */
    /*----------------------------------------------------------------------*/
    task update_array;
        input [A_MSB:0] Address;
        integer Dummy_Count, i, i_tmp;
        integer program_time;
        reg [7:0]  ori [0:Buffer_Num-1];
        begin
            Dummy_Count = Buffer_Num;
            Address = { Address [A_MSB:8], 8'h0 };
            program_time = tPP_Real;
            Status_Reg[0]= 1'b1;
            Secur_Reg[5] = 1'b0;
            if ( write_protect(Address) == 1'b0 && add_in_erase(Address) == 1'b0 ) begin
                for ( i = 0; i < Dummy_Count; i = i + 1 ) begin
                    if ( Secur_Mode == 1'b1) begin
                        ori[i] = Secur_ARRAY[Address + i];
                        Secur_ARRAY[Address + i] = Secur_ARRAY[Address + i] & 8'bx;
                    end
                    else begin
                        ori[i] = ARRAY[Address + i];
                        ARRAY[Address+ i] = ARRAY[Address + i] & 8'bx;
                    end
                end
                fork
                    pg_timer;
                    begin
                        for( i = 0; i*2 < program_time; i = i + 1 ) begin
                            @ ( negedge PGM_CLK or posedge Susp_Trig );
                            if ( Susp_Trig == 1'b1 ) begin
                                if( Susp_Ready == 0 ) i = i_tmp;
                                i_tmp = i;
                                wait( Resume_Trig );
                                $display ( $time, " Resume program ..." );
                            end
                        end
                        //#program_time ;
                        for ( i = 0; i < Dummy_Count; i = i + 1 ) begin
                            if ( Secur_Mode == 1'b1)
                                Secur_ARRAY[Address + i] = ori[i] & Dummy_A[i];
                            else
                                ARRAY[Address+ i] = ori[i] & Dummy_A[i];
                        end
                        disable pg_timer;
                        disable resume_write;
                        Susp_Ready = 1'b1;
                    end
                join
            end
            else begin
                #tPGM_CHK ;
                Secur_Reg[5] = 1'b1;
            end
            Status_Reg[0] = 1'b0;
            Status_Reg[1] = 1'b0;
            PP_4XIO_Mode = 1'b0;
            PP_1XIO_Mode = 1'b0;
            Byte_PGM_Mode = 1'b0;
        end
    endtask // update_array

    /*----------------------------------------------------------------------*/
    /*Description: find out whether the address is selected for erase       */
    /*----------------------------------------------------------------------*/
    function add_in_erase;
        input [A_MSB:0] Address;
        begin
            if( Secur_Mode == 1'b0 ) begin
                if (( ERS_Time == ERS_Count_BE32K && Address[A_MSB:15] == Block2 && ESB ) ||
                   ( ERS_Time == ERS_Count_BE && Address[A_MSB:16] == Block && ESB ) ||
                   ( ERS_Time == ERS_Count_SE && Address[A_MSB:12] == Sector && ESB ) ) begin
                    add_in_erase = 1'b1;
                    $display ( $time," Failed programing,address is in erase" );
                end
                else begin
                    add_in_erase = 1'b0;
                end
            end
            else if( Secur_Mode == 1'b1 ) begin
                    add_in_erase = 1'b0;
            end
        end
    endfunction // add_in_erase


    /*----------------------------------------------------------------------*/
    /*  Description: define a timer to count program time                   */
    /*----------------------------------------------------------------------*/
    task pg_timer;
        begin
            PGM_CLK = 1'b0;
            forever
                begin
                    #1 PGM_CLK = ~PGM_CLK;    // program timer period is 2ns
                end
        end
    endtask // pg_timer

    /*----------------------------------------------------------------------*/
    /*  Description: define a enter secured OTP task                        */
    /*----------------------------------------------------------------------*/
    task enter_secured_otp;
        begin
            if (VERBOSE) $display( $time, " Enter secured OTP mode  = %b",  Secur_Mode );
            Secur_Mode= 1;
            if (VERBOSE) $display( $time, " New Enter  secured OTP mode  = %b",  Secur_Mode );
        end
    endtask // enter_secured_otp

    /*----------------------------------------------------------------------*/
    /*  Description: define a exit secured OTP task                         */
    /*----------------------------------------------------------------------*/
    task exit_secured_otp;
        begin
            if (VERBOSE) $display( $time, " Enter secured OTP mode  = %b",  Secur_Mode );
            Secur_Mode = 0;
            if (VERBOSE) $display( $time,  " New Enter secured OTP mode  = %b",  Secur_Mode );
        end
    endtask

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Reading Security Register                      */
    /*----------------------------------------------------------------------*/
    task read_Secur_Register;
        integer Dummy_Count;
        begin
            if (ENQUAD) begin
                Dummy_Count = 2;
            end
            else begin
                Dummy_Count = 8;
            end
            forever @ ( negedge SCLK or posedge CS_INT ) begin // output security register info
                if ( CS_INT == 1 ) begin
                    disable     read_Secur_Register;
                end
                else  begin   
                    if (ENQUAD) begin
                        SI_OUT_EN    = 1'b1;
                        WP_OUT_EN    = 1'b1;
                        SIO3_OUT_EN  = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    WP_IN_EN  = 1'b0;
                    SIO3_IN_EN= 1'b0;
                    if ( Dummy_Count ) begin
                        Dummy_Count = Dummy_Count - 1;
                        if (ENQUAD) begin
                            {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <=  Dummy_Count ?
                                                          Secur_Reg[7:4] : Secur_Reg[3:0];
                        end
                        else begin
                            SIO1_Reg    <=  Secur_Reg[Dummy_Count];
                        end
                    end
                    else begin
                        if (ENQUAD) begin
                            Dummy_Count = 1;
                            {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <=  Secur_Reg[7:4];
                        end
                        else begin
                            Dummy_Count = 7;
                            SIO1_Reg    <=  Secur_Reg[Dummy_Count];
                        end
                    end          
                end      
            end
        end  
    endtask // read_Secur_Register

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Write Security Register                        */
    /*----------------------------------------------------------------------*/
    task write_secur_register;
        begin
            WRSCUR_Mode = 1'b1;
            Status_Reg[0] = 1'b1;
            #tBP; 
            WRSCUR_Mode = 1'b0;
            Secur_Reg [1] = 1'b1;
            Status_Reg[0] = 1'b0;
            Status_Reg[1] = 1'b0;
        end
    endtask // write_secur_register

    /*----------------------------------------------------------------------*/
    /*  Description: Execute 2X IO Read Mode                                */
    /*----------------------------------------------------------------------*/
    task read_2xio;
        reg  [7:0]  OUT_Buf;
        integer     Dummy_Count;
        begin
            Dummy_Count=4;
            SI_IN_EN = 1'b1;
            SO_IN_EN = 1'b1;
            SI_OUT_EN = 1'b0;
            SO_OUT_EN = 1'b0;
            dummy_cycle(12);
            dummy_cycle(2);
            #1;
            dummy_cycle(2);
            read_array(Address, OUT_Buf);
          
            forever @ ( negedge SCLK or  posedge CS_INT ) begin
                if ( CS_INT == 1'b1 ) begin
                    disable read_2xio;
                end
                else begin
                    Read_Mode   = 1'b1;
                    SO_OUT_EN   = 1'b1;
                    SI_OUT_EN   = 1'b1;
                    SI_IN_EN    = 1'b0;
                    SO_IN_EN    = 1'b0;
                    if ( Dummy_Count ) begin
                        {SIO1_Reg, SIO0_Reg, OUT_Buf} <=  {OUT_Buf, OUT_Buf[1:0]};
                        Dummy_Count = Dummy_Count - 1;
                    end
                    else begin
                        Address = Address + 1;
                        load_address(Address);
                        read_array(Address, OUT_Buf);
                        {SIO1_Reg, SIO0_Reg, OUT_Buf} <=  {OUT_Buf, OUT_Buf[1:0]};
                        Dummy_Count = 3 ;
                    end
                end
            end//forever  
        end
    endtask // read_2xio

    /*----------------------------------------------------------------------*/
    /*  Description: Execute 4X IO Read Mode                                */
    /*----------------------------------------------------------------------*/
    task read_4xio;
        //reg [A_MSB:0] Address;
        reg [7:0]   OUT_Buf ;
        integer     Dummy_Count;
        begin
            Dummy_Count = 2;
            SI_OUT_EN    = 1'b0;
            SO_OUT_EN    = 1'b0;
            WP_OUT_EN    = 1'b0;
            SIO3_OUT_EN  = 1'b0;
            SI_IN_EN    = 1'b1;
            SO_IN_EN    = 1'b1;
            WP_IN_EN    = 1'b1;
            SIO3_IN_EN   = 1'b1;
            dummy_cycle(6); // for address
            dummy_cycle(2);
            #1;
            if ( ((SI_Reg[0] === 1'hz) ||
                 (SI_Reg[1] === 1'hz) ||
                 (SI_Reg[2] === 1'hz) ||
                 (SI_Reg[3] === 1'hz) ||
                 (SI_Reg[4] === 1'hz) || 
                 (SI_Reg[5] === 1'hz) ||  
                 (SI_Reg[6] === 1'hz) ||
                 (SI_Reg[7] === 1'hz) ) &&
                 (SFDP_Mode  !== 1) ) begin
                 $display("Warning: Hi-impedance is inhibited for the two clock cycles.");
                 STATE = `BAD_CMD_STATE;
                 disable read_4xio;
            end
            else if ((SI_Reg[0] !== SI_Reg[4]) &&
                 (SI_Reg[1]!= SI_Reg[5]) &&
                 (SI_Reg[2]!= SI_Reg[6]) &&
                 (SI_Reg[3]!= SI_Reg[7]) ) begin
                Set_4XIO_Enhance_Mode = 1'b1;
            end
            else  begin 
                Set_4XIO_Enhance_Mode = 1'b0;
            end
            if ( CMD_BUS == FASTREAD1X || CMD_BUS == W4READ || (!READ4X_Mode && (CMD_BUS == RSTEN || CMD_BUS == RST) && EN4XIO_Read_Mode == 1'b1) )
                dummy_cycle(2);
            else if ( SFDP_Mode == 1 )
                dummy_cycle(6);
            else
                dummy_cycle(4);
            read_array(Address, OUT_Buf);


            forever @ ( negedge SCLK or  posedge CS_INT ) begin
                if ( CS_INT == 1'b1 ) begin
                    disable read_4xio;
                end
                  
                else begin
                    SO_OUT_EN   = 1'b1;
                    SI_OUT_EN   = 1'b1;
                    WP_OUT_EN   = 1'b1;
                    SIO3_OUT_EN = 1'b1;
                    SO_IN_EN    = 1'b0;
                    SI_IN_EN    = 1'b0;
                    WP_IN_EN    = 1'b0;
                    SIO3_IN_EN  = 1'b0;
                    Read_Mode  = 1'b1;
                    if ( Dummy_Count ) begin
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg, OUT_Buf} <=  {OUT_Buf, OUT_Buf[3:0]};
                        Dummy_Count = Dummy_Count - 1;
                    end
                    else begin
                        if ( EN_Burst && Burst_Length==8 && Address[2:0]==3'b111 )
                            Address = {Address[A_MSB:3], 3'b000};
                        else if ( EN_Burst && Burst_Length==16 && Address[3:0]==4'b1111 )
                            Address = {Address[A_MSB:4], 4'b0000};
                        else if ( EN_Burst && Burst_Length==32 && Address[4:0]==5'b1_1111 )
                            Address = {Address[A_MSB:5], 5'b0_0000};
                        else if ( EN_Burst && Burst_Length==64 && Address[5:0]==6'b11_1111 )
                            Address = {Address[A_MSB:6], 6'b00_0000};
                        else
                            Address = Address + 1;
                        load_address(Address);
                        read_array(Address, OUT_Buf);
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg, OUT_Buf} <=  {OUT_Buf, OUT_Buf[3:0]};
                        Dummy_Count = 1 ;
                    end
                end
            end//forever  
        end
    endtask // read_4xio

    /*----------------------------------------------------------------------*/
    /*  Description: define a fast read dual output data task               */
    /*               3B AD1 AD2 AD3 X                                       */
    /*----------------------------------------------------------------------*/
    task fastread_2xio;
        integer Dummy_Count;
        reg  [7:0] OUT_Buf;
        begin
            Dummy_Count = 4 ;
            dummy_cycle(32);
            read_array(Address, OUT_Buf);
            forever @ ( negedge SCLK or  posedge CS_INT ) begin
                if ( CS_INT == 1'b1 ) begin
                    disable fastread_2xio;
                end
                else begin
                    Read_Mode= 1'b1;
                    SO_OUT_EN = 1'b1;
                    SI_OUT_EN = 1'b1;
                    SI_IN_EN  = 1'b0;
                    SO_IN_EN  = 1'b0;
                    if ( Dummy_Count ) begin
                        {SIO1_Reg, SIO0_Reg, OUT_Buf} <=  {OUT_Buf, OUT_Buf[1:0]};
                        Dummy_Count = Dummy_Count - 1;
                    end
                    else begin
                        Address = Address + 1;
                        load_address(Address);
                        read_array(Address, OUT_Buf);
                        {SIO1_Reg, SIO0_Reg, OUT_Buf} <=  {OUT_Buf, OUT_Buf[1:0]};
                        Dummy_Count = 3 ;
                    end
                end
            end//forever  
        end
    endtask // fastread_2xio

    /*----------------------------------------------------------------------*/
    /*  Description: define a fast read quad output data task               */
    /*               6B AD1 AD2 AD3 X                                       */
    /*----------------------------------------------------------------------*/
    task fastread_4xio;
        integer Dummy_Count;
        reg  [7:0]  OUT_Buf;
        begin
            Dummy_Count = 2 ;
            dummy_cycle(32);
            read_array(Address, OUT_Buf);
            forever @ ( negedge SCLK or  posedge CS ) begin
                if ( CS ==      1'b1 ) begin
                    disable fastread_4xio;
                end
                else begin
                    SI_IN_EN    = 1'b0;
                    SI_OUT_EN   = 1'b1;
                    SO_OUT_EN   = 1'b1;
                    WP_OUT_EN   = 1'b1;
                    SIO3_OUT_EN = 1'b1;
                    if ( Dummy_Count ) begin
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg, OUT_Buf} <=  {OUT_Buf, OUT_Buf[3:0]};                       
                         Dummy_Count = Dummy_Count - 1;
                    end
                    else begin
                        Address = Address + 1;
                        load_address(Address);
                        read_array(Address, OUT_Buf);
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg, OUT_Buf} <=  {OUT_Buf, OUT_Buf[3:0]};
                        Dummy_Count = 1 ;
                    end
                end
            end//forever
        end
    endtask // fastread_4xio

    /*----------------------------------------------------------------------*/
    /*  Description: define read array output task                          */
    /*----------------------------------------------------------------------*/
    task read_array;
        input [A_MSB:0] Address;
        output [7:0]    OUT_Buf;
        begin
            if ( Secur_Mode == 1 ) begin
                OUT_Buf = Secur_ARRAY[Address];
            end
            else if ( SFDP_Mode == 1 ) begin
                OUT_Buf = SFDP_ARRAY[Address];
            end
            else begin
                OUT_Buf = ARRAY[Address] ;
            end
        end
    endtask //  read_array

    /*----------------------------------------------------------------------*/
    /*  Description: define read array output task                          */
    /*----------------------------------------------------------------------*/
    task load_address;
        inout [A_MSB:0] Address;
        begin
            if ( Secur_Mode == 1 ) begin
                Address = Address[A_MSB_OTP:0] ;
            end
            else if ( SFDP_Mode == 1 ) begin
                Address = Address[A_MSB_SFDP:0] ;
            end
        end
    endtask //  load_address

    /*----------------------------------------------------------------------*/
    /*  Description: define a write_protect area function                   */
    /*  INPUT: address                                                      */
    /*----------------------------------------------------------------------*/ 
    function write_protect;
        input [A_MSB:0] Address;
        reg [Block_MSB:0] Block;
        begin
            //protect_define
            if( Secur_Mode == 1'b0 ) begin
                Block  =  Address [A_MSB:16];
                if ( WPSEL_Mode == 1'b0 ) begin
                    if (Status_Reg[5:2] == 4'b0000) begin
                        write_protect = 1'b0;
                    end
                    else if (Status_Reg[5:2] == 4'b0001) begin
                        if (Block[Block_MSB:0] == 63) begin
                                  write_protect = 1'b1;
                        end
                        else begin
                            write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0010) begin
                        if (Block[Block_MSB:0] >= 62 && Block[Block_MSB:0] <= 63) begin
                            write_protect = 1'b1;
                        end
                        else begin
                            write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0011) begin
                        if (Block[Block_MSB:0] >= 60 && Block[Block_MSB:0] <= 63) begin
                            write_protect = 1'b1;
                        end
                        else begin
                            write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0100) begin
                        if (Block[Block_MSB:0] >= 56 && Block[Block_MSB:0] <= 63) begin
                            write_protect = 1'b1;
                        end
                        else begin
                            write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0101) begin
                        if (Block[Block_MSB:0] >= 48 && Block[Block_MSB:0] <= 63) begin
                            write_protect = 1'b1;
                        end
                        else begin
                            write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0110) begin
                        if (Block[Block_MSB:0] >= 32 && Block[Block_MSB:0] <= 63) begin
                            write_protect = 1'b1;
                        end
                        else begin
                            write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0111) begin
                          write_protect = 1'b1;
                      end
                    else if (Status_Reg[5:2] == 4'b1000) begin
                          write_protect = 1'b1;
                      end
                    else if (Status_Reg[5:2] == 4'b1001) begin
                        if (Block[Block_MSB:0] >= 0  && Block[Block_MSB:0] <= 31) begin
                            write_protect = 1'b1;
                        end
                        else begin
                            write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b1010) begin
                        if (Block[Block_MSB:0] >= 0  && Block[Block_MSB:0] <= 47) begin
                            write_protect = 1'b1;
                        end
                        else begin
                            write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b1011) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 55) begin
                            write_protect = 1'b1;
                        end
                        else begin
                            write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b1100) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 59) begin
                            write_protect = 1'b1;
                        end
                        else begin
                            write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b1101) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 61) begin
                            write_protect = 1'b1;
                        end
                        else begin
                            write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b1110) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 62) begin
                            write_protect = 1'b1;
                        end
                        else begin
                            write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b1111) begin
                        write_protect = 1'b1;
                    end
                end
                else begin
                    if (Block[Block_MSB:0] == 0) begin
                        if ( SEC_Pro_Reg_BOT[Address[15:12]] == 1'b0 ) begin
                            write_protect = 1'b0;
                        end
                        else begin
                            write_protect = 1'b1;
                        end
                    end
                    else if (Block[Block_MSB:0] == 63) begin
                        if ( SEC_Pro_Reg_TOP[Address[15:12]] == 1'b0 ) begin
                            write_protect = 1'b0;
                        end
                        else begin
                            write_protect = 1'b1;
                        end
                    end
                    else begin
                        if ( SEC_Pro_Reg[Address[A_MSB:16]] == 1'b0 ) begin
                            write_protect = 1'b0;
                        end
                        else begin
                            write_protect = 1'b1;
                        end
                    end
                    if( WP_B_INT == 1'b0 )
                        write_protect = 1'b1;
                end
            end
            else if( Secur_Mode == 1'b1 ) begin
                if ( Secur_Reg [1] == 1'b0 && Secur_Reg [0] == 1'b0 ) begin
                    write_protect = 1'b0;
                end
                else begin
                    write_protect = 1'b1;
                end
            end 
        end
    endfunction // write_protect


// *============================================================================================== 
// * AC Timing Check Section
// *==============================================================================================
    wire SIO3_EN;
    wire WP_EN;
    assign SIO3_EN = !Status_Reg[6];
    assign WP_EN = !Status_Reg[6] && !ENQUAD && SRWD;

    assign  Write_SHSL = !Read_SHSL;

    wire Read_1XIO_Chk_W;
    assign Read_1XIO_Chk_W = Read_1XIO_Chk;
    wire Read_2XIO_Chk_W;
    assign Read_2XIO_Chk_W = Read_2XIO_Chk;
    wire Read_2XIO_Chk_W2;
    assign Read_2XIO_Chk_W2 = FastRD_2XIO_Chk;
    wire Read_4XIO_Chk_W2;
    assign Read_4XIO_Chk_W2 = FastRD_4XIO_Chk;
    wire tDP_Chk_W;
    assign tDP_Chk_W = tDP_Chk;
    wire tRES1_Chk_W;
    assign tRES1_Chk_W = tRES1_Chk;
    wire tRES2_Chk_W;
    assign tRES2_Chk_W = tRES2_Chk;
    wire PP_4XIO_Chk_W;
    assign PP_4XIO_Chk_W = PP_4XIO_Chk;
    wire Read_SHSL_W;
    assign Read_SHSL_W = Read_SHSL;
    wire SI_IN_EN_W;
    assign SI_IN_EN_W = SI_IN_EN;
    wire SO_IN_EN_W;
    assign SO_IN_EN_W = SO_IN_EN;
    wire WP_IN_EN_W;
    assign WP_IN_EN_W = WP_IN_EN;
    wire SIO3_IN_EN_W;
    assign SIO3_IN_EN_W = SIO3_IN_EN;

    specify
        /*----------------------------------------------------------------------*/
        /*  Timing Check                                                        */
        /*----------------------------------------------------------------------*/
        $period( posedge  SCLK &&& ~CS, tSCLK  );       // SCLK _/~ ->_/~
        $period( negedge  SCLK &&& ~CS, tSCLK  );       // SCLK ~\_ ->~\_
        $period( posedge  SCLK &&& Read_1XIO_Chk_W , tRSCLK ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& Read_2XIO_Chk_W , tTSCLK ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& Read_2XIO_Chk_W2 , tTSCLK2 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& fQ_104M , tQSCLK ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& fQ_84M , tQSCLK2 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& Read_4XIO_Chk_W2 , tQSCLK3 ); // SCLK _/~ ->_/~

        $width ( posedge  CS  &&& tDP_Chk_W, tDP );       // CS _/~\_
        $width ( posedge  CS  &&& tRES1_Chk_W, tRES1 );   // CS _/~\_
        $width ( posedge  CS  &&& tRES2_Chk_W, tRES2 );   // CS _/~\_

        $width ( posedge  SCLK &&& ~CS, tCH   );       // SCLK _/~~\_
        $width ( negedge  SCLK &&& ~CS, tCL   );       // SCLK ~\__/~
        $width ( posedge  SCLK &&& Read_1XIO_Chk_W, tCH_R   );       // SCLK _/~~\_
        $width ( negedge  SCLK &&& Read_1XIO_Chk_W, tCL_R   );       // SCLK ~\__/~
        $width ( posedge  SCLK &&& PP_4XIO_Chk_W, tCH   );       // SCLK _/~~\_
        $width ( negedge  SCLK &&& PP_4XIO_Chk_W, tCL   );       // SCLK ~\__/~

        $width ( posedge  CS  &&& Read_SHSL_W, tSHSL_R );       // CS _/~\_
        $width ( posedge  CS  &&& Write_SHSL, tSHSL_W );// CS _/~\_
        $setup ( SI &&& ~CS, posedge SCLK &&& SI_IN_EN_W,  tDVCH );
        $hold  ( posedge SCLK &&& SI_IN_EN_W, SI &&& ~CS,  tCHDX );

        $setup ( SO &&& ~CS, posedge SCLK &&& SO_IN_EN_W,  tDVCH );
        $hold  ( posedge SCLK &&& SO_IN_EN_W, SO &&& ~CS,  tCHDX );
        $setup ( WP &&& ~CS, posedge SCLK &&& WP_IN_EN_W,  tDVCH );
        $hold  ( posedge SCLK &&& WP_IN_EN_W, WP &&& ~CS,  tCHDX );

        $setup ( SIO3 &&& ~CS, posedge SCLK &&& SIO3_IN_EN_W,  tDVCH );
        $hold  ( posedge SCLK &&& SIO3_IN_EN_W, SIO3 &&& ~CS,  tCHDX );

        $setup    ( negedge CS, posedge SCLK &&& ~CS, tSLCH );
        $hold     ( posedge SCLK &&& ~CS, posedge CS, tCHSH );
     
        $setup    ( posedge CS, posedge SCLK &&& CS, tSHCH );
        $hold     ( posedge SCLK &&& CS, negedge CS, tCHSL );

        $setup ( posedge WP &&& WP_EN, negedge CS,  tWHSL );
        $hold  ( posedge CS, negedge WP &&& WP_EN,  tSHWL );

        $width ( negedge  RESETB_INT, tRLRH   );      // RESET ~\__/~
        $setup ( posedge CS, negedge RESETB_INT ,  tRS );
        $hold  ( negedge RESETB_INT, posedge CS ,  tRH );

     endspecify

    integer AC_Check_File;
    // timing check module 
    initial 
    begin 
        AC_Check_File= $fopen ("ac_check.err" );    
    end

    realtime  T_CS_P , T_CS_N;
    realtime  T_WP_P , T_WP_N;
    realtime  T_SCLK_P , T_SCLK_N;
    realtime  T_SIO3_P , T_SIO3_N;
    realtime  T_SI;
    realtime  T_SO;
    realtime  T_WP;
    realtime  T_SIO3;
    realtime  T_RESET_N, T_RESET_P;                    

    initial 
    begin
        T_CS_P = 0; 
        T_CS_N = 0;
        T_WP_P = 0;  
        T_WP_N = 0;
        T_SCLK_P = 0;  
        T_SCLK_N = 0;
        T_SIO3_P = 0;  
        T_SIO3_N = 0;
        T_SI = 0;
        T_SO = 0;
        T_WP = 0;
        T_SIO3 = 0;
        T_RESET_N = 0;
        T_RESET_P = 0;              
    end

    always @ ( posedge SCLK ) begin
        //tSCLK
        if ( $realtime - T_SCLK_P < tSCLK && $realtime > 0 && ~CS ) 
            $fwrite (AC_Check_File, "Clock Frequence for except READ instruction fSCLK =%f Mhz, fSCLK timing violation at %f \n", fSCLK, $realtime );
        //fRSCLK
        if ( $realtime - T_SCLK_P < tRSCLK && Read_1XIO_Chk && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for READ instruction fRSCLK =%f Mhz, fRSCLK timing violation at %f \n", fRSCLK, $realtime );
        //fTSCLK
        if ( $realtime - T_SCLK_P < tTSCLK && Read_2XIO_Chk && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 2XI/O instruction fTSCLK =%f Mhz, fTSCLK timing violation at %f \n", fTSCLK, $realtime );
        //fTSCLK2
        if ( $realtime - T_SCLK_P < tTSCLK2 && FastRD_2XIO_Chk && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 2XI/O instruction fTSCLK2 =%f Mhz, fTSCLK2 timing violation at %f \n", fTSCLK2, $realtime );
        //fQSCLK
        if ( $realtime - T_SCLK_P < tQSCLK && Read_4XIO_Chk && fQ_104M && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 4XI/O instruction fQSCLK =%f Mhz, fQSCLK timing violation at %f \n", fQSCLK, $realtime );
        //fQSCLK2
        if ( $realtime - T_SCLK_P < tQSCLK2 && Read_4XIO_Chk && fQ_84M && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 4XI/O instruction fQSCLK2 =%f Mhz, fQSCLK2 timing violation at %f \n", fQSCLK2, $realtime );
        //fQSCLK3
        if ( $realtime - T_SCLK_P < tQSCLK3 && FastRD_4XIO_Chk && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 4XI/O instruction fQSCLK3 =%f Mhz, fQSCLK3 timing violation at %f \n", fQSCLK3, $realtime );


        T_SCLK_P = $realtime; 
        #0;  
        //tDVCH
        if ( T_SCLK_P - T_SI < tDVCH && SI_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SI setup time tDVCH=%f ns, tDVCH timing violation at %f \n", tDVCH, $realtime );
        if ( T_SCLK_P - T_SO < tDVCH && SO_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SO setup time tDVCH=%f ns, tDVCH timing violation at %f \n", tDVCH, $realtime );
        if ( T_SCLK_P - T_WP < tDVCH && WP_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data WP setup time tDVCH=%f ns, tDVCH timing violation at %f \n", tDVCH, $realtime );

        if ( T_SCLK_P - T_SIO3 < tDVCH && SIO3_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO3 setup time tDVCH=%f ns, tDVCH timing violation at %f \n", tDVCH, $realtime );
        //tCL
        if ( T_SCLK_P - T_SCLK_N < tCL && ~CS && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum SCLK Low time tCL=%f ns, tCL timing violation at %f \n", tCL, $realtime );
        //tCL_R
        if ( T_SCLK_P - T_SCLK_N < tCL_R && Read_1XIO_Chk && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum SCLK Low time tCL=%f ns, tCL timing violation at %f \n", tCL_R, $realtime );
        if ( T_SCLK_P - T_SCLK_N < tCL && PP_4XIO_Chk && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum SCLK Low time tCL=%f ns, tCL timing violation at %f \n", tCL, $realtime );
        #0;
        // tSLCH
        if ( T_SCLK_P - T_CS_N < tSLCH  && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum CS# active setup time tSLCH=%f ns, tSLCH timing violation at %f \n", tSLCH, $realtime );

        // tSHCH
        if ( T_SCLK_P - T_CS_P < tSHCH  && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum CS# not active setup time tSHCH=%f ns, tSHCH timing violation at %f \n", tSHCH, $realtime );
    end

    always @ ( negedge SCLK ) begin
        T_SCLK_N = $realtime;
        #0; 
        //tCH
        if ( T_SCLK_N - T_SCLK_P < tCH && ~CS && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum SCLK High time tCH=%f ns, tCH timing violation at %f \n", tCH, $realtime );
        //tCH_R
        if ( T_SCLK_N - T_SCLK_P < tCH_R && Read_1XIO_Chk && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum SCLK High time tCH=%f ns, tCH timing violation at %f \n", tCH_R, $realtime );
        if ( T_SCLK_N - T_SCLK_P < tCH && PP_4XIO_Chk && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum SCLK High time tCH=%f ns, tCH timing violation at %f \n", tCH, $realtime );
    end


    always @ ( SI ) begin
        T_SI = $realtime; 
        #0;  
        //tCHDX
        if ( T_SI - T_SCLK_P < tCHDX && SI_IN_EN && T_SI > 0 )
            $fwrite (AC_Check_File, "minimum Data SI hold time tCHDX=%f ns, tCHDX timing violation at %f \n", tCHDX, $realtime );
    end

    always @ ( SO ) begin
        T_SO = $realtime; 
        #0;  
        //tCHDX
        if ( T_SO - T_SCLK_P < tCHDX && SO_IN_EN && T_SO > 0 )
            $fwrite (AC_Check_File, "minimum Data SO hold time tCHDX=%f ns, tCHDX timing violation at %f \n", tCHDX, $realtime );
    end

    always @ ( WP ) begin
        T_WP = $realtime; 
        #0;  
        //tCHDX
        if ( T_WP - T_SCLK_P < tCHDX && WP_IN_EN && T_WP > 0 )
            $fwrite (AC_Check_File, "minimum Data WP hold time tCHDX=%f ns, tCHDX timing violation at %f \n", tCHDX, $realtime );
    end

    always @ ( SIO3 ) begin
        T_SIO3 = $realtime; 
        #0;  
        //tCHDX
       if ( T_SIO3 - T_SCLK_P < tCHDX && SIO3_IN_EN && T_SIO3 > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO3 hold time tCHDX=%f ns, tCHDX timing violation at %f \n", tCHDX, $realtime );
    end

    always @ ( posedge CS ) begin
        T_CS_P = $realtime;
        #0;  
        // tCHSH 
        if ( T_CS_P - T_SCLK_P < tCHSH  && T_CS_P > 0 )
            $fwrite (AC_Check_File, "minimum CS# active hold time tCHSH=%f ns, tCHSH timing violation at %f \n", tCHSH, $realtime );
       // tRH
       if ( T_CS_P - T_RESET_N < tRH  && T_CS_P > 0 )
            $fwrite (AC_Check_File, "minimum hold time tRH=%f ns, tRH timing violation at %f \n", tRH, $realtime );
    end

    always @ ( negedge CS ) begin
        T_CS_N = $realtime;
        #0;
        //tCHSL
        if ( T_CS_N - T_SCLK_P < tCHSL  && T_CS_N > 0 )
            $fwrite (AC_Check_File, "minimum CS# not active hold time tCHSL=%f ns, tCHSL timing violation at %f \n", tCHSL, $realtime );
        //tSHSL
        if ( T_CS_N - T_CS_P < tSHSL_R && T_CS_N > 0 && Read_SHSL)
            $fwrite (AC_Check_File, "minimum CS# deselect  time tSHSL_R=%f ns, tSHSL timing violation at %f \n", tSHSL_R, $realtime );
        if ( T_CS_N - T_CS_P < tSHSL_W && T_CS_N > 0 && Write_SHSL)
            $fwrite (AC_Check_File, "minimum CS# deselect  time tSHSL_W=%f ns, tSHSL timing violation at %f \n", tSHSL_W, $realtime );

        //tWHSL
        if ( T_CS_N - T_WP_P < tWHSL && WP_EN  && T_CS_N > 0 )
            $fwrite (AC_Check_File, "minimum WP setup  time tWHSL=%f ns, tWHSL timing violation at %f \n", tWHSL, $realtime );


        //tDP
        if ( T_CS_N - T_CS_P < tDP && T_CS_N > 0 && tDP_Chk)
            $fwrite (AC_Check_File, "when transit from Standby Mode to Deep-Power Mode, CS# must remain high for at least tDP =%f ns, tDP timing violation at %f \n", tDP, $realtime );


        //tRES1/2
        if ( T_CS_N - T_CS_P < tRES1 && T_CS_N > 0 && tRES1_Chk)
            $fwrite (AC_Check_File, "when transit from Deep-Power Mode to Standby Mode, CS# must remain high for at least tRES1 =%f ns, tRES1 timing violation at %f \n", tRES1, $realtime );

        if ( T_CS_N - T_CS_P < tRES2 && T_CS_N > 0 && tRES2_Chk)
            $fwrite (AC_Check_File, "when transit from Deep-Power Mode to Standby Mode, CS# must remain high for at least tRES2 =%f ns, tRES2 timing violation at %f \n", tRES2, $realtime );

    end

    always @ ( posedge WP ) begin
        T_WP_P = $realtime;
        #0;  
    end

    always @ ( negedge WP ) begin
        T_WP_N = $realtime;
        #0;
        //tSHWL
        if ( ((T_WP_N - T_CS_P < tSHWL) || ~CS) && WP_EN && T_WP_N > 0 )
            $fwrite (AC_Check_File, "minimum WP hold time tSHWL=%f ns, tSHWL timing violation at %f \n", tSHWL, $realtime );
    end

    always @ ( negedge RESETB_INT ) begin
        T_RESET_N = $realtime;
        #0;
        //tRS
        if ( (T_RESET_N - T_CS_P < tRS) && T_RESET_N > 0 )
            $fwrite (AC_Check_File, "minimum setup time tRS=%f ns, tRS timing violation at %f \n", tRS, $realtime );
    end

    always @ ( posedge RESETB_INT ) begin
        T_RESET_P = $realtime;
        #0;
        //tRLRH
        if ( (T_RESET_P - T_RESET_N < tRLRH) && T_RESET_P > 0 )
            $fwrite (AC_Check_File, "minimum reset pulse width tRLRH=%f ns, tRLRH timing violation at %f \n", tRLRH, $realtime );
    end
endmodule
