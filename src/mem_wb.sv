module mem_wb(
    input  logic        clk,
    input  logic        reset,
    // Control in
    input  logic        memtoreg_in,
    input  logic        regwrite_in,
    // Data in
    input  logic [31:0] aluout_in,
    input  logic [31:0] readdata_in,
    input  logic [4:0]  destReg_in,
    // outputs
    output logic        memtoreg_out,
    output logic        regwrite_out,
    output logic [31:0] aluout_out,
    output logic [31:0] readdata_out,
    output logic [4:0]  destReg_out
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            memtoreg_out <= 0;
            regwrite_out <= 0;
            aluout_out   <= 0;
            readdata_out <= 0;
            destReg_out  <= 0;
        end else begin
            memtoreg_out <= memtoreg_in;
            regwrite_out <= regwrite_in;
            aluout_out   <= aluout_in;
            readdata_out <= readdata_in;
            destReg_out  <= destReg_in;
        end
    end
endmodule
