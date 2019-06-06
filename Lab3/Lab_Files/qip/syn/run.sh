rm -rf WORK tb.f syn.log rtl.f log.log incdir.list default.svf command.log alib-52 112L-RISCV


$scripts/lister.pl -top_rtl_cfg $design/sources.list -sim_file_list rtl.f
cat rtl.f | grep -v saed32sram | awk 'BEGIN {printf("analyze -format sverilog { \\\n")} {printf("%s \\\n", $1)} END {printf("}\n")}' > scripts/files_design_top.tcl

dc_shell-t -f synth.tcl | tee log.log

