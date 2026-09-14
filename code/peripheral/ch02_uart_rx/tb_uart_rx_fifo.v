`timescale 1ns / 1ps

module tb_uart_rx_fifo;

reg clk;
reg reset;
reg clear;
reg wr_en;
reg [7:0] wr_data;
reg rd_en;

wire [7:0] rd_data;
wire empty;
wire full;
wire valid;
wire overrun_error;

uart_rx_fifo dut (
    .clk(clk),
    .reset(reset),
    .clear(clear),
    .wr_en(wr_en),
    .wr_data(wr_data),
    .rd_en(rd_en),
    .rd_data(rd_data),
    .empty(empty),
    .full(full),
    .valid(valid),
    .overrun_error(overrun_error)
);

always #5 clk = ~clk;

task write_byte;
    input [7:0] data;
begin
    wr_data = data;
    wr_en = 1'b1;
    #10;
    wr_en = 1'b0;
    #10;
end
endtask

task read_byte;
begin
    rd_en = 1'b1;
    #10;
    rd_en = 1'b0;
    #10;
end
endtask

integer i;

initial begin
    clk = 1'b0;
    reset = 1'b1;
    clear = 1'b0;
    wr_en = 1'b0;
    wr_data = 8'd0;
    rd_en = 1'b0;
    #20;

    reset = 1'b0;

    // 기본 Write / Read
    write_byte(8'h41);
    write_byte(8'h42);
    read_byte;
    read_byte;

    // 16개 저장 후 Full 확인
    for (i = 0; i < 16; i = i + 1)
        write_byte(i[7:0]);

    // Full 상태 추가 Write → Overrun Error
    write_byte(8'hFF);

    $finish;
end

endmodule
