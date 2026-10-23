`timescale 1ns/1ps
module cpu_tb;
    reg        clk = 0;
    reg        rst = 1;
    reg [31:0] prev_pc;
    reg        halted;
    integer    cycles;

    cpu dut (.clk(clk), .rst(rst));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/cpu.vcd");
        $dumpvars(0, cpu_tb);

        repeat (2) @(posedge clk);
        #1 rst = 0;

        cycles = 0;
        halted = 0;
        while (!halted && cycles < 20000) begin
            prev_pc = dut.pc;
            @(posedge clk); #1;
            cycles = cycles + 1;
            if (dut.pc === prev_pc) halted = 1;   // stuck on the same instruction
        end

        if (!halted)
            $display("RESULT: TIMEOUT (program never halted)");
        else if (dut.u_dmem.mem[0] === 32'd1000)
            $display("RESULT: PASS (%0d cycles)", cycles);
        else if (dut.u_dmem.mem[0] === 32'd0)
            $display("RESULT: FAIL (program wrote no result)");
        else
            $display("RESULT: FAIL (check #%0d)", dut.u_dmem.mem[0]);
        $finish;
    end
endmodule