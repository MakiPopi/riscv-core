module imem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:255];
    reg [8*128-1:0] prog;     // holds a file name of up to 128 characters
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'd0;
        if (!$value$plusargs("prog=%s", prog))
            prog = "sw/program.hex";    // default if no +prog= is given
        $readmemh(prog, mem);
    end

    assign instr = mem[addr[9:2]];
endmodule