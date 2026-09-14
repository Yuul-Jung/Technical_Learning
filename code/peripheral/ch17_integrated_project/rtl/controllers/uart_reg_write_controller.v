`timescale 1ns / 1ps
module uart_reg_write_controller #(
    parameter CMD_WRITE = 8'h01
)(
    input wire clk, input wire reset,
    input wire [7:0] in_data, input wire in_valid, output wire in_ready,
    output reg reg_wr_en, output reg [7:0] reg_wr_addr, output reg [7:0] reg_wr_data,
    output reg [1:0] byte_index, output reg [7:0] last_cmd, output reg cmd_error
);
    reg [7:0] cmd_reg;
    reg [7:0] addr_reg;
    assign in_ready = 1'b1;

    always @(posedge clk) begin
        if (reset) begin
            byte_index <= 2'd0; cmd_reg <= 8'd0; addr_reg <= 8'd0; last_cmd <= 8'd0;
            reg_wr_en <= 1'b0; reg_wr_addr <= 8'd0; reg_wr_data <= 8'd0; cmd_error <= 1'b0;
        end else begin
            reg_wr_en <= 1'b0;
            cmd_error <= 1'b0;
            if (in_valid && in_ready) begin
                case (byte_index)
                    2'd0: begin
                        cmd_reg <= in_data;
                        last_cmd <= in_data;
                        byte_index <= 2'd1;
                    end
                    2'd1: begin
                        addr_reg <= in_data;
                        byte_index <= 2'd2;
                    end
                    2'd2: begin
                        if (cmd_reg == CMD_WRITE) begin
                            reg_wr_en <= 1'b1;
                            reg_wr_addr <= addr_reg;
                            reg_wr_data <= in_data;
                        end else begin
                            cmd_error <= 1'b1;
                        end
                        byte_index <= 2'd0;
                    end
                    default: byte_index <= 2'd0;
                endcase
            end
        end
    end
endmodule
