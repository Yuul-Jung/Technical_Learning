module shift_left_right(
    input clk,              // 기준 Clock
    input dir,              // 0: Left, 1: Right
    input din,              // 직렬 입력
    output reg [3:0] q      // Shift 결과
);

always @(posedge clk) begin
    if (dir == 1'b0)
        q <= {q[2:0], din}; // Left Shift
    else
        q <= {din, q[3:1]}; // Right Shift
end

endmodule
