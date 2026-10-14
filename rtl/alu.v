module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  op,
    output reg  [31:0] result,
    output wire        zero
);
    localparam ADD  = 4'd0, SUB  = 4'd1, AND_ = 4'd2, OR_  = 4'd3,
               XOR_ = 4'd4, SLL  = 4'd5, SRL  = 4'd6, SRA  = 4'd7,
               SLT  = 4'd8, SLTU = 4'd9;

    always @(*) begin
        case (op)
            ADD:     result = a + b;
            SUB:     result = a - b;
            AND_:    result = a & b;
            OR_:     result = a | b;
            XOR_:    result = a ^ b;
            SLL:     result = a << b[4:0];
            SRL:     result = a >> b[4:0];
            SRA:     result = $signed(a) >>> b[4:0];
            SLT:     result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            SLTU:    result = (a < b) ? 32'd1 : 32'd0;
            default: result = 32'd0;
        endcase
    end

    assign zero = (result == 32'd0);
endmodule