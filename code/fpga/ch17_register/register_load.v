module register_load(
    input clk,             // Clock 입력
    input load,            // Load 입력
    input [7:0] d,         // 데이터 입력

    output reg [7:0] q     // 데이터 출력
);

// Load가 1일 때 저장
always @(posedge clk) begin

    if (load)
        q <= d;

end

endmodule
