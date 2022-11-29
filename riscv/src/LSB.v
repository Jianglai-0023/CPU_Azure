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
    input wire [31 : 0]  val_in,
    input wire          mem_ok,
    output reg [31 : 0]  val_out,
    output reg [5 : 0]  store_op,
    //ROB
    output reg [`RBID] rob_reorder,
    output reg [31 : 0]rob_val,
    output reg         rob_flag
);
    reg full;
    reg [`ILEN]     ins                 [`LSSZ];     //存储指令
    reg [`LSSZ]     is_commit                  ;     //是否该条指令已经push
    reg [`RLEN]     imm_val             [`LSSZ];     //LS大小为16
    reg [`RLEN]     rs1_val             [`LSSZ]; 
    reg [`RLEN]     rs2_val             [`LSSZ]; 
    reg [`LSSZ]     rs1_ready,rs2_ready        ;
    reg [`RBID]     ROB_idx             [`LSSZ];      //load 对应的rob   
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
        if(rs1_ready[front]&&rs2_ready[front])begin//todo branch
            case(opcode)//todo 可以先统一load/store 再根据位数处理
                `LB:begin
                    if(mem_ok)begin
                        flag <= `False;
                        rob_flag <= `True;
                        rob_reorder <= ROB_idx[front];
                        rob_val <={{24{val_in[7]}}, val_in[7:0]};
                        is_commit[front] <= `True;
                        front <= -(~front);

                    end
                    else begin
                        rob_flag <= `False;
                        is_write <= `False;
                        addr <= rs1_val[front] + imm_val[front];
                        flag <= `True; 
                    end

                end
                `LH:begin
                    if(mem_ok)begin
                       flag <= `False;
                        rob_flag <= `True;
                        rob_reorder <= ROB_idx[front];
                        rob_val <= {{16{val_in[15]}},val_in[15:0]};
                        is_commit[front] <= `True;
                        front <= -(~front); 
                    end
                    else begin
                        rob_flag <= `False;
                        is_write <= `False;
                        addr <= rs1_val[front] + imm_val[front];
                        flag <= `True; 
                    end
                end
                `LW:begin
                    if(mem_ok)begin
                        flag <= `False;
                        rob_flag <= `True;
                        rob_reorder <= ROB_idx[front];
                        rob_val <= val_in;
                        is_commit[front] <= `True;
                        front <= -(~front); 
                    end
                    else begin
                        rob_flag <= `False;
                        is_write <= `False;
                        addr <= rs1_val[front] + imm_val[front];
                        flag <= `True; 
                    end 
                     
                end
                `LBU:begin
                    if(mem_ok)begin
                       flag <= `False;
                        rob_flag <= `True;
                        rob_reorder <= ROB_idx[front];
                        rob_val <= {24'b0,val_in[7:0]};
                        is_commit[front] <= `True;
                        front <= -(~front); 
                    end
                    else begin
                        rob_flag <= `False;
                        is_write <= `False;
                        addr <= rs1_val[front] + imm_val[front];
                        flag <= `True; 
                    end  
                end
                `LHU:begin
                    if(mem_ok)begin
                       flag <= `False;
                        rob_flag <= `True;
                        rob_reorder <= ROB_idx[front];
                        rob_val <= {16'b0,val_in[15:0]};
                        is_commit[front] <= `True;
                        front <= -(~front); 
                    end
                    else begin
                        rob_flag <= `False;
                        is_write <= `False;
                        addr <= rs1_val[front] + imm_val[front];
                        flag <= `True; 
                    end   
                end
                `SB:begin
                    if(mem_ok)begin
                        flag <= `False;
                        is_commit[front] <= `True;
                        front <= -(~front); 
                    end
                    else begin
                        rob_flag <= `False;
                        is_write <= `True;
                        addr <= rs1_val[front] + imm_val[front];
                        val_out <= {24'b0,rs2_val[front][7:0]};
                        flag <= `True;
                        store_op <= opcode;
                    end   
                end
                `SW:begin
                    if(mem_ok)begin
                        flag <= `False;
                        is_commit[front] <= `True;
                        front <= -(~front); 
                    end
                    else begin
                        rob_flag <= `False;
                        is_write <= `True;
                        addr <= rs1_val[front] + imm_val[front];
                        val_out <= rs2_val[front];
                        flag <= `True;
                        store_op <= opcode;
                    end   
                end
                `SH:begin
                    if(mem_ok)begin
                        flag <= `False;
                        is_commit[front] <= `True;
                        front <= -(~front); 
                    end
                    else begin
                        rob_flag <= `False;
                        is_write <= `True;
                        addr <= rs1_val[front] + imm_val[front];
                        val_out <= {16'b0,rs2_val[front][15:0]};
                        flag <= `True;
                        store_op <= opcode;
                    end   
                end
                default:flag <= `False;
            endcase
        end
        
    end
end
endmodule