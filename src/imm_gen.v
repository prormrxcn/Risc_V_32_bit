module imm_gen(
    input wire [31:0] instruction,
    input wire [2:0] imm_src,  // Now 3 bits
    output reg [31:0] imm_ext
);
    
    always @(*) begin
        case(imm_src)
            3'b001: // I-type
                imm_ext = {{20{instruction[31]}}, instruction[31:20]};

            3'b010: // S-type
                imm_ext = {{20{instruction[31]}}, 
                          instruction[31:25], instruction[11:7]};
            
            3'b011: // B-type
                imm_ext = {{20{instruction[31]}}, 
                          instruction[7], instruction[30:25], 
                          instruction[11:8], 1'b0};
            
            3'b100: // J-type
                imm_ext = {{12{instruction[31]}}, 
                          instruction[19:12], instruction[20], 
                          instruction[30:21], 1'b0};
            
            3'b101: // U-type (LUI, AUIPC)
                imm_ext = {instruction[31:12], 12'b0};  
            
            default: // 3'b000 or others
                imm_ext = 32'b0;
        endcase
    end
    
endmodule
