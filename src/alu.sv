module alu(
    input  logic [31:0] a, b,
    input  logic [2:0]  control,
    output logic [31:0] result,
    output logic        zero
);
    always_comb begin
        unique case(control)
            3'b000: result = a & b;          // AND
            3'b001: result = a | b;          // OR
            3'b010: result = a + b;          // ADD
            3'b110: result = a - b;          // SUB
            3'b111: result = ($signed(a) < $signed(b));
            default: result = 32'hx;
        endcase
    end
    assign zero = (result == 32'd0);
endmodule
