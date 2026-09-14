`timescale 1ns / 1ps

module tb_rx_bram_line_buffer;

    // 검증 목적
    // 1. ABC + LF 수신 시 frame_valid와 frame_length를 확인함
    // 2. 64Byte를 초과하면 overflow와 discarding을 확인함
    // 3. overflow 이후 LF를 만나면 다음 Frame 준비 상태로 복귀하는지 확인함

    reg clk;
    reg reset;
    reg [7:0] rx_data;
    reg rx_valid;

    wire rx_ready;
    wire [7:0] last_data;
    wire frame_valid;
    wire [6:0] frame_length;
    wire receiving;
    wire overflow;
    wire discarding;

    integer i;

    rx_bram_line_buffer dut (
        .clk(clk),
        .reset(reset),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_ready(rx_ready),
        .last_data(last_data),
        .frame_valid(frame_valid),
        .frame_length(frame_length),
        .receiving(receiving),
        .overflow(overflow),
        .discarding(discarding)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // FIFO에서 1Byte가 나온 것처럼 rx_data와 rx_valid를 1Clock 동안 제공함
    task push_byte;
        input [7:0] data;
        begin
            @(posedge clk);
            rx_data  = data;
            rx_valid = 1'b1;

            @(posedge clk);
            rx_valid = 1'b0;
            rx_data  = 8'h00;
        end
    endtask

    initial begin
        // 초기값 설정
        reset    = 1'b1;
        rx_data  = 8'h00;
        rx_valid = 1'b0;

        #100;

        // Reset 해제
        reset = 1'b0;

        // Test 1: ABC + LF
        push_byte(8'h41);
        push_byte(8'h42);
        push_byte(8'h43);
        push_byte(8'h0A);

        #100;

        // Reset 후 overflow 테스트 준비
        reset = 1'b1;
        #50;
        reset = 1'b0;

        // Test 2: 70Byte 입력 후 LF
        for (i = 0; i < 70; i = i + 1) begin
            push_byte(8'h41);
        end

        push_byte(8'h0A);

        #200;

        $finish;
    end

endmodule
