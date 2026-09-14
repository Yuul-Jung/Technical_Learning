`timescale 1ns / 1ps

module tb_bad_latch;

reg en;
reg d;
wire q;

bad_latch dut(
    .en(en),
    .d(d),
    .q(q)
);

initial begin
    en = 1'b0;
    d = 1'b0;
    #10;

    en = 1'b1;
    d = 1'b0; #10;
    d = 1'b1; #10;
    d = 1'b0; #10;
    d = 1'b1; #10;

    en = 1'b0;
    #10;            // q 유지

    d = 1'b0; #10;
    d = 1'b1; #10;  // en=0이므로 q 유지

    $finish;
end

endmodule
