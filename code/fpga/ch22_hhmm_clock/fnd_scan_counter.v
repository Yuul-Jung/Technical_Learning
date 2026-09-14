module fnd_scan_counter(
    input clk,                 // 기준 Clock
    input reset,               // 동기 Reset
    output reg [1:0] digit_sel // 현재 선택 Digit
);

reg [15:0] scan_count;

always @(posedge clk) begin
    if (reset) begin
        scan_count <= 16'd0;
        digit_sel <= 2'd0;
    end
    else begin
        if (scan_count == 16'd49_999) begin
            scan_count <= 16'd0;
            digit_sel <= digit_sel + 1'b1;
        end
        else begin
            scan_count <= scan_count + 1'b1;
        end
    end
end

endmodule
