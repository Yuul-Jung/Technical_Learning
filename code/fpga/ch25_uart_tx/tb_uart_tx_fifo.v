`timescale 1ns / 1ps
module tb_uart_tx_fifo;
    localparam CLK_PERIOD = 10;
    reg clk, reset, wr_en, rd_en;
    reg [7:0] wr_data;
    wire [7:0] rd_data;
    wire full, empty;
    wire [4:0] count;

    uart_tx_fifo dut(
        .clk(clk), .reset(reset), .wr_en(wr_en), .wr_data(wr_data),
        .rd_en(rd_en), .rd_data(rd_data), .full(full), .empty(empty), .count(count)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    task fifo_write;
        input [7:0] data;
        begin
            if (full) begin $display("TEST FAIL: FIFO full before write."); $finish; end
            @(posedge clk); wr_data <= data; wr_en <= 1'b1;
            @(posedge clk); wr_en <= 1'b0; wr_data <= 8'd0; #1;
        end
    endtask

    task fifo_read_check;
        input [7:0] expected_data;
        begin
            if (empty) begin $display("TEST FAIL: FIFO empty before read."); $finish; end
            if (rd_data != expected_data) begin
                $display("TEST FAIL: rd_data mismatch. expected=0x%02h, got=0x%02h", expected_data, rd_data);
                $finish;
            end
            else $display("READ PASS: 0x%02h", rd_data);
            @(posedge clk); rd_en <= 1'b1;
            @(posedge clk); rd_en <= 1'b0; #1;
        end
    endtask

    initial begin
        reset=1'b1; wr_en=1'b0; wr_data=8'd0; rd_en=1'b0;
        repeat (5) @(posedge clk);
        reset=1'b0;
        repeat (2) @(posedge clk); #1;
        if (empty != 1'b1 || count != 5'd0) begin $display("TEST FAIL: reset state."); $finish; end
        fifo_write(8'h61); fifo_write(8'h62); fifo_write(8'h63);
        if (count != 5'd3) begin $display("TEST FAIL: count after write."); $finish; end
        fifo_read_check(8'h61); fifo_read_check(8'h62); fifo_read_check(8'h63);
        if (empty != 1'b1 || count != 5'd0) begin $display("TEST FAIL: final FIFO state."); $finish; end
        $display("TEST PASS: uart_tx_fifo write/read order is correct.");
        $finish;
    end
endmodule
