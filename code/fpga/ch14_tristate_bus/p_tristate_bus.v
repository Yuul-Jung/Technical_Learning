module p_tristate_bus(

    input [3:0] a,
    input [3:0] b,

    input en_a,
    input en_b,

    output [3:0] bus

);

// Shared Bus 제어
assign bus =

    en_a ? a :

    en_b ? b :

    4'bzzzz;

endmodule
