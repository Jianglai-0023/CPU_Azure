`include "defines.v";


module RS(
    //Decode
    input wire [31 : 0] imm,
    input wire [5 : 0] opcode,
    input wire [4 : 0] rs1,rs2,
    input wire         opflag,
    //RegFile
    input wire [4 : 0] rs1,rs2,
    output wire rs1_flag,rs2_flag,
    output wire [31 : 0] rs1_val,rs2_val
);
    reg  [`ILEN]    ins             [`RSSZ];                            // RS 中保存的指令
    reg  [`RSSZ]    used;                                               // RS 的使用状态
    reg  [`RLEN]    val1            [`RSSZ];                            // RS 存的 rs1 寄存器值
    reg  [`RLEN]    val2            [`RSSZ];                            // RS 存的 rs2 寄存器值
    reg  [`RSSZ]    val1_ready;                                         // RS 中 rs1 是否拿到真值
    reg  [`RSSZ]    val2_ready;                                         // RS 中 rs2 是否拿到真值
    reg  [`RBID]    ROB_idx         [`RSSZ];                            // RS 要把结果发送到的 ROB 编号
integer i;
always @(*)begin
    if(opflag)begin
    for(i = 0; i < `RSSIZE; i = i + 1)
        if(!used[i])begin
            ins[i]=opcode;
            
             
        end
        
    
    
end
end

                    
endmodule