module uart_rx_fifo #(
    parameter FIFO_DEPTH = 16,
    parameter ADDR_WIDTH = 4
)(
    input        clk,
    input        reset,
    input        clear,

    input        wr_en,
    input  [7:0] wr_data,

    input        rd_en,
    output [7:0] rd_data,

    output       empty,
    output       full,
    output       valid,
    output       overrun_error
);

    // 8비트 저장 공간 16개
    reg [7:0] mem [0:FIFO_DEPTH-1];

    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;

    // 0~16을 표현해야 하므로 5비트
    reg [ADDR_WIDTH:0] count;

    reg overrun_reg;

    wire write_ok;
    wire read_ok;

    assign empty = (count == 0);
    assign full  = (count == FIFO_DEPTH);
    assign valid = !empty;

    assign write_ok = wr_en && !full;
    assign read_ok  = rd_en && !empty;

    // Fall-through FIFO: rd_ptr 위치 데이터가 항상 출력
    assign rd_data = mem[rd_ptr];

    always @(posedge clk) begin
        if (reset || clear) begin
            wr_ptr      <= {ADDR_WIDTH{1'b0}};
            rd_ptr      <= {ADDR_WIDTH{1'b0}};
            count       <= {(ADDR_WIDTH+1){1'b0}};
            overrun_reg <= 1'b0;
        end
        else begin
            // Full 상태 Write 요청 이력 유지
            if (wr_en && full)
                overrun_reg <= 1'b1;

            if (write_ok) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr <= wr_ptr + 1'b1;
            end

            if (read_ok) begin
                rd_ptr <= rd_ptr + 1'b1;
            end

            if (write_ok && !read_ok)
                count <= count + 1'b1;
            else if (!write_ok && read_ok)
                count <= count - 1'b1;
            else
                count <= count;
        end
    end

    assign overrun_error = overrun_reg;

endmodule
