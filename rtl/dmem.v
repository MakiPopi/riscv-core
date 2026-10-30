module dmem (
    input  wire         clk,
    input  wire         we,
    input  wire [31:0]  addr,
    input  wire [31:0]  wdata,
    output wire [31:0]  rdata,
    input  wire [31:0]  line_addr,     // any address inside the wanted cache line
    output wire [127:0] line_rdata,    // the 4 words of that line, word 0 in [31:0]
    // memory-side row operations (the data path of the "PIM" unit)
    input  wire         row_en,        // perform a row operation on this clock edge
    input  wire         row_and,       // 0 = copy src row to dst row, 1 = dst row & src row
    input  wire [31:0]  row_dst,       // any address inside the destination row
    input  wire [31:0]  row_src        // any address inside the source row
);
    // A row is 32 words (128 bytes). Address bits 9:7 select the row.
    reg [31:0] mem [0:255];
    reg [8*128-1:0] dfile;
    integer i;
    integer j;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'd0;
        if ($value$plusargs("data=%s", dfile))   // optional: preload data memory
            $readmemh(dfile, mem);
    end

    always @(posedge clk) begin
        if (we)
            mem[addr[9:2]] <= wdata;

        if (row_en) begin
            for (j = 0; j < 32; j = j + 1)
                mem[{row_dst[9:7], j[4:0]}] <= row_and
                    ? (mem[{row_dst[9:7], j[4:0]}] & mem[{row_src[9:7], j[4:0]}])
                    :  mem[{row_src[9:7], j[4:0]}];
        end
    end

    assign rdata = mem[addr[9:2]];

    // Wide read: the 4 words of the line that contains line_addr.
    wire [7:0] line_base = {line_addr[9:4], 2'b00};
    assign line_rdata = {mem[line_base + 3], mem[line_base + 2],
                         mem[line_base + 1], mem[line_base]};
endmodule
