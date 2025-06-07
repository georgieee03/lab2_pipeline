module top(
    input  logic        clk, reset,
    output logic [31:0] writedata,
    output logic [31:0] dataadr,
    output logic        memwrite
);
    logic [31:0] pc, instr, readdata;

    // Instantiate modules
    mips mips_core(.clk(clk), .reset(reset), .pc(pc), .instr(instr),
                   .memwrite(memwrite), .dataadr(dataadr),
                   .writedata(writedata), .readdata(readdata));

    imem imem_inst(.a(pc[7:2]), .rd(instr));
    dmem dmem_inst(.clk(clk), .we(memwrite), .a(dataadr),
                   .wd(writedata), .rd(readdata));
endmodule
