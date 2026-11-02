create_bd_design "design_1"

#PS_WIZARD BOOT only
create_bd_cell -type ip -vlnv xilinx.com:ip:ps_wizard:1.0 ps_wizard_0

set_property -dict [list \
    CONFIG.PS_PMC_CONFIG(PMC_SMAP_PERIPHERAL) {PRIMARY_ENABLE 1 IO 8_Bit} \
    CONFIG.PS_PMC_CONFIG(PS_SLR_ID) {0} \
] [get_bd_cells ps_wizard_0]

#AXI NOC DDR4
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 axi_noc_0

set_property -dict [list \
  CONFIG.MC_DATAWIDTH {72} \
  CONFIG.MC_EN_INTR_RESP {TRUE} \
  CONFIG.MC_INPUTCLK0_PERIOD {4944} \
  CONFIG.MC_MEMORY_DEVICETYPE {SODIMMs} \
  CONFIG.MC_MEMORY_SPEEDGRADE {DDR4-3200AA(22-22-22)} \
  CONFIG.MC_MEMORY_TIMEPERIOD0 {682} \
  CONFIG.MC_PARITY {true} \
  CONFIG.MC_RANK {2} \
  CONFIG.MC_ROWADDRESSWIDTH {17} \
  CONFIG.NUM_CLKS {1} \
  CONFIG.NUM_MC {1} \
  CONFIG.NUM_MI {0} \
] [get_bd_cells axi_noc_0]

set_property -dict [list \
    CONFIG.CONNECTIONS {MC_0 { \
        read_bw {500} \
        write_bw {500} \
        read_avg_burst {4} \
        write_avg_burst {4}}} \
] [get_bd_intf_pins axi_noc_0/S00_AXI]

set_property CONFIG.MC_CHAN_REGION0 {DDR_LOW1} [get_bd_cells axi_noc_0]

# Match SoC ID_WIDTH
set_property CONFIG.ID_WIDTH    5  [get_bd_intf_pins axi_noc_0/S00_AXI]
set_property CONFIG.DATA_WIDTH 128  [get_bd_intf_pins axi_noc_0/S00_AXI]

# Make External Pins To Connect SoC RTL
make_bd_intf_pins_external [get_bd_intf_pins axi_noc_0/CH0_DDR4_0]
make_bd_intf_pins_external [get_bd_intf_pins axi_noc_0/S00_AXI]
make_bd_pins_external [get_bd_pins axi_noc_0/aclk0]
make_bd_intf_pins_external [get_bd_intf_pins axi_noc_0/sys_clk0]

set_property -dict [list CONFIG.FREQ_HZ 50000000] [get_bd_ports aclk0_0]

assign_bd_address -target_address_space /S00_AXI_0 [get_bd_addr_segs axi_noc_0/S00_AXI/C0_DDR_LOW1] -force
set_property range 32G [get_bd_addr_segs {S00_AXI_0/SEG_axi_noc_0_C0_DDR_LOW1}]

validate_bd_design
save_bd_design
