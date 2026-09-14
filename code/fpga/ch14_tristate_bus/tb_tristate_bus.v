module tb_tristate_bus;

reg [3:0] a;
reg [3:0] b;

reg en_a;
reg en_b;

wire [3:0] bus;

// DUT
p_tristate_bus dut(

    .a(a),
    .b(b),

    .en_a(en_a),
    .en_b(en_b),

    .bus(bus)

);

initial begin

    // 초기값
    a = 4'b1010;
    b = 4'b0101;

    en_a = 0;
    en_b = 0;

    #10;

    // A 출력
    en_a = 1;
    en_b = 0;

    #10;

    // B 출력
    en_a = 0;
    en_b = 1;

    #10;

    // 둘 다 OFF
    en_a = 0;
    en_b = 0;

    #10;

    // 둘 다 ON
    // Bus Contention 상황
    en_a = 1;
    en_b = 1;

    #10;

    $finish;

end

endmodule
