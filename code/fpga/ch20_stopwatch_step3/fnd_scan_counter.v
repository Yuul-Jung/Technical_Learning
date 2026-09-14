module fnd_scan_counter(
    input clk,                 // 기준 Clock
    input reset,               // 동기 Reset
    output reg [1:0] digit_sel // 현재 선택 Digit
);

reg [15:0] scan_div;           // FND Scan 속도 생성 Counter

always @(posedge clk) begin
    if (reset) begin
        scan_div <= 16'd0;
        digit_sel <= 2'd0;
    end
    else begin
        scan_div <= scan_div + 1'b1;
        digit_sel <= scan_div[15:14];
    end
end

endmodule
