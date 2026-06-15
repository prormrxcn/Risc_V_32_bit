module control_unit(
    input wire [6:0] op_code,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg alu_src,
    output reg mem_to_reg,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg branch,
    output reg jump,
    output reg [2:0] alu_ctrl,
    output reg [2:0] imm_src  // Match imm_gen encodings
);
    
    always @(*) begin
        // Default values
        alu_src = 0;
        mem_to_reg = 0;
        reg_write = 0;
        mem_read = 0;
        mem_write = 0;
        branch = 0;
        jump = 0;
        alu_ctrl = 3'b000;
        imm_src = 3'b000; // Default to 0 (unused)
        
        case(op_code)
            // R-type instructions (no immediate)
            7'b0110011: begin
                reg_write = 1;
                alu_src = 0;
                imm_src = 3'b000; // Not used for R-type
                case(funct3)
                    3'b000: alu_ctrl = (funct7[5]) ? 3'b001 : 3'b000; // SUB/ADD
                    3'b001: alu_ctrl = 3'b101; // SLL
                    3'b010: alu_ctrl = 3'b111; // SLT
                    3'b011: alu_ctrl = 3'b111; // SLTU
                    3'b100: alu_ctrl = 3'b100; // XOR
                    3'b101: alu_ctrl = (funct7[5]) ? 3'b110 : 3'b101; // SRL/SRA
                    3'b110: alu_ctrl = 3'b011; // OR
                    3'b111: alu_ctrl = 3'b010; // AND
                    default : alu_ctrl = 3'b000;
                endcase
            end

            // I-type (arithmetic) - uses I-type immediate (001)
            7'b0010011: begin
                reg_write = 1;
                alu_src = 1;
                imm_src = 3'b001; // I-type
                case(funct3)
                    3'b000: alu_ctrl = 3'b000; // ADDI
                    3'b001: alu_ctrl = 3'b101; // SLLI
                    3'b010: alu_ctrl = 3'b111; // SLTI
                    3'b011: alu_ctrl = 3'b111; // SLTIU
                    3'b100: alu_ctrl = 3'b100; // XORI
                    3'b101: alu_ctrl = (funct7[5]) ? 3'b110 : 3'b101; // SRLI/SRAI
                    3'b110: alu_ctrl = 3'b011; // ORI  ← maps 110 to 011
                    3'b111: alu_ctrl = 3'b010; // ANDI ← maps 111 to 010
                    default: alu_ctrl = 3'b000;
                endcase
            end
            
            // I-type (Load) - uses I-type immediate (001)
            7'b0000011: begin
                reg_write = 1;
                alu_src = 1;
                mem_to_reg = 1;
                mem_read = 1;
                imm_src = 3'b001; // I-type
                alu_ctrl = 3'b000; // ADD for address
            end
            
            // S-type (Store) - uses S-type immediate (010)
            7'b0100011: begin
                alu_src = 1;
                mem_write = 1;
                imm_src = 3'b010; // S-type
                alu_ctrl = 3'b000; // ADD for address
            end
            
            // B-type (Branch) - uses B-type immediate (011)
            7'b1100011: begin
                branch = 1;
                imm_src = 3'b011; // B-type
                alu_ctrl = 3'b001; // SUB for comparison
            end
            
            // J-type (Jump) - uses J-type immediate (100)
            7'b1101111: begin
                jump = 1;
                reg_write = 1;
                imm_src = 3'b100; // J-type
                alu_ctrl = 3'b000; // Not used
            end
            
            // U-type (LUI) - uses U-type immediate (101)
            7'b0110111: begin // lui
                reg_write = 1;
                alu_src = 1;
                imm_src = 3'b101; // U-type
                // alu_ctrl = 3'b000; // ADD (pass immediate)
            end

            // U-type (AUIPC) - uses U-type immediate (101)
            7'b0010111: begin // auipc
                reg_write = 1;
                alu_src = 1;
                alu_ctrl = 3'b000; // ADD PC + immediate
                imm_src = 3'b101; // U-type
            end
            
            default : begin
                // Keep defaults
            end
        endcase
    end
    
endmodule

