`timescale 1ns / 1ps
module tb_uart_tx_sender;
    localparam CLK_PERIOD = 10;
    reg clk, reset;
    reg [7:0] fifo_rd_data;
    reg fifo_empty;
    wire fifo_rd_en;
    wire [7:0] tx_data;
    wire tx_start;
    reg tx_busy;

    uart_tx_sender dut(
        .clk(clk), .reset(reset), .fifo_rd_data(fifo_rd_data), .fifo_empty(fifo_empty),
        .fifo_rd_en(fifo_rd_en), .tx_data(tx_data), .tx_start(tx_start), .tx_busy(tx_busy)
    );

    initial begin clk=1'b0; forever #(CLK_PERIOD/2) clk=~clk; end

    initial begin
        reset=1'b1; fifo_rd_data=8'd0; fifo_empty=1'b1; tx_busy=1'b0;
        repeat (5) @(posedge clk); reset=1'b0; repeat (2) @(posedge clk); #1;

        fifo_empty=1'b1; fifo_rd_data=8'h61; tx_busy=1'b0;
        @(posedge clk); #1;
        if (tx_start || fifo_rd_en) begin $display("TEST FAIL: request while FIFO empty."); $finish; end

        fifo_empty=1'b0; fifo_rd_data=8'h61; tx_busy=1'b0;
        @(posedge clk); #1;
        if (!tx_start || !fifo_rd_en || tx_data != 8'h61) begin $display("TEST FAIL: first send start."); $finish; end

        tx_busy=1'b1; @(posedge clk); #1;
        if (tx_start || fifo_rd_en) begin $display("TEST FAIL: repeated request while busy."); $finish; end

        tx_busy=1'b0; @(posedge clk); #1; @(posedge clk); #1;
        fifo_empty=1'b0; fifo_rd_data=8'h62; tx_busy=1'b0;
        @(posedge clk); #1;
        if (!tx_start || !fifo_rd_en || tx_data != 8'h62) begin $display("TEST FAIL: second send start."); $finish; end

        $display("TEST PASS: uart_tx_sender control operation is correct.");
        $finish;
    end
endmodule
