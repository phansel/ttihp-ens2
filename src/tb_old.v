`default_nettype none
`timescale 1ns/1ps

module tb();

    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        #1;
        ctr <= 4'b0;
    end

    reg clk;
    reg [1:0] valin1;
    reg [1:0] valin2;
    reg [1:0] valout;

    reg [3:0] ctr;


    always @(posedge clk) begin
        ctr <= ctr + 1;
        valin1 <= ctr[1:0];
        valin2 <= ctr[3:2];
    end

    two_bit_mult two_bit_mult (
        .in1(valin1),
        .in2(valin2),
        .outv(valout),
        .clk(clk)
    );

endmodule
