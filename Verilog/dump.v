/* -------------------------------------------------------------------------- */
    /*         defining the wires and registers and instantiating modules         */
    /* -------------------------------------------------------------------------- */

    /* ----------------------------- program counter ---------------------------- */
    // wire [31:0] PC; // needs to be wired into the memory such that the instruction comes from memory
    // reg [31:0] PC_Last;
    // wire [31:0] alternative_PC;
    // wire use_alternative_PC;

    // PC pc(.PC(PC), .PC_Last(PC_Last), .alternative_PC(alternative_PC), .use_alternative_PC(use_alternative_PC));
/* --------------------------------- memory --------------------------------- */
    wire [31:0]  data_out;
    reg [31:0]  data_in;
    reg [31:0]  data_addr;
    reg wr_en;

    memory MEMORY(.PC(PC), .instruction(instruction), .data_out(data_out), .data_in(data_in), .data_addr(data_addr), .clk(clk), .wr_en(wr_en));

    // /* --------------------------- instruction decoder -------------------------- */
    // wire [5:0] opcode;
    // wire [4:0] rs;
    // wire [4:0] rt;
    // wire [4:0] rd;
    // wire [4:0] shamt;
    // wire [5:0] funct;
    // wire [15:0] immediate;
    // wire [25:0] address;
    // wire [31:0] instruction;

    // instructionDecoder INSTRUCTIONDECODER(.opcode(opcode), .rs(rs), .rt(rt), .rd(rd), .shamt(shamt), .funct(funct), .immediate(immediate), .address(address), .instruction(instruction));

    // /* ----------------------------------- fsm ---------------------------------- */
    // // wire wrenable;
    // wire [2:0] ALU_Signal;
    // // wire ADD_Signal;
    // // wire SUB_Signal,
    // // wire SLT_Signal;
    // // wire JR_Signal;
    // // wire ADDI_Signal;
    // // wire XORI_Signal;
    // // wire BNE_Signal;
    // // wire BEQ_Signal;
    // // wire SW_Signal;
    // // wire LW_Signal;
    // // wire JAL_Signal;
    // // wire J_Signal;

    // fsm FSM(.wrenable(wrenable), .ALU_Signal(ALU_Signal), .ADD_Signal(ADD_Signal), .SUB_Signal(SUB_Signal), .SLT_Signal(SLT_Signal), .JR_Signal(JR_Signal), .ADDI_Signal(ADDI_Signal), .XORI_Signal(XORI_Signal), .BNE_Signal(BNE_Signal), .BEQ_Signal(BEQ_Signal), .LW_Signal(LW_Signal), .JAL_Signal(JAL_Signal), .J_Signal(J_Signal), .opcode(opcode), .funct(funct));

    // // /* --------------------------------- regfile -------------------------------- */
    // // regfile REGFILE(.ReadData1(ReadData1), .ReadData2(ReadData2), .WriteData(ALU_result), .ReadRegister1(rs), .ReadRegister2(rt), .WriteRegister(rd), .Reg_Write(wrenable)), .clk(clk));

    // // /* ----------------------------------- alu ---------------------------------- */
    // // wire [31:0] ALU_result;
    // // wire [31:0]	ReadData1;
    // // wire [31:0]	ReadData2;

    // // alu ALU(.result(ALU_result), .operandA(ReadData1), .operandB(ReadData2), .command(ALU_Signal));