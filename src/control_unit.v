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
