module basys3_universal_shift_register(
    input btnC,             // 수동 Clock
    input btnU,             // Parallel Load 버튼
    input [15:0] sw,        // Basys3 Switch
    output [15:0] led       // Basys3 LED
);

reg [3:0] q;

wire [1:0] mode;
wire serial_in;
wire [3:0] pdata;

assign mode      = sw[1:0];
assign pdata     = sw[7:4];
assign serial_in = sw[8];

assign led[3:0]  = q;       // 병렬 출력
assign led[4]    = q[0];    // LSB First 직렬 출력
assign led[15:5] = 11'b0;   // 미사용 LED는 0으로 고정

always @(posedge btnC) begin
    if (btnU)
        q <= pdata;                  // 버튼 Load 우선
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
