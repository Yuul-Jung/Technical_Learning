`timescale 1ns / 1ps

// uart_tx_fifo.v
// UART TX 송신 대기 데이터를 저장하는 FIFO임.
// 앞단 uart_tx_core에서 wr_en과 wr_data를 받아 데이터를 저장함.
// 뒤단 uart_tx_sender가 rd_en을 발생시키면 저장된 데이터를 1Byte씩 내보냄.

module uart_tx_fifo(
    input  wire       clk,
    input  wire       reset,
    input  wire       wr_en,
    input  wire [7:0] wr_data,
    input  wire       rd_en,
    output wire [7:0] rd_data,
    output wire       full,
    output wire       empty,
    output wire [4:0] count
);

    reg [7:0] mem [0:15];
    reg [3:0] wr_ptr;
    reg [3:0] rd_ptr;
    reg [4:0] count_reg;

    assign rd_data = mem[rd_ptr];
    assign count = count_reg;
    assign full = (count_reg == 5'd16);
    assign empty = (count_reg == 5'd0);

    always @(posedge clk) begin
        if (reset) begin
            wr_ptr    <= 4'd0;
            rd_ptr    <= 4'd0;
            count_reg <= 5'd0;
        end
        else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: begin
                    mem[wr_ptr] <= wr_data;
                    wr_ptr      <= wr_ptr + 1'b1;
                    count_reg   <= count_reg + 1'b1;
                end
                2'b01: begin
                    rd_ptr    <= rd_ptr + 1'b1;
                    count_reg <= count_reg - 1'b1;
                end
                2'b11: begin
                    mem[wr_ptr] <= wr_data;
                    wr_ptr      <= wr_ptr + 1'b1;
                    rd_ptr      <= rd_ptr + 1'b1;
                    count_reg   <= count_reg;
                end
                default: begin
                    wr_ptr    <= wr_ptr;
                    rd_ptr    <= rd_ptr;
                    count_reg <= count_reg;
                end
            endcase
        end
    end

endmodule
