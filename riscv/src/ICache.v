`include "defines.v"
module ICache(
    input wire clk,rst,rdy,
    // input wire jp_wrong,
    //IF
    output reg [31 : 0] ins_ori,
    output wire          ins_flag,// ==> ins_ori_flag
    input wire  [31 : 0] pc,
    input wire           pc_flag,
    //Mem
    output wire [31 : 0] pc_mem,
    output reg          pc_flag_mem,
    input wire  [31 : 0] ins_mem,
    input wire           ins_mem_flag
);

reg [`ICSZ-1: 0]      valid;
reg [`TGID]           tag   [`ICSZ-1:0];
reg [31 : 0]          cache [`ICSZ-1:0];
integer i;

//cache:
//只有读操作的cache
//memctrl传回结果
//IF传来pc,结果出现之前pc会一直放在这里

wire is_hit = valid[pc[`ICID]] && tag[pc[`ICID]] == pc[`TGID];
// assign pc_flag_mem = !is_hit&&pc_flag;
assign pc_mem = pc;
assign ins_flag = !rst&&rdy&&(is_hit?1:ins_mem_flag);
// initial begin
    
// end
always @(*) begin
    if(rst)begin
       pc_flag_mem = `False;
    end
    else if(!rdy)begin
        // ins_flag = 0;
    end
    else begin
        if(!is_hit)begin
        ins_ori = ins_mem;
        pc_flag_mem = pc_flag;
        end
        else begin
            pc_flag_mem = 0;
            ins_ori = cache[pc[`ICID]];
        end
    end
end
always @(posedge clk) begin
    // $display("%s","wangwang");
    // $display("%d",is_hit);
   if(rst)begin
    valid <= `ICSZ'b0;  
   end 
   else if(!rdy)begin
    
   end
    else if(ins_mem_flag)begin
        cache[pc[`ICID]] <= ins_mem;
        valid[pc[`ICID]] <= `True;
        tag[pc[`ICID]]   <= pc[`TGID];
        
    end
    else ;
end


endmodule