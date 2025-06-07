module id_ex(
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    // Control in
    input  logic        memtoreg_in,
    input  logic        memwrite_in,
    input  logic        alusrc_in,
    input  logic        regdst_in,
    input  logic        regwrite_in,
    input  logic        branch_in,
    input  logic [2:0]  alucontrol_in,
    // Data in
    input  logic [31:0] pc4_in,
    input  logic [31:0] rs_data_in,
    input  logic [31:0] rt_data_in,
    input  logic [31:0] signext_in,
    input  logic [4:0]  rs_in,
    input  logic [4:0]  rt_in,
    input  logic [4:0]  rd_in,
    // Control out
    output logic        memtoreg_out,
    output logic        memwrite_out,
    output logic        alusrc_out,
    output logic        regdst_out,
    output logic        regwrite_out,
    output logic        branch_out,
    output logic [2:0]  alucontrol_out,
    // Data out
    output logic [31:0] pc4_out,
    output logic [31:0] rs_data_out,
    output logic [31:0] rt_data_out,
    output logic [31:0] signext_out,
    output logic [4:0]  rs_out,
    output logic [4:0]  rt_out,
    output logic [4:0]  rd_out
);
    task automatic bubble();
        memtoreg_out  = 0;
        memwrite_out  = 0;
        alusrc_out    = 0;
        regdst_out    = 0;
        regwrite_out  = 0;
        branch_out    = 0;
        alucontrol_out= 3'd0;
        pc4_out       = 32'd0;
        rs_data_out   = 32'd0;
        rt_data_out   = 32'd0;
        signext_out   = 32'd0;
        rs_out        = 5'd0;
        rt_out        = 5'd0;
        rd_out        = 5'd0;
    endtask

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            bubble();
        end else if (stall) begin
            bubble();
        end else begin
            memtoreg_out  <= memtoreg_in;
            memwrite_out  <= memwrite_in;
            alusrc_out    <= alusrc_in;
            regdst_out    <= regdst_in;
            regwrite_out  <= regwrite_in;
            branch_out    <= branch_in;
            alucontrol_out<= alucontrol_in;
            pc4_out       <= pc4_in;
            rs_data_out   <= rs_data_in;
            rt_data_out   <= rt_data_in;
            signext_out   <= signext_in;
            rs_out        <= rs_in;
            rt_out        <= rt_in;
            rd_out        <= rd_in;
        end
    end
endmodule
