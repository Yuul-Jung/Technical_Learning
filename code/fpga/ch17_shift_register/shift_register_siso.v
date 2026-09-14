module shift_register_siso(
    input clk,          // 기준 Clock
    input din,          // 직렬 입력
    output serial_out,  // 직렬 출력
    output reg [3:0] q  // 내부 상태 관찰용
);

assign serial_out = q[3];   // MSB 쪽 직렬 출력

always @(posedge clk) begin
    q <= {q[2:0], din};     // Shift Left 후 din 입력
end

endmodule
