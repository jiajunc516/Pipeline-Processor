onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /hdl_tb_top/dut_inst/riscv_inst/clk
add wave -noupdate /hdl_tb_top/dut_inst/riscv_inst/rst_n
add wave -noupdate -group inst_mem -radix unsigned -radixshowbase 0 /hdl_tb_top/dut_inst/riscv_inst/imem_inst/addr
add wave -noupdate -group inst_mem /hdl_tb_top/dut_inst/riscv_inst/imem_inst/rdata
add wave -noupdate -group inst_mem -label rinst /hdl_tb_top/dut_inst/riscv_inst/inst.rinst
add wave -noupdate -group Controler /hdl_tb_top/dut_inst/riscv_inst/ctrl_if/aluop
add wave -noupdate -group Controler /hdl_tb_top/dut_inst/riscv_inst/ctrl_if/branch
add wave -noupdate -group Controler /hdl_tb_top/dut_inst/riscv_inst/ctrl_if/jalr_mode
add wave -noupdate -group Controler /hdl_tb_top/dut_inst/riscv_inst/ctrl_if/jal_mode
add wave -noupdate -group Controler /hdl_tb_top/dut_inst/riscv_inst/ctrl_if/lui_mode
add wave -noupdate -group Controler /hdl_tb_top/dut_inst/riscv_inst/ctrl_if/alu_src
add wave -noupdate -group Controler /hdl_tb_top/dut_inst/riscv_inst/ctrl_if/mem_read
add wave -noupdate -group Controler /hdl_tb_top/dut_inst/riscv_inst/ctrl_if/mem_write
add wave -noupdate -group Controler /hdl_tb_top/dut_inst/riscv_inst/ctrl_if/mem2reg
add wave -noupdate -group Controler /hdl_tb_top/dut_inst/riscv_inst/ctrl_if/reg_write
add wave -noupdate -group {Reg File} /hdl_tb_top/dut_inst/riscv_inst/dp_inst/regf_inst/rd_addr1
add wave -noupdate -group {Reg File} /hdl_tb_top/dut_inst/riscv_inst/dp_inst/regf_inst/rd_data1
add wave -noupdate -group {Reg File} /hdl_tb_top/dut_inst/riscv_inst/dp_inst/regf_inst/rd_addr2
add wave -noupdate -group {Reg File} /hdl_tb_top/dut_inst/riscv_inst/dp_inst/regf_inst/rd_data2
add wave -noupdate -group {Reg File} /hdl_tb_top/dut_inst/riscv_inst/dp_inst/regf_inst/wr_en
add wave -noupdate -group {Reg File} /hdl_tb_top/dut_inst/riscv_inst/dp_inst/regf_inst/wr_addr
add wave -noupdate -group {Reg File} /hdl_tb_top/dut_inst/riscv_inst/dp_inst/regf_inst/wr_data
add wave -noupdate -group {Imm Gen} /hdl_tb_top/dut_inst/riscv_inst/dp_inst/immgen_inst/imm
add wave -noupdate -expand -group ALU /hdl_tb_top/dut_inst/riscv_inst/dp_inst/aluc_inst/aluop
add wave -noupdate -expand -group ALU /hdl_tb_top/dut_inst/riscv_inst/dp_inst/aluc_inst/funct7
add wave -noupdate -expand -group ALU /hdl_tb_top/dut_inst/riscv_inst/dp_inst/aluc_inst/funct3
add wave -noupdate -expand -group ALU /hdl_tb_top/dut_inst/riscv_inst/dp_inst/alu_inst/operation
add wave -noupdate -expand -group ALU -radix decimal /hdl_tb_top/dut_inst/riscv_inst/dp_inst/alu_inst/operand_a
add wave -noupdate -expand -group ALU -radix decimal /hdl_tb_top/dut_inst/riscv_inst/dp_inst/alu_inst/operand_b
add wave -noupdate -expand -group ALU -radix decimal /hdl_tb_top/dut_inst/riscv_inst/dp_inst/alu_inst/result
add wave -noupdate -expand -group ALU /hdl_tb_top/dut_inst/riscv_inst/dp_inst/alu_inst/branch
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3010 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {18840 ps}
