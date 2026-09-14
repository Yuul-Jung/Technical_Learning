module universal_shift_register(
    input clk,               // 기준 Clock
    input reset,             // 동기 Reset
    input [1:0] mode,        // 동작 모드
    input serial_in,         // 직렬 입력
    input [3:0] pdata,       // 병렬 입력
    output serial_out,       // 직렬 출력
    output reg [3:0] q       // 병렬 출력
);

assign serial_out = q[0];    // LSB First 출력

always @(posedge clk) begin
    if (reset)
        q <= 4'b0000;        // 초기화
    else begin
        case (mode)
            2'b00: q <= q;                    // Hold
            2'b01: q <= {serial_in, q[3:1]}; // Serial In Shift
            2'b10: q <= {1'b0, q[3:1]};      // Serial Out Shift
            2'b11: q <= pdata;               // Parallel Load
            default: q <= q;
        endcase
    end
end

endmodule
