`timescale 1ns/1ps
module MIPS_Testbench();
    logic clk, reset;
    logic [31:0] writedata, dataadr;
    logic memwrite;

    parameter int N = 2;
    logic [31:0] expected_data [1:N];
    logic [31:0] expected_addr [1:N];

    top dut(.clk(clk), .reset(reset), .writedata(writedata),
            .dataadr(dataadr), .memwrite(memwrite));

    initial begin
        expected_data[1] = 32'h7;
        expected_addr[1] = 32'h50;
        expected_data[2] = 32'h7;
        expected_addr[2] = 32'h54;

        clk = 0; reset = 1;
        #20; reset = 0;
    end

    always #5 clk = ~clk;

    int i;
    initial begin
        #20;
        for (i=1;i<=N;i++) begin
            @(posedge memwrite);
            @(negedge clk);
            if (dataadr == expected_addr[i] && writedata == expected_data[i])
                $display("Memory write %0d correct", i);
            else
                $error("Mismatch on write %0d", i);
        end
        $display("TEST COMPLETE");
        $finish;
    end
endmodule
