`include "defines.v"
module IF(
    input wire          clk,rst,rdy,
    //I-Cache
    input wire [31:0]   ins_ori,
    output wire[31:0]   pc_cache,
    input wire          ins_ori_flag,
    //Decoder
    output wire[31:0]   ins,
    output wire         ins_flag,
    output reg[31:0]    pc_decode,
    output reg[31:0]    pc_decode_bc,
    output reg[0]       pc_decode_bc_flag,
    //ROB
    input wire[31:0]    jp_pc,
    input wire          jp_wrong
    //todo input wire jp_wrong;
);
reg [31:0] imm;
reg [31:0] pc;
assign ins_flag = ins_ori_flag;
assign ins = ins_ori;
//calculate imm
always @(*)begin
    if(ins_ori_flag)begin 
            case(ins_ori[6:0])
                `AUIPCOP: imm = {ins_ori[31:12], 12'b0};
                `LUIOP  : imm = {ins_ori[31:12], 12'b0};                                 
                `JALROP : imm = {{20{ins_ori[31]}}, ins_ori[31:20]};
                `JALOP  : imm = {{12{ins_ori[31]}}, ins_ori[19:12], ins_ori[20], ins_ori[30:21]} << 1;
                default: imm = {{20{ins_ori[31]}}, ins_ori[7], ins_ori[30:25], ins_ori[11:8]} << 1; //branch
            endcase
    end 
    else if(!ins_ori_flag)begin end
    end
    
always @(*)begin 
    if(ins_ori_flag&&!jp_wrong)begin
        pc_decode = pc;
        pc_decode_bc_flag = 'False;
        case(ins_ori[6:0])
            `AUIPCOP: pc = pc + imm;
            `JALOP  : pc = pc + imm;
            `BRANCHOP:begin 
                    pc = pc + 4;
                    pc_decode_bc = pc + imm; 
                    pc_decode_bc_flag = 'True;
                end
            default: pc = pc + 4;
        endcase
        assign pc_cache = pc;
    end 
    else if(!ins_ori_flag)begin end
    else if(jp_wrong)begin 
        pc = jp_pc;
        assign pc_cache = jp_pc;
    end
end


endmodule