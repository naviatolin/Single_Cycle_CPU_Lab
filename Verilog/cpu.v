`include "ALU/alu.v"
`include "Addresses_and_Immediates/signextimm.v"
`include "Addresses_and_Immediates/branchaddr.v"
`include "Addresses_and_Immediates/jumpaddr.v"
`include "Instruction_Decoder_and_FSM/instructiondecoder.v"
`include "Instruction_Decoder_and_FSM/fsm.v"
`include "Memory/memory.v"
`include "Program_Counter/PC.v"
`include "Register_File/regfile.v"

module CPU(
    input clk
);
    /* -------------------------------------------------------------------------- */
    /*         defining the wires and registers and instantiating modules         */
    /* -------------------------------------------------------------------------- */

    /* ----------------------------- program counter ---------------------------- */
    wire [31:0] PC; // needs to be wired into the memory such that the instruction comes from memory
    reg [31:0] PC_Last;
    reg [31:0] alternative_PC;
    reg use_alternative_PC;

    PC pc(
        .PC(PC), // is connected to PC in MEMORY
        .PC_last(PC_Last),
        .alternative_PC(alternative_PC),
        .use_alternative_PC(use_alternative_PC),
        .clk(clk)
    );

    /* --------------------------------- memory --------------------------------- */
    wire [31:0]  data_out;
    reg [31:0]  data_in;
    reg [31:0]  data_addr;
    wire [31:0] instruction;
    reg wr_en_mem;

    memory MEMORY(
        .PC(PC), // is connected to PC in pc
        .instruction(instruction),
        .data_out(data_out),
        .data_in(data_in),
        .data_addr(data_addr),
        .clk(clk),
        .wr_en(wr_en_mem)
    );

    /* --------------------------- instruction decoder -------------------------- */
    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [5:0] funct;
    wire [15:0] immediate;
    wire [25:0] address;

    instructionDecoder INSTRUCTIONDECODER(
        .opcode(opcode), 
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .shamt(shamt),
        .funct(funct),
        .immediate(immediate),
        .address(address),
        .instruction(instruction)
    );

    /* ----------------------------------- fsm ---------------------------------- */
    wire [2:0] ALU_Signal;

    FSM FSM(
        .wrenable(wr_en_reg),
        .ALU_Signal(ALU_Signal),
        .ADD_Signal(ADD_Signal),
        .SUB_Signal(SUB_Signal),
        .SLT_Signal(SLT_Signal),
        .JR_Signal(JR_Signal),
        .ADDI_Signal(ADDI_Signal),
        .XORI_Signal(XORI_Signal), .BNE_Signal(BNE_Signal),
        .BEQ_Signal(BEQ_Signal),
        .SW_Signal(SW_Signal),
        .LW_Signal(LW_Signal),
        .JAL_Signal(JAL_Signal),
        .J_Signal(J_Signal),
        .opcode(opcode),
        .funct(funct)
    );

    /* ------------------------------- signextimm ------------------------------- */
    wire [31:0] signextimm;
    signextend SIGNEXTEND(
        .signextimm(signextimm),
        .immediate(immediate)
    );

    /* ------------------------------- branchaddr ------------------------------- */
    wire [31:0] branch_addr;
    branchAddress BRANCHADDRESS(
        .branch_addr(branch_addr),
        .immediate(immediate)
    );

    /* -------------------------------- jumpaddr -------------------------------- */
    wire [31:0] jump_addr;
    jumpAddress JUMPADDRESS(
        .jump_addr(jump_addr),
        .address(address),
        .PC(PC)
    );

    /* --------------------------------- regfile -------------------------------- */
    wire [31:0]	ReadData1;
    wire [31:0]	ReadData2;
    wire [31:0] ALU_result;
    reg [4:0] ReadRegister2;
    reg [4:0] WriteRegister;
    reg [31:0] WriteData;

    regfile regfile(
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .WriteData(WriteData),
        .ReadRegister1(rs),
        .ReadRegister2(ReadRegister2),
        .WriteRegister(WriteRegister),
        .RegWrite(wr_en_reg),
        .Clk(clk)
    );

    /* ----------------------------------- alu ---------------------------------- */
    reg [31:0] second_operand;
    ALU ALU(
        .result(ALU_result),
        .operandA(ReadData1),
        .operandB(second_operand),
        .command(ALU_Signal)
    );

    /* -------------------------------------------------------------------------- */
    /*                          Setting All The Muxes Up                          */
    /* -------------------------------------------------------------------------- */

    // deciding which registers to read and write from
    always @* begin
        if (ADDI_Signal == 1 | XORI_Signal == 1 | LW_Signal == 1) begin
            ReadRegister2 <= rd;
            WriteRegister <= rt;
        end
        else begin
            ReadRegister2 <= rt;
            WriteRegister <= rd;
        end

    end

    // mux for choosing between signextimm and readdata2
    always @* begin 
        if (ADDI_Signal == 1 | XORI_Signal == 1) second_operand <= signextimm;
        else second_operand <= ReadData2;
    end

    // mux for replacing the PC if necessary
    always @* begin
        if (BEQ_Signal == 1 | BNE_Signal == 1) begin
            if (ReadData1 == ReadData2) begin
                alternative_PC <= PC_Last + 32'd4 + branch_addr;
                use_alternative_PC <= 1'b1;
            end
            else begin
                alternative_PC <= PC_Last;
                use_alternative_PC <= 1'b0;
            end
        end
        else begin
            use_alternative_PC <= 1'b0;
            alternative_PC <= PC_Last;
        end
    end

    // sw and lw functionality muxes
    reg [31:0] memory_address;
    always @* begin
        if (SW_Signal == 1) begin
            data_addr <= ReadData1 + signextimm;
            data_in <= ReadData2;
            wr_en_mem <= 1'b1;
        end
        else if (LW_Signal == 1) begin
            data_addr <= ReadData1 + signextimm;
            wr_en_mem <= 1'b0;
            WriteData <= data_out;
        end
        else begin
            WriteData <= ALU_result;
        end
    end

    // muxes for j, jal, and jr
    always @* begin
        if (J_Signal == 1) begin
            use_alternative_PC <= 1'b1;
            alternative_PC <= jump_addr;
        end
        else if (JAL_Signal == 1) begin
            WriteData = PC + 32'd8;
            WriteRegister = 32'd31;
            use_alternative_PC = 1'b1;
            alternative_PC = jump_addr;
        end
        else if (JR_Signal == 1) begin
            use_alternative_PC <= 1'b1;
            alternative_PC <= ReadData1;
        end
    end
endmodule