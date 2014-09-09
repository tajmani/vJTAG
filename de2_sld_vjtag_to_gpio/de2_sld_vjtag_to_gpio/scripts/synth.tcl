# -----------------------------------------------------------------
# de2/cyclone2/sld_vjtag_to_gpio/scripts/synth.tcl
#
# 11/2/2010 D. W. Hawkins (dwh@ovro.caltech.edu)
#
# Quartus synthesis script.
#
# -----------------------------------------------------------------
# Usage
# -----
#
# 1. From within Quartus, change to the project folder, and type
#
#    source scripts/synth.tcl
#
# 2. Command-line processing. Change to the project folder,
#    and type either;
#
#    a) quartus_sh -s
#       tcl> source scripts/synth.tcl
#
#    b)  quartus_sh -t scripts/synth.tcl
#
# -----------------------------------------------------------------
# References
# ----------
#
# [1] Altera. "Quartus II Scripting Reference Manual",
#     v9.1, 2009.
#
# [2] Altera. "Quartus II Settings File Reference Manual",
#     v7.0, 2010.
#
#
# -----------------------------------------------------------------

puts ""
puts "Synthesizing the DE2 'sld_vjtag_to_gpio' design"
puts "-----------------------------------------------"

# -----------------------------------------------------------------
# Packages
# -----------------------------------------------------------------

package require ::quartus::project
package require ::quartus::flow

# -----------------------------------------------------------------
# Design paths
# -----------------------------------------------------------------

# Design parameters
set board      de2
set device     cyclone2
set design     sld_vjtag_to_gpio

# Design paths
set design_top  [pwd]
set scripts     $design_top/scripts
set src         $design_top/src
set constraints $scripts/constraints.tcl

# -----------------------------------------------------------------
# Quartus work
# -----------------------------------------------------------------

global quartus
puts " - Quartus $quartus(version)"

# Version-specific build directory
set qwork $design_top/qwork

if {![file exists $qwork]} {
    puts " - Creating the Quartus work directory"
    puts "   * $qwork"
    file mkdir $qwork
}

# Create all the generated files in the work directory
cd $qwork
puts " - Changing to the Quartus work directory"
puts "   * $qwork"

# -----------------------------------------------------------------
# Quartus project
# -----------------------------------------------------------------

puts " - Creating the Quartus project"

# Close any open project
# * since all the DE2 projects are named de2, close the current
#   project to clear the files list. This avoids the top-level
#   files from another DE2 project being picked up if the
#   previous project was not closed.
#
if {[is_project_open]} {
	puts "   * close the project"
	project_close
}

# Best to name the project your "top" component name.
#
#  * $quartus(project) contains the project name
#  * project_exist de2 returns 1 only in the work directory,
#    since that is where the Quartus project file is located
#
if {[project_exists de2]} {
	puts "   * open the existing de2 project"
	project_open -revision de2 de2
} else {
	puts "   * create a new de2 project"
	project_new -revision de2 de2
}

# -----------------------------------------------------------------
# Design files
# -----------------------------------------------------------------

puts " - Creating the design files list"

# Create a list of VHDL files to build
#
set vfiles ""

# Add the design files
lappend vfiles $src/hex_display.vhd
lappend vfiles $src/de2.vhd

# Pass the VHDL files list to Quartus
foreach vfile $vfiles {
    set_global_assignment -name VHDL_FILE $vfile
}

# SignalTap II (default to disabled)
set_global_assignment -name ENABLE_SIGNALTAP OFF
set_global_assignment -name USE_SIGNALTAP_FILE $scripts/de2.stp

# -----------------------------------------------------------------
# Design constraints
# -----------------------------------------------------------------

puts " - Applying constraints"
source $constraints
set_default_constraints

# SDC constraints
set_global_assignment -name SDC_FILE $scripts/de2.sdc

# -----------------------------------------------------------------
# Process the design
# -----------------------------------------------------------------

puts " - Processing the design"

execute_flow -compile

# Use one of the following to save the settings
#project_close
export_assignments

# Return to the top directory
cd $design_top

puts " - Processing completed"
puts ""

