`timescale 1ns / 1ps

// xadc_analog_reader.v
//
// Vivado XADC Wizard IP를 감싸는 Reader 모듈이다.
//
// 역할:
// 1. Basys3 JXADC AD6 / VAUX6 입력을 읽는다.
// 2. XADC Wizard의 do_out[15:4]를 12-bit Raw 값으로 추출한다.
// 3. 새 값이 준비되면 xadc_valid를 1 Clock 동안 1로 만든다.
//
// 주의:
// xadc_wiz_0은 이 파일에서 직접 작성하는 RTL이 아니다.
// Vivado IP Catalog의 XADC Wizard가 자동 생성해야 한다.

module xadc_analog_reader (
    input  wire        clk,
    input  wire        reset,

    input  wire        vauxp6,
    input  wire        vauxn6,

    input  wire        vp_in,
    input  wire        vn_in,

    output reg  [11:0] xadc_raw,
    output reg         xadc_valid
);

    localparam [6:0] XADC_ADDR_VAUX6 = 7'h16;

    wire [6:0]  daddr_in;
    wire        eoc_out;
    wire        drdy_out;
    wire [15:0] do_out;

    assign daddr_in = XADC_ADDR_VAUX6;

    xadc_wiz_0 u_xadc_wiz_0 (
        .daddr_in    (daddr_in),
        .dclk_in     (clk),
        .den_in      (eoc_out),
        .di_in       (16'h0000),
        .dwe_in      (1'b0),
        .reset_in    (reset),

        .vauxp6      (vauxp6),
        .vauxn6      (vauxn6),
        .vp_in       (vp_in),
        .vn_in       (vn_in),

        .busy_out    (),
        .channel_out (),
        .do_out      (do_out),
        .drdy_out    (drdy_out),
        .eoc_out     (eoc_out),
        .eos_out     (),
        .alarm_out   ()
    );

    always @(posedge clk) begin
        if (reset) begin
            xadc_raw   <= 12'd0;
            xadc_valid <= 1'b0;
        end
        else begin
            xadc_valid <= 1'b0;

            if (drdy_out) begin
                xadc_raw   <= do_out[15:4];
                xadc_valid <= 1'b1;
            end
        end
    end

endmodule
