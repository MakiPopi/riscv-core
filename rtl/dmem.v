module dmem (
    input  wire        clk,
    input  wire        we,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output wire [31:0] rdata
);
    reg [31:0] mem [0:255];
    reg [8*128-1:0] dfile;
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'd0;
        if ($value$plusargs("data=%s", dfile))   // preload data memory
            $readmemh(dfile, mem);
    end

    always @(posedge clk) begin
        if (we)
            mem[addr[9:2]] <= wdata;
    end

    assign rdata = mem[addr[9:2]];
endmodule
