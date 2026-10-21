`timescale 1ns/1ps
module cpu_tb;
    reg clk = 0;
    reg rst = 1;
    integer cycles;
    integer errors = 0;

    cpu dut (.clk(clk), .rst(rst));

    always #5 clk = ~clk;

    task check(input [255:0] name, input [31:0] got, input [31:0] expected);
        begin
            if (got !== expected) begin
                $display("FAIL %0s: got %0d expected %0d", name, got, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/cpu.vcd");
        $dumpvars(0, cpu_tb);

        repeat (2) @(posedge clk);
        #1 rst = 0;

        // run until the PC reaches the halt instruction at 0x1C
        cycles = 0;
        while (dut.pc !== 32'h0000001C && cycles < 200) begin
            @(posedge clk); #1;
            cycles = cycles + 1;
        end

        if (dut.pc !== 32'h0000001C) begin
            $display("FAIL: program did not reach halt (pc=%h)", dut.pc);
            errors = errors + 1;
        end
        $display("Reached halt after %0d cycles", cycles);

        check("x1", dut.u_regfile.regs[1], 32'd0);
        check("x2", dut.u_regfile.regs[2], 32'd15);
        check("x3", dut.u_regfile.regs[3], 32'd15);
        check("mem[0]", dut.u_dmem.mem[0], 32'd15);

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TESTS FAILED", errors);
        $finish;
    end
endmodule