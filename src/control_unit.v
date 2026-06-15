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
    output reg [2:0] imm_src
);
    
    always @(*) begin
        alu_src = 0;
        mem_to_reg = 0;
        reg_write = 0;
        mem_read = 0;
        mem_write = 0;
        branch = 0;
        jump = 0;
        alu_ctrl = 3'b000;
        imm_src = 3'b000;
        
        case(op_code)
            7'b0110011: begin
                reg_write = 1;
                alu_src = 0;
                imm_src = 3'b000;
                case(funct3)
                    3'b000: alu_ctrl = (funct7[5]) ? 3'b001 : 3'b000;
                    3'b001: alu_ctrl = 3'b101;
                    3'b010: alu_ctrl = 3'b111;
                    3'b011: alu_ctrl = 3'b111;
                    3'b100: alu_ctrl = 3'b100;
                    3'b101: alu_ctrl = (funct7[5]) ? 3'b110 : 3'b101;
                    3'b110: alu_ctrl = 3'b011;
                    3'b111: alu_ctrl = 3'b010;
                    default : alu_ctrl = 3'b000;
                endcase
            end

            7'b0010011: begin
                reg_write = 1;
                alu_src = 1;
                imm_src = 3'b001;
                case(funct3)
                    3'b000: alu_ctrl = 3'b000;
                    3'b001: alu_ctrl = 3'b101;
                    3'b010: alu_ctrl = 3'b111;
                    3'b011: alu_ctrl = 3'b111;
                    3'b100: alu_ctrl = 3'b100;
                    3'b101: alu_ctrl = (funct7[5]) ? 3'b110 : 3'b101;
                    3'b110: alu_ctrl = 3'b011;
                    3'b111: alu_ctrl = 3'b010;
                    default: alu_ctrl = 3'b000;
                endcase
            end
            
            7'b0000011: begin
                reg_write = 1;
                alu_src = 1;
                mem_to_reg = 1;
                mem_read = 1;
                imm_src = 3'b001;
                alu_ctrl = 3'b000;
            end
            
            7'b0100011: begin
                alu_src = 1;
                mem_write = 1;
                imm_src = 3'b010;
                alu_ctrl = 3'b000;
            end
            
            7'b1100011: begin
                branch = 1;
                imm_src = 3'b011;
                alu_ctrl = 3'b001;
            end
            
            7'b1101111: begin
                jump = 1;
                reg_write = 1;
                imm_src = 3'b100;
                alu_ctrl = 3'b000;
            end
            
            7'b0110111: begin
                reg_write = 1;
                alu_src = 1;
                imm_src = 3'b101;
            end

            7'b0010111: begin
                reg_write = 1;
                alu_src = 1;
                alu_ctrl = 3'b000;
                imm_src = 3'b101;
            end
            
            default : begin
            end
        endcase
    end
    
endmodule

`ifdef SIMULATION
module control_unit_tb();

reg [6:0] op_code;
reg [2:0] funct3;
reg [6:0] funct7;
wire alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch, jump;
wire [2:0] alu_ctrl;
wire [1:0] imm_src;

reg [15:0] expected;

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

task check_outputs;
    input [15:0] exp;
    begin
        #1;
        $write("OP: %07b | FUNCT3: %03b | FUNCT7: %07b | ", op_code, funct3, funct7);
        $write("ALU_SRC=%b REG_WR=%b MEM_RD=%b MEM_WR=%b ", 
                alu_src, reg_write, mem_read, mem_write);
        $write("BR=%b JMP=%b MEM2REG=%b ", branch, jump, mem_to_reg);
        $write("ALU_CTRL=%03b IMM_SRC=%b ", alu_ctrl, imm_src);
        $display("");
    end
endtask

initial begin
    $display("\n========================================");
    $display("CONTROL UNIT TESTBENCH");
    $display("========================================\n");
    
    $display("1. TESTING R-TYPE INSTRUCTIONS");
    $display("----------------------------------------");
    
    op_code = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10 check_outputs(16'h0);
    
    funct7 = 7'b0100000;
    #10 check_outputs(16'h0);
    
    funct3 = 3'b001;
    funct7 = 7'b0000000;
    #10 check_outputs(16'h0);
    
    funct3 = 3'b010;
    #10 check_outputs(16'h0);
    
    funct3 = 3'b011;
    #10 check_outputs(16'h0);
    
    funct3 = 3'b100;
    #10 check_outputs(16'h0);
    
    funct3 = 3'b101;
    funct7 = 7'b0000000;
    #10 check_outputs(16'h0);
    
    funct3 = 3'b101;
    funct7 = 7'b0100000;
    #10 check_outputs(16'h0);
    
    funct3 = 3'b110;
    #10 check_outputs(16'h0);
    
    funct3 = 3'b111;
    #10 check_outputs(16'h0);
    
    $display("\n2. TESTING I-TYPE INSTRUCTIONS");
    $display("----------------------------------------");
    
    op_code = 7'b0010011;
    funct3 = 3'b000;
    #10 check_outputs(16'h0);
    
    funct3 = 3'b111;
    #10 check_outputs(16'h0);
    
    funct3 = 3'b110;
    #10 check_outputs(16'h0);
    
    funct3 = 3'b100;
    #10 check_outputs(16'h0);
    
    $display("\n3. TESTING LOAD INSTRUCTIONS");
    $display("----------------------------------------");
    
    op_code = 7'b0000011;
    funct3 = 3'b010;
    #10 check_outputs(16'h0);
    
    $display("\n4. TESTING STORE INSTRUCTIONS");
    $display("----------------------------------------");
    
    op_code = 7'b0100011;
    funct3 = 3'b010;
    #10 check_outputs(16'h0);
    
    $display("\n5. TESTING BRANCH INSTRUCTIONS");
    $display("----------------------------------------");
    
    op_code = 7'b1100011;
    funct3 = 3'b000;
    #10 check_outputs(16'h0);
    
    $display("\n6. TESTING JUMP INSTRUCTIONS");
    $display("----------------------------------------");
    
    op_code = 7'b1101111;
    #10 check_outputs(16'h0);
    
    op_code = 7'b1100111;
    #10 check_outputs(16'h0);
    
    $display("\n7. TESTING LUI");
    $display("----------------------------------------");
    
    op_code = 7'b0110111;
    #10 check_outputs(16'h0);
    
    $display("\n========================================");
    $display("SIMULATION COMPLETE");
    $display("========================================\n");
    
    $finish;
end

initial begin
    $monitor("Time=%0t op=%b funct3=%b funct7=%b | src=%b m2r=%b regW=%b memR=%b memW=%b br=%b jmp=%b alu=%b imm=%b",
             $time, op_code, funct3, funct7,
             alu_src, mem_to_reg, reg_write, mem_read, mem_write,
             branch, jump, alu_ctrl, imm_src);
end

endmodule
`endif
