module fpga_top#( parameter AXI_ID_WIDTH = 5, parameter AXI_ADDR_WIDTH = 64, parameter AXI_DATA_WIDTH = 128)
  (

   input [0:0]          sys_clk0_0_clk_n,
   input [0:0]          sys_clk0_0_clk_p,  

//JTAG
  input pin_tck,
  input pin_trst,
  input pin_tdi,
  input pin_tms,
  output pin_tdo,

  // ---- DDR ports --------------//

   output [0:0]         CH0_DDR4_0_0_act_n,
   output [16:0]        CH0_DDR4_0_0_adr,    
   input [0:0]          CH0_DDR4_0_0_alert_n,  
   output [1:0]         CH0_DDR4_0_0_ba,      
   output [1:0]         CH0_DDR4_0_0_bg,      
   output [1:0]         CH0_DDR4_0_0_ck_c,    
   output [1:0]         CH0_DDR4_0_0_ck_t,    
   output [1:0]         CH0_DDR4_0_0_cke,     
   output [1:0]         CH0_DDR4_0_0_cs_n,    
   inout [8:0]          CH0_DDR4_0_0_dm_n,     
   inout [71:0]         CH0_DDR4_0_0_dq,      
   inout [8:0]          CH0_DDR4_0_0_dqs_c,    
   inout [8:0]          CH0_DDR4_0_0_dqs_t,    
   output [1:0]         CH0_DDR4_0_0_odt,     
   output [0:0]         CH0_DDR4_0_0_par,     
   output [0:0]         CH0_DDR4_0_0_reset_n, 
  
  // ---- JTAG ports ------- //
   // ---- UART ports --------//
    input         uart0_SIN,
    output        uart0_SOUT,

//   // ---- I2C ports --------//
/*
    inout         i2c0_sda,
    inout         i2c0_scl,
    inout         i2c1_sda,
    inout         i2c1_scl,
*/
//   // ---- SPI ports ---------//
//   inout       spi0_mosi,
//   inout       spi0_sclk,
//   inout       spi0_nss,
//   inout        spi0_miso,

  // ---- io_cell_ports(Pin Muxed) ---------//
    inout io7_cell,
    inout io8_cell,
    inout io9_cell,
    inout io10_cell,
    inout io12_cell,
    inout io13_cell,
    inout io16_cell,
    inout io17_cell,
    inout io18_cell,
    inout io19_cell,
    inout io20_cell,


    // ---- GPIO ports --------//
//    inout gpio_4,
//    inout gpio_7,
//    inout gpio_8,
//    inout gpio_14,
//    inout gpio_15,
//    inout gpio_16,
//    inout gpio_17,
//    inout gpio_18,
//    inout gpio_19,
//    inout gpio_20,
//    inout gpio_21,
//    inout gpio_22,
//    inout gpio_23,
//    inout gpio_24,
//    inout gpio_25,
//    inout gpio_26,
//    inout gpio_27,
//    inout gpio_28,
//    inout gpio_29,
//    inout gpio_30,
//    inout gpio_31,


    // ---- System Reset ------//
    input         sys_rst,	//Active high

  
    // ---- System Clock ------//
  input                   sys_clk_p,
  input                   sys_clk_n

   );

  reg aresetn ;

  wire                            soc_reset;      // reset to the SoC
  wire                            core_clk;       // clock to the SoC
  wire                            locked;         // indicates pll is stable
  wire                              clk;            // mig ui clk            
  wire                              rst;            // mig ui reset
  wire                            mmcm_locked;    // indicates the ui clock from mig is stable
  
  
