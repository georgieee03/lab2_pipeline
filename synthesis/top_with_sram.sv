module top_with_sram (
    input  logic        clk, reset,
    output logic [31:0] writedata,
    output logic [31:0] dataadr,
    output logic        memwrite
);
    logic [31:0] pc, instr, readdata;

    // Core pipeline
    mips mips_core(.clk(clk), .reset(reset), .pc(pc), .instr(instr),
                   .memwrite(memwrite), .dataadr(dataadr),
                   .writedata(writedata), .readdata(readdata));

    // Instruction SRAM (read‑only)
    logic csb0_i, web0_i;
    assign csb0_i = 1'b0;
    assign web0_i = 1'b1;

    SRAM_32x64_1rw imem_ram(
        .clk0(clk),
        .csb0(csb0_i),
        .web0(web0_i),
        .addr0(pc[7:2]),
        .din0(32'b0),
        .dout0(instr)
    );

    // Data SRAM (read/write)
    logic csb0_d, web0_d;
    assign csb0_d = 1'b0;
    assign web0_d = ~memwrite;

    SRAM_32x64_1rw dmem_ram(
        .clk0(clk),
        .csb0(csb0_d),
        .web0(web0_d),
        .addr0(dataadr[7:2]),
        .din0(writedata),
        .dout0(readdata)
    );
endmodule
