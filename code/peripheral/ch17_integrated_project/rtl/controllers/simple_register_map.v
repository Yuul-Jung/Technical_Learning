`timescale 1ns / 1ps

module simple_register_map(
    input  wire       clk,
    input  wire       reset,

    input  wire       reg_wr_en,
    input  wire [7:0] reg_wr_addr,
    input  wire [7:0] reg_wr_data,

    output reg  [7:0] ctrl_reg,
    output reg  [7:0] pwm_value_reg,
    output reg  [7:0] dist_limit_cm_reg,
    output reg  [7:0] spi0_ctrl_reg,
    output reg  [7:0] i2c0_ctrl_reg,

    output reg        reg_error
);

    localparam ADDR_CTRL          = 8'h00;
    localparam ADDR_PWM_VALUE     = 8'h01;
    localparam ADDR_DIST_LIMIT_CM = 8'h02;
    localparam ADDR_SPI0_CTRL     = 8'h10;
    localparam ADDR_I2C0_CTRL     = 8'h20;

    always @(posedge clk) begin
        if (reset) begin
            ctrl_reg          <= 8'h00;
            pwm_value_reg     <= 8'h00;
            dist_limit_cm_reg <= 8'h00;
            spi0_ctrl_reg     <= 8'h00;
            i2c0_ctrl_reg     <= 8'h00;
            reg_error         <= 1'b0;
        end
        else begin
            reg_error <= 1'b0;

            if (reg_wr_en) begin
                case (reg_wr_addr)
                    ADDR_CTRL:
                        ctrl_reg <= reg_wr_data;

                    ADDR_PWM_VALUE:
                        pwm_value_reg <= reg_wr_data;

                    ADDR_DIST_LIMIT_CM:
                        dist_limit_cm_reg <= reg_wr_data;

                    ADDR_SPI0_CTRL:
                        spi0_ctrl_reg <= reg_wr_data;

                    ADDR_I2C0_CTRL:
                        i2c0_ctrl_reg <= reg_wr_data;

                    default:
                        reg_error <= 1'b1;
                endcase
            end
        end
    end
endmodule
