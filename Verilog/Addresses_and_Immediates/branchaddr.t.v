`include "branchaddr.v"

module branchaddrTest();
    wire [31:0] branch_addr;
    reg [15:0] immediate;

    branchAddress dut(.branch_addr(branch_addr), .immediate(immediate));

    initial begin
        immediate = 16'b0111111111111111;
        #1
        if (branch_addr != 32'b00000000000000011111111111111100) $display("Error");
    end
endmodule