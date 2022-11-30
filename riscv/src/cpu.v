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

  .mem_a(mem_ram_a),
  .mem_write(mem_ram_wri),
  .is_write(mem_ram_wrifla),
  .cannot_read(ram_mem_ctread),
  .mem_result(ram_mem_resl),

  .addr_target(ic_mem_a),
  .ic_flag(ic_mem_fg),
  .ic_val(mem_ic_val),
  .ic_isok(mem_ic_fg)
);

RS RS(

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