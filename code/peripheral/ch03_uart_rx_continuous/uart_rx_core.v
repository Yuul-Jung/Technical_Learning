module uart_rx_core(
    input        clk,
    input        reset,
    input        rx,

    input        fifo_clear,

    output [7:0] rx_data,
    output       rx_valid,
    input        rx_ready,

    output       rx_empty,
    output       rx_full,
    output       frame_error,
    output       overrun_error
);

    wire rx_sync;
    wire sample_tick;

    wire [7:0] fsm_rx_data;
    wire fsm_rx_done;
    wire fsm_frame_error;

    uart_rx_sync u_uart_rx_sync (
        .clk(clk),
        .reset(reset),
        .rx_async(rx),
        .rx_sync(rx_sync)
    );

    uart_baud_tick_gen u_uart_baud_tick_gen (
        .clk(clk),
        .reset(reset),
        .tick(sample_tick)
    );

    uart_rx_fsm u_uart_rx_fsm (
        .clk(clk),
        .reset(reset),
        .tick(sample_tick),
        .rx_sync(rx_sync),
        .rx_data(fsm_rx_data),
        .rx_done(fsm_rx_done),
        .frame_error(fsm_frame_error)
    );

    uart_rx_fifo u_uart_rx_fifo (
        .clk(clk),
        .reset(reset),
        .clear(fifo_clear),
        .wr_en(fsm_rx_done),
        .wr_data(fsm_rx_data),
        .rd_en(rx_ready),
        .rd_data(rx_data),
        .empty(rx_empty),
        .full(rx_full),
        .valid(rx_valid),
        .overrun_error(overrun_error)
    );

    assign frame_error = fsm_frame_error;

endmodule
