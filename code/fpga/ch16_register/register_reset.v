module register_reset(
    input clk,             // Clock 입력
    input reset,           // Reset 입력
    input [7:0] d,         // 데이터 입력

    output reg [7:0] q     // 데이터 출력
);

always @(posedge clk) begin

    if (reset)
        q <= 8'h00;

    else
        q <= d;

end

endmodule
