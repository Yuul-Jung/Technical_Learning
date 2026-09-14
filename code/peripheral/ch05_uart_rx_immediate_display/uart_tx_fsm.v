`timescale 1ns / 1ps

// uart_tx_fsm.v
// 실제 UART TX 8N1 직렬 송신 FSM임.
// tx_start가 1클럭 들어오면 tx_data 1Byte를 Start, Data, Stop 순서로 송신함.

module uart_tx_fsm #(
    parameter CLKS_PER_BIT = 10417
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx_serial,
    output reg        tx_busy,
    output reg        tx_done
);

    localparam S_IDLE  = 2'b00;
    localparam S_START = 2'b01;
    localparam S_DATA  = 2'b10;
    localparam S_STOP  = 2'b11;

    reg [1:0] state_reg;
    reg [31:0] bit_timer;
    reg [2:0] bit_index;
    reg [7:0] data_reg;

    always @(posedge clk) begin
        tx_done <= 1'b0;

        if (reset) begin
            state_reg <= S_IDLE;
            bit_timer <= 32'd0;
            bit_index <= 3'd0;
            data_reg  <= 8'd0;
            tx_serial <= 1'b1;
            tx_busy   <= 1'b0;
            tx_done   <= 1'b0;
        end
        else begin
            case (state_reg)
                S_IDLE: begin
                    tx_serial <= 1'b1;
                    tx_busy   <= 1'b0;
                    bit_timer <= 32'd0;
                    bit_index <= 3'd0;

                    if (tx_start) begin
                        data_reg  <= tx_data;
                        tx_serial <= 1'b0;
                        tx_busy   <= 1'b1;
                        state_reg <= S_START;
                    end
                    else begin
                        state_reg <= S_IDLE;
                    end
                end

                S_START: begin
                    tx_serial <= 1'b0;
                    tx_busy   <= 1'b1;

                    if (bit_timer == CLKS_PER_BIT - 1) begin
                        bit_timer <= 32'd0;
                        tx_serial <= data_reg[0];
                        bit_index <= 3'd0;
                        state_reg <= S_DATA;
                    end
                    else begin
                        bit_timer <= bit_timer + 1'b1;
                    end
                end

                S_DATA: begin
                    tx_busy <= 1'b1;

                    if (bit_timer == CLKS_PER_BIT - 1) begin
                        bit_timer <= 32'd0;

                        if (bit_index == 3'd7) begin
                            bit_index <= 3'd0;
                            tx_serial <= 1'b1;
                            state_reg <= S_STOP;
                        end
                        else begin
                            bit_index <= bit_index + 1'b1;
                            tx_serial <= data_reg[bit_index + 1'b1];
                            state_reg <= S_DATA;
                        end
                    end
                    else begin
                        bit_timer <= bit_timer + 1'b1;
                    end
                end

                S_STOP: begin
                    tx_serial <= 1'b1;
                    tx_busy   <= 1'b1;

                    if (bit_timer == CLKS_PER_BIT - 1) begin
                        bit_timer <= 32'd0;
                        tx_busy   <= 1'b0;
                        tx_done   <= 1'b1;
                        state_reg <= S_IDLE;
                    end
                    else begin
                        bit_timer <= bit_timer + 1'b1;
                    end
                end

                default: begin
                    state_reg <= S_IDLE;
                    bit_timer <= 32'd0;
                    bit_index <= 3'd0;
                    tx_serial <= 1'b1;
                    tx_busy   <= 1'b0;
                    tx_done   <= 1'b0;
                end
            endcase
        end
    end

endmodule
