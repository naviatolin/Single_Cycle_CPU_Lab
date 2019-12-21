`include "fsm.v"

module fsmTest();
    reg clk;
    wire wrenable;
    wire [2:0] ALU_Signal;
    wire ADD_Signal;
    wire SUB_Signal;
    wire SLT_Signal;
    wire JR_Signal;
    wire ADDI_Signal;
    wire XORI_Signal;
    wire BNE_Signal;
    wire BEQ_Signal;
    wire SW_Signal;
    wire LW_Signal;
    wire JAL_Signal;
    wire J_Signal;
    reg [5:0] opcode;
    reg [5:0] funct;

    FSM fsmdut (.wrenable(wrenable), .ALU_Signal(ALU_Signal), .ADD_Signal(ADD_Signal), .SUB_Signal(SUB_Signal), .SLT_Signal(SLT_Signal), .JR_Signal(JR_Signal), .ADDI_Signal(ADDI_Signal), .XORI_Signal(XORI_Signal), .BNE_Signal(BNE_Signal), .BEQ_Signal(BEQ_Signal), .SW_Signal(SW_Signal), .LW_Signal(LW_Signal), .JAL_Signal(JAL_Signal), .J_Signal(J_Signal), .opcode(opcode), .funct(funct));

    initial begin
        // Testing Add
        opcode = 6'b000000; 
        funct = 6'h20;
        #1
        if (ADD_Signal != 1'b1) begin $display("ADD: Not Working"); end
        if (wrenable != 1'b1) $display("ADD Write: Not Working");
        if (ALU_Signal != 3'd0) begin $display("ADD ALU: Not Working"); end

        // Testing Sub
        opcode = 6'b000000; 
        funct = 6'h22;
        #1
        if (SUB_Signal != 1'b1) begin $display("SUB: Not Working"); end
        if (wrenable != 1'b1) $display("SUB Write: Not Working");
        if (ALU_Signal != 3'd1) begin $display("SUB ALU: Not Working"); end

        // Testing SLT
        opcode = 6'b000000; 
        funct = 6'h2A;
        #1
        if (SLT_Signal != 1'b1) $display("SLT: Not Working");
        if (wrenable != 1'b1) $display("SLT Write: Not Working");
        if (ALU_Signal != 3'd3) $display("SLT ALU: Not Working");
        

        // Testing JR
        opcode = 6'b000000; 
        funct = 6'h08;
        #1
        if (JR_Signal != 1'b1) $display("JR: Not Working");
        if (ALU_Signal != 1'b0) $display("JR ALU: Not Working");

        // Testing Jump
        opcode = 6'b000010; 
        funct = 6'h08;
        #1
        if (J_Signal != 1'b1) $display("J: Not Working");
        if (ALU_Signal != 3'd0) $display("ALU J: Not Working");

        // Testing JAL
        opcode = 6'b000011;
        funct = 6'h08;
        #1
        if (JAL_Signal != 1'b1) $display("JAL: Not Working");
        if (wrenable != 1'b1) $display("JAL Write: Not Working");
        if (ALU_Signal != 3'd0) $display("JAL ALU: Not Working");
        

        // Testing ADDI
        opcode = 6'b001000;
        funct = 6'h08;
        #1
        if (ADDI_Signal != 1'b1) $display("ADDI: Not Working");
        if (wrenable != 1'b1) $display("ADDI Write: Not Working");
        if (ALU_Signal != 3'd0) $display("ADDI ALU: Not Working");

        // Testing XORI
        opcode = 6'b001110;
        funct = 6'h08;
        #1
        if (XORI_Signal != 1'b1) $display("XORI: Not Working");
        if (wrenable != 1'b1) $display("XORI Write: Not Working");
        if (ALU_Signal != 3'd2) $display("XORI ALU: Not Working");

        // Testing BNE
        opcode = 6'b000101;
        funct = 6'h08;
        #1
        if (BNE_Signal != 1'b1) $display("BNE: Not Working");
        if (ALU_Signal != 3'd0) $display("BNE: Not Working");

        // Testing BEQ
        opcode = 6'b000100;
        funct = 6'h08;
        #1
        if (BEQ_Signal != 1'b1) $display("BEQ: Not Working");
        if (ALU_Signal != 3'd0) $display("BEQ ALU: Not Working");

        // Testing SW
        opcode = 6'b101011;
        funct = 6'h08;
        #1
        if (SW_Signal != 1'b1) $display("SW: Not Working");
        if (ALU_Signal != 3'd0) $display("SW ALU: Not Working");

        // Testing LW
        opcode = 6'b100011;
        funct = 6'h08;
        #1
        if (LW_Signal != 1'b1) $display("LW: Not Working");
        if (wrenable != 1'b1) $display("LW Write: Not Working");
        if (ALU_Signal != 3'd0) $display("LW ALU: Not Working");
        $finish();
    end

        
endmodule

