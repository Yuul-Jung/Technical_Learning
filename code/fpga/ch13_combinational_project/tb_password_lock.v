module tb_password_lock;

reg [3:0] sw;
wire led;
wire [6:0] seg;
wire [3:0] an;

p_password_lock dut(
    .sw(sw),
    .led(led),
    .seg(seg),
    .an(an)
);

initial begin
    sw = 4'b0000; #10;
    sw = 4'b0101; #10;
    sw = 4'b1010; #10;
    sw = 4'b1111; #10;

    $finish;
end

endmodule
