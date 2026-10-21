module decoder (
    input  wire [31:0] instr,
    output wire [4:0]  rs1,
    output wire [4:0]  rs2,
    output wire [4:0]  rd,
    output wire [2:0]  funct3,
    output reg  [31:0] imm,
    output reg  [3:0]  alu_op,
    output reg         reg_write,
    output reg         alu_src,     // 1 = ALU's b input is imm, 0 = rs2
    output reg         mem_read,
    output reg         mem_write,
    output reg         mem_to_reg,  // 1 = write memory data to rd
    output reg         branch,
    output reg         illegal
);
    localparam OP_R      = 7'b0110011,
               OP_I      = 7'b0010011,
               OP_LOAD   = 7'b0000011,
               OP_STORE  = 7'b0100011,
               OP_BRANCH = 7'b1100011;

    // Must match the codes in alu.v
    localparam ALU_ADD  = 4'd0, ALU_SUB  = 4'd1, ALU_AND = 4'd2, ALU_OR  = 4'd3,
               ALU_XOR  = 4'd4, ALU_SLL  = 4'd5, ALU_SRL = 4'd6, ALU_SRA = 4'd7,
               ALU_SLT  = 4'd8, ALU_SLTU = 4'd9;

    wire [6:0] opcode = instr[6:0];
    wire       alt    = instr[30];   // distinguishes add/sub and srl/sra

    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];

    always @(*) begin
        // Defaults first, so no signal is left undefined (avoids latches)
        imm        = 32'd0;
        alu_op     = ALU_ADD;
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        illegal    = 1'b0;

        case (opcode)
            OP_R: begin
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_op = alt ? ALU_SUB : ALU_ADD;
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = alt ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                endcase
            end

            OP_I: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm       = {{20{instr[31]}}, instr[31:20]};
                case (funct3)
                    3'b000: alu_op = ALU_ADD;            // addi: never SUB
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = alt ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                endcase
            end

            OP_LOAD: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                imm        = {{20{instr[31]}}, instr[31:20]};
            end

            OP_STORE: begin
                alu_src   = 1'b1;
                mem_write = 1'b1;
                imm       = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            OP_BRANCH: begin
                branch = 1'b1;
                alu_op = ALU_SUB;   // beq/bne: subtract and check the zero flag
                imm    = {{19{instr[31]}}, instr[31], instr[7],
                          instr[30:25], instr[11:8], 1'b0};
            end

            default: illegal = 1'b1;
        endcase
    end
endmodule