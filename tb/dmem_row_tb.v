`timescale 1ns/1ps
module dmem_row_tb;
    reg          clk = 0;
    reg          row_en = 0;
    reg          row_and = 0;
    reg  [31:0]  row_dst = 0;
    reg  [31:0]  row_src = 0;
    integer      errors = 0;
    integer      w;

    dmem u_dmem (.clk(clk), .we(1'b0), .addr(32'd0), .wdata(32'd0), .rdata(),
                 .line_addr(32'd0), .line_rdata(),
                 .row_en(row_en), .row_and(row_and), .row_dst(row_dst), .row_src(row_src));

    always #5 clk = ~clk;

    // Issue one row operation for one clock edge.
    task row_op(input is_and, input [31:0] dst, input [31:0] src);
        begin
            row_and = is_and; row_dst = dst; row_src = src; row_en = 1;
            @(posedge clk); #1;
            row_en = 0;
        end
    endtask

    // Every word of 'row' must equal the original contents of row 'srow'.
    // Initially memory word w holds w * 0x01010101, so a row has a distinct pattern.
    task check_copy_of(input integer row, input integer srow);
        integer j;
        begin
            for (j = 0; j < 32; j = j + 1)
                if (u_dmem.mem[32*row + j] !== (32*srow + j) * 32'h01010101) begin
                    $display("FAIL row %0d word %0d: got %h, expected copy of row %0d (%h)",
                             row, j, u_dmem.mem[32*row + j], srow, (32*srow + j) * 32'h01010101);
                    errors = errors + 1;
                end
        end
    endtask

    // Every word of 'row' must equal the AND of the original rows ra and rb.
    task check_and_of(input integer row, input integer ra, input integer rb);
        integer j;
        begin
            for (j = 0; j < 32; j = j + 1)
                if (u_dmem.mem[32*row + j] !== (((32*ra + j) & (32*rb + j)) * 32'h01010101)) begin
                    $display("FAIL row %0d word %0d: got %h, expected AND of rows %0d and %0d (%h)",
                             row, j, u_dmem.mem[32*row + j], ra, rb,
                             ((32*ra + j) & (32*rb + j)) * 32'h01010101);
                    errors = errors + 1;
                end
        end
    endtask

    initial begin
        #2;   // let dmem finish its own initialisation first
        for (w = 0; w < 256; w = w + 1)
            u_dmem.mem[w] = w * 32'h01010101;

        // 1. nothing happens while row_en is 0
        row_and = 0; row_dst = 32'h200; row_src = 32'h100; row_en = 0;
        @(posedge clk); #1;
        check_copy_of(4, 4);

        // 2. copy row 2 (0x100..0x17F) into row 4 (0x200..0x27F)
        row_op(0, 32'h200, 32'h100);
        check_copy_of(4, 2);
        check_copy_of(2, 2);                 // the source is unchanged
        check_copy_of(5, 5);                 // the next row is untouched

        // 3. AND row 1 (0x080..0x0FF) into row 4, which now holds a copy of row 2.
        // (64+j) AND (32+j) = j
        row_op(1, 32'h200, 32'h080);
        check_and_of(4, 2, 1);
        check_copy_of(1, 1);                 // the source is unchanged

        // 4. any address inside a row selects that row
        row_op(0, 32'h2FC, 32'h174);
        check_copy_of(5, 2);

        // 5. copying a row onto itself changes nothing
        row_op(0, 32'h100, 32'h100);
        check_copy_of(2, 2);

        // 6. rows that were never involved are unchanged
        check_copy_of(0, 0);
        check_copy_of(1, 1);
        check_copy_of(6, 6);
        check_copy_of(7, 7);

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TESTS FAILED", errors);
        $finish;
    end
endmodule
