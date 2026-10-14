`timescale 1ns/1ps
module alu_tb;
    reg  [31:0] a, b;
    reg  [3:0]  op;
    wire [31:0] result;
    wire        zero;
    integer errors = 0;

    alu dut (.a(a), .b(b), .op(op), .result(result), .zero(zero));

    task check(input [3:0] o, input [31:0] x, y, expected);
        begin
            op = o; a = x; b = y; #1;
            if (result !== expected) begin
                $display("FAIL op=%0d a=%h b=%h got=%h expected=%h",
                         o, x, y, result, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        check(4'd0, 32'd5,         32'd7,  32'd12);        // ADD
        check(4'd1, 32'd5,         32'd7,  32'hFFFFFFFE);  // SUB wraps
        check(4'd2, 32'hFF00FF00,  32'h0FF00FF0, 32'h0F000F00); // AND
        check(4'd5, 32'd1,         32'd4,  32'd16);        // SLL
        check(4'd7, 32'h80000000,  32'd4,  32'hF8000000);  // SRA keeps sign
        check(4'd6, 32'h80000000,  32'd4,  32'h08000000);  // SRL does not
        check(4'd8, 32'hFFFFFFFF,  32'd1,  32'd1);         // SLT: -1 < 1
        check(4'd9, 32'hFFFFFFFF,  32'd1,  32'd0);         // SLTU: big > 1

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TESTS FAILED", errors);
        $finish;
    end
endmodule