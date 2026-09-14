module uart_rx_fsm(
    input        clk,          // 시스템 Clock
    input        reset,        // 동기 Reset
    input        tick,         // 16x Sample Tick
    input        rx_sync,      // 동기화된 UART RX 입력
    output [7:0] rx_data,      // 정상 수신된 8비트 데이터
    output       rx_done,      // 1 Byte 수신 완료 Pulse
    output       frame_error   // Stop Bit 오류 Pulse
);

    parameter S_IDLE  = 3'd0;
    parameter S_START = 3'd1;
    parameter S_DATA  = 3'd2;
    parameter S_STOP  = 3'd3;

    reg [2:0] state;
    reg [3:0] sample_count;
    reg [2:0] bit_count;
    reg [7:0] shift_reg;
    reg [7:0] data_reg;
    reg done_reg;
    reg frame_error_reg;

    always @(posedge clk) begin
        if (reset) begin
            state           <= S_IDLE;
            sample_count    <= 4'd0;
            bit_count       <= 3'd0;
            shift_reg       <= 8'd0;
            data_reg        <= 8'd0;
            done_reg        <= 1'b0;
            frame_error_reg <= 1'b0;
        end
        else begin
            // Event 신호는 1 Clock Pulse
            done_reg        <= 1'b0;
            frame_error_reg <= 1'b0;

            case (state)

                S_IDLE: begin
                    sample_count <= 4'd0;
                    bit_count    <= 3'd0;

                    // UART Idle=1, 0 검출 시 Start Bit 후보
                    if (rx_sync == 1'b0)
                        state <= S_START;
                end

                S_START: begin
                    if (tick) begin
                        // 16x Oversampling의 반 비트 지점
                        if (sample_count == 4'd7) begin
                            sample_count <= 4'd0;

                            // 중앙에서도 0이면 정상 Start Bit
                            if (rx_sync == 1'b0) begin
                                bit_count <= 3'd0;
                                state <= S_DATA;
                            end
                            else begin
                                // 순간 Noise / False Detection
                                state <= S_IDLE;
                            end
                        end
                        else begin
                            sample_count <= sample_count + 1'b1;
                        end
                    end
                end

                S_DATA: begin
                    if (tick) begin
                        if (sample_count == 4'd15) begin
                            sample_count <= 4'd0;

                            // UART는 LSB First
                            shift_reg[bit_count] <= rx_sync;

                            if (bit_count == 3'd7) begin
                                bit_count <= 3'd0;
                                state <= S_STOP;
                            end
                            else begin
                                bit_count <= bit_count + 1'b1;
                            end
                        end
                        else begin
                            sample_count <= sample_count + 1'b1;
                        end
                    end
                end

                S_STOP: begin
                    if (tick) begin
                        if (sample_count == 4'd15) begin
                            sample_count <= 4'd0;

                            if (rx_sync == 1'b1) begin
                                data_reg <= shift_reg;
                                done_reg <= 1'b1;
                            end
                            else begin
                                frame_error_reg <= 1'b1;
                            end

                            state <= S_IDLE;
                        end
                        else begin
                            sample_count <= sample_count + 1'b1;
                        end
                    end
                end

                default: begin
                    state <= S_IDLE;
                end

            endcase
        end
    end

    assign rx_data     = data_reg;
    assign rx_done     = done_reg;
    assign frame_error = frame_error_reg;

endmodule
