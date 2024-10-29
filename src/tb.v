`default_nettype none
`timescale 1ns/1ps

module tb();
    
    reg clk;
    reg rst_n;
    reg ena;
    reg [7:0] ui_in;
    reg [7:0] uo_out;
    reg [7:0] uio_in;
    reg [7:0] uio_out;
    reg [7:0] uio_oe;

    wire [7:0] chars_remaining;
    wire [3:0] which_state;

    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        uio_in = 8'd0;
    end

    tt_um_phansel_laplace_lut tt_um_laplace_lut_1 (
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .ena(ena),
    .clk(clk),
    .rst_n(rst_n)
    // .chars_remaining(chars_remaining),
    // .which_state(which_state)
    );

endmodule
