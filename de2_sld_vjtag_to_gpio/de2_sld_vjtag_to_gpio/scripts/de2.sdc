# de2.sdc
#
# 10/2/2010 D. W. Hawkins (dwh@ovro.caltech.edu)
#
# Quartus II synthesis TimeQuest SDC timing constraints.
#
# -----------------------------------------------------------------
# Notes
# -----
#
# 1. This script is typically called automatically by Quartus by
#    including the SDC file as a project design file via
#
#    set_global_assignment -name SDC_FILE $scripts/de2.sdc
#
#    The Quartus GUI log window indicates that the script is run
#    under the quartus_sta program. If you try to use the
#    Tcl commands get_ports, create_clock, etc. under the Quartus
#    Tcl console, it will tell you the commands are only supported
#    by quartus_sta and quartus_map.
#
# 2. The results of this script and script modifications can be
#    analyzed using the TimeQuest GUI, eg.
#
#    a) From Quartus, select Tools->TimeQuest Timing Analyzer
#    b) In TimeQuest, Netlist->Create Timing Netlist, Ok
#    c) Run any of the analysis tasks
#       eg. 'Check Timing' and 'Report Unconstrained Paths'
#       show the design is constrained. 'Report All I/O Timings'
#       shows the input/output setup/hold results.
#
#    d) Look at input/output setup/hold times using
#
#       report_timing -from [get_keepers $tdi] \
#                     -setup -panel_name {Report Timing}
#
#       report_timing -from [get_keepers $tdi] \
#                     -hold  -panel_name {Report Timing}
#
#       report_timing -to   [get_keepers $tdo] \
#                     -setup -panel_name {Report Timing}
#
#       report_timing -to   [get_keepers $tdo] \
#                     -hold  -panel_name {Report Timing}
#  
# -----------------------------------------------------------------

# =================================================================
# Timing parameters
# =================================================================
#
# -----------------------------------------------------------------
# JTAG parameters
# -----------------------------------------------------------------
#
# The timing of the JTAG interface is determined by the device
# communicating with the FPGA, eg. a USB-Blaster, or an on-board
# USB-Blaster such as the ones used on the Altera development kits.
# The following USB-Blaster parameters are fairly arbitrary and
# their values have been selected to be unique so that each 
# parameter can be easily identifed in the TimeQuest report_timing
# waveforms.

# JTAG signal names (for use in assigning constraints)
set tck altera_reserved_tck
set tms altera_reserved_tms
set tdi altera_reserved_tdi
set tdo altera_reserved_tdo

# JTAG clock (10MHz/100ns period)
set tck_period 100.0

# USB-Blaster timing (estimates)
set usb_blaster_tco_min  5.0
set usb_blaster_tco_max 15.0
set usb_blaster_tsu     11.0
set usb_blaster_th      10.0

# Delay calculations
#
#   The USB-Blaster TCK/TMS/TDI signals are most likely all 
#   generated using a common digital output register, so there
#   should be very little skew between the signals, i.e., 
#   both the clock, TCK, and data signals, TMS and TDI, will arrive
#   at the same time. Use the USB-Blaster estimated clock-to-output
#   delay parameters to determine the SDC input delay minimum
#   and maximum constraints as that will account for the worst-case
#   possible skew between the TCK output and the TMS/TDI outputs.
#
#   The USB-Blaster will read the TDO output, so use the
#   USB-Blaster setup/hold estimates to determine the SDC
#   output minimum and maximum delay constraints.
#
# JTAG Inputs
set jtag_input_delay_min $usb_blaster_tco_min
set jtag_input_delay_max $usb_blaster_tco_max
#
# JTAG Outputs
set jtag_output_delay_min -$usb_blaster_th
set jtag_output_delay_max  $usb_blaster_tsu

# -----------------------------------------------------------------
# User I/O timing parameters
# -----------------------------------------------------------------
#
# No external clocks used in this design

# No I/O constraints for this design

# =================================================================
# SDC assignments
# =================================================================
#
# The Altera SLD component includes SDC constraints that cause the
# virtual JTAG clock constraints below to not work. Resetting the
# design, or removing clock groups fixes things. Without one of
# these settings, the 'Report All I/O Timings' macro will not
# report any timing. The 'Report Clock Transfers' diagnostic shows
# that tck and vtck transfers are considered false paths, hence
# the lack of I/O timings.
#
#reset_design
remove_clock_groups -all

# -----------------------------------------------------------------
# Clocks
# -----------------------------------------------------------------
#
# JTAG clock
create_clock -period $tck_period -name $tck [get_ports $tck]

# Virtual JTAG clock (for use in I/O constraints)
create_clock -period $tck_period -name vtck

# Ensure the clock domains are considered separate
set_clock_groups -exclusive -group [list $tck vtck]

# -----------------------------------------------------------------
# JTAG timing
# -----------------------------------------------------------------
#
# Constraining the JTAG paths allows the TimeQuest timing estimates
# for the JTAG signals to be compared to their data sheet
# parameters.
#
# If the JTAG timing paths are cut, then 'Report All I/O Timing'
# will have no paths to report. Its possible to P&R with the
# paths cut, and then re-run the analysis with the paths
# constrained. However, since there are no programmable delay
# elements in the JTAG the timing results are identical.
#
if {0} {
	# Cut all JTAG timing paths
	set_false_path -from *                -to [get_ports $tdo]
	set_false_path -from [get_ports $tms] -to *
	set_false_path -from [get_ports $tdi] -to *
} else {
	# Constrain all JTAG timing paths

	# Inputs (externally driven on falling edge)
	set_input_delay  -clock vtck -clock_fall \
		-min $jtag_input_delay_min [get_ports [list $tms $tdi]]
	set_input_delay  -clock vtck -clock_fall \
		-max $jtag_input_delay_max [get_ports [list $tms $tdi]]
	
	# Output (externally registered on rising edge)
	set_output_delay -clock vtck \
		-min $jtag_output_delay_min [get_ports $tdo]
	set_output_delay -clock vtck \
		-max $jtag_output_delay_max [get_ports $tdo]
}

# -----------------------------------------------------------------
# Cut timing paths
# -----------------------------------------------------------------
#
# The timing for the I/Os in this design is arbitrary, so cut all
# paths to the I/Os, even though they are used in the design.
#

# Switches
set_false_path -from [get_ports sw*] -to *

# Push buttons
set_false_path -from [get_ports key*] -to *

# LED and hex display output paths
set_false_path -from * -to [get_ports led*]
set_false_path -from * -to [get_ports hex*]

# GPIO input/output paths
set_false_path -from [get_ports gpio*] -to *
set_false_path -from *                 -to [get_ports gpio*]



