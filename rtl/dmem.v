module dmem (
    input  wire         clk,
    input  wire         we,
    input  wire [31:0]  addr,
    input  wire [31:0]  wdata,
    output wire [31:0]  rdata,
    input  wire [31:0]  line_addr,     // any address inside the wanted line
    output wire [127:0] line_rdata     // the 4 words of that line, word 0 in [31:0]
);
    reg [31:0] mem [0:255];
    reg [8*128-1:0] dfile;
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'd0;
        if ($value$plusargs("data=%s", dfile))   // optional: preload data memory
            $readmemh(dfile, mem);
    end

    always @(posedge clk) begin
        if (we)
            mem[addr[9:2]] <= wdata;
    end

    assign rdata = mem[addr[9:2]];

    // Wide read: the 4 words of the line that contains line_addr.
    wire [7:0] line_base = {line_addr[9:4], 2'b00};   // first word number of the line
    assign line_rdata = {mem[line_base + 3], mem[line_base + 2],
                         mem[line_base + 1], mem[line_base]};
endmodule
