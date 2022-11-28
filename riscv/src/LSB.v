`include "defines.v";
module LSB(
    input wire          clk,rst,rdy,
    //Decode
    input wire          op_flag,
    input wire [5 : 0]  opcode,
    input wire [31 : 0] imm,
    input wire [4 : 0]  rd,
    input wire [31 : 0] rs1_val_, rs2_val_,
    input wire          is_val1,is_val2,
    //MemCtrl
    output reg          is_write,
    output reg          flag,
    output reg [31 : 0] addr,
    input wire [7 : 0]  val_in,
    input wire          mem_come,
    output reg [7 : 0]  val_out
);
    reg full;
    reg [`ILEN]     ins                 [`LSSZ];     //存储指令
    reg [`LSSZ]     is_commit                  ;     //是否该条指令已经push
    reg [`RLEN]     imm_val             [`LSSZ];     //LS大小为16
    reg [`RLEN]     rs1_val             [`LSSZ]; 
    reg [`RLEN]     rs2_val             [`LSSZ]; 
    reg [`LSSZ]     rs1_ready,rs2_ready        ;
    reg [`RBID]     ROB_idx             [`LSSZ];     
    reg [`LSID]     front,rear;                       //rear放在最后一个空节点，头节点放数据；

always @(posedge clk) begin//接受信息，将指令加入lsb
    if(!full&&op_flag)begin//加入信息
        ins[rear] <= opcode;
        imm_val[rear] <= imm;
        rs1_val[rear] <= rs1_val_;
        rs2_val[rear] <= rs2_val_;
        rs1_ready[rear] <= is_val1;
        rs2_ready[rear] <= is_val2;
        rear <= -(~rear);
        if(front==rear)begin//rear
            full <= `True;
        end
        else if(front!=rear);

    end
    else if((full||!op_flag)&&(front!=rear || is_commit[front]))begin//push front
        if(rs1_ready[front]&&rs2_ready[front])begin
            flag <= `True;
            case(opcode)
                `LB:begin
                        is_write <= `False;
                        addr <= rs1_val[front] + imm_val[front];
                

                end
                `LH:begin
                    
                        is_write <= `False;
                end
                `LW:begin
                        is_write <= `False;
                    
                end
                `LBU:begin
                    
                        is_write <= `False;
                end
                `LHU:begin
                    
                        is_write <= `False;
                end
                `SB:begin
                    
                        is_write <= `True;
                end
                `SW:begin
                    
                        is_write <= `True;
                end
                `SH:begin
                    
                        is_write <= `True;
                end
                default:flag <= `False;
            endcase
        end
        
    end
end

always @(posedge clk) begin//如果没有新加入or full的就看看是否可以push
    
end
endmodule