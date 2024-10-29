module transformer(
input wire start, // goes high when the user wants to start printing
input wire [7:0] line, // which line do we want?
input wire clk,        // clock
input wire rst,      // reset
input wire [19:0] pointer_addr, // what is the array ref for this txform?
input wire [15:0] mem_dout, // what's the dat
output reg [9:0] mem_addr, // which address in memory has our chars?a
output reg [9:0] chars_remaining,
output wire [7:0] lhs, // input version
output wire [7:0] rhs, // transformed version
output reg [3:0] which_state
);


wire [9:0] line_start;
wire [9:0] line_len;

assign line_start = pointer_addr[9:0];
assign line_len = pointer_addr[19:10];

// output assignment - the ascii chars
assign lhs = mem_dout[15:8];
assign rhs = mem_dout[7:0];


reg started;


always @(posedge clk) begin
    if (rst) begin
        mem_addr <= 10'b1111111111;
        chars_remaining <= 10'd0;
        started <= 1'b0;
        which_state <= 0;
    end else begin
        if ((~start) && (~started)) begin
            // first character
            mem_addr <= line_start;
            chars_remaining <= line_len;
            started <= 1'b1;
            which_state <= 1;
        end else begin
            if ((chars_remaining > 0)) begin
            // second -> last characters
            mem_addr <= mem_addr + 1;
            chars_remaining <= chars_remaining - 1;
            which_state <= 2;
            end else begin
                // last+1 character
                started <= 1'b1;
                which_state <= 3;
            end
        end
    end
end

endmodule

// divide the 50 MHz clock to 1s
module clk_div_50M #(parameter CLK_DIV = 26'd50000000) (input wire rst, input wire clk_fast, input wire fast_or_slow, output wire clk_out);

reg [25:0] counter;
reg clk_slow;

assign clk_out = fast_or_slow ? clk_fast : clk_slow;

always @(posedge clk_fast) begin
    if (rst) begin
        counter <= 26'd0;
        clk_slow <= 1'b0;
    end
    else begin
        if (counter < CLK_DIV) begin
            counter <= counter + 1;
        end
        else begin
            counter <= 26'd0;
            clk_slow <= ~clk_slow;
        end
    end
end

endmodule
