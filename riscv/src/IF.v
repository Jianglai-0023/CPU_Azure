`include "defines.v"
module IF(
    input wire          clk,rst,rdy,
    //I-Cache
    input wire [31:0]   ins_ori,
    output reg[31:0]    pc_cache,
    input wire          ins_ori_flag,
    output wire         pc_flag,
    //Decoder
    output wire[31:0]   ins,
    output wire         ins_flag,
    output reg [31 : 0] ins_imm,
    output reg [31 : 0] pc_decode,
    output reg[31:0]    pc_decode_bc,
    output reg          pc_decode_bc_flag,
    //ROB
    input wire[31:0]    jp_pc,
    input wire          jp_wrong
    //todo input wire jp_wrong;
);
    reg [31:0] imm;
    reg [31:0] pc;
    
    assign ins_flag = ins_ori_flag;
    assign ins = ins_ori;
    assign pc_cache = pc;
    //calculate imm
    always @(*)begin
        pc_decode_bc_flag = `False;
        ins_imm = 32'b0;
        if(ins_ori_flag)begin 
            case(ins_ori[6:0])
                `AUIPCOP: imm = {ins_ori[31:12], 12'b0};
                `LUIOP  : imm = {ins_ori[31:12], 12'b0};                                 
                `JALROP : imm = {{20{ins_ori[31]}}, ins_ori[31:20]};
                `JALOP  : imm = {{12{ins_ori[31]}}, ins_ori[19:12], ins_ori[20], ins_ori[30:21]} << 1;
                `BRANCHOP: begin 
                    pc_decode_bc = pc + imm; 
                    pc_decode_bc_flag = `True;
                    imm = {{20{ins_ori[31]}}, ins_ori[7], ins_ori[30:25], ins_ori[11:8]} << 1;
                end
                default: imm = {{20{ins_ori[31]}}, ins_ori[7], ins_ori[30:25], ins_ori[11:8]} << 1; //branch
            endcase
            ins_imm = imm;
        end 
        else ;
        pc_decode = pc;
    end
    
    always @(posedge clk)begin 
        if(ins_ori_flag&&!jp_wrong)begin    
            case(ins_ori[6:0])
                `AUIPCOP: pc <= pc + imm;
                `JALOP  : pc <= pc + imm;
                `BRANCHOP:begin 
                        pc <= pc + 4;                
                    end
                default: pc <= pc + 4;
            endcase
        end 
        else if(!ins_ori_flag)begin end
        else if(jp_wrong)begin 
            pc <= jp_pc;        
        end
    end
    
    
endmodule