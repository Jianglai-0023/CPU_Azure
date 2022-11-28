`include "defines.v";
module MemCtrl(//现在只可以处理I-cache发来的指令
    input wire      clk,rst,rdy,
    
    //RAM
    output reg [31 : 0] mem_a,
    output reg [7  : 0] mem_write,
    output wire         is_write,
    input wire          cannot_read,//io-buffer
    input wire [7 : 0]  mem_result,

    //ICache
    input wire [31 : 0] addr_target,
    input wire          ic_flag, // is wating for instruction
    output reg [31 : 0] ic_val,
    output reg          ic_isok
);
reg [2:0] clk_cal;
always @(posedge clk) begin
    if(ic_flag)begin 
        if(cannot_read)begin end
        else begin 
            ic_isok <= 0;
            clk_cal <= -(~clk_cal);
            mem_a <= addr_target;
            case(clk_cal)
            2'b01:  ic_val[7:0] <= mem_result;
            2'b10:  ic_val[15:8] <= mem_result;
            2'b11: begin 
                ic_val[23:16] <= mem_result; 
                ic_isok <= 1;
            end
            default: ic_isok <= 0; 
            endcase
        end
    end
end
endmodule