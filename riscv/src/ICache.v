`include "defines.v";
module ICache(
    input wire clk,rst,rdy,
    //IF
    output wire [31 : 0] ins_ori,
    output wire          ins_flag,
    input wire  [31 : 0] pc,
    input wire           pc_flag,
    //Mem
    output wire [31 : 0] pc_mem,
    output wire          pc_flag_mem,
    input wire  [31 : 0] ins_mem,
    input wire           ins_mem_flag
);
assign pc_flag_mem = pc_flag;
assign pc_mem = pc;
assign ins_ori = ins_mem;
assign ins_flag =  ins_mem_flag;
endmodule