set PathSeparator .

#set WLFFilename waveform.wlf
#log -r .*

log hdl_tb_top.dut_inst.riscv_inst.imem_inst.mem
log hdl_tb_top.dut_inst.riscv_inst.dp_inst.regf_inst.regmem
log -r .* 
run -all
quit
