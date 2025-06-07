module if_id(
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] pc_plus4_in,
    input  logic [31:0] instr_in,
    output logic [31:0] pc_plus4_out,
    output logic [31:0] instr_out
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_plus4_out <= '0;
            instr_out    <= '0;
        end else if (!stall) begin
            pc_plus4_out <= pc_plus4_in;
            instr_out    <= instr_in;
        end
    end
endmodule
