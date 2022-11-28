`include "defines.v";
module RF(
    input wire clk,rdy,rst,
    //find reg's val or reorder
    //RS
    input wire  [4 : 0]     rs1,rs2,
    output wire             rs1_ready, rs2_ready,
    output wire [31 : 0]    rs1_val,rs2_val,

    //ROB
    input wire rd_in_flag,rd_out_flag,
    input wire [4 : 0] rd_out,rd_in,
    input wire [31 : 0] rd_val
);
reg  [31 : 0]    reg_val    [32];       //寄存器中的rename或者val
reg  [31 : 0]    reg_state;             //寄存器是否被rename的状态
reg  [ 3: 0]    ROB_pos     [31: 0];    //不知道有啥用

assign rs1_ready = reg_state[rs1];
assign rs2_ready = reg_state[rs2];
assign rs1_val = reg_val[rs1];
assign rs2_val = reg_val[rs2];

integer i;
always @(posedge clk) begin
    if(rst)begin
        reg_state <= ~(`null32);
            for (i = 0; i < 32; i = i + 1)
                reg_val[i] <= `null32;
    end
    else if(!rst);
    if(rd_in_flag)begin
        reg_val[rd_in] = rd_val;
    end
    else if(rd_out_flag)begin
        reg_val[rd_out] = rd_val;
    end
end




endmodule