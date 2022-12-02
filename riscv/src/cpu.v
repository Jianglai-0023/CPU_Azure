// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
  input  wire                 clk_in,			// system clock signal
  input  wire                 rst_in,			// reset signal
	input  wire					        rdy_in,			// ready signal, pause cpu when low

  input  wire [ 7:0]          mem_din,		// data input bus
  output wire [ 7:0]          mem_dout,		// data output bus
  output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
  output wire                 mem_wr,			// write/read signal (1 for write)
	
	input  wire                 io_buffer_full, // 1 if uart buffer is full
	
	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);


// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)
wire [31 : 0] ic_if_ins;
wire [31 : 0] if_ic_pc;
wire          ic_if_fg;
wire          if_ic_fg;

wire [31 : 0] if_de_ins;
wire          if_de_insfg;
wire [31 : 0] if_de_pc;
wire [31 : 0] if_de_bc;
wire          if_de_bcfg;
wire [31 : 0] if_de_imm;

wire [31 : 0] if_rob_jppc; 
wire          if_rob_jpwrong; 
IF IF(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
//IC
  .ins_ori(ic_if_ins),
  .pc_cache(if_ic_pc),
  .ins_ori_flag(ic_if_fg),
  .pc_flag(if_ic_fg),
//Decoder
  .ins(if_de_ins),
  .ins_flag(if_de_insfg),
  .ins_imm(if_de_imm),
  .pc_decode(if_de_pc),
  .pc_decode_bc(if_de_bc),
  .pc_decode_bc_flag(if_de_bcfg),
//ROB
  .jp_pc(if_rob_jppc),
  .jp_wrong(if_rob_jpwrong)
);



ICache IC(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in), 

  .ins_ori(ic_if_ins),
  .ins_flag(ic_if_fg),
  .pc(if_ic_pc),
  .pc_flag(if_ic_fg),

  .pc_mem(ic_mem_a),
  .pc_flag_mem(ic_mem_fg),
  .ins_mem(mem_ic_val),
  .ins_mem_flag(mem_ic_fg)         
);

wire [31 : 0] mem_ram_a;
wire [7  : 0] mem_ram_wri;
wire          mem_ram_wrifla;
wire          ram_mem_ctread;
wire [7  : 0] ram_mem_resl;

wire [31 : 0] ic_mem_a;
wire          ic_mem_fg;
wire [31 : 0] mem_ic_val;
wire          mem_ic_fg;


MemCtrl Memctrl(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
  //RAM
  .mem_a(mem_ram_a),
  .mem_write(mem_ram_wri),
  .is_write(mem_ram_wrifla),
  .cannot_read(ram_mem_ctread),
  .mem_result(ram_mem_resl),
  //IC
  .addr_target(ic_mem_a),
  .ic_flag(ic_mem_fg),
  .ic_val_out(mem_ic_val),
  .ic_isok(mem_ic_fg),
  //LSB
  .lsb_addr(lsb_mem_a),
  .lsb_flag(lsb_mem_flag),
  .opcode(lsb_mem_op),
  .lsb_store(lsb_mem_val),
  .lsb_isok(mem_lsb_memok),
  .lsb_val_out(mem_lsb_val) 
);

wire          de_if_stal;
wire [5 : 0]  de_rs_op;
wire [31 :0]  de_rs_imm;
wire [4 : 0]  de_rs_rs1;
wire [4 : 0]  de_rs_rs2;
wire [4 : 0]  de_rs_rd;
wire          de_rs_flag;
wire          lsb_de_full;
Decoder Decoder(
  //IF
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),

  .ins(if_de_ins),
  .ins_flag(if_de_insfg),
  .ins_imm(if_de_imm),
  .pc(if_de_pc),
  .pc_bc_flag(if_de_bcfg),
  .pc_bc(if_de_bc),
  .if_stall(de_if_stal),
  //RS

  .opcode(de_rs_op),
  .imm(de_rs_imm),
  .rs1(de_rs_rs1),
  .rs2(de_rs_rs2),
  .rd(de_rs_rd),
  .op_flag(de_rs_flag),
    
    
  .rob_full(rb_de_full),
    
  .lsb_full(lsb_de_full)
  


);
wire [4 : 0] rs_reg_rs1a;
wire [4 : 0] rs_reg_rs2a;

wire  [5 : 0 ] rs_alu_op ;   
wire  [31 : 0] rs_alu_rs1; 
wire  [31 : 0] rs_alu_rs2;
wire           rs_alu_fg ; 
wire  [3 : 0 ] rs_alu_rb ; 

wire           reg_rs_rs1fg;
wire           reg_rs_rs2fg;
wire           rs_res_fg;
wire  [31 : 0] reg_rs_val1;
wire  [31 : 0] reg_rs_val2;
wire  [3 : 0 ] rob_CDB_reorder;
wire  [4 : 0] rob_CDB_outidx;
wire  [4 : 0] rob_CDB_inidx;
wire  [31 : 0] rob_CDB_outval;
wire           rob_CDB_outflag;
wire           rob_CDB_inflag;
wire [5 : 0 ] rs_alu_op;
wire [31 : 0] rs_alu_rs1;
wire [31 : 0] rs_alu_rs2;
wire          rs_alu_fg; 
wire [3 : 0] rs_alu_rob;


