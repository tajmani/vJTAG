Altera SLD_Virtual_JTAG Example Design
--------------------------------------

4/12/2014 D. W. Hawkins (dwh@ovro.caltech.edu)

This example design shows how to connect the 
SLD_Virtual_JTAG component to the LEDs and push
buttons on the DE2 board.

The Tcl script scripts/vjtag_cmds.tcl can be used
from the command-line application quartus_stp to
access the GPIO.

---------------------------------------------------------------------
Synthesis Instructions
----------------------

1. Unzip the example source, eg., into

   C:\temp\de2_sld_vjtag_to_gpio

2. Start Quartus

3. Select the Tcl console
   (if its not visible, select View->Utility Windows->Tcl Console)
   
4. Change directory to the top-level of the source

   tcl> cd {C:\temp\de2_sld_vjtag_to_gpio}
   
5. Source the synthesis Tcl script

   tcl> source scripts/synth.tcl

   The console will output the following messages ...   
   
   Synthesizing the DE2 'sld_vjtag_to_gpio' design
   -----------------------------------------------
    - Quartus Version 12.1 Build 243 01/31/2013 Service Pack 1 SJ Web Edition
    - Creating the Quartus work directory
      * C:/temp/de2_sld_vjtag_to_gpio/qwork
    - Changing to the Quartus work directory
      * C:/temp/de2_sld_vjtag_to_gpio/qwork
    - Creating the Quartus project
      * create a new de2 project
    - Creating the design files list
    - Applying constraints
    - Processing the design
    - Processing completed

6. You can now use the JTAG programmer to download your DE2.

If your target board is not the DE2, then you will have to create
your own top-level VHDL design and corresponding pin assignments
(see constraints.tcl for an example).

---------------------------------------------------------------------
GPIO Control Instructions
-------------------------

1. Download the DE2 board

2. Start a NIOS II IDE Shell (Cygwin console)

   eg. Under Windows XP
   
   Start->All Programs->Altera->NIOS II EDS 12.1sp1->NIOS II 12.1sp1 Command Shell
   
3. View the JTAG nodes

   $ jtagconfig -n
   1) USB-Blaster [USB-0]
     020B40DD   EP2C35
       Node 00406E00  (110:8) #0
    Design hash    D1C56CB2D6FF7B6F3030
    
4. Start quartus_stp

   $ quartus_stp -s
   
   This starts the Tcl interface.
   
5. Change to the project folder

   tcl> cd {C:\temp\de2_sld_vjtag_to_gpio}
   
6. Source the VJTAG Tcl commands

   tcl> source scripts/vjtag_cmds.tcl
   
7. Issue VJTAG IR Tcl commands

a) Read the JTAG device IDCODE

   tcl> read_idcode
   0x020B40DD

b) Read the JTAG device USERCODE

   tcl> read_usercode
   0xDEADBEEF

c) Print the Altera Virtual JTAG hub info

   tcl> print_hub_info
            Hub info: 0x08086E04
         VIR m-width: 4
     Manufacturer ID: 0x6E
     Number of nodes: 1
          IP Version: 1

d) Change the VJTAG IR value

   tcl> jtag_vir 0x1234
   38565   
   
   The DE2 board red and green LEDs and one of the
   hex displays will illuminate SLD_IR_WIDTH LEDs,
   where SLD_IR_WIDTH is the top-level generic on
   the DE2.vhd design (nominally set to 18-bits).
   
   The jtag_vir instruction returns the status of
   the 18-bits of switches. The value can be converted
   to hex to make it easier to determine which pins
   were asserted, eg.,
   
   tcl> set sw [jtag_vir 0x1234]
   tcl> puts [format "0x%.4X" $sw]
   0x96A5
   
   which matches the settings used during this test.
      
8. Issue VJTAG DR Tcl commands
   
   tcl> jtag_vdr 0x1234
   0x55

   A SignalTap II trace will show the data serialized
   on TDI. TDO is configured to toggle, so it will
   always read 0x55 or 0xAA.
      
---------------------------------------------------------------------
   
Enjoy!

Cheers,
Dave

   
   

