module shift_register_piso(
    input clk,              // 기준 Clock
    input load,             // 병렬 Load
    input [3:0] pdata,      // 병렬 입력
    output serial_out,      // 직렬 출력
    output reg [3:0] q      // 내부 상태
);

assign serial_out = q[0];   // LSB First 출력

always @(posedge clk) begin
    if (load)
        q <= pdata;          // 병렬 데이터 저장
    else
        q <= {1'b0, q[3:1]};// 오른쪽 Shift
end

endmodule
