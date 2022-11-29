`include "defines.v";
module MemCtrl(//现在只可以处理I-cache发来的指令
    input wire           clk,rst,rdy,
    //RAM
    output reg [31 : 0]  mem_a,
    output reg [7  : 0]  mem_write,
    output wire          is_write,
    input  wire          cannot_read,//io-buffer
    input  wire [7 : 0]  mem_result,

    //ICache
    input  wire [31 : 0] addr_target,
    input  wire          ic_flag, // is wating for instruction
    output reg [31 : 0]  ic_val,
    output reg [31 : 0]  ic_val_out,
    output reg           ic_isok, 

    //LSB
    input wire [31 : 0]  lsb_addr,
    input  wire          lsb_flag,
    input wire [5 : 0]   opcode,
    output wire          lsb_isok,
    output reg  [31 : 0] lsb_val,
    output reg  [31 : 0] lsb_val_out
);
//todo lsb的store指令，一次写入不一定为4字节
reg [1:0] if_stp;
reg [1:0] lsb_stp;
reg       lsb_onestp;
always @(*) begin
    if(cannot_read)begin end
    else begin
       ic_val_out = {mem_result,ic_val[23:0]}; 
       if(lsb_flag)begin
        case(opcode)
        `LB:lsb_val_out = {{24{mem_result[7]}},mem_result};
        `LH:lsb_val_out = {{16{mem_result[7]}},mem_result,lsb_val[15:0]};
        `LW:lsb_val_out = lsb_val;
        `LBU:lsb_val_out = {24'b0,mem_result};
        `LHU:lsb_val_out = {16'b0,mem_result,lsb_val[15:0]};
        default:;
        endcase
       end
    end
end
always @(posedge clk) begin
    if(ic_flag)begin 
        if(cannot_read)begin end
        else begin 
            mem_a <= addr_target + if_stp;
            if_stp <= -(~if_stp);
            case(if_stp)
            2'b01:begin
                ic_val[7:0] <= mem_result;
                ic_isok <= `False;
            end 
            2'b10:begin
                ic_val[15:8] <= mem_result;
                ic_isok <= `False;
            end
            2'b11: begin 
                ic_val[23:16] <= mem_result; 
                ic_isok <= 1;
            end
            default: ic_isok <= 0; 
            endcase
        end
    end
    else if(lsb_flag)begin
        if(cannot_read)begin end
        else begin
            lsb_stp <= -(~lsb_stp);
        case(opcode)
            `LB:begin
                is_write <= `False;
                mem_a <= lsb_addr;
                case(lsb_stp)
                    2'b01:begin
                        ic_isok <= 1;
                    end
                    default:begin
                        ic_isok <= 0;
                    end
                endcase
       
            end
            `LH:;
            `LW:begin
                is_write <= `False;
                mem_a <= lsb_addr + lsb_stp;
                case(lsb_stp)
                    2'b01:begin
                        lsb_val[7:0] <= mem_result;
                        ic_isok <= 0;
                    end
                    2'b10:begin
                        lsb_val[15:8] <= mem_result;
                        ic_isok <= 0;
                    end
                    2'b11:begin
                        lsb_val[23:15] <= mem_result;
                        ic_isok <= 1;
                    end
                    default: ic_isok <= 0;
                endcase
            end
            `LBU:
            `
            
        endcase
        end
    end
end
endmodule