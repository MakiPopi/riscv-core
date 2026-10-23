module cpu (
    input wire        clk,
    input wire        rst,
    input wire [31:0] mem_latency   // extra cycles every load/store waits
);
    reg  [31:0] pc = 32'd0;
    wire [31:0] instr;

    wire [4:0]  rs1, rs2, rd;
    wire [2:0]  funct3;
    wire [31:0] imm;
    wire [3:0]  alu_op;
    wire        reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, illegal;

    wire [31:0] rs1_data, rs2_data, alu_b, alu_result, mem_rdata, rd_data;
    wire        zero;

    // ---- memory latency: a load/store waits mem_latency extra cycles ----
    reg  [31:0] wait_cnt = 32'd0;
    wire        mem_op   = mem_read || mem_write;
    wire        stall    = mem_op && (wait_cnt < mem_latency);

    // ---- performance counters ----
    reg  [31:0] cycle_count = 32'd0;
    reg  [31:0] instret     = 32'd0;
    reg  [31:0] mem_ops     = 32'd0;

    imem u_imem (.addr(pc), .instr(instr));

    decoder u_decoder (
        .instr(instr), .rs1(rs1), .rs2(rs2), .rd(rd), .funct3(funct3),
        .imm(imm), .alu_op(alu_op), .reg_write(reg_write), .alu_src(alu_src),
        .mem_read(mem_read), .mem_write(mem_write), .mem_to_reg(mem_to_reg),
        .branch(branch), .illegal(illegal)
    );

    regfile u_regfile (
        .clk(clk), .we(reg_write && !rst && !stall),
        .rs1_addr(rs1), .rs2_addr(rs2), .rd_addr(rd), .rd_data(rd_data),
        .rs1_data(rs1_data), .rs2_data(rs2_data)
    );

    assign alu_b = alu_src ? imm : rs2_data;

    alu u_alu (
        .a(rs1_data), .b(alu_b), .op(alu_op),
        .result(alu_result), .zero(zero)
    );

    dmem u_dmem (
        .clk(clk), .we(mem_write && !rst && !stall),
        .addr(alu_result), .wdata(rs2_data), .rdata(mem_rdata)
    );

    assign rd_data = mem_to_reg ? mem_rdata : alu_result;

    // beq (funct3=000) branches if equal, bne (funct3=001) if not equal
    wire take_branch = branch && ((funct3 == 3'b000 &&  zero) ||
                                  (funct3 == 3'b001 && !zero));

    wire [31:0] pc_next = take_branch ? (pc + imm) : (pc + 32'd4);

    always @(posedge clk) begin
        if (rst) begin
            pc          <= 32'd0;
            wait_cnt    <= 32'd0;
            cycle_count <= 32'd0;
            instret     <= 32'd0;
            mem_ops     <= 32'd0;
        end else begin
            cycle_count <= cycle_count + 1;
            if (stall) begin
                wait_cnt <= wait_cnt + 1;       // still waiting: change nothing else
            end else begin
                wait_cnt <= 32'd0;
                pc       <= pc_next;            // the instruction completes
                instret  <= instret + 1;
                if (mem_op) mem_ops <= mem_ops + 1;
            end
        end
    end
endmodule
