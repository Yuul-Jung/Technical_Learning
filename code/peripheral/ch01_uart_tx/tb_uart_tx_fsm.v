`timescale 1ns / 1ps
module tb_uart_tx_fsm;
    localparam CLK_PERIOD = 10;
    localparam CLKS_PER_BIT_TB = 16;
    localparam BIT_TIME = CLKS_PER_BIT_TB * CLK_PERIOD;
    localparam TIMEOUT_TIME = BIT_TIME * 60;

    reg clk, reset, tx_start;
    reg [7:0] tx_data;
    wire tx_serial, tx_busy, tx_done;
    integer bit_index;
    reg sampled_bit;

    uart_tx_fsm #(.CLKS_PER_BIT(CLKS_PER_BIT_TB)) dut(
        .clk(clk), .reset(reset), .tx_start(tx_start), .tx_data(tx_data),
        .tx_serial(tx_serial), .tx_busy(tx_busy), .tx_done(tx_done)
    );

    initial begin clk=1'b0; forever #(CLK_PERIOD/2) clk=~clk; end
    initial begin #(TIMEOUT_TIME); $display("TEST FAIL: timeout occurred."); $finish; end

    initial begin
        reset=1'b1; tx_start=1'b0; tx_data=8'h61;
        repeat (5) @(posedge clk); reset=1'b0; repeat (2) @(posedge clk);
        @(posedge clk); tx_start <= 1'b1;
        @(posedge clk); tx_start <= 1'b0;

        #(BIT_TIME/2);
        if (tx_serial != 1'b0) begin $display("TEST FAIL: Start Bit mismatch."); $finish; end

        for (bit_index=0; bit_index<8; bit_index=bit_index+1) begin
            #(BIT_TIME); sampled_bit = tx_serial;
            if (sampled_bit != tx_data[bit_index]) begin
                $display("TEST FAIL: Data Bit %0d mismatch.", bit_index); $finish;
            end
        end

        #(BIT_TIME);
        if (tx_serial != 1'b1) begin $display("TEST FAIL: Stop Bit mismatch."); $finish; end
        wait (tx_done == 1'b1);
        @(posedge clk); #1;
        if (tx_busy != 1'b0) begin $display("TEST FAIL: tx_busy did not return to 0."); $finish; end
        $display("TEST PASS: uart_tx_fsm transmitted 8'h61 correctly.");
        $finish;
    end
endmodule
