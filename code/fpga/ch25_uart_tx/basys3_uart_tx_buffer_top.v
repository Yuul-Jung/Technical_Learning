`timescale 1ns / 1ps

// basys3_uart_tx_buffer_top.v
// btnC를 누를 때마다 ASCII 문자를 1개씩 UART TX로 송신함.
// 송신 문자는 'a'부터 시작하여 'z'까지 증가하고, 이후 다시 'a'로 초기화됨.

module basys3_uart_tx_buffer_top(
    input  wire        clk,
    input  wire        btnC,
    input  wire        btnU,
    output wire        RsTx,
    output wire [15:0] led
);

    wire reset;
    assign reset = btnU;

    wire btn_pulse;
    reg tx_wr_en;
    reg [7:0] tx_wr_data;
    reg [7:0] ascii_reg;
    wire tx_full;
    wire tx_empty;
    wire [4:0] tx_count;
    wire tx_busy;
    wire tx_done;

    button_debounce_pulse u_button_debounce_pulse (
        .clk       (clk),
        .rst       (reset),
        .btn_in    (btnC),
        .btn_pulse (btn_pulse)
    );

    uart_tx_core #(
        .CLKS_PER_BIT(10417)
    ) u_uart_tx_core (
        .clk        (clk),
        .reset      (reset),
        .tx_wr_en   (tx_wr_en),
        .tx_wr_data (tx_wr_data),
        .tx_full    (tx_full),
        .tx_empty   (tx_empty),
        .tx_count   (tx_count),
        .tx_busy    (tx_busy),
        .tx_done    (tx_done),
        .tx_serial  (RsTx)
    );

    always @(posedge clk) begin
        if (reset) begin
            ascii_reg  <= 8'h61;
            tx_wr_en   <= 1'b0;
            tx_wr_data <= 8'd0;
        end
        else begin
            tx_wr_en <= 1'b0;

            if (btn_pulse && !tx_full) begin
                tx_wr_data <= ascii_reg;
                tx_wr_en   <= 1'b1;

                if (ascii_reg == 8'h7A)
                    ascii_reg <= 8'h61;
                else
                    ascii_reg <= ascii_reg + 1'b1;
            end
            else begin
                ascii_reg <= ascii_reg;
            end
        end
    end

    assign led[0] = tx_empty;
    assign led[1] = tx_full;
    assign led[2] = tx_busy;
    assign led[3] = tx_done;
    assign led[8:4] = tx_count;
    assign led[15:9] = ascii_reg[6:0];

endmodule
