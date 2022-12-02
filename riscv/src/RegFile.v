`include "defines.v";
module RegFile(
    input wire clk,rdy,rst,
    //find reg's val or reorder
    //RS 查询ready情况，输出val or rename
    input wire  [4 : 0]     rs1,rs2,
    output wire             rs1_ready, rs2_ready,
    output wire [31 : 0]    rs1_val,rs2_val,

    //ROB 分为写入和读出两种情况。ROB in：更新目标reg的rename值；ROB pop：修改目标reg的val，比较rename是否一致
    input wire rd_in_flag,rd_out_flag,
    input wire [4 : 0] rd_in_a,rd_out_a,
    input wire [31 : 0] rd_out_val,
    input wire [3 : 0] rd_in_rob,rd_out_rob
);
reg  [31 : 0]    reg_val    [32];       //寄存器中的val
reg  [31 : 0]    reg_state;             //寄存器是否被rename的状态
reg  [ 3: 0]    ROB_pos     [31: 0];    //寄存器的rename


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
    else if(!rst)begin
        if(rd_in_flag)begin
            if(!reg_state[rd_in_a])begin
                reg_state[rd_in_a] <= 1;
                ROB_pos[rd_in_a] <= rd_in_rob;
            end
            else begin
                ROB_pos[rd_in_a] <= rd_in_rob;
            end
        end
        else if(rd_out_flag)begin
            if(ROB_pos[rd_out_a] != rd_out_rob)begin
                reg_val[rd_out_a] <= rd_out_val;
            end
            else begin
                reg_val[rd_out_a] <= rd_out_val;
                reg_state[rd_out_a] <= 0;
            end
        end
    end
    
    

end


endmodule