`ifdef SIMULATION
module control_unit_tb();

// Testbench signals
reg [6:0] op_code;
reg [2:0] funct3;
reg [6:0] funct7;
wire alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch, jump;
wire [2:0] alu_ctrl;
wire [1:0] imm_src;

// Expected values for verification
reg [15:0] expected; // Packed expected outputs for easy checking

// Instantiate control unit
control_unit dut(
    .op_code(op_code),
    .funct3(funct3),
    .funct7(funct7),
    .alu_src(alu_src),
    .mem_to_reg(mem_to_reg),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .branch(branch),
    .jump(jump),
    .alu_ctrl(alu_ctrl),
    .imm_src(imm_src)
);

// Task to check results
task check_outputs;
    input [15:0] exp;
    begin
        #1;
        $write("OP: %07b | FUNCT3: %03b | FUNCT7: %07b | ", op_code, funct3, funct7);
        $write("ALU_SRC=%b REG_WR=%b MEM_RD=%b MEM_WR=%b ", 
                alu_src, reg_write, mem_read, mem_write);
        $write("BR=%b JMP=%b MEM2REG=%b ", branch, jump, mem_to_reg);
        $write("ALU_CTRL=%03b IMM_SRC=%b ", alu_ctrl, imm_src);
        
        // Verify against expected (simplified - you can expand this)
        $display("");
    end
endtask

initial begin
    $display("\n========================================");
    $display("CONTROL UNIT TESTBENCH");
    $display("========================================\n");
    
    $display("1. TESTING R-TYPE INSTRUCTIONS");
    $display("----------------------------------------");
    
    // R-type ADD (funct7[5]=0)
    op_code = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10 check_outputs(16'h0);
    
    // R-type SUB (funct7[5]=1)
    funct7 = 7'b0100000;
    #10 check_outputs(16'h0);
    
    // R-type SLL
    funct3 = 3'b001;
    funct7 = 7'b0000000;
    #10 check_outputs(16'h0);
    
    // R-type SLT
    funct3 = 3'b010;
    #10 check_outputs(16'h0);
    
    // R-type SLTU
    funct3 = 3'b011;
    #10 check_outputs(16'h0);
    
    // R-type XOR
    funct3 = 3'b100;
    #10 check_outputs(16'h0);
    
    // R-type SRL
    funct3 = 3'b101;
    funct7 = 7'b0000000;
    #10 check_outputs(16'h0);
    
    // R-type SRA
    funct3 = 3'b101;
    funct7 = 7'b0100000;
    #10 check_outputs(16'h0);
    
    // R-type OR
    funct3 = 3'b110;
    #10 check_outputs(16'h0);
    
    // R-type AND
    funct3 = 3'b111;
    #10 check_outputs(16'h0);
    
    $display("\n2. TESTING I-TYPE INSTRUCTIONS");
    $display("----------------------------------------");
    
    // I-type ADDI
    op_code = 7'b0010011;
    funct3 = 3'b000;
    #10 check_outputs(16'h0);
    
    // I-type ANDI
    funct3 = 3'b111;
    #10 check_outputs(16'h0);
    
    // I-type ORI
    funct3 = 3'b110;
    #10 check_outputs(16'h0);
    
    // I-type XORI
    funct3 = 3'b100;
    #10 check_outputs(16'h0);
    
    $display("\n3. TESTING LOAD INSTRUCTIONS");
    $display("----------------------------------------");
    
    // LB, LH, LW, LBU, LHU
    op_code = 7'b0000011;
    funct3 = 3'b010; // LW
    #10 check_outputs(16'h0);
    
    $display("\n4. TESTING STORE INSTRUCTIONS");
    $display("----------------------------------------");
    
    // SB, SH, SW
    op_code = 7'b0100011;
    funct3 = 3'b010; // SW
    #10 check_outputs(16'h0);
    
    $display("\n5. TESTING BRANCH INSTRUCTIONS");
    $display("----------------------------------------");
    
    // BEQ, BNE, BLT, BGE, BLTU, BGEU
    op_code = 7'b1100011;
    funct3 = 3'b000; // BEQ
    #10 check_outputs(16'h0);
    
    $display("\n6. TESTING JUMP INSTRUCTIONS");
    $display("----------------------------------------");
    
    // JAL
    op_code = 7'b1101111;
    #10 check_outputs(16'h0);
    
    // JALR
    op_code = 7'b1100111;
    #10 check_outputs(16'h0);
    
    $display("\n7. TESTING LUI");
    $display("----------------------------------------");
    
    // LUI
    op_code = 7'b0110111;
    #10 check_outputs(16'h0);
    
    $display("\n========================================");
    $display("SIMULATION COMPLETE");
    $display("========================================\n");
    
    $finish;
end

// Monitor to show continuous output
initial begin
    $monitor("Time=%0t op=%b funct3=%b funct7=%b | src=%b m2r=%b regW=%b memR=%b memW=%b br=%b jmp=%b alu=%b imm=%b",
             $time, op_code, funct3, funct7,
             alu_src, mem_to_reg, reg_write, mem_read, mem_write,
             branch, jump, alu_ctrl, imm_src);
end

endmodule
`endif
