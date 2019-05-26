typedef struct packed
{
	logic [8:0] curr_pc;
	logic [31:0] curr_instr;
}IF_ID_REG;

typedef struct packed
{
	logic [8:0] curr_pc;
	logic [31:0] rdata1;
	logic [31:0] rdata2;
	logic [31:0] imm_value;
	
	logic [4:0]	 rs1;
	logic [4:0]  rs2;
	logic [4:0]  rd;
	logic [2:0]  func3;
	logic [6:0]  func7;
	
	//from control unit:
	logic ALUSrc;
	logic MemtoReg;
	logic RegWrite;
	logic MemRead;
	logic MemWrite;
	logic [1:0] rw_sel; //Read or Write
	logic [1:0]  ALUOp;
	logic branch;
	logic jalr_sel;
	
	logic [31:0] curr_instr; //current instruction-       
	//future update according to controller design
}ID_EX_REG;

typedef struct packed
{
	logic [31:0] pc_imm;
	logic [31:0] pc_4;
	logic [31:0] alu_result;
	logic [31:0] imm_value;
	logic [31:0] rdata2;
	logic [4:0]  rd;
	logic [2:0]  func3;
	logic [6:0] func7;
	logic [1:0] rw_sel; //Read or Write
	logic RegWrite;
	logic MemRead;
	logic MemWrite;
	logic MemtoReg;
	
	logic [31:0] curr_instr; //current instruction-       
	//future update according to controller design
}EX_MEM_REG;

typedef struct packed
{
	logic [31:0] mem_read_data;
	logic [31:0] alu_out;
	logic [31:0] imm_value;
	logic [31:0] add_out; //pc 
	logic [4:0] rd;
	
	logic RegWrite;
	logic MemtoReg;
	
	logic [31:0] curr_instr; //current instruction-       
		//future update according to controller design
}MEM_WB_REG;


typedef union packed
{
	IF_ID_REG if_id;
	ID_EX_REG id_ex;
	EX_MEM_REG ex_mem;
	MEM_WB_REG mem_wb;
		//future update according to controller design
}pipelining;