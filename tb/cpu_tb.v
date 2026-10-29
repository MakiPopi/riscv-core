`timescale 1ns/1ps
module cpu_tb;
    reg         clk = 0;
    reg         rst = 1;
    reg  [31:0] latency;
    reg         cache_en;
    reg         halted;
    real        cpi;
    integer     i, bad;

    cpu dut (.clk(clk), .rst(rst), .mem_latency(latency), .cache_en(cache_en));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/cpu.vcd");
        $dumpvars(0, cpu_tb);

        if (!$value$plusargs("latency=%d", latency)) latency  = 0;
        if (!$value$plusargs("cache=%d",   cache_en)) cache_en = 0;

        repeat (2) @(posedge clk);
        #1 rst = 0;

        halted = 0;
        while (!halted && dut.cycle_count < 100000) begin
            @(negedge clk);
            if (!dut.stall && dut.pc_next === dut.pc)
                halted = 1;
        end

        if (!halted)
            $display("RESULT: TIMEOUT (program never halted)");
        else if (dut.u_dmem.mem[0] === 32'd0)
            $display("RESULT: FAIL (program wrote no result)");
        else if (dut.u_dmem.mem[0] !== 32'd1000)
            $display("RESULT: FAIL (check #%0d)", dut.u_dmem.mem[0]);
        else begin
            bad = 0;
            // every cycle is either a stall or a completed instruction
            if (dut.cycle_count !== dut.instret + dut.stall_cycles) begin
                $display("counter mismatch: cycles=%0d instret=%0d stalls=%0d",
                         dut.cycle_count, dut.instret, dut.stall_cycles);
                bad = bad + 1;
            end
            if ($test$plusargs("verify_copy")) begin
                if (dut.u_dmem.mem[64] === 32'd0) bad = bad + 1;   // source never loaded
                for (i = 0; i < 32; i = i + 1)
                    if (dut.u_dmem.mem[128 + i] !== dut.u_dmem.mem[64 + i])
                        bad = bad + 1;
            end
            if ($test$plusargs("verify_and")) begin
                if (dut.u_dmem.mem[64] === 32'd0 || dut.u_dmem.mem[96] === 32'd0)
                    bad = bad + 1;                                  // inputs never loaded
                for (i = 0; i < 32; i = i + 1)
                    if (dut.u_dmem.mem[128 + i] !==
                        (dut.u_dmem.mem[64 + i] & dut.u_dmem.mem[96 + i]))
                        bad = bad + 1;
            end
            if (bad != 0)
                $display("RESULT: FAIL (verification: %0d problems)", bad);
            else begin
                cpi = (1.0 * dut.cycle_count) / dut.instret;
                $display("RESULT: PASS cycles=%0d instret=%0d mem_ops=%0d stalls=%0d hits=%0d misses=%0d CPI=%0.2f",
                         dut.cycle_count, dut.instret, dut.mem_ops, dut.stall_cycles,
                         dut.cache_hits, dut.cache_misses, cpi);
            end
        end
        $finish;
    end
endmodule
