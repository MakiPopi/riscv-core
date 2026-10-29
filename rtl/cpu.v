module cpu (
    input wire        clk,
    input wire        rst,
    input wire [31:0] mem_latency,   // extra cycles a memory access waits
    input wire        cache_en       // 1 = use the data cache, 0 = go straight to memory
);
    reg  [31:0] pc = 32'd0;
    wire [31:0] instr;

    wire [4:0]  rs1, rs2, rd;
    wire [2:0]  funct3;
    wire [31:0] imm;
    wire [3:0]  alu_op;
    wire        reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, illegal;

    wire [31:0] rs1_data, rs2_data, alu_b, alu_result, mem_rdata, load_data, rd_data;
    wire        zero;

    // ---- data cache wires ----
    wire         cache_hit_raw;
    wire [31:0]  cache_rdata;
    wire [127:0] line_data;

    // ---- when does a memory access wait? ----
    wire mem_op    = mem_read || mem_write;
    wire cache_hit = cache_en && cache_hit_raw;
    wire load_hit  = mem_read && cache_hit;       // served by the cache: no waiting
    wire waits     = mem_op && !load_hit;         // everything else pays the latency

    reg  [31:0] wait_cnt = 32'd0;
    wire        stall    = waits && (wait_cnt < mem_latency);

    // The cache is only changed on the cycle the access completes.
    wire cache_fill = cache_en && mem_read  && !cache_hit_raw && !stall && !rst;
    wire cache_upd  = cache_en && mem_write && !stall && !rst;

    // ---- performance counters ----
    reg  [31:0] cycle_count  = 32'd0;
    reg  [31:0] instret      = 32'd0;
    reg  [31:0] mem_ops      = 32'd0;
    reg  [31:0] stall_cycles = 32'd0;
    reg  [31:0] cache_hits   = 32'd0;   // loads served by the cache
    reg  [31:0] cache_misses = 32'd0;   // loads that had to go to memory (cache on)

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
        .addr(alu_result), .wdata(rs2_data), .rdata(mem_rdata),
        .line_addr(alu_result), .line_rdata(line_data)
    );

    cache u_cache (
        .clk(clk), .rst(rst), .addr(alu_result),
        .hit(cache_hit_raw), .rdata(cache_rdata),
        .upd_en(cache_upd), .wdata(rs2_data),
        .fill_en(cache_fill), .fill_data(line_data)
    );

    assign load_data = load_hit ? cache_rdata : mem_rdata;
    assign rd_data   = mem_to_reg ? load_data : alu_result;

    // beq (funct3=000) branches if equal, bne (funct3=001) if not equal
    wire take_branch = branch && ((funct3 == 3'b000 &&  zero) ||
                                  (funct3 == 3'b001 && !zero));

    wire [31:0] pc_next = take_branch ? (pc + imm) : (pc + 32'd4);

    always @(posedge clk) begin
        if (rst) begin
            pc           <= 32'd0;
            wait_cnt     <= 32'd0;
            cycle_count  <= 32'd0;
            instret      <= 32'd0;
            mem_ops      <= 32'd0;
            stall_cycles <= 32'd0;
            cache_hits   <= 32'd0;
            cache_misses <= 32'd0;
        end else begin
            cycle_count <= cycle_count + 1;
            if (stall) begin
                wait_cnt     <= wait_cnt + 1;       // still waiting
                stall_cycles <= stall_cycles + 1;
            end else begin
                wait_cnt <= 32'd0;
                pc       <= pc_next;                // the instruction completes
                instret  <= instret + 1;
                if (mem_op) mem_ops <= mem_ops + 1;
                if (mem_read && cache_en) begin
                    if (cache_hit) cache_hits   <= cache_hits + 1;
                    else           cache_misses <= cache_misses + 1;
                end
            end
        end
    end
endmodule
