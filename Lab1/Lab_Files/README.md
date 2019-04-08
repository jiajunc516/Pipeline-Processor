# README #

This README documents whatever steps are necessary to get your simulation up and running.

### What is this repository for? ###

* Quick summary
* Version v0.5

### How do I get set up? ###

* git clone ...
* source setup.csh
* cd sim/run/
* ## Lists all the design files that need to be compiled and writes into rtl.f
* $scripts/lister.pl -top_rtl_cfg $design/sources.list -sim_file_list rtl.f -d
* ## Lists all the testbench files that need to be compiled and writes into tb.f
* $scripts/lister.pl -top_rtl_cfg $verif/tb/tb.list -sim_file_list tb.f
* ## Creates libraries (needed only once)
* ## Go to scr folder and ther run:
* ./do.pl -L
* ## Compiles rtl, Compiles testbench, optimises, and run the simulation with the binaary file "add.bin"
* ## Copy rtl and tb from run folder to scr:
* ./do.pl -C rtl:tb -O -S --sim_args="+BIN=add.bin"
* ##  Opens the waveform viewer
* vsim -64 -view logs/default/waveform.wlf -do wave.do

 
### Notes ###

* inst.bin is located under $verif/test/bin/

* You can run different binaries with different filenames (e.g. load.bin)

 ./do.pl -C rtl:tb -O -S --sim_args="+BIN=load.bin"

* Dirctory Structure

"
.
├── doc
├── qip
│   ├── cdc
│   ├── emu
│   ├── formal
│   ├── lint
│   └── syn
├── README.md
├── scr
│   ├── common.pl
│   ├── do.pl
│   ├── lister.pl
│   └── Mixed.pm
├── setup.csh
├── setup.sh
├── sim
│   ├── model
│   ├── run
│   └── verif
└── src
    ├── design_top.sv
    ├── sources.list
    └── sub
"

