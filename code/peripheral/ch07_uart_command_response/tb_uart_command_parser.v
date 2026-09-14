`timescale 1ns / 1ps

module tb_uart_command_parser;

reg clk;
reg reset;
reg frame_valid;
reg [7:0] frame_len;
reg [8*16-1:0] frame_data;

wire led0_state;
wire response_req;
wire [2:0] response_sel;

uart_command_parser #(
    .MAX_LEN(16)
) dut (
    .clk          (clk),
    .reset        (reset),
    .frame_valid  (frame_valid),
    .frame_len    (frame_len),
    .frame_data   (frame_data),
    .led0_state   (led0_state),
    .response_req (response_req),
    .response_sel (response_sel)
);

always #5 clk = ~clk;

task pulse_frame;
begin
    @(posedge clk);
    frame_valid <= 1'b1;
    @(posedge clk);
    frame_valid <= 1'b0;
end
endtask

initial begin
    clk = 1'b0;
    reset = 1'b1;
    frame_valid = 1'b0;
    frame_len = 8'd0;
    frame_data = 0;

    #30;
    reset = 1'b0;

    // LED=ON
    frame_data = 0;
    frame_data[7:0]   = "L";
    frame_data[15:8]  = "E";
    frame_data[23:16] = "D";
    frame_data[31:24] = "=";
    frame_data[39:32] = "O";
    frame_data[47:40] = "N";
    frame_len = 8'd6;
    pulse_frame;

    #20;

    // LED=OFF
    frame_data = 0;
    frame_data[7:0]   = "L";
    frame_data[15:8]  = "E";
    frame_data[23:16] = "D";
    frame_data[31:24] = "=";
    frame_data[39:32] = "O";
    frame_data[47:40] = "F";
    frame_data[55:48] = "F";
    frame_len = 8'd7;
    pulse_frame;

    #20;

    // STATUS?
    frame_data = 0;
    frame_data[7:0]   = "S";
    frame_data[15:8]  = "T";
    frame_data[23:16] = "A";
    frame_data[31:24] = "T";
    frame_data[39:32] = "U";
    frame_data[47:40] = "S";
    frame_data[55:48] = "?";
    frame_len = 8'd7;
    pulse_frame;

    #20;

    // Unknown Command
    frame_data = 0;
    frame_data[7:0]   = "B";
    frame_data[15:8]  = "A";
    frame_data[23:16] = "D";
    frame_len = 8'd3;
    pulse_frame;

    #40;
    $finish;
end

endmodule
