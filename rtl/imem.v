module imem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:255];   // 256 words = 1 KB
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'd0;
        $readmemh("sw/program.hex", mem);   // load the program from a file
    end

    assign instr = mem[addr[9:2]];          // word-aligned: drop the low 2 bits
endmodule