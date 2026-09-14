`timescale 1ns / 1ps

module fnd_status_3digit_display #(
    parameter CLK_FREQ_HZ = 100_000_000,
    parameter SCAN_HZ     = 1000
)(
    input  wire        clk,
    input  wire        reset,
    input  wire        status_valid,
    input  wire [3:0]  status_code,
    input  wire [11:0] value_bcd,
    input  wire        value_valid,
    output reg  [6:0]  seg,
    output reg  [3:0]  an,
    output reg         dp
);

    localparam CHAR_L     = 4'hA;
    localparam CHAR_d     = 4'hB;
    localparam CHAR_DASH  = 4'hC;
    // (추가) 거리 상태 표시용 문자
    localparam CHAR_n     = 4'hD;
    localparam CHAR_F     = 4'hE;
    localparam CHAR_BLANK = 4'hF;

    localparam integer SCAN_DIV = CLK_FREQ_HZ / SCAN_HZ;

    reg [31:0] scan_cnt;
    reg [1:0]  scan_sel;

    always @(posedge clk) begin
        if (reset) begin
            scan_cnt <= 32'd0;
            scan_sel <= 2'd0;
        end else begin
            if (scan_cnt >= SCAN_DIV - 1) begin
                scan_cnt <= 32'd0;
                scan_sel <= scan_sel + 2'd1;
            end else begin
                scan_cnt <= scan_cnt + 32'd1;
            end
        end
    end

    wire [3:0] digit_hundreds;
    wire [3:0] digit_tens;
    wire [3:0] digit_ones;

    assign digit_hundreds =
        value_valid ? value_bcd[11:8] : CHAR_DASH;
    assign digit_tens =
        value_valid ? value_bcd[7:4] : CHAR_DASH;
    assign digit_ones =
        value_valid ? value_bcd[3:0] : CHAR_DASH;

    // (추가) BCD 값 기준 거리 구간 판단
    wire distance_less_030;
    wire distance_ge_100;

    assign distance_less_030 =
        value_valid &&
        (value_bcd[11:8] == 4'd0) &&
        (value_bcd[7:4] < 4'd3);

    assign distance_ge_100 =
        value_valid &&
        (value_bcd[11:8] != 4'd0);

    wire [3:0] distance_status_code;

    assign distance_status_code =
        distance_less_030 ? CHAR_n :
        distance_ge_100   ? CHAR_F :
                            CHAR_DASH;

    wire [3:0] status_digit;

    // (변경) L/d는 그대로 우선하고 '-'일 때만 거리 상태 n/-/F를 적용
    assign status_digit =
        status_valid ?
        ((status_code == CHAR_DASH) ?
            distance_status_code :
            status_code) :
        CHAR_DASH;

    reg [3:0] current_char;

    always @(*) begin
        case (scan_sel)
            2'd0: begin
                an = 4'b1110;
                current_char = digit_ones;
            end
            2'd1: begin
                an = 4'b1101;
                current_char = digit_tens;
            end
            2'd2: begin
                an = 4'b1011;
                current_char = digit_hundreds;
            end
            2'd3: begin
                an = 4'b0111;
                current_char = status_digit;
            end
            default: begin
                an = 4'b1111;
                current_char = CHAR_BLANK;
            end
        endcase
    end

    always @(*) begin
        dp = 1'b1;

        case (current_char)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            CHAR_L:    seg = 7'b1000111;
            CHAR_d:    seg = 7'b0100001;
            CHAR_DASH: seg = 7'b0111111;
            // (추가) near
            CHAR_n:    seg = 7'b0101011;
            // (추가) far
            CHAR_F:    seg = 7'b0001110;
            default:   seg = 7'b1111111;
        endcase
    end

endmodule
