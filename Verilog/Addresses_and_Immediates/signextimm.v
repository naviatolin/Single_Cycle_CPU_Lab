module signextend (
	output [31:0] signextimm,
	input [15:0] immediate
);
    reg [31:0] signext;
    reg [31:0] signextimm;
    
    always @* begin
        signext <= {16{immediate[15]}};
        signextimm <= {signext,immediate};
    end

endmodule