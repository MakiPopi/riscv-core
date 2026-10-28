`timescale 1ns/1ps
module cache_tb;
    reg          clk = 0;
    reg          rst = 1;
    reg  [31:0]  addr = 0;
    reg          upd_en = 0;
    reg  [31:0]  wdata = 0;
    reg          fill_en = 0;
    wire         hit;
    wire [31:0]  rdata;
    wire [127:0] line;
    integer      errors = 0;
    integer      w;

    cache u_cache (.clk(clk), .rst(rst), .addr(addr), .hit(hit), .rdata(rdata),
                   .upd_en(upd_en), .wdata(wdata), .fill_en(fill_en), .fill_data(line));

    // The data memory supplies the line to install, as it will in the real CPU.
    dmem u_dmem (.clk(clk), .we(1'b0), .addr(32'd0), .wdata(32'd0), .rdata(),
                 .line_addr(addr), .line_rdata(line));

    always #5 clk = ~clk;

    task expect_hit(input [31:0] a, input want);
        begin
            addr = a; #1;
            if (hit !== want) begin
                $display("FAIL addr=%h: hit=%b, expected %b", a, hit, want);
                errors = errors + 1;
            end
        end
    endtask

    task expect_word(input [31:0] a, input [31:0] want);
        begin
            addr = a; #1;
            if (hit !== 1'b1 || rdata !== want) begin
                $display("FAIL addr=%h: hit=%b rdata=%h, expected a hit with %h",
                         a, hit, rdata, want);
                errors = errors + 1;
            end
        end
    endtask

    task fill(input [31:0] a);
        begin
            addr = a; #1;
            fill_en = 1;
            @(posedge clk); #1;
            fill_en = 0;
        end
    endtask

    task write_cache(input [31:0] a, input [31:0] d);
        begin
            addr = a; wdata = d; upd_en = 1;
            @(posedge clk); #1;
            upd_en = 0;
        end
    endtask

    initial begin
        #2;   // let dmem finish its own initialisation first
        for (w = 0; w < 256; w = w + 1)
            u_dmem.mem[w] = 32'h1000 + w;       // memory word w holds 0x1000 + w

        repeat (2) @(posedge clk);
        #1 rst = 0;

        // 1. an empty cache misses
        expect_hit(32'h100, 0);
        expect_hit(32'h110, 0);
        expect_hit(32'h000, 0);   
        expect_hit(32'h0F0, 0);

        // 2. a fill brings in the whole line (words 64..67 = bytes 0x100..0x10C)
        fill(32'h100);
        expect_word(32'h100, 32'h1000 + 64);
        expect_word(32'h104, 32'h1000 + 65);
        expect_word(32'h108, 32'h1000 + 66);
        expect_word(32'h10C, 32'h1000 + 67);

        // 3. the neighbouring line was not filled
        expect_hit(32'h110, 0);

        // 4. conflict: 0x200 maps to the same line as 0x100 but has a different tag
        expect_hit(32'h200, 0);
        fill(32'h200);
        expect_word(32'h200, 32'h1000 + 128);
        expect_hit(32'h100, 0);                 // 0x100 was evicted

        // 5. a write hit changes exactly one word
        write_cache(32'h204, 32'hAAAA5555);
        expect_word(32'h204, 32'hAAAA5555);
        expect_word(32'h200, 32'h1000 + 128);
        expect_word(32'h208, 32'h1000 + 130);

        // 6. a write miss does not allocate a line
        write_cache(32'h110, 32'hDEADBEEF);
        expect_hit(32'h110, 0);

        // 7. reset empties the cache
        rst = 1; @(posedge clk); #1 rst = 0;
        expect_hit(32'h200, 0);

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TESTS FAILED", errors);
        $finish;
    end
endmodule
