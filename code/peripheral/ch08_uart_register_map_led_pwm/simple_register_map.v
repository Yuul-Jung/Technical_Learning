`timescale 1ns / 1ps
module simple_register_map(
    input wire clk, input wire reset,
    input wire reg_wr_en, input wire [7:0] reg_wr_addr, input wire [7:0] reg_wr_data,
    output reg [7:0] ctrl_reg, output reg [7:0] pwm_value_reg, output reg reg_error
);
    localparam ADDR_CTRL = 8'h00;
    localparam ADDR_PWM_VALUE = 8'h01;

    always @(posedge clk) begin
        if (reset) begin
            ctrl_reg <= 8'h00;
            pwm_value_reg <= 8'h00;
            reg_error <= 1'b0;
        end else begin
            reg_error <= 1'b0;
            if (reg_wr_en) begin
                case (reg_wr_addr)
                    ADDR_CTRL: ctrl_reg <= reg_wr_data;
                    ADDR_PWM_VALUE: pwm_value_reg <= reg_wr_data;
                    default: reg_error <= 1'b1;
                endcase
            end
        end
    end
endmodule
