`timescale 1ns/1ps
module decoder_tb;
    reg  [31:0] instr;
    wire [4:0]  rs1, rs2, rd;
    wire [2:0]  funct3;
    wire [31:0] imm;
    wire [3:0]  alu_op;
    wire        reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, illegal;
    integer errors = 0;

    decoder dut (.instr(instr), .rs1(rs1), .rs2(rs2), .rd(rd), .funct3(funct3),
                 .imm(imm), .alu_op(alu_op), .reg_write(reg_write),
                 .alu_src(alu_src), .mem_read(mem_read), .mem_write(mem_write),
                 .mem_to_reg(mem_to_reg), .branch(branch), .illegal(illegal));

    // ctrl = {reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, illegal}
    task check(input [31:0] i, input [3:0] e_op, input [31:0] e_imm, input [6:0] e_ctrl);
        reg [6:0] ctrl;
        begin
            instr = i; #1;
            ctrl = {reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, illegal};
            if (alu_op !== e_op || imm !== e_imm || ctrl !== e_ctrl) begin
                $display("FAIL instr=%h: got op=%0d imm=%h ctrl=%b, expected op=%0d imm=%h ctrl=%b",
                         i, alu_op, imm, ctrl, e_op, e_imm, e_ctrl);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        check(32'h002081B3, 4'd0, 32'h00000000, 7'b1000000); // add  x3, x1, x2
        check(32'h402081B3, 4'd1, 32'h00000000, 7'b1000000); // sub  x3, x1, x2
        check(32'hFFF00293, 4'd0, 32'hFFFFFFFF, 7'b1100000); // addi x5, x0, -1
        check(32'h4030D293, 4'd7, 32'h00000403, 7'b1100000); // srai x5, x1, 3
        check(32'h0080A303, 4'd0, 32'h00000008, 7'b1110100); // lw   x6, 8(x1)
        check(32'h0020A623, 4'd0, 32'h0000000C, 7'b0101000); // sw   x2, 12(x1)
        check(32'h00208463, 4'd1, 32'h00000008, 7'b0000010); // beq  x1, x2, +8
        check(32'hFE209EE3, 4'd1, 32'hFFFFFFFC, 7'b0000010); // bne  x1, x2, -4
        check(32'h00000000, 4'd0, 32'h00000000, 7'b0000001); // all zeros: illegal

        // register and funct3 fields of "add x3, x1, x2"
        instr = 32'h002081B3; #1;
        if (rs1 !== 5'd1 || rs2 !== 5'd2 || rd !== 5'd3 || funct3 !== 3'd0) begin
            $display("FAIL field extraction");
            errors = errors + 1;
        end

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TESTS FAILED", errors);
        $finish;
    end
endmodule