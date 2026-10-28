module cache (
    input  wire         clk,
    input  wire         rst,
    input  wire [31:0]  addr,        // byte address being accessed
    output wire         hit,         // 1 if the word at addr is in the cache
    output wire [31:0]  rdata,       // the cached word (meaningful only when hit = 1)
    input  wire         upd_en,      // store: update the cached word (only if it is there)
    input  wire [31:0]  wdata,       // data for that update
    input  wire         fill_en,     // install the whole line that contains addr
    input  wire [127:0] fill_data    // the line, word 0 in bits [31:0]
);
    wire [1:0] word = addr[3:2];
    wire [3:0] idx  = addr[7:4];
    wire [1:0] tag  = addr[9:8];

    reg [31:0] data  [0:63];    // 16 lines x 4 words
    reg [1:0]  tags  [0:15];    // one tag per line
    reg [15:0] valid;           // one valid bit per line
    integer i;

    initial begin
        valid = 16'd0;
        for (i = 0; i < 64; i = i + 1) data[i] = 32'd0;
        for (i = 0; i < 16; i = i + 1) tags[i] = 2'd0;
    end

    // Lookup (combinational): no clock needed to read.
    assign hit   = valid[idx]&& (tags[idx] == tag) ;
    assign rdata = data[{idx, word}];

    // Updates happen on the clock edge.
    always @(posedge clk) begin
        if (rst) begin
            valid <= 16'd0;                       // reset empties the cache
        end else if (fill_en) begin
            data[{idx, 2'd0}] <= fill_data[31:0];
            data[{idx, 2'd1}] <= fill_data[63:32];
            data[{idx, 2'd2}] <= fill_data[95:64];
            data[{idx, 2'd3}] <= fill_data[127:96];
            tags[idx]  <= tag;
            valid[idx] <= 1'b1;
        end else if (upd_en && hit) begin
            data[{idx, word}] <= wdata;           // write hit: change one word
        end
    end
endmodule
