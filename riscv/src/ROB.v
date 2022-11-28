`include "defines.v"

module ROB(
  input wire            clk,rst,rdy,
  //Decode
  input wire  [4 : 0]   rd_idx,
  input wire            rd_isready,
  input wire  [31 :0]   rd_val,
  input                 flag,
  output wire           full,
  //CDB
  output reg [31 : 0]  rd_val_update,   //修改的值
  output reg [4 : 0]   rd_idx_update,   //需要被修改的reg
  output reg [`RBID]    front,rear      //ROB reorder的位置 只有在regfile的reorder与rob reorder相同时，regfile才需要被置零
  
);
  reg [`RLEN]     val         [`RBSZ];      //rd写入的值
  reg             is_full;                  //ROB is full
  reg [`RBSZ]     is_ready;                 //是否ready
  reg [`RIDX]     rd_addr     [`RBSZ];      //写入位置
  
  assign full = is_full;
  
  always @(posedge clk) begin//考虑ROB is full
    if(!is_full)begin
        if(flag)begin//加入新的opt
            is_ready[rear]  <= rd_isready;
            rd_addr[rear] <= rd_idx;
            val[rear] <= rd_val;
            rear <= -(~rear);
            if(rear == front) is_full <= `True;
        end    
    end
    if((front != rear || val[front] != 32'b0) && is_ready[front])begin//可以发射指令:非空 & ready
        rd_val_update <= val[rear];
        rd_idx_update <= rd_addr[rear];
        val[front] <= 32'b0;
        front <= -(~front);
        if(is_full)is_full<= `False;
    end
  end
  
  
endmodule