module ex_mem(
    input  logic        clk,
    input  logic        reset,
    // Control in
    input  logic        memtoreg_in,
    input  logic        memwrite_in,
    input  logic        regwrite_in,
    input  logic        branch_in,
    input  logic        zero_in,
    // Data in
    input  logic [31:0] aluout_in,
    input  logic [31:0] rt_data_in,
    input  logic [31:0] pcbranch_in,
    input  logic [4:0]  destReg_in,
    // Control out
    output logic        memtoreg_out,
    output logic        memwrite_out,
    output logic        regwrite_out,
    output logic        branch_out,
    output logic        zero_out,
    // Data out
    output logic [31:0] aluout_out,
    output logic [31:0] rt_data_out,
    output logic [31:0] pcbranch_out,
    output logic [4:0]  destReg_out
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            memtoreg_out <= 0;
            memwrite_out <= 0;
            regwrite_out <= 0;
            branch_out   <= 0;
            zero_out     <= 0;
            aluout_out   <= 0;
            rt_data_out  <= 0;
            pcbranch_out <= 0;
            destReg_out  <= 0;
        end else begin
            memtoreg_out <= memtoreg_in;
            memwrite_out <= memwrite_in;
            regwrite_out <= regwrite_in;
            branch_out   <= branch_in;
            zero_out     <= zero_in;
            aluout_out   <= aluout_in;
            rt_data_out  <= rt_data_in;
            pcbranch_out <= pcbranch_in;
            destReg_out  <= destReg_in;
        end
    end
endmodule
