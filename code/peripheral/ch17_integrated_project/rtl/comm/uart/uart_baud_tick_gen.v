module uart_baud_tick_gen #(
    parameter CLKS_PER_SAMPLE = 651
)(
    input  clk,     // 시스템 Clock. Basys3에서는 100 MHz 사용
    input  reset,   // 동기 Reset
    output tick     // 16x Oversampling용 1 Clock Pulse
);

    reg [15:0] count_reg;
    reg tick_reg;

    always @(posedge clk) begin
        if (reset) begin
            count_reg <= 16'd0;
            tick_reg  <= 1'b0;
        end
        else begin
            tick_reg <= 1'b0;

            if (count_reg == CLKS_PER_SAMPLE - 1) begin
                count_reg <= 16'd0;
                tick_reg  <= 1'b1;
            end
            else begin
                count_reg <= count_reg + 1'b1;
            end
        end
    end

    assign tick = tick_reg;

endmodule
