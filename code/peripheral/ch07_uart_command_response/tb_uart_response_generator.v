`timescale 1ns / 1ps

module tb_uart_response_generator;

reg clk;
reg reset;
reg response_req;
reg [2:0] response_sel;
reg led0_state;
reg out_ready;

wire [7:0] out_data;
wire out_valid;
wire busy;

uart_response_generator dut (
    .clk          (clk),
    .reset        (reset),
    .response_req (response_req),
    .response_sel (response_sel),
    .led0_state   (led0_state),
    .out_data     (out_data),
    .out_valid    (out_valid),
    .out_ready    (out_ready),
    .busy         (busy)
);

always #5 clk = ~clk;

initial begin
    clk = 1'b0;
    reset = 1'b1;
    response_req = 1'b0;
    response_sel = 3'd0;
    led0_state = 1'b0;
    out_ready = 1'b1;

    #30;
    reset = 1'b0;

    // OK LED ON\n
    @(posedge clk);
    response_sel <= 3'd1;
    led0_state <= 1'b1;
    response_req <= 1'b1;

    @(posedge clk);
    response_req <= 1'b0;

    wait (!busy);
    #20;

    // STATUS? → LED=OFF\n
    @(posedge clk);
    response_sel <= 3'd3;
    led0_state <= 1'b0;
    response_req <= 1'b1;

    @(posedge clk);
    response_req <= 1'b0;

    wait (!busy);
    #20;

    // ERR CMD\n
    @(posedge clk);
    response_sel <= 3'd4;
    response_req <= 1'b1;

    @(posedge clk);
    response_req <= 1'b0;

    wait (!busy);
    #20;

    $finish;
end

endmodule
