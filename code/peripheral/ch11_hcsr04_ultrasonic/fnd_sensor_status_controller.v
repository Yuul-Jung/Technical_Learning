`timescale 1ns / 1ps

module fnd_sensor_status_controller(
    input  wire        cds_en,
    input  wire        dist_en,
    input  wire        cds_is_light,

    input  wire [11:0] distance_bcd,
    input  wire        distance_valid,

    output wire        status_valid,
    output wire [3:0]  status_code,
    output wire [11:0] value_bcd,
    output wire        value_valid
);

    assign status_valid =
        cds_en || dist_en;

    assign status_code =
        cds_en ?
        (cds_is_light ? 4'hA : 4'hB) :
        4'hC;

    assign value_bcd =
        dist_en ? distance_bcd : 12'h000;

    assign value_valid =
        dist_en && distance_valid;

endmodule
