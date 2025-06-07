module hazard_unit(
    input  logic        memtoreg_EX,
    input  logic [4:0]  rt_EX,
    input  logic [4:0]  rs_ID,
    input  logic [4:0]  rt_ID,
    output logic        stall
);
    always_comb begin
        stall = memtoreg_EX && ((rt_EX == rs_ID) || (rt_EX == rt_ID));
    end
endmodule
