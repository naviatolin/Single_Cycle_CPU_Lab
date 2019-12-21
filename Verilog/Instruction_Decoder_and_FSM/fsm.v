// r type opcode value
`define R_TYPE 6'b000000

// rtype function values to distinguish between them
`define ADD 6'h20
`define SUB 6'h22
`define SLT 6'h2A
`define JR 6'h08

// define j type instructions
`define JUMP 6'b000010
`define JAL 6'b000011

// define i type instructions
`define ADDI 6'b001000
`define XORI 6'b001110
`define BNE 6'b000101
`define BEQ 6'b000100
`define SW 6'b101011
`define LW 6'b100011

// ALU Stuff
`define ALU_ADD  3'd0
`define ALU_SUB  3'd1
`define ALU_XOR  3'd2
`define ALU_SLT  3'd3
`define ALU_AND  3'd4
`define ALU_NAND 3'd5
`define ALU_NOR  3'd6
`define ALU_OR   3'd7

module FSM
(
    output reg wrenable,
    output reg [2:0] ALU_Signal,
    output reg ADD_Signal,
    output reg SUB_Signal,
    output reg SLT_Signal,
    output reg JR_Signal,
    output reg ADDI_Signal,
    output reg XORI_Signal,
    output reg BNE_Signal,
    output reg BEQ_Signal,
    output reg SW_Signal,
    output reg LW_Signal,
    output reg JAL_Signal,
    output reg J_Signal,
    input [5:0] opcode,
    input [5:0] funct
    
);
    always @(opcode or funct) begin
        wrenable <= 1'b0;
        ALU_Signal <= 1'd0;
        ADD_Signal <= 1'b0;
        SUB_Signal <= 1'b0;
        SLT_Signal <= 1'b0;
        JR_Signal <= 1'b0;
        ADDI_Signal <= 1'b0;
        XORI_Signal <= 1'b0;
        BNE_Signal <= 1'b0;
        BEQ_Signal <= 1'b0;
        SW_Signal <= 1'b0;
        LW_Signal <= 1'b0;
        JAL_Signal <= 1'b0;
        J_Signal <= 1'b0;

        
        if (opcode == `R_TYPE) begin
            if (funct == `ADD) begin
                wrenable <= 1'b1;
                ALU_Signal <= `ALU_ADD;
                ADD_Signal <= 1'b1;
            end
            else if (funct == `SUB) begin
                wrenable <= 1'b1;
                ALU_Signal <= `ALU_SUB;
                SUB_Signal <= 1'b1;
            end
            else if (funct == `SLT) begin
                wrenable <= 1'b1;
                ALU_Signal <= `ALU_SLT;
                SLT_Signal <= 1'b1;
            end
            else if (funct == `JR) begin
                ALU_Signal <= `ALU_ADD;
                JR_Signal <= 1'b1;
            end
        end
        else if (opcode == `JUMP) begin
            ALU_Signal <= `ALU_ADD;
            J_Signal <= 1'b1;
        end
        else if (opcode == `JAL) begin
            wrenable <= 1'b1;
            ALU_Signal <= `ALU_ADD;
            JAL_Signal <= 1'b1;
        end
        else if (opcode == `ADDI) begin
            wrenable <= 1'b1;
            ALU_Signal <= `ALU_ADD;
            ADDI_Signal <= 1'b1;
        end
        else if (opcode == `XORI) begin
            wrenable <= 1'b1;
            ALU_Signal <= `ALU_XOR;
            XORI_Signal <= 1'b1;
        end
        else if (opcode == `BNE) begin
            ALU_Signal <= `ALU_ADD;
            BNE_Signal <= 1'b1;
        end
        else if (opcode == `BEQ) begin
            ALU_Signal <= `ALU_ADD;
            BEQ_Signal <= 1'b1;
        end
        else if (opcode == `SW) begin
            ALU_Signal <= `ALU_ADD;
            SW_Signal <= 1'b1;
        end
        else if (opcode == `LW) begin
            wrenable <= 1'b1;
            ALU_Signal <= `ALU_ADD;
            LW_Signal <= 1'b1;
        end
    end
endmodule
