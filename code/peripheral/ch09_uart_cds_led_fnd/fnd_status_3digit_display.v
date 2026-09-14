`timescale 1ns / 1ps

// fnd_status_3digit_display.v
//
// Basys3 4자리 FND에
//   [상태문자][백][십][일]
// 형식으로 표시하는 재사용 표시 모듈이다.
//
// 이번 CdS 단계:
//   status_valid=0 -> ----
//   status_valid=1, status_code=L -> L---
//   status_valid=1, status_code=d -> d---
//
// 문자 코드:
//   0~9 : 숫자
//   A   : L
//   B   : d
//   C   : -
//   F   : blank
//
// Basys3 FND:
//   seg[6:0] = {g,f,e,d,c,b,a}
//   an[3:0] Active-Low
//   dp Active-Low

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
    localparam CHAR_BLANK = 4'hF;

    localparam integer SCAN_DIV = CLK_FREQ_HZ / SCAN_HZ;

    reg [31:0] scan_cnt;
    reg [1:0]  scan_sel;

    always @(posedge clk) begin
        if (reset) begin
            scan_cnt <= 32'd0;
            scan_sel <= 2'd0;
        end
        else begin
            if (scan_cnt >= SCAN_DIV - 1) begin
                scan_cnt <= 32'd0;
                scan_sel <= scan_sel + 2'd1;
            end
            else begin
                scan_cnt <= scan_cnt + 1'b1;
            end
        end
    end

    wire [3:0] digit_hundreds;
    wire [3:0] digit_tens;
    wire [3:0] digit_ones;
    wire [3:0] status_digit;

    assign digit_hundreds =
        value_valid ? value_bcd[11:8] : CHAR_DASH;

    assign digit_tens =
        value_valid ? value_bcd[7:4] : CHAR_DASH;

    assign digit_ones =
        value_valid ? value_bcd[3:0] : CHAR_DASH;

    assign status_digit =
        status_valid ? status_code : CHAR_DASH;

    reg [3:0] current_char;

    always @(*) begin
        case (scan_sel)
            2'd0: begin
                an           = 4'b1110;
                current_char = digit_ones;
            end
            2'd1: begin
                an           = 4'b1101;
                current_char = digit_tens;
            end
            2'd2: begin
                an           = 4'b1011;
                current_char = digit_hundreds;
            end
            2'd3: begin
                an           = 4'b0111;
                current_char = status_digit;
            end
            default: begin
                an           = 4'b1111;
                current_char = CHAR_BLANK;
            end
        endcase
    end

    always @(*) begin
        // Decimal Point는 이번 단계에서 사용하지 않는다.
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

            default:   seg = 7'b1111111;
        endcase
    end

endmodule
