module riscv_cpu #(
    parameter WIDTH = 32
) (

    input wire clk,
    input wire reset,
    
    // Instruction memory interface
    output wire [WIDTH-1:0] instr_addr,
    input wire [WIDTH-1:0] instruction,
    
    // Data memory interface
    output wire [WIDTH-1:0] data_addr,
    output wire [WIDTH-1:0] data_write_data,
    input wire [WIDTH-1:0] data_read_data,
    output wire mem_read,
    output wire mem_write
);
    
    // Internal signals
    wire [WIDTH-1:0] pc_current;
    wire [WIDTH-1:0] pc_next;
    wire [WIDTH-1:0] pc_plus_4;
    wire [WIDTH-1:0] pc_branch_target;
    wire [WIDTH-1:0] pc_jump_target;
    
    // Control signals
    wire alu_src;
    wire mem_to_reg;
    wire reg_write;
    wire branch;
    wire jump;
    wire [2:0] alu_ctrl;
    wire [2:0] imm_src;
    wire alu_zero;
    wire is_lui = (instruction[6:0] == 7'b0110111);
    wire [WIDTH-1:0] lui_result = {instruction[31:12], 12'b0};

    // Register file signals
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd = instruction[11:7];
    wire [WIDTH-1:0] reg_rdata1;
    wire [WIDTH-1:0] reg_rdata2;
    
    // ALU signals
    wire [WIDTH-1:0] alu_input_b;
    wire [WIDTH-1:0] alu_result;
    
    // Immediate generator signal
    wire [WIDTH-1:0] imm_ext;
    
    // Write back signal
    wire [WIDTH-1:0] writeback_data;
    
    // Program Counter
    program_counter #(.WIDTH(WIDTH)) pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );
    
    assign instr_addr = pc_current;
    assign pc_plus_4 = pc_current + 32'd4;
    
    // Branch target calculation
    assign pc_branch_target = pc_current + imm_ext;
    
    // Jump target calculation
    assign pc_jump_target = pc_current + imm_ext;
    
    // Next PC logic
    assign pc_next = (jump) ? pc_jump_target :
                     (branch & alu_zero) ? pc_branch_target :
                     pc_plus_4;
    
    // Control Unit
    control_unit cu_inst (
        .op_code(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
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
    
    // Register File
    register_file #(.width(WIDTH)) regfile_inst (
        .we(reg_write),
        .clk(clk),
        .reset(reset),
        .addr1(rs1),
        .addr2(rs2),
        .addr3(rd),
        .wdata(writeback_data),
        .rdata1(reg_rdata1),
        .rdata2(reg_rdata2)
    );
    
    // Immediate Generator
    imm_gen immgen_inst (
        .instruction(instruction),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
    );
    
    // ALU input mux
    assign alu_input_b = alu_src ? imm_ext : reg_rdata2;
    
    // ALU
    ALU #(
        .ALU_WIDTH(3),
        .WIDTH(WIDTH)
    ) alu_inst (
        .a(reg_rdata1),
        .b(alu_input_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .alu_zero(alu_zero)
    );
    
    // Data memory interface
    assign data_addr = alu_result;
    assign data_write_data = reg_rdata2;
    
    // Write back mux - SINGLE driver with all logic combined
    assign writeback_data = is_lui ? lui_result : 
                            (mem_to_reg ? data_read_data : alu_result);
    
endmodule

// Program Counter module
module program_counter #(
    parameter WIDTH = 32
) (
    input wire clk,
    input wire reset,
    input wire [WIDTH-1:0] pc_next,
    output reg [WIDTH-1:0] pc_current
);
    
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            pc_current <= {WIDTH{1'b0}};
        end else begin
            pc_current <= pc_next;
        end
    end
    
endmodule