// ---------------------------------------------------------------------------- //
    wire wire_tck_clk;
    wire wire_trst;
    wire wire_capture;
    wire wire_run_test;
    wire wire_sel;
    wire wire_shift;
    wire wire_tdi;
    wire wire_tms;
    wire wire_update;
    wire wire_tdo;

   wire io7_cell_in, io7_cell_out, io7_cell_en;
   wire io8_cell_in, io8_cell_out, io8_cell_en;
   wire io9_cell_in, io9_cell_out, io9_cell_en;
   wire io10_cell_in, io10_cell_out, io10_cell_en;
   wire io12_cell_in, io12_cell_out, io12_cell_en;
   wire io13_cell_in, io13_cell_out, io13_cell_en;
   wire io16_cell_in, io16_cell_out, io16_cell_en;
   wire io17_cell_in, io17_cell_out, io17_cell_en;
   wire io18_cell_in, io18_cell_out, io18_cell_en;
   wire io19_cell_in, io19_cell_out, io19_cell_en;
   wire io20_cell_in, io20_cell_out, io20_cell_en; 

  wire [AXI_ADDR_WIDTH-1:0] S00_AXI_0_araddr;
  wire [1:0]                S00_AXI_0_arburst;
  wire [3:0]                S00_AXI_0_arcache;
  wire [AXI_ID_WIDTH-1:0]   S00_AXI_0_arid;
  wire [7:0]                S00_AXI_0_arlen;
  wire [0:0]                S00_AXI_0_arlock;
  wire [2:0]                S00_AXI_0_arprot;
  wire [3:0]                S00_AXI_0_arqos;
  wire [0:0]                S00_AXI_0_arready;
  wire [3:0]                S00_AXI_0_arregion;
  wire [2:0]                S00_AXI_0_arsize;
  wire [0:0]                S00_AXI_0_arvalid;
  wire [AXI_ADDR_WIDTH-1:0] S00_AXI_0_awaddr;
  wire [1:0]                S00_AXI_0_awburst;
  wire [3:0]                S00_AXI_0_awcache;
  wire [AXI_ID_WIDTH-1:0]   S00_AXI_0_awid;
  wire [7:0]                S00_AXI_0_awlen;
  wire [0:0]                S00_AXI_0_awlock;
  wire [2:0]                S00_AXI_0_awprot;
  wire [3:0]                S00_AXI_0_awqos;
  wire [0:0]                S00_AXI_0_awready;
  wire [3:0]                S00_AXI_0_awregion;
  wire [2:0]                S00_AXI_0_awsize;
  wire [0:0]                S00_AXI_0_awvalid;
  wire [AXI_ID_WIDTH-1:0]   S00_AXI_0_bid;
  wire [0:0]                S00_AXI_0_bready;
  wire [1:0]                S00_AXI_0_bresp;
  wire [0:0]                S00_AXI_0_bvalid;
  wire [AXI_DATA_WIDTH-1:0] S00_AXI_0_rdata;
  wire [AXI_ID_WIDTH-1:0]   S00_AXI_0_rid;
  wire [0:0]                S00_AXI_0_rlast;
  wire [0:0]                S00_AXI_0_rready;
  wire [1:0]                S00_AXI_0_rresp;
  wire [0:0]                S00_AXI_0_rvalid;
  wire [AXI_DATA_WIDTH-1:0] S00_AXI_0_wdata;
  wire [0:0]                S00_AXI_0_wlast;
  wire [0:0]                S00_AXI_0_wready;
  wire [15:0]               S00_AXI_0_wstrb;
  wire [0:0]                S00_AXI_0_wvalid; 
  
  // --------- Address width truncation and Reset generation for SoC ------------ //
  wire [35:0] temp_s_axi_awaddr, temp_s_axi_araddr;

  assign S00_AXI_0_awaddr = {{(AXI_ADDR_WIDTH-28){1'b0}}, temp_s_axi_awaddr};
  assign S00_AXI_0_araddr = {{(AXI_ADDR_WIDTH-28){1'b0}}, temp_s_axi_araddr};



//assign clk_out = core_clk;

  proc_sys_reset_0 proc_reset_inst (
      .slowest_sync_clk (core_clk),
      .ext_reset_in     (sys_rst),  //sys_rst
      .aux_reset_in     (1'b1), 
      .mb_debug_sys_rst (0),
      .dcm_locked       (locked),
      .mb_reset         (soc_reset),
      .bus_struct_reset (),
      .peripheral_reset (),
      .interconnect_aresetn (),
      .peripheral_aresetn ()
  );
   // ---------------------------------------------------------------------------- //
   // ---------- Clock divider ----------------//
   clk_divider clk_div (
                       .clk_in1_p(sys_clk_p),
                       .clk_in1_n(sys_clk_n),
                       .clk_out1(core_clk),
                    .clk_out2(phy_ref_clk),
             
    .reset   (sys_rst), 
    .locked   (locked)
  );
  
  
//    axis_ila_0 ila (
//    .clk(core_clk),
//    .probe0(~soc_reset),
//    .probe1(s_axi_arvalid),
//    .probe2(s_axi_arready),
//    .probe3(temp_s_axi_araddr),
//    .probe4(s_axi_rvalid),
//    .probe5(s_axi_rready),
//    .probe6(s_axi_rresp),
//    .probe7(s_axi_awvalid),
//    .probe8(s_axi_awready),
//    .probe9(s_axi_wvalid),
//    .probe10(s_axi_bvalid),
//    .probe11(temp_s_axi_awaddr),
//    .probe12(core_clk)

//  );


  design_1_wrapper u_bd(
  //DDR4 interface
    .CH0_DDR4_0_0_act_n     (CH0_DDR4_0_0_act_n   ), //   (CH0_DDR4_0_0_act_n,
    .CH0_DDR4_0_0_adr       (CH0_DDR4_0_0_adr     ), //    CH0_DDR4_0_0_adr,
    .CH0_DDR4_0_0_alert_n   (CH0_DDR4_0_0_alert_n ), //    CH0_DDR4_0_0_alert_n,
    .CH0_DDR4_0_0_ba        (CH0_DDR4_0_0_ba      ), //    CH0_DDR4_0_0_ba,
    .CH0_DDR4_0_0_bg        (CH0_DDR4_0_0_bg      ), //    CH0_DDR4_0_0_bg,
    .CH0_DDR4_0_0_ck_c      (CH0_DDR4_0_0_ck_c    ), //    CH0_DDR4_0_0_ck_c,
    .CH0_DDR4_0_0_ck_t      (CH0_DDR4_0_0_ck_t    ), //    CH0_DDR4_0_0_ck_t,
    .CH0_DDR4_0_0_cke       (CH0_DDR4_0_0_cke     ), //    CH0_DDR4_0_0_cke,
    .CH0_DDR4_0_0_cs_n      (CH0_DDR4_0_0_cs_n    ), //    CH0_DDR4_0_0_cs_n,
    .CH0_DDR4_0_0_dm_n      (CH0_DDR4_0_0_dm_n    ), //    CH0_DDR4_0_0_dm_n,
    .CH0_DDR4_0_0_dq        (CH0_DDR4_0_0_dq      ), //    CH0_DDR4_0_0_dq,
    .CH0_DDR4_0_0_dqs_c     (CH0_DDR4_0_0_dqs_c   ), //    CH0_DDR4_0_0_dqs_c,
    .CH0_DDR4_0_0_dqs_t     (CH0_DDR4_0_0_dqs_t   ), //    CH0_DDR4_0_0_dqs_t,
    .CH0_DDR4_0_0_odt       (CH0_DDR4_0_0_odt     ), //    CH0_DDR4_0_0_odt,
    .CH0_DDR4_0_0_par       (CH0_DDR4_0_0_par     ), //    CH0_DDR4_0_0_par,
    .CH0_DDR4_0_0_reset_n   (CH0_DDR4_0_0_reset_n ), //    CH0_DDR4_0_0_reset_n,
    
    // Slave AXI interface
    .S00_AXI_0_araddr(S00_AXI_0_araddr),
    .S00_AXI_0_arburst(S00_AXI_0_arburst),
    .S00_AXI_0_arcache(4'b10),
    .S00_AXI_0_arid(S00_AXI_0_arid),
    .S00_AXI_0_arlen(S00_AXI_0_arlen),
    .S00_AXI_0_arlock(1'b0),
    .S00_AXI_0_arprot(S00_AXI_0_arprot),
    .S00_AXI_0_arqos(4'b0),
    .S00_AXI_0_arready(S00_AXI_0_arready),
    .S00_AXI_0_arregion(4'b0),
    .S00_AXI_0_arsize(S00_AXI_0_arsize),
    .S00_AXI_0_arvalid(S00_AXI_0_arvalid),
    .S00_AXI_0_awaddr(S00_AXI_0_awaddr),
    .S00_AXI_0_awburst(S00_AXI_0_awburst),
    .S00_AXI_0_awcache(4'b10),
    .S00_AXI_0_awid(S00_AXI_0_awid),
    .S00_AXI_0_awlen(S00_AXI_0_awlen),
    .S00_AXI_0_awlock(1'b0),
    .S00_AXI_0_awprot(S00_AXI_0_awprot),
    .S00_AXI_0_awqos(4'b0),
    .S00_AXI_0_awready(S00_AXI_0_awready),
    .S00_AXI_0_awregion(4'b0),
    .S00_AXI_0_awsize(S00_AXI_0_awsize),
    .S00_AXI_0_awvalid(S00_AXI_0_awvalid),
    .S00_AXI_0_bid(S00_AXI_0_bid),
    .S00_AXI_0_bready(S00_AXI_0_bready),
    .S00_AXI_0_bresp(S00_AXI_0_bresp),
    .S00_AXI_0_bvalid(S00_AXI_0_bvalid),
    .S00_AXI_0_rdata(S00_AXI_0_rdata),
    .S00_AXI_0_rid(S00_AXI_0_rid),
    .S00_AXI_0_rlast(S00_AXI_0_rlast),
    .S00_AXI_0_rready(S00_AXI_0_rready),
    .S00_AXI_0_rresp(S00_AXI_0_rresp),
    .S00_AXI_0_rvalid(S00_AXI_0_rvalid),
    .S00_AXI_0_wdata(S00_AXI_0_wdata),
    .S00_AXI_0_wlast(S00_AXI_0_wlast),
    .S00_AXI_0_wready(S00_AXI_0_wready),
    .S00_AXI_0_wstrb(S00_AXI_0_wstrb),
    .S00_AXI_0_wvalid(S00_AXI_0_wvalid),
    .aclk0_0(core_clk),
    .sys_clk0_0_clk_n(sys_clk0_0_clk_n),
    .sys_clk0_0_clk_p(sys_clk0_0_clk_p)
    );
   // ----------------------------------------- //
   
    // ---- Instantiating the C-class SoC -------------//
   mkDebugSoc core(
       // Main Clock and Reset to the SoC
        .CLK(core_clk),
        .RST_N(~soc_reset),
        .CLK_tck_clk(pin_tck),
        .RST_N_trst(pin_trst),
        .wire_tdi_tdi_in(pin_tdi),
        .wire_tms_tms_in(pin_tms),
        .wire_tdo(pin_tdo),

      // SPI ports
        .spi0_io_mosi_out(spi0_io_mosi_out),
        .spi0_io_mosi_outen(spi0_io_mosi_outen),
        .spi0_io_mosi_in_val(spi0_io_mosi_in_val),
        .spi0_io_sclk_out(spi0_io_sclk_out),
        .spi0_io_sclk_outen(spi0_io_sclk_outen),
        .spi0_io_sclk_in_val(spi0_io_sclk_in_val),
        .spi0_io_ncs_out0(spi0_io_nss_out),
        .spi0_io_ncs_outen0(spi0_io_nss_outen),
        .spi0_io_ncs_in0_val(spi0_io_nss_in_val),
	      .spi0_io_miso_out(spi0_io_miso_out),
	      .spi0_io_miso_outen(spi0_io_miso_outen),
	      .spi0_io_miso_in_val(spi0_io_miso_in_val),

       // UART port definitions
        .uart0_io_SIN(uart0_SIN),
        .uart0_io_SOUT(uart0_SOUT),
            

  		  .mem_master_AWVALID(S00_AXI_0_awvalid),
		  .mem_master_AWADDR(temp_s_axi_awaddr),
//		  .mem_master_AWUSER(),
		  .mem_master_AWPROT(S00_AXI_0_awprot),
		  .mem_master_AWLEN(S00_AXI_0_awlen),
		  .mem_master_AWSIZE(S00_AXI_0_awsize),
		  .mem_master_AWBURST(S00_AXI_0_awburst),
		  .mem_master_AWID(S00_AXI_0_awid),
		  .mem_master_AWREADY(S00_AXI_0_awready),
		  .mem_master_WVALID(S00_AXI_0_wvalid),
		  .mem_master_WDATA(S00_AXI_0_wdata),
		  .mem_master_WSTRB(S00_AXI_0_wstrb),
		  .mem_master_WLAST(S00_AXI_0_wlast),
//		  .mem_master_WID(),
		  .mem_master_WREADY(S00_AXI_0_wready),
		  .mem_master_BVALID(S00_AXI_0_bvalid),
		  .mem_master_BRESP(S00_AXI_0_bresp),
//		  .mem_master_BUSER(),
		  .mem_master_BID(S00_AXI_0_bid),
		  .mem_master_BREADY(S00_AXI_0_bready),
		  .mem_master_ARVALID(S00_AXI_0_arvalid),
		  .mem_master_ARADDR(temp_s_axi_araddr),
//		  .mem_master_ARUSER(),
		  .mem_master_ARPROT(S00_AXI_0_arprot),
		  .mem_master_ARLEN(S00_AXI_0_arlen),
		  .mem_master_ARSIZE(S00_AXI_0_arsize),
		  .mem_master_ARBURST(S00_AXI_0_arburst),
		  .mem_master_ARID(S00_AXI_0_arid),
		  .mem_master_ARREADY(S00_AXI_0_arready),
		  .mem_master_RVALID(S00_AXI_0_rvalid),
		  .mem_master_RRESP(S00_AXI_0_rresp),
		  .mem_master_RDATA(S00_AXI_0_rdata),
		  .mem_master_RLAST(S00_AXI_0_rlast),
//		  .mem_master_RUSER(),
		  .mem_master_RID(S00_AXI_0_rid),
		  .mem_master_RREADY(S00_AXI_0_rready),
		  
      			  //I2C ports
       /* .i2c0_out_scl_out (i2c0_scl_out),
        .i2c0_out_scl_in_in(i2c0_scl_in),
        .i2c0_out_scl_out_en(i2c0_scl_out_en),
        .i2c0_out_sda_out(i2c0_sda_out),
        .i2c0_out_sda_in_in(i2c0_sda_in),
        .i2c0_out_sda_out_en(i2c0_sda_out_en),

			  //I2C ports
        .i2c1_out_scl_out (i2c1_scl_out),
        .i2c1_out_scl_in_in(i2c1_scl_in),
        .i2c1_out_scl_out_en(i2c1_scl_out_en),
        .i2c1_out_sda_out(i2c1_sda_out),
        .i2c1_out_sda_in_in(i2c1_sda_in),
        .i2c1_out_sda_out_en(i2c1_sda_out_en), */

        //pin muxed pins
    	  .iocell_io_io7_cell_in_in(io7_cell_in),
    	  .iocell_io_io8_cell_in_in(io8_cell_in),
    	  .iocell_io_io9_cell_in_in(io9_cell_in),
    	  .iocell_io_io10_cell_in_in(io10_cell_in),
    	  .iocell_io_io12_cell_in_in(io12_cell_in),
    	  .iocell_io_io13_cell_in_in(io13_cell_in),
    	  .iocell_io_io16_cell_in_in(io16_cell_in),
    	  .iocell_io_io17_cell_in_in(io17_cell_in),
    	  .iocell_io_io18_cell_in_in(io18_cell_in),
    	  .iocell_io_io19_cell_in_in(io19_cell_in),
    	  .iocell_io_io20_cell_in_in(io20_cell_in),
    	  .iocell_io_io7_cell_out(io7_cell_out),
    	  .iocell_io_io8_cell_out(io8_cell_out),
    	  .iocell_io_io9_cell_out(io9_cell_out),
    	  .iocell_io_io10_cell_out(io10_cell_out),
    	  .iocell_io_io12_cell_out(io12_cell_out),
    	  .iocell_io_io13_cell_out(io13_cell_out),
    	  .iocell_io_io16_cell_out(io16_cell_out),
    	  .iocell_io_io17_cell_out(io17_cell_out),
    	  .iocell_io_io18_cell_out(io18_cell_out),
    	  .iocell_io_io19_cell_out(io19_cell_out),
    	  .iocell_io_io20_cell_out(io20_cell_out),
    	  .iocell_io_io7_cell_outen(io7_cell_en),
    	  .iocell_io_io8_cell_outen(io8_cell_en),
    	  .iocell_io_io9_cell_outen(io9_cell_en),
    	  .iocell_io_io10_cell_outen(io10_cell_en),
    	  .iocell_io_io12_cell_outen(io12_cell_en),
    	  .iocell_io_io13_cell_outen(io13_cell_en),
    	  .iocell_io_io16_cell_outen(io16_cell_en),
    	  .iocell_io_io17_cell_outen(io17_cell_en),
    	  .iocell_io_io18_cell_outen(io18_cell_en),
    	  .iocell_io_io19_cell_outen(io19_cell_en),
    	  .iocell_io_io20_cell_outen(io20_cell_en),
        
     
        //GPIO
       /* .gpio_4_in(gpio_4_in),
        .gpio_7_in(gpio_7_in),
        .gpio_8_in(gpio_8_in),
        .gpio_14_in(gpio_14_in),
        .gpio_15_in(gpio_15_in),
        .gpio_16_in(gpio_16_in),
        .gpio_17_in(gpio_17_in),
        .gpio_18_in(gpio_18_in),
        .gpio_19_in(gpio_19_in),
        .gpio_20_in(gpio_20_in),
        .gpio_21_in(gpio_21_in),
        .gpio_22_in(gpio_22_in),
        .gpio_23_in(gpio_23_in),
        .gpio_24_in(gpio_24_in),
        .gpio_25_in(gpio_25_in),
        .gpio_26_in(gpio_26_in),
        .gpio_27_in(gpio_27_in),
        .gpio_28_in(gpio_28_in),
        .gpio_29_in(gpio_29_in),
        .gpio_30_in(gpio_30_in),
        .gpio_31_in(gpio_31_in),
        .gpio_4_out(gpio_4_out),
        .gpio_7_out(gpio_7_out),
        .gpio_8_out(gpio_8_out),
        .gpio_14_out(gpio_14_out),
        .gpio_15_out(gpio_15_out),
        .gpio_16_out(gpio_16_out),
        .gpio_17_out(gpio_17_out),
        .gpio_18_out(gpio_18_out),
        .gpio_19_out(gpio_19_out),
        .gpio_20_out(gpio_20_out),
        .gpio_21_out(gpio_21_out),
        .gpio_22_out(gpio_22_out),
        .gpio_23_out(gpio_23_out),
        .gpio_24_out(gpio_24_out),
        .gpio_25_out(gpio_25_out),
        .gpio_26_out(gpio_26_out),
        .gpio_27_out(gpio_27_out),
        .gpio_28_out(gpio_28_out),
        .gpio_29_out(gpio_29_out),
        .gpio_30_out(gpio_30_out),
        .gpio_31_out(gpio_31_out),
        .gpio_4_outen(gpio_4_en),
        .gpio_7_outen(gpio_7_en),
        .gpio_8_outen(gpio_8_en),
        .gpio_14_outen(gpio_14_en),
        .gpio_15_outen(gpio_15_en),
        .gpio_16_outen(gpio_16_en),
        .gpio_17_outen(gpio_17_en),
        .gpio_18_outen(gpio_18_en),
        .gpio_19_outen(gpio_19_en),
        .gpio_20_outen(gpio_20_en),
        .gpio_21_outen(gpio_21_en),
        .gpio_22_outen(gpio_22_en),
        .gpio_23_outen(gpio_23_en),
        .gpio_24_outen(gpio_24_en),
        .gpio_25_outen(gpio_25_en),
        .gpio_26_outen(gpio_26_en),
        .gpio_27_outen(gpio_27_en),
        .gpio_28_outen(gpio_28_en),
        .gpio_29_outen(gpio_29_en),
        .gpio_30_outen(gpio_30_en),
        .gpio_31_outen(gpio_31_en),*/

        .ext_interrupts_i(interrupts)
   );


//   IOBUF i2c0_scl_inst(
//             .O(i2c0_scl_in),
//             .IO(i2c0_scl),
//             .I(i2c0_scl_out),
//             .T(~i2c0_scl_out_en)
//         );

//   IOBUF i2c0_sda_inst(
//             .O(i2c0_sda_in),
//             .IO(i2c0_sda),
//             .I(i2c0_sda_out),
//             .T(~i2c0_sda_out_en)
//         );

//   //---- IOBUF FOR I2C -----//
//   IOBUF i2c1_scl_inst(
//             .O(i2c1_scl_in),
//             .IO(i2c1_scl),
//             .I(i2c1_scl_out),
//             .T(~i2c1_scl_out_en)
//         );

//   IOBUF i2c1_sda_inst(
//             .O(i2c1_sda_in),
//             .IO(i2c1_sda),
//             .I(i2c1_sda_out),
//             .T(~i2c1_sda_out_en)
//         );
   //----IOBUF FOR MUXED PIN----//

   IOBUF io7_cell_inst(
             .O(io7_cell_in),
             .IO(io7_cell),
             .I(io7_cell_out),
             .T(io7_cell_en)
         );

   IOBUF io8_cell_inst(
             .O(io8_cell_in),
             .IO(io8_cell),
             .I(io8_cell_out),
             .T(io8_cell_en)
         );

   IOBUF io9_cell_inst(
             .O(io9_cell_in),
             .IO(io9_cell),
             .I(io9_cell_out),
             .T(io9_cell_en)
         );

   IOBUF io10_cell_inst(
             .O(io10_cell_in),
             .IO(io10_cell),
             .I(io10_cell_out),
             .T(io10_cell_en)
         );

   IOBUF io12_cell_inst(
             .O(io12_cell_in),
             .IO(io12_cell),
             .I(io12_cell_out),
             .T(io12_cell_en)
         );

   IOBUF io13_cell_inst(
             .O(io13_cell_in),
             .IO(io13_cell),
             .I(io13_cell_out),
             .T(io13_cell_en)
         );

   IOBUF io16_cell_inst(
             .O(io16_cell_in),
             .IO(io16_cell),
             .I(io16_cell_out),
             .T(io16_cell_en)
         );

   IOBUF io17_cell_inst(
             .O(io17_cell_in),
             .IO(io17_cell),
             .I(io17_cell_out),
             .T(io17_cell_en)
         );

   IOBUF io18_cell_inst(
             .O(io18_cell_in),
             .IO(io18_cell),
             .I(io18_cell_out),
             .T(io18_cell_en)
         );

   IOBUF io19_cell_inst(
             .O(io19_cell_in),
             .IO(io19_cell),
             .I(io19_cell_out),
             .T(io19_cell_en)
         );

   IOBUF io20_cell_inst(
             .O(io20_cell_in),
             .IO(io20_cell),
             .I(io20_cell_out),
             .T(io20_cell_en)
         );
         
endmodule
