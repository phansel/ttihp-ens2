/*
 * Copyright (c) 2023 Paul Hansel
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_phansel_laplace_lut (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
    // output wire [9:0] chars_remaining,
    // output wire [3:0] which_state
);


// input: number between 0->50
// output uio_out: function encoded in LaTeX as ASCII
// output uo_out: laplace transform of function encoded in latex as ASCII
// mystery bit: triggers CQ DE KC1GPW

assign uio_oe = 8'hFF;

// debug
wire [9:0] chars_remaining;
wire [3:0] which_state;

wire start;
wire [7:0] line;
wire [7:0] lhs, rhs;
wire [9:0] mem_addr;
wire [19:0] pointer_addr;
wire [15:0] mem_dout;


wire rst;

wire clk_buffered;
wire fast_or_slow;


clk_div_50M clk_picker(
    .clk_fast(clk),
    .rst(rst),
    .fast_or_slow(fast_or_slow),
    .clk_out(clk_buffered)
);


transformer transformer_1 (
    .start(start),
	.line(line),
	.clk(clk_buffered),
	.rst(rst),
	.lhs(lhs),
	.rhs(rhs),
	.pointer_addr(pointer_addr),
	.mem_addr(mem_addr),
	.mem_dout(mem_dout),
	.chars_remaining(chars_remaining),
	.which_state(which_state)
);


// stores the transforms as packed ascii
memory_chars memory_1 (
    .mem_addr(mem_addr),
    .dout(mem_dout),
    .clk(clk_buffered),
    .rst(rst)
);

// gets the appropriate indices for each line
line_mapper line_mapper_1 (
    .clk(clk_buffered),
    .rst(rst),
    .line(line),
    .pointer_addr(pointer_addr)
);

assign rst = ~rst_n;

assign line = {2'b0, ui_in[5:0]};
assign start = ui_in[6];
assign uio_out = lhs;
assign uo_out = rhs;
assign fast_or_slow = ui_in[7];


endmodule
