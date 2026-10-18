`timescale 1ns/1ps
module regfile_tb;
    reg         clk = 0;
    reg         we;
    reg  [4:0]  rs1_addr, rs2_addr, rd_addr;
    reg  [31:0] rd_data;
    wire [31:0] rs1_data, rs2_data;
    integer errors = 0;

    regfile dut (.clk(clk), .we(we), .rs1_addr(rs1_addr), .rs2_addr(rs2_addr),
                 .rd_addr(rd_addr), .rd_data(rd_data),
                 .rs1_data(rs1_data), .rs2_data(rs2_data));

    always #5 clk = ~clk;

    task write_reg(input [4:0] addr, input [31:0] data);
        begin
            we = 1; rd_addr = addr; rd_data = data;
            @(posedge clk); #1;
            we = 0;
        end
    endtask

    task expect_reads(input [4:0] a1, input [4:0] a2,
                      input [31:0] e1, input [31:0] e2);
        begin
            rs1_addr = a1; rs2_addr = a2; #1;
            if (rs1_data !== e1 || rs2_data !== e2) begin
                $display("FAIL r%0d,r%0d: got %h,%h expected %h,%h",
                         a1, a2, rs1_data, rs2_data, e1, e2);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        we = 0; rd_addr = 0; rd_data = 0; rs1_addr = 0; rs2_addr = 0;
        #12;

        write_reg(5'd1, 32'hDEADBEEF);
        write_reg(5'd2, 32'h12345678);
        expect_reads(5'd1, 5'd2, 32'hDEADBEEF, 32'h12345678);

        write_reg(5'd0, 32'hFFFFFFFF);                  // x0 must stay zero
        expect_reads(5'd0, 5'd1, 32'd0, 32'hDEADBEEF);

        we = 0; rd_addr = 5'd3; rd_data = 32'hCAFEBABE; // we=0: no write
        @(posedge clk); #1;
        expect_reads(5'd3, 5'd3, 32'd0, 32'd0);

        write_reg(5'd31, 32'h0000000F);                 // highest register
        expect_reads(5'd31, 5'd1, 32'h0000000F, 32'hDEADBEEF);

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TESTS FAILED", errors);
        $finish;
    end
endmodule