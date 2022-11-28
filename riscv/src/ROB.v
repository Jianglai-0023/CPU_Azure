`include "defines.v"

module ROB(
//Decode
input wire  [4 : 0] rd_idx,
input flag,
output wire [4 : 0] rd_reorder,
output wire full,
//CDB
output wire [31 : 0] rd_val_update,
output wire [4 : 0] rd_idx_update

);
reg [`RLEN]     val      [`RBSZ];
reg             is_full;
reg [`RBSZ]     is_ready;
reg [`RIDX]     rd      [`RBSZ];
reg [`RBSZ]     front,rear;

integer i;
always @(*) begin
    if(flag)begin

       if() 
    end
    else if(!flag);
end


endmodule