RS RS(
  //IF
  .imm(de_rs_imm),
  .opcode(de_rs_op),
  .rs1(de_rs_rs1),
  .rs2(de_rs_rs2),
  .opflag(de_rs_flag),
  //Regfile
  .rs1_addr(rs_reg_rs1a),
  .rs2_addr(rs_reg_rs2a),
  .rs1_ready(reg_rs_rs1fg),
  .rs2_ready(reg_rs_rs2fg),
  .reg_flag(rs_res_fg),
  .rs1_val(reg_rs_val1),
  .rs2_val(reg_rs_val2),

  .rob_reorder(rob_CDB_reorder),
  .rd_val(rob_CDB_outval),
  .rd_flag(rob_CDB_outflag),
  //alu
  .op_alu(rs_alu_op),
  .rs1_alu(rs_alu_rs1),
  .rs2_alu(rs_alu_rs2),
  .flag_alu(rs_alu_fg),
  .rob_alu(rs_alu_rob)

);

wire [4 : 0] de_rb_idx;
wire         de_rb_rdready;
wire [31 : 0]de_rb_val;
wire         de_rb_flag;
wire         rb_de_full;

wire [4 : 0] rd_idx_CDB;
wire [3 : 0] rear_CDB,front_CDB;
//alu & rob
wire [3 : 0]  rb_alu_reorder;
wire [31 : 0] rb_alu_val;
wire          rb_alu_flag;

ROB ROB(
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    //Decode
    .rd_idx(de_rb_idx),
    .rd_isready(de_rb_rdready),
    .rd_val(de_rb_val),
    .flag(de_rb_flag),
    .full(rb_de_full),
    //CDB
    .rd_val_update(rob_CDB_outval),
    .rd_idxin_update(rob_CDB_inidx),
    .rd_idxout_update(rob_CDB_outidx),
    .rd_out_fg(rob_CDB_outflag),
    .rd_in_fg(rob_CDB_inflag),
    .front(front_CDB),
    .rear(rear_CDB),
    //ALU
    .rob_reorder(rb_alu_reorder),
    .alu_val(rb_alu_val),
    .alu_flag(rb_alu_flag)
 );  
//decode 
wire          de_lsb_flag;
wire [5 : 0 ] de_lsb_op;
wire [31 : 0] de_lsb_imm;
wire [4 : 0]  de_lsb_rd;
wire [31 :0]  de_lsb_val1;
wire [31 : 0] de_lsb_val2;
wire          de_lsb_val1rdy;
wire          de_lsb_val2rdy;

//Memctrl
wire          lsb_mem_iswrite;
wire          lsb_mem_flag;
wire [31 : 0] lsb_mem_a;
wire [31 : 0] mem_lsb_val;
wire          mem_lsb_memok;
wire [31 : 0] lsb_mem_val;
wire [5 : 0] lsb_mem_op;

//CDB
wire [3 : 0] lsb_CDB_reorder;
wire [31 :0] lsb_CDB_val;
wire         lsb_CDB_flg;
LSB LSB(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
  //Decode
  .op_flag(de_lsb_flag),          
  .opcode(de_lsb_op),           
  .imm(de_lsb_imm),
  .rd(de_lsb_rd),
  .rs1_val_(de_lsb_val1),
  .rs2_val_(de_lsb_val2),
  .is_val1(de_lsb_val1rdy),
  .is_val2(de_lsb_val2rdy),
  //Memctrl
  .is_write(lsb_mem_iswrite),
  .flag(lsb_mem_flag),
  .addr(lsb_mem_a),
  .val_in(lsb_mem_val),
  .mem_ok(mem_lsb_memok),
  .val_out(mem_lsb_val),
  .lsb_op(lsb_mem_op),
  //CDB
  .rob_reorder(lsb_CDB_reorder),
  .rob_val(lsb_CDB_val),
  .rob_flag(lsb_CDB_flg),
  .isfull(lsb_de_full)
 );
wire [31 :0] rob_alu_val1,rob_alu_val2;
wire rob_alu_fg;
wire [5 : 0] rob_alu_op;
wire [3 : 0] rob_alu_reorder;
wire [31 :0] alu_CDB_ans;
wire alu_CDB_fg;
wire [3 :0] alu_CDB_reorder;

ALU ALU(
.val1(rob_alu_val1),
.val2(rob_alu_val2),
.flag(rob_alu_fg),
.opcode(rob_alu_op),
.rob_reorder(rob_alu_reorder),
.ans(alu_CDB_ans),
.flag_out(alu_CDB_fg),
.rob_(alu_CDB_reorder)
); 


RegFile RegFile(
    .clk(clk_in),
    .rdy(rdy_in),
    .rst(rst_in),
    //RS
    .rs1(rs_reg_rs1a),
    .rs2(rs_reg_rs2a),
    .rs1_ready(reg_rs_rs1fg),
    .rs2_ready(reg_rs_rs2fg),
    .rs1_val(reg_rs_val1),
    .rs2_val(reg_rs_val2),
    //ROB
    .rd_in_flag(rob_CDB_inflag),
    .rd_out_flag(rob_CDB_outflag),
    .rd_in_a(rob_CDB_inidx),
    .rd_out_a(rob_CDB_outidx),

    .rd_out_val(rob_CDB_outval),
    .rd_in_rob(rear_CDB),
    .rd_out_rob(front_CDB)

);


always @(posedge clk_in)
  begin
    if (rst_in)
      begin
      
      end
    else if (!rdy_in)
      begin
      
      end
    else
      begin
      
      end
  end

endmodule