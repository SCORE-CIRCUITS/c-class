set curdir [ file dirname [ file normalize [ info script ] ] ]
source $curdir/env.tcl

if { $argc != 6 } {
  puts "Please pass the top modu le name that needs to be synthesized along with the fpga part"
  puts " -tclargs <top-module> <xcvp1902-vsva6865-2mp-e-s> <riscv-isa> <jtag_type> <verilogdir> <axibuswidth>"
  exit 2
} else {
  puts "Synthesizing with Top Module: [lindex $argv 0] for ISA: [lindex $argv 2] with Jtag: [lindex $argv 3]"
}

set top_module [lindex $argv 0]
set fpga_part [lindex $argv 1]
set isa [lindex $argv 2]
set base_version [string range [version -short] 0 3]
set jtag_type [lindex $argv 3]
set verilogdir [lindex $argv 4]
set axibuswidth [lindex $argv 5]
# create folders
file mkdir $fpga_dir

# create project
create_project -force $core_project -dir $core_project_dir

# Set project properties
set project_obj [get_projects $core_project]
set_property "default_lib" "xil_defaultlib" $project_obj
set_property "simulator_language" "Mixed" $project_obj
set_property part xcvp1902-vsva6865-2mp-e-s [current_project]

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
add_files -norecurse -fileset [get_filesets sources_1] $verilogdir ./test_soc/S8-100/fpga_top.v

# Set 'source_1' bd file
source $home_dir/tcl/create_boot_bd.tcl 
make_wrapper -files [get_files $core_project_dir/c-class.srcs/sources_1/bd/design_1/design_1.bd] -top
import_files -force -norecurse $core_project_dir/c-class.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v
#add_files -norecurse -fileset [get_filesets sources_1] $core_project_dir/c-class.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v

# add include path
set_property include_dirs $verilogdir [get_filesets sources_1]

# Set 'sources_1' fileset properties
set_property "top" $top_module [get_filesets sources_1]

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Add/Import constrs file and set constrs file properties
add_files -norecurse -fileset constrs_1 $home_dir/constraints.xdc

import_ip $ip_project_dir/manage_ip.srcs/sources_1/ip/clk_divider/clk_divider.xci
import_ip $ip_project_dir/manage_ip.srcs/sources_1/ip/proc_sys_reset_0/proc_sys_reset_0.xci
#import_ip $ip_project_dir/manage_ip.srcs/sources_1/ip/axi_ethernetlite_0/axi_ethernetlite_0.xci

# force create the synth_1 path (need to make soft link in Makefile)
if {[string equal [get_runs -quiet core_synth_1] ""]} {

    create_run \
        -flow "Vivado Synthesis $base_version" \
        -strategy "Flow_PerfOptimized_high" \
        -constrset constrs_1 \
        core_synth_1

} else {

    set_property strategy \
        "Flow_PerfOptimized_high" \
        [get_runs core_synth_1]

    set_property flow \
        "Vivado Synthesis $base_version" \
        [get_runs core_synth_1]
}

# Set synthesis report strategy
set_property report_strategy \
    "Vivado Synthesis Default Reports" \
    [get_runs core_synth_1]
    
set obj [get_runs core_synth_1]

# do not flatten design
#set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs core_synth_1]

## Add the verilog define argument to the string
set verilog_define_args " -verilog_define BSV_RESET_FIFO_HEAD -verilog_define BSV_RESET_FIFO_ARRAY -verilog_define BSV_ASYNC_RESET"
if { $jtag_type eq "JTAG_BSCAN2E" } {
	append verilog_define_args " -verilog_define JTAG_BSCAN2E"
}
if { $axibuswidth eq "BUS_WIDTH128" } {
	append verilog_define_args " -verilog_define BUS_WIDTH128"
}
if { $axibuswidth eq "BUS_WIDTH64" } {
	append verilog_define_args " -verilog_define BUS_WIDTH64"
}
if { $axibuswidth eq "BUS_WIDTH32" } {
	append verilog_define_args " -verilog_define BUS_WIDTH32"
}


set_property STEPS.SYNTH_DESIGN.ARGS.RESOURCE_SHARING off [get_runs core_synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.GLOBAL_RETIMING off [get_runs core_synth_1]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value $verilog_define_args -objects [get_runs core_synth_1]

current_run -synthesis [get_runs core_synth_1]
#set_property strategy Area_Explore [get_runs core_synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet core_impl_1] ""]} {

    create_run \
        -flow "Vivado Advanced Implementation $base_version" \
        -strategy "Performance_ExtraTimingOpt" \
        -constrset constrs_1 \
        -parent_run core_synth_1 \
        core_impl_1

} else {

    set_property flow \
        "Vivado Advanced Implementation $base_version" \
        [get_runs core_impl_1]

    set_property strategy \
        "Performance_ExtraTimingOpt" \
        [get_runs core_impl_1]
}

# Report strategy from implementation flow
set_property report_strategy \
    "Vivado Advanced Implementation Default Reports" \
    [get_runs core_impl_1]

set obj [get_runs core_impl_1]

set_property -name "steps.write_device_image.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_device_image.args.verbose" -value "0" -objects $obj

#set_property STEPS.WRITE_DEVICE_IMAGE.ARGS.READBACK_FILE 0 [get_runs impl_1]
#set_property STEPS.WRITE_DEVICE_IMAGE.ARGS.VERBOSE 0 [get_runs impl_1]

set_property SEVERITY {Warning} [get_drc_checks NSTD-1]

# set the current impl run
current_run -implementation [get_runs core_impl_1]

puts "INFO: Project created:project_1"
exit
