`timescale 1ns/1ps
module cpu_tb;
    reg         clk = 0;
    reg         rst = 1;
    reg  [31:0] latency;
    reg         halted;
    real        cpi;

    cpu dut (.clk(clk), .rst(rst), .mem_latency(latency));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/cpu.vcd");
        $dumpvars(0, cpu_tb);

        if (!$value$plusargs("latency=%d", latency))
            latency = 0;

        repeat (2) @(posedge clk);
        #1 rst = 0;

        halted = 0;
        while (!halted && dut.cycle_count < 100000) begin
            @(negedge clk);   // mid-cycle, when all signals have settled
            if (!dut.stall && dut.pc_next === dut.pc)
                halted = 1;   // this instruction jumps to itself: halt loop
        end

        if (!halted)
            $display("RESULT: TIMEOUT (program never halted)");
        else begin
            cpi = (1.0 * dut.cycle_count) / dut.instret;
            if (dut.u_dmem.mem[0] === 32'd1000)
                $display("RESULT: PASS cycles=%0d instret=%0d mem_ops=%0d CPI=%0.2f",
                         dut.cycle_count, dut.instret, dut.mem_ops, cpi);
            else if (dut.u_dmem.mem[0] === 32'd0)
                $display("RESULT: FAIL (program wrote no result)");
            else
                $display("RESULT: FAIL (check #%0d)", dut.u_dmem.mem[0]);
        end
        $finish;
    end
endmodule
