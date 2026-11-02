#set curdir [ file dirname [ file normalize [ info script ] ] ]
#source $curdir/env.tcl
#
#open_project $ip_project_dir/$ip_project.xpr
#set_property "simulator_language" "Mixed" [current_project]
#set_property "target_language" "Verilog" [current_project]

puts "\nDEBUG: Creating Clock Divider from Clock Wizard\n"

if { [get_ips -quiet clk_divider] eq "" } {
    create_ip -name clk_wizard -vendor xilinx.com -library ip -version 1.0 -module_name clk_divider 
} else {
    reset_run clk_divider_synth_1
}
set_property -dict [list \
  CONFIG.CLKOUT_DRIVES {BUFG,BUFG} \
  CONFIG.CLKOUT_GROUPING {Auto,Auto} \
  CONFIG.CLKOUT_MATCHED_ROUTING {false,false} \
  CONFIG.CLKOUT_PORT {clk_out1,clk_out2} \
  CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000} \
  CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {50,50} \
  CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000} \
  CONFIG.CLKOUT_USED {true,true} \
  CONFIG.PRIM_IN_FREQ {300} \
  CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
  CONFIG.USE_RESET {true} \
  CONFIG.USE_LOCKED {true} \
] [get_ips clk_divider]
generate_target {instantiation_template} [get_ips clk_divider]
create_ip_run [get_ips clk_divider]
#launch_run clk_divider_synth_1
#wait_on_run clk_divider_synth_1
#exit
