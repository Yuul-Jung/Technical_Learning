module bcd_4digit_counter(
    input clk,
    input reset,
    input enable,
    input tick,
    output reg [3:0] digit0,
    output reg [3:0] digit1,
    output reg [3:0] digit2,
    output reg [3:0] digit3
);

always @(posedge clk) begin
    if (reset) begin
        digit0 <= 4'd0;
        digit1 <= 4'd0;
        digit2 <= 4'd0;
        digit3 <= 4'd0;
    end
    else begin
        if (enable && tick) begin
            if (digit0 == 4'd9) begin
                digit0 <= 4'd0;

                if (digit1 == 4'd9) begin
                    digit1 <= 4'd0;

                    if (digit2 == 4'd9) begin
                        digit2 <= 4'd0;

                        if (digit3 == 4'd9)
                            digit3 <= 4'd0;
                        else
                            digit3 <= digit3 + 1'b1;
                    end
                    else begin
                        digit2 <= digit2 + 1'b1;
                    end
                end
                else begin
                    digit1 <= digit1 + 1'b1;
                end
            end
            else begin
                digit0 <= digit0 + 1'b1;
            end
        end
    end
end

endmodule
