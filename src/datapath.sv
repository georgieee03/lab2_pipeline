module datapath(
    input  logic        clk, reset,
    // Control signals from ID stage
    input  logic        memtoreg_ID,
    input  logic        memwrite_ID,
    input  logic        alusrc_ID,
    input  logic        regdst_ID,
    input  logic        regwrite_ID,
    input  logic        branch_ID,
    input  logic [2:0]  alucontrol_ID,
    // From hazard unit
    input  logic        stall,
    // Instruction fetched for IF stage
    input  logic [31:0] instr_if,
    // Data memory read data
    input  logic [31:0] readdata,
    // Outputs to hazard unit
    output logic        memtoreg_EX,
    output logic [4:0]  rt_EX,
    // Outputs to data memory
    output logic [31:0] writedata,
    output logic [31:0] aluout_MEM,
    output logic        memwrite_MEM,
    // Program counter
    output logic [31:0] pc
);
    //========================================================
    // Fetch logic
    //========================================================
    logic [31:0] pc_if, pc_plus4_if, pc_next_if;
    assign pc = pc_if;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            pc_if <= 32'd0;
        else if (!stall)
            pc_if <= pc_next_if;
    end

    adder pc_inc(.a(pc_if), .b(32'd4), .y(pc_plus4_if));

    // IF/ID
    logic [31:0] ifid_pc4, ifid_instr;
    if_id ifid_reg(.clk(clk), .reset(reset), .stall(stall),
                   .pc_plus4_in(pc_plus4_if), .instr_in(instr_if),
                   .pc_plus4_out(ifid_pc4), .instr_out(ifid_instr));

    //========================================================
    // Decode / RF logic
    //========================================================
    logic [4:0] rs_ID, rt_ID, rd_ID;
    logic [31:0] rs_data_ID, rt_data_ID, signext_ID;

    assign rs_ID = ifid_instr[25:21];
    assign rt_ID = ifid_instr[20:16];
    assign rd_ID = ifid_instr[15:11];

    regfile rf(.clk(clk), .we3(regwrite_WB),
               .ra1(rs_ID), .ra2(rt_ID), .wa3(destReg_WB),
               .wd3(writeback_data),
               .rd1(rs_data_ID), .rd2(rt_data_ID));

    signext se(.a(ifid_instr[15:0]), .y(signext_ID));

    // ID/EX
    logic        memtoreg_EX_reg, memwrite_EX, alusrc_EX, regdst_EX, regwrite_EX, branch_EX;
    logic [2:0]  alucontrol_EX;
    logic [31:0] pc4_EX, rs_data_EX, rt_data_EX, signext_EX;
    logic [4:0]  rs_EX_reg, rt_EX_reg, rd_EX;

    id_ex idex_reg(
        .clk(clk), .reset(reset), .stall(stall),
        .memtoreg_in(memtoreg_ID), .memwrite_in(memwrite_ID), .alusrc_in(alusrc_ID),
        .regdst_in(regdst_ID), .regwrite_in(regwrite_ID), .branch_in(branch_ID),
        .alucontrol_in(alucontrol_ID),
        .pc4_in(ifid_pc4), .rs_data_in(rs_data_ID), .rt_data_in(rt_data_ID), .signext_in(signext_ID),
        .rs_in(rs_ID), .rt_in(rt_ID), .rd_in(rd_ID),
        .memtoreg_out(memtoreg_EX_reg), .memwrite_out(memwrite_EX), .alusrc_out(alusrc_EX),
        .regdst_out(regdst_EX), .regwrite_out(regwrite_EX), .branch_out(branch_EX),
        .alucontrol_out(alucontrol_EX),
        .pc4_out(pc4_EX), .rs_data_out(rs_data_EX), .rt_data_out(rt_data_EX),
        .signext_out(signext_EX), .rs_out(rs_EX_reg), .rt_out(rt_EX_reg), .rd_out(rd_EX)
    );

    assign memtoreg_EX = memtoreg_EX_reg;
    assign rt_EX = rt_EX_reg;

    //========================================================
    // Execute logic
    //========================================================
    logic [31:0] alu_srcb_EX, alu_result_EX, branch_target_EX;
    logic zero_EX;

    mux2 #(.WIDTH(32)) srcb_mux(.d0(rt_data_EX), .d1(signext_EX), .s(alusrc_EX), .y(alu_srcb_EX));

    alu alu_unit(.a(rs_data_EX), .b(alu_srcb_EX), .control(alucontrol_EX),
                 .result(alu_result_EX), .zero(zero_EX));

    sl2 u_sl2(.a(signext_EX), .y(branch_target_EX));
    adder branch_add(.a(pc4_EX), .b(branch_target_EX), .y(branch_target_EX));

    logic [4:0] destReg_EX;
    assign destReg_EX = regdst_EX ? rd_EX : rt_EX_reg;

    // EX/MEM
    logic        memtoreg_MEM, memwrite_MEM_reg, regwrite_MEM, branch_MEM, zero_MEM;
    logic [31:0] rt_data_MEM, pcbranch_MEM;
    logic [4:0]  destReg_MEM;

    ex_mem exmem_reg(
        .clk(clk), .reset(reset),
        .memtoreg_in(memtoreg_EX_reg), .memwrite_in(memwrite_EX),
        .regwrite_in(regwrite_EX), .branch_in(branch_EX), .zero_in(zero_EX),
        .aluout_in(alu_result_EX), .rt_data_in(rt_data_EX),
        .pcbranch_in(branch_target_EX), .destReg_in(destReg_EX),
        .memtoreg_out(memtoreg_MEM), .memwrite_out(memwrite_MEM_reg),
        .regwrite_out(regwrite_MEM), .branch_out(branch_MEM), .zero_out(zero_MEM),
        .aluout_out(aluout_MEM), .rt_data_out(rt_data_MEM),
        .pcbranch_out(pcbranch_MEM), .destReg_out(destReg_MEM)
    );

    //========================================================
    // Memory stage
    //========================================================
    assign writedata   = rt_data_MEM;
    assign memwrite_MEM = memwrite_MEM_reg;

    //========================================================
    // MEM/WB
    logic        memtoreg_WB, regwrite_WB;
    logic [31:0] aluout_WB, readdata_WB;

    mem_wb memwb_reg(
        .clk(clk), .reset(reset),
        .memtoreg_in(memtoreg_MEM), .regwrite_in(regwrite_MEM),
        .aluout_in(aluout_MEM), .readdata_in(readdata),
        .destReg_in(destReg_MEM),
        .memtoreg_out(memtoreg_WB), .regwrite_out(regwrite_WB),
        .aluout_out(aluout_WB), .readdata_out(readdata_WB),
        .destReg_out(destReg_WB)
    );

    //========================================================
    // Writeback logic
    //========================================================
    logic [31:0] writeback_data;
    assign writeback_data = memtoreg_WB ? readdata_WB : aluout_WB;

    //========================================================
    // Branch handling (stall PC one cycle penalty)
    //========================================================
    always_comb begin
        pc_next_if = pc_plus4_if;
        if (branch_MEM && zero_MEM)
            pc_next_if = pcbranch_MEM;
    end
endmodule
