`include "defines.v";


module RS(
    //Decode
    input  wire [31 : 0]     imm,
    input  wire [5 : 0 ]     opcode,
    input  wire [4 : 0 ]     rs1,rs2,
    input  wire              opflag,
    //RegFile
    output wire [4 : 0 ]     rs1_addr,rs2_addr,
    input  wire              rs1_ready,rs2_ready,
    output wire              reg_flag,
    input  wire [31 : 0]     rs1_val,rs2_val,
    //CDB(from ROB or LSB)
    input  wire [3 : 0 ]     rob_reorder,   //rd变量在ROB中的编号
    // input  wire [4 : 0 ]     rd_addr,       
    input  wire [31 : 0]     rd_val,        //rd变量的现有值
    input  wire              rd_flag,        //是否有可用的rd变量
    //ALU
    output reg  [5 : 0 ]     op_alu,
    output reg  [31 : 0]     rs1_alu,
    output reg  [31 : 0]     rs2_alu,
    output reg               flag_alu,
    output wire [3 : 0]      rob_alu,
);
    reg  [`ILEN]    ins             [`RSSZ];                            // RS 中保存的指令
    reg  [`RSSZ]    used;                                               // RS 的使用状态
    reg  [`RLEN]    val1            [`RSSZ];                            // RS 存的 rs1 寄存器值
    reg  [`RLEN]    val2            [`RSSZ];                            // RS 存的 rs2 寄存器值
    reg  [`RSSZ]    val1_ready;                                         // RS 中 rs1 是否拿到真值
    reg  [`RSSZ]    val2_ready;                                         // RS 中 rs2 是否拿到真值
    reg  [`RBID]    ROB_idx         [`RSSZ];                            // RS 要把结果发送到的 ROB 编号
    integer i;

assign reg_flag = opflag;
assign rs1_addr = rs1;
assign rs2_addr = rs2;

always @(*)begin
    if(opflag)begin//加入新的op
        for(i = 0; i < `RSSIZE; i = i + 1)begin//考虑RS is full的情况
            if(!used[i])begin
                ins[i]=opcode;
                ROB_idx[i] = rob_reorder;//考虑ROB满的情况  
                val1_ready[i] = rs1_ready;
                val2_ready[i] = rs2_ready;
                val1[i] = rs1_val;
                val2[i] = rs2_val;
                break;
            end
        end
    end
    else if(!opflag);

    if(rd_flag)begin//给rename赋值
        for(i = 0; i < `RSSIZE; i = i + 1)begin
           if(used[i] && (!val1_ready[i]&&val1[i] == {rob_reorder,28'b0} || !val2_ready[i]&&val2[i] == {rob_reorder,28'b0}))begin
                if(!val1_ready[i]&&val1[i] == {rob_reorder,28'b0})begin
                    val1_ready[i] = `True;
                    val1[i] = rd_val;
                end
                if(!val2_ready[i]&&val2[i] == {rob_reorder,28'b0})begin
                    val2_ready[i] = `True;
                    val2[i] = rd_val;
                end
           end 
        end
    end
    else begin //发送给alu
        for(i = 0; i < `RSSIZE; i = i+1)begin
            if(val1_ready[i]&&val2_ready[i]&&used[i])begin
                flag_alu = `True;
                rs1_alu = val1[i];
                rs2_alu = val2[i];
                op_alu = ins[i];
                rob_alu = ROB_idx[i];
                used[i] = `False; 
            end
        end
    end
end

                    
endmodule