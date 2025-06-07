module mips(
    input  logic        clk, reset,
    output logic [31:0] pc,
    input  logic [31:0] instr,
    output logic        memwrite,
    output logic [31:0] dataadr,
    output logic [31:0] writedata,
    input  logic [31:0] readdata
);
    // Control from controller (ID stage)
    logic memtoreg_ID, memwrite_ID, alusrc_ID, regdst_ID, regwrite_ID, branch_ID, jump_ID;
    logic [2:0] alucontrol_ID;
    // Hazard wires
    logic memtoreg_EX;
    logic [4:0] rt_EX;
    logic stall;
    // Zero flag not needed at top level now
    logic zero_dummy;

    // Datapath -> dmem signals
    logic [31:0] aluout_MEM;
    logic memwrite_MEM;

    // Controller (combinational, ID stage)
    controller ctrl(
        .op(instr[31:26]), .funct(instr[5:0]), .zero(zero_dummy),
        .memtoreg(memtoreg_ID), .memwrite(memwrite_ID),
        .pcsrc(), .alusrc(alusrc_ID),
        .regdst(regdst_ID), .regwrite(regwrite_ID),
        .jump(jump_ID),
        .alucontrol(alucontrol_ID)
    );

    // Hazard Unit
    logic [4:0] rs_ID, rt_ID;
    assign rs_ID = instr[25:21];
    assign rt_ID = instr[20:16];

    hazard_unit hu(.memtoreg_EX(memtoreg_EX), .rt_EX(rt_EX),
                   .rs_ID(rs_ID), .rt_ID(rt_ID), .stall(stall));

    // Datapath
    datapath dp(
        .clk(clk), .reset(reset),
        .memtoreg_ID(memtoreg_ID), .memwrite_ID(memwrite_ID),
        .alusrc_ID(alusrc_ID), .regdst_ID(regdst_ID),
        .regwrite_ID(regwrite_ID), .branch_ID(branch_ID),
        .alucontrol_ID(alucontrol_ID),
        .stall(stall),
        .instr_if(instr),
        .readdata(readdata),
        .memtoreg_EX(memtoreg_EX), .rt_EX(rt_EX),
        .writedata(writedata), .aluout_MEM(aluout_MEM),
        .memwrite_MEM(memwrite_MEM),
        .pc(pc)
    );

    assign dataadr  = aluout_MEM;
    assign memwrite = memwrite_MEM;
endmodule
