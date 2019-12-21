`define R_Type 6'b000000
`define Jump 6'b000010
`define JAL 6'b000011

module instructionDecoder
(
    output reg[5:0] opcode,
    output reg [4:0] rs,
    output reg [4:0] rt,
    output reg [4:0] rd,
    output reg [4:0] shamt,
    output reg [5:0] funct,
    output reg [15:0] immediate,
    output reg [25:0] address,
    input [31:0] instruction
);
    
    always @(instruction) begin
        opcode = instruction[31:26];

        // r type break down
        if (opcode == `R_Type) begin
            rs <= instruction[25:21];
            rt <= instruction[20:16];
            rd <= instruction[15:11];
            shamt <= instruction[10:6];
            funct <= instruction[5:0];
        end
        
        // if opcode is j
        else if (opcode == `Jump) begin
            address <= instruction[25:0];
        end

        // if opcode is jal
        else if (opcode == `JAL) begin
            address <= instruction [25:0];
        end

        // if opcode is anything else (i type)
        else begin
            rs <= instruction[25:21];
            rt <= instruction[20:16];
            immediate <= instruction[15:0];
        end
    end
endmodule