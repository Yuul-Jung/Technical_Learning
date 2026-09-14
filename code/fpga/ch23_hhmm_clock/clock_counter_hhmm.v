module clock_counter_hhmm(
    input clk,                  // 기준 Clock
    input reset,                // 동기 Reset
    input tick_1min,            // 1분 Tick Enable
    output reg [3:0] min_ones,  // 1분 자리, 0~9
    output reg [3:0] min_tens,  // 10분 자리, 0~5
    output reg [3:0] hour_ones, // 1시간 자리
    output reg [3:0] hour_tens  // 10시간 자리, 0~2
);

wire carry_min_ones;
wire carry_min_tens;
wire last_time;

assign carry_min_ones = (min_ones == 4'd9);
assign carry_min_tens = (min_ones == 4'd9) && (min_tens == 4'd5);
assign last_time = (hour_tens == 4'd2) && (hour_ones == 4'd3) &&
                   (min_tens == 4'd5) && (min_ones == 4'd9);

always @(posedge clk) begin
    if (reset) begin
        min_ones <= 4'd0;
        min_tens <= 4'd0;
        hour_ones <= 4'd0;
        hour_tens <= 4'd0;
    end
    else begin
        if (tick_1min) begin
            if (last_time) begin
                min_ones <= 4'd0;
                min_tens <= 4'd0;
                hour_ones <= 4'd0;
                hour_tens <= 4'd0;
            end
            else begin
                min_ones <= carry_min_ones ? 4'd0 : min_ones + 1'b1;

                if (carry_min_ones)
                    min_tens <= (min_tens == 4'd5) ? 4'd0 :
                                min_tens + 1'b1;

                if (carry_min_tens) begin
                    if (hour_ones == 4'd9) begin
                        hour_ones <= 4'd0;
                        hour_tens <= hour_tens + 1'b1;
                    end
                    else begin
                        hour_ones <= hour_ones + 1'b1;
                    end
                end
            end
        end
    end
end

endmodule
