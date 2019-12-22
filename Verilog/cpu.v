`include "ALU/alu.v"
`include "Addresses_and_Immediates/signextimm.v"
`include "Addresses_and_Immediates/branchaddr.v"
`include "Addresses_and_Immediates/jumpaddr.v"
`include "Instruction_Decoder_and_FSM/instructiondecoder.v"
`include "Instruction_Decoder_and_FSM/fsm.v"
`include "Memory/memory.v"
`include "Program_Counter/PC.v"
`include "Register_File/regfile.v"

`define JR_PC_ENABLE 3'd3
`define J_JAL_PC_ENABLE 3'd2
`define B_PC_Enable 3'd1

module CPU(
    input clk,
    input reset
);
    /* -------------------------------------------------------------------------- */
    /*         defining the wires and registers and instantiating modules         */
    /* -------------------------------------------------------------------------- */

    /* ------------------------------- definitions ------------------------------ */
    // PC definitions
    wire [31:0] PC; // needs to be wired into the memory such that the instruction comes from memory
    reg [31:0] PC_Last;
    reg [31:0] alternative_PC;
    wire [2:0] ALU_Signal;
    reg really_use_alternative_PC;

    // fsm definitions
    wire [1:0] choose_alternative_PC; 
    wire wr_en_reg;
    wire write_from_memory_to_reg;
    wire write_reg_31;
    wire write_pc8_to_reg;
    wire use_alternative_PC; // used in pc
    wire use_signextimm;
    wire wr_en_memory;
    wire write_to_rt;

    // memory definitions
    wire [31:0]  data_out;
    wire [31:0] instruction;
    
    // instruction decode definitions
    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [5:0] funct;
    wire [15:0] immediate;
    wire [25:0] address;

    // creating constants definitions
    wire [31:0] signextimm;
    wire [31:0] branch_addr;
    wire [31:0] jump_addr;

    // alu definitions
    reg [31:0] second_register;
    wire [31:0]	ReadData1;
    wire [31:0] ALU_result;
    
    // regfile definitions
    wire [31:0]	ReadData2;
    reg [4:0] ReadRegister2;
    reg [4:0] WriteRegister;
    reg [31:0] WriteData;

    // intermediate definitions
    reg [31:0] pc8_or_alu;

    /* ----------------------------- program counter ---------------------------- */

    PC pc(
        .PC(PC), // is connected to PC in MEMORY
        .PC_last(PC_Last), // connected to PC
        .alternative_PC(alternative_PC), // connected to MUX below
        .use_alternative_PC(really_use_alternative_PC), // connected in mux below
        .clk(clk), // no need to be connected
        .reset(reset) // no need to be connected
    );

    /* --------------------------------- memory --------------------------------- */

    memory MEMORY(
        .PC(PC), // is connected to PC in pc
        .instruction(instruction), // connected to instruction decoder
        .data_out(data_out), // connected to mux
        .data_in(ReadData2), // connected to regfile
        .data_addr(ALU_result), // connected to ALU
        .clk(clk), // no need to be connected
        .wr_en(wr_en_memory) // connected to fsm
    );

    /* --------------------------- instruction decoder -------------------------- */

    instructionDecoder INSTRUCTIONDECODER(
        .opcode(opcode), // connected to fsm
        .rs(rs), // connected to regfile & mux
        .rt(rt), // connected to mux
        .rd(rd), // connected to mux
        .shamt(shamt), // no need to be connected
        .funct(funct), // connected to fsm
        .immediate(immediate), // connected to signextimm and branchaddr
        .address(address), // connected to jump addr
        .instruction(instruction) // connected to memory
    );

    /* ----------------------------------- fsm ---------------------------------- */
    FSM FSM(
        .wr_en_reg(wr_en_reg), // connected to regfile
        .ALU_Signal(ALU_Signal), // connected to ALU
        .write_from_memory_to_reg(write_from_memory_to_reg), // used as control signal in mux
        .write_reg_31(write_reg_31), // used as control signal in mux
        .write_pc8_to_reg(write_pc8_to_reg), // used as control signal in mux
        .use_alternative_PC(use_alternative_PC), // used to set really_use_alternative_PC
        .choose_alternative_PC(choose_alternative_PC), // used in case switch
        .use_signextimm(use_signextimm), // used in signextimm mux
        .wr_en_memory(wr_en_memory), // connected to memory
        .write_to_rt(write_to_rt), // used in muxes 
        .opcode(opcode), // connected to instruction decoder
        .funct(funct) // connected to instruction decoder
    );

    /* ----------------------------------- alu ---------------------------------- */
    ALU ALU(
        .result(ALU_result), // connected to memory and mux
        .operandA(ReadData1), // connected to regfile
        .operandB(second_register), // connected to mux
        .command(ALU_Signal) // connected to fsm
    );

    /* --------------------------------- regfile -------------------------------- */
    regfile regfile(
        .ReadData1(ReadData1), // connected to case switch and alu
        .ReadData2(ReadData2), // connected to mux
        .WriteData(WriteData), // connected to muxes
        .ReadRegister1(rs), // connected to instruction decoder
        .ReadRegister2(ReadRegister2), // connected to muxes
        .WriteRegister(WriteRegister), // connected to muxes
        .RegWrite(wr_en_reg), // connected to fsm
        .Clk(clk) // no need to be connected
    );

    /* ------------------------------- signextimm ------------------------------- */
    signextend SIGNEXTEND(
        .signextimm(signextimm), // connected to mux
        .immediate(immediate) // connected to instruction decoder
    );

    /* ------------------------------- branchaddr ------------------------------- */
    branchAddress BRANCHADDRESS(
        .branch_addr(branch_addr), // connected to case statement
        .immediate(immediate) // connected to intruction decoder
    );

    /* -------------------------------- jumpaddr -------------------------------- */
    jumpAddress JUMPADDRESS(
        .jump_addr(jump_addr), // connected to case statement
        .address(address), // connected to instruction decoder
        .PC(PC) // connected to PC
    );

    /* -------------------------------------------------------------------------- */
    /*                          Setting All The Muxes Up                          */
    /* -------------------------------------------------------------------------- */
    // deciding which registers to read and write from
    always @(*) begin
        PC_Last = PC;
    end
    // "write pc8 to reg" mux and "load word data?" mux
    always @(posedge clk, negedge clk, write_pc8_to_reg, ALU_result) begin
        if (write_pc8_to_reg == 1) begin
            pc8_or_alu <= PC + 32'd8;
        end
        else begin
            pc8_or_alu <= ALU_result;
        end
    end

    always @(posedge clk, negedge clk, write_from_memory_to_reg, data_out, pc8_or_alu) begin
        if (write_from_memory_to_reg) begin
            WriteData <= data_out;
        end
        else begin
            WriteData <= pc8_or_alu;
        end
    end

    // "Rs again [1] or Rt [0] for read register 2" mux and "Write to Rt [1] or Rd [0]?" combined mux
    // , write_to_rt, rs, write_reg_31, rt, rd
    always @(posedge clk, negedge clk) begin
        if (write_to_rt) begin
            ReadRegister2 <= rs;
            if (write_reg_31 == 1) begin
                WriteRegister <= 32'd31;
            end
            else begin
                WriteRegister <= rt;
            end
        end
        else begin
            ReadRegister2 <= rt;
            if (write_reg_31 == 1) begin
                WriteRegister <= 32'd31;
            end
            else WriteRegister <= rd;
        end
    end

    // signextimm mux
    always @(posedge clk, negedge clk, use_signextimm, signextimm, ReadData2) begin
        if (use_signextimm == 1) begin
            second_register <= signextimm;
        end
        else begin
            second_register <= ReadData2;
        end
    end

    // choose alternate PC mux
    always @(posedge clk, negedge clk, choose_alternative_PC, ReadData1, use_alternative_PC, jump_addr, branch_addr) begin
        case(choose_alternative_PC)
            `JR_PC_ENABLE: begin
                alternative_PC <= ReadData1;
                really_use_alternative_PC <= use_alternative_PC;
            end

            `J_JAL_PC_ENABLE: begin
                alternative_PC <= jump_addr;
                really_use_alternative_PC <= use_alternative_PC;
            end

            `B_PC_Enable: begin
                if (ReadData1 == ReadData2) begin
                    alternative_PC <= PC + 32'd4 + branch_addr;
                    really_use_alternative_PC <= use_alternative_PC;
                end
                else begin
                    alternative_PC <= PC + 32'd4 + branch_addr;
                    really_use_alternative_PC <= 1'b0;
                end
            end
            2'b0: begin
                alternative_PC <= 32'b0;
                really_use_alternative_PC <= 1'b0;
            end
        endcase
    end
endmodule