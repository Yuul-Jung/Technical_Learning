module tb_mux2;

reg a;
reg b;
reg sel;

wire y_gate;
wire y_dataflow;
wire y_behavioral;

c_mux2_gate dut0(.a(a),.b(b),.sel(sel),.y(y_gate));
c_mux2_dataflow dut1(.a(a),.b(b),.sel(sel),.y(y_dataflow));
c_mux2_behavioral dut2(.a(a),.b(b),.sel(sel),.y(y_behavioral));

initial begin
    a=0; b=0; sel=0; #10;
    a=1; b=0; sel=0; #10;
    a=0; b=1; sel=1; #10;
    a=1; b=0; sel=1; #10;
    $finish;
end

endmodule
