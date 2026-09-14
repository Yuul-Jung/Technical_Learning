`timescale 1ns / 1ps

// uart_tx_sender.v
// TX FIFO와 TX FSM 사이에 위치하는 송신 제어기임.
// FIFO에 데이터가 있고 TX FSM이 쉬고 있으면 FIFO에서 1Byte를 꺼냄.
// 꺼낸 데이터를 tx_data로 넘기고 tx_start를 1클럭 발생시킴.

module uart_tx_sender(
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] fifo_rd_data,
    input  wire       fifo_empty,
    output reg        fifo_rd_en,
    output reg  [7:0] tx_data,
    output reg        tx_start,
    input  wire       tx_busy
);

    localparam S_IDLE      = 2'b00;
    localparam S_WAIT_BUSY = 2'b01;
    localparam S_WAIT_DONE = 2'b10;

    reg [1:0] state_reg;

    always @(posedge clk) begin
        if (reset) begin
            state_reg  <= S_IDLE;
            fifo_rd_en <= 1'b0;
            tx_data    <= 8'd0;
            tx_start   <= 1'b0;
        end
        else begin
            fifo_rd_en <= 1'b0;
            tx_start <= 1'b0;

            case (state_reg)
                S_IDLE: begin
                    if (!fifo_empty && !tx_busy) begin
                        tx_data    <= fifo_rd_data;
                        tx_start   <= 1'b1;
                        fifo_rd_en <= 1'b1;
                        state_reg  <= S_WAIT_BUSY;
                    end
                    else begin
                        tx_data   <= tx_data;
                        state_reg <= S_IDLE;
                    end
                end

                S_WAIT_BUSY: begin
                    if (tx_busy)
                        state_reg <= S_WAIT_DONE;
                    else
                        state_reg <= S_WAIT_BUSY;
                end

                S_WAIT_DONE: begin
                    if (!tx_busy)
                        state_reg <= S_IDLE;
                    else
                        state_reg <= S_WAIT_DONE;
                end

                default: begin
                    state_reg <= S_IDLE;
                end
            endcase
        end
    end

endmodule
