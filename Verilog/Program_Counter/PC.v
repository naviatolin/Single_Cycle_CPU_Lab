module PC
// decide what the next PC should be
(
    output [31:0] PC,
    input [31:0] PC_last,
    input [31:0] alternative_PC,
    input use_alternative_PC,
    input clk
);
    reg [31:0] PC_next;
    assign PC = PC_next;

    always @(posedge clk) begin
        if (use_alternative_PC) PC_next = alternative_PC;
        else PC_next = PC_last + 32'd4;
    end
endmodule