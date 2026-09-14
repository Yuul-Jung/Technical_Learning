`timescale 1ns / 1ps

module ultrasonic_distance_meter #(
    parameter CLK_FREQ_HZ     = 100_000_000,
    parameter MEASURE_GAP_US  = 60_000,
    parameter TRIG_PULSE_US   = 10,
    parameter ECHO_TIMEOUT_US = 30_000
)(
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire        echo,

    output reg         trig,
    output reg  [9:0]  distance_cm,
    output reg  [11:0] distance_bcd,
    output reg         distance_valid,
    output reg         busy,
    output reg         timeout_error
);

    localparam integer CYCLES_PER_US =
        CLK_FREQ_HZ / 1_000_000;

    localparam S_IDLE           = 3'd0;
    localparam S_TRIG           = 3'd1;
    localparam S_WAIT_ECHO_HIGH = 3'd2;
    localparam S_MEASURE_ECHO   = 3'd3;

    reg [2:0] state;

    reg [31:0] us_div_cnt;
    reg        tick_1us;

    reg [31:0] gap_us_cnt;
    reg [31:0] trig_us_cnt;
    reg [31:0] wait_us_cnt;
    reg [31:0] echo_us_cnt;

    reg echo_meta;
    reg echo_sync;

    wire [31:0] calc_distance_cm_wide;
    wire [9:0]  calc_distance_cm;

    assign calc_distance_cm_wide =
        echo_us_cnt / 32'd58;

    assign calc_distance_cm =
        (calc_distance_cm_wide > 32'd999) ?
        10'd999 :
        calc_distance_cm_wide[9:0];

    function [11:0] bin_to_bcd3;
        input [9:0] bin;
        integer hundreds;
        integer tens;
        integer ones;
        begin
            hundreds = bin / 100;
            tens     = (bin % 100) / 10;
            ones     = bin % 10;
            bin_to_bcd3 = {
                hundreds[3:0],
                tens[3:0],
                ones[3:0]
            };
        end
    endfunction

    // Echo 입력 2-FF 동기화
    always @(posedge clk) begin
        if (reset) begin
            echo_meta <= 1'b0;
            echo_sync <= 1'b0;
        end
        else begin
            echo_meta <= echo;
            echo_sync <= echo_meta;
        end
    end

    // 1us Tick 생성
    always @(posedge clk) begin
        if (reset) begin
            us_div_cnt <= 32'd0;
            tick_1us   <= 1'b0;
        end
        else begin
            tick_1us <= 1'b0;

            if (!enable) begin
                us_div_cnt <= 32'd0;
            end
            else if (us_div_cnt >= CYCLES_PER_US - 1) begin
                us_div_cnt <= 32'd0;
                tick_1us   <= 1'b1;
            end
            else begin
                us_div_cnt <= us_div_cnt + 32'd1;
            end
        end
    end

    // 초음파 거리 측정 FSM
    always @(posedge clk) begin
        if (reset) begin
            state <= S_IDLE;

            trig <= 1'b0;
            busy <= 1'b0;

            distance_cm    <= 10'd0;
            distance_bcd   <= 12'h000;
            distance_valid <= 1'b0;
            timeout_error  <= 1'b0;

            gap_us_cnt  <= MEASURE_GAP_US;
            trig_us_cnt <= 32'd0;
            wait_us_cnt <= 32'd0;
            echo_us_cnt <= 32'd0;
        end
        else begin
            timeout_error <= 1'b0;

            if (!enable) begin
                state <= S_IDLE;

                trig <= 1'b0;
                busy <= 1'b0;

                distance_cm    <= 10'd0;
                distance_bcd   <= 12'h000;
                distance_valid <= 1'b0;

                gap_us_cnt  <= MEASURE_GAP_US;
                trig_us_cnt <= 32'd0;
                wait_us_cnt <= 32'd0;
                echo_us_cnt <= 32'd0;
            end
            else begin
                case (state)

                    S_IDLE: begin
                        trig <= 1'b0;
                        busy <= 1'b0;

                        if (tick_1us) begin
                            if (gap_us_cnt >= MEASURE_GAP_US) begin
                                gap_us_cnt  <= 32'd0;
                                trig_us_cnt <= 32'd0;
                                state       <= S_TRIG;
                                busy        <= 1'b1;
                            end
                            else begin
                                gap_us_cnt <= gap_us_cnt + 32'd1;
                            end
                        end
                    end

                    S_TRIG: begin
                        busy <= 1'b1;
                        trig <= 1'b1;

                        if (tick_1us) begin
                            if (trig_us_cnt >= TRIG_PULSE_US - 1) begin
                                trig        <= 1'b0;
                                wait_us_cnt <= 32'd0;
                                state       <= S_WAIT_ECHO_HIGH;
                            end
                            else begin
                                trig_us_cnt <= trig_us_cnt + 32'd1;
                            end
                        end
                    end

                    S_WAIT_ECHO_HIGH: begin
                        busy <= 1'b1;
                        trig <= 1'b0;

                        if (echo_sync) begin
                            echo_us_cnt <= 32'd1;
                            state       <= S_MEASURE_ECHO;
                        end
                        else if (tick_1us) begin
                            if (wait_us_cnt >= ECHO_TIMEOUT_US) begin
                                timeout_error   <= 1'b1;
                                distance_valid <= 1'b0;
                                busy           <= 1'b0;
                                state          <= S_IDLE;
                            end
                            else begin
                                wait_us_cnt <= wait_us_cnt + 32'd1;
                            end
                        end
                    end

                    S_MEASURE_ECHO: begin
                        busy <= 1'b1;
                        trig <= 1'b0;

                        if (!echo_sync) begin
                            distance_cm    <= calc_distance_cm;
                            distance_bcd   <= bin_to_bcd3(calc_distance_cm);
                            distance_valid <= 1'b1;

                            busy  <= 1'b0;
                            state <= S_IDLE;
                        end
                        else if (tick_1us) begin
                            if (echo_us_cnt >= ECHO_TIMEOUT_US) begin
                                timeout_error   <= 1'b1;
                                distance_valid <= 1'b0;
                                busy           <= 1'b0;
                                state          <= S_IDLE;
                            end
                            else begin
                                echo_us_cnt <= echo_us_cnt + 32'd1;
                            end
                        end
                    end

                    default: begin
                        state <= S_IDLE;
                        trig  <= 1'b0;
                        busy  <= 1'b0;
                    end
                endcase
            end
        end
    end
endmodule
