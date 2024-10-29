module two_bit_mult (
    input wire [1:0] in1,
    input wire [1:0] in2,
    output reg [1:0] outv,
    input wire clk
);

always @(posedge clk) begin
    outv[0] <= in1[0] * in2[0];
    outv[1] <= in1[1] * in2[1];
end

endmodule
