module riscv_cpu_scalar_wrapper #(
    parameter WIDTH = 32
) (
    `ifdef USE_POWER_SUPPLY
        inout    vccd1,
        inout    vssd1,
    `endif 
    input wire clk,
    input wire reset,
    
    // Instruction memory interface - scalar ports
    output wire instr_addr_0, instr_addr_1, instr_addr_2, instr_addr_3,
    output wire instr_addr_4, instr_addr_5, instr_addr_6, instr_addr_7,
    output wire instr_addr_8, instr_addr_9, instr_addr_10, instr_addr_11,
    output wire instr_addr_12, instr_addr_13, instr_addr_14, instr_addr_15,
    output wire instr_addr_16, instr_addr_17, instr_addr_18, instr_addr_19,
    output wire instr_addr_20, instr_addr_21, instr_addr_22, instr_addr_23,
    output wire instr_addr_24, instr_addr_25, instr_addr_26, instr_addr_27,
    output wire instr_addr_28, instr_addr_29, instr_addr_30, instr_addr_31,
    
    input wire instruction_0, instruction_1, instruction_2, instruction_3,
    input wire instruction_4, instruction_5, instruction_6, instruction_7,
    input wire instruction_8, instruction_9, instruction_10, instruction_11,
    input wire instruction_12, instruction_13, instruction_14, instruction_15,
    input wire instruction_16, instruction_17, instruction_18, instruction_19,
    input wire instruction_20, instruction_21, instruction_22, instruction_23,
    input wire instruction_24, instruction_25, instruction_26, instruction_27,
    input wire instruction_28, instruction_29, instruction_30, instruction_31,
    
    // Data memory interface - scalar ports
    output wire data_addr_0, data_addr_1, data_addr_2, data_addr_3,
    output wire data_addr_4, data_addr_5, data_addr_6, data_addr_7,
    output wire data_addr_8, data_addr_9, data_addr_10, data_addr_11,
    output wire data_addr_12, data_addr_13, data_addr_14, data_addr_15,
    output wire data_addr_16, data_addr_17, data_addr_18, data_addr_19,
    output wire data_addr_20, data_addr_21, data_addr_22, data_addr_23,
    output wire data_addr_24, data_addr_25, data_addr_26, data_addr_27,
    output wire data_addr_28, data_addr_29, data_addr_30, data_addr_31,
    
    output wire data_write_data_0, data_write_data_1, data_write_data_2, data_write_data_3,
    output wire data_write_data_4, data_write_data_5, data_write_data_6, data_write_data_7,
    output wire data_write_data_8, data_write_data_9, data_write_data_10, data_write_data_11,
    output wire data_write_data_12, data_write_data_13, data_write_data_14, data_write_data_15,
    output wire data_write_data_16, data_write_data_17, data_write_data_18, data_write_data_19,
    output wire data_write_data_20, data_write_data_21, data_write_data_22, data_write_data_23,
    output wire data_write_data_24, data_write_data_25, data_write_data_26, data_write_data_27,
    output wire data_write_data_28, data_write_data_29, data_write_data_30, data_write_data_31,
    
    input wire data_read_data_0, data_read_data_1, data_read_data_2, data_read_data_3,
    input wire data_read_data_4, data_read_data_5, data_read_data_6, data_read_data_7,
    input wire data_read_data_8, data_read_data_9, data_read_data_10, data_read_data_11,
    input wire data_read_data_12, data_read_data_13, data_read_data_14, data_read_data_15,
    input wire data_read_data_16, data_read_data_17, data_read_data_18, data_read_data_19,
    input wire data_read_data_20, data_read_data_21, data_read_data_22, data_read_data_23,
    input wire data_read_data_24, data_read_data_25, data_read_data_26, data_read_data_27,
    input wire data_read_data_28, data_read_data_29, data_read_data_30, data_read_data_31,
    
    output wire mem_read,
    output wire mem_write
);

    // Internal signals for packed array connections
    wire [WIDTH-1:0] instr_addr_int;
    wire [WIDTH-1:0] instruction_int;
    wire [WIDTH-1:0] data_addr_int;
    wire [WIDTH-1:0] data_write_data_int;
    wire [WIDTH-1:0] data_read_data_int;

    // Instantiate the original CPU module
    riscv_cpu #(
        .WIDTH(WIDTH)
    ) cpu_inst (
        `ifdef USE_POWER_SUPPLY
            .vccd1(vccd1),
            .vssd1(vssd1),
        `endif
        .clk(clk),
        .reset(reset),
        
        // Instruction memory interface
        .instr_addr(instr_addr_int),
        .instruction(instruction_int),
        
        // Data memory interface
        .data_addr(data_addr_int),
        .data_write_data(data_write_data_int),
        .data_read_data(data_read_data_int),
        .mem_read(mem_read),
        .mem_write(mem_write)
    );

    // Connect packed array to scalar outputs
    assign instr_addr_0  = instr_addr_int[0];
    assign instr_addr_1  = instr_addr_int[1];
    assign instr_addr_2  = instr_addr_int[2];
    assign instr_addr_3  = instr_addr_int[3];
    assign instr_addr_4  = instr_addr_int[4];
    assign instr_addr_5  = instr_addr_int[5];
    assign instr_addr_6  = instr_addr_int[6];
    assign instr_addr_7  = instr_addr_int[7];
    assign instr_addr_8  = instr_addr_int[8];
    assign instr_addr_9  = instr_addr_int[9];
    assign instr_addr_10 = instr_addr_int[10];
    assign instr_addr_11 = instr_addr_int[11];
    assign instr_addr_12 = instr_addr_int[12];
    assign instr_addr_13 = instr_addr_int[13];
    assign instr_addr_14 = instr_addr_int[14];
    assign instr_addr_15 = instr_addr_int[15];
    assign instr_addr_16 = instr_addr_int[16];
    assign instr_addr_17 = instr_addr_int[17];
    assign instr_addr_18 = instr_addr_int[18];
    assign instr_addr_19 = instr_addr_int[19];
    assign instr_addr_20 = instr_addr_int[20];
    assign instr_addr_21 = instr_addr_int[21];
    assign instr_addr_22 = instr_addr_int[22];
    assign instr_addr_23 = instr_addr_int[23];
    assign instr_addr_24 = instr_addr_int[24];
    assign instr_addr_25 = instr_addr_int[25];
    assign instr_addr_26 = instr_addr_int[26];
    assign instr_addr_27 = instr_addr_int[27];
    assign instr_addr_28 = instr_addr_int[28];
    assign instr_addr_29 = instr_addr_int[29];
    assign instr_addr_30 = instr_addr_int[30];
    assign instr_addr_31 = instr_addr_int[31];

    // Connect scalar inputs to packed array
    assign instruction_int[0]  = instruction_0;
    assign instruction_int[1]  = instruction_1;
    assign instruction_int[2]  = instruction_2;
    assign instruction_int[3]  = instruction_3;
    assign instruction_int[4]  = instruction_4;
    assign instruction_int[5]  = instruction_5;
    assign instruction_int[6]  = instruction_6;
    assign instruction_int[7]  = instruction_7;
    assign instruction_int[8]  = instruction_8;
    assign instruction_int[9]  = instruction_9;
    assign instruction_int[10] = instruction_10;
    assign instruction_int[11] = instruction_11;
    assign instruction_int[12] = instruction_12;
    assign instruction_int[13] = instruction_13;
    assign instruction_int[14] = instruction_14;
    assign instruction_int[15] = instruction_15;
    assign instruction_int[16] = instruction_16;
    assign instruction_int[17] = instruction_17;
    assign instruction_int[18] = instruction_18;
    assign instruction_int[19] = instruction_19;
    assign instruction_int[20] = instruction_20;
    assign instruction_int[21] = instruction_21;
    assign instruction_int[22] = instruction_22;
    assign instruction_int[23] = instruction_23;
    assign instruction_int[24] = instruction_24;
    assign instruction_int[25] = instruction_25;
    assign instruction_int[26] = instruction_26;
    assign instruction_int[27] = instruction_27;
    assign instruction_int[28] = instruction_28;
    assign instruction_int[29] = instruction_29;
    assign instruction_int[30] = instruction_30;
    assign instruction_int[31] = instruction_31;

    // Connect data address outputs
    assign data_addr_0  = data_addr_int[0];
    assign data_addr_1  = data_addr_int[1];
    assign data_addr_2  = data_addr_int[2];
    assign data_addr_3  = data_addr_int[3];
    assign data_addr_4  = data_addr_int[4];
    assign data_addr_5  = data_addr_int[5];
    assign data_addr_6  = data_addr_int[6];
    assign data_addr_7  = data_addr_int[7];
    assign data_addr_8  = data_addr_int[8];
    assign data_addr_9  = data_addr_int[9];
    assign data_addr_10 = data_addr_int[10];
    assign data_addr_11 = data_addr_int[11];
    assign data_addr_12 = data_addr_int[12];
    assign data_addr_13 = data_addr_int[13];
    assign data_addr_14 = data_addr_int[14];
    assign data_addr_15 = data_addr_int[15];
    assign data_addr_16 = data_addr_int[16];
    assign data_addr_17 = data_addr_int[17];
    assign data_addr_18 = data_addr_int[18];
    assign data_addr_19 = data_addr_int[19];
    assign data_addr_20 = data_addr_int[20];
    assign data_addr_21 = data_addr_int[21];
    assign data_addr_22 = data_addr_int[22];
    assign data_addr_23 = data_addr_int[23];
    assign data_addr_24 = data_addr_int[24];
    assign data_addr_25 = data_addr_int[25];
    assign data_addr_26 = data_addr_int[26];
    assign data_addr_27 = data_addr_int[27];
    assign data_addr_28 = data_addr_int[28];
    assign data_addr_29 = data_addr_int[29];
    assign data_addr_30 = data_addr_int[30];
    assign data_addr_31 = data_addr_int[31];

    // Connect data write data outputs
    assign data_write_data_0  = data_write_data_int[0];
    assign data_write_data_1  = data_write_data_int[1];
    assign data_write_data_2  = data_write_data_int[2];
    assign data_write_data_3  = data_write_data_int[3];
    assign data_write_data_4  = data_write_data_int[4];
    assign data_write_data_5  = data_write_data_int[5];
    assign data_write_data_6  = data_write_data_int[6];
    assign data_write_data_7  = data_write_data_int[7];
    assign data_write_data_8  = data_write_data_int[8];
    assign data_write_data_9  = data_write_data_int[9];
    assign data_write_data_10 = data_write_data_int[10];
    assign data_write_data_11 = data_write_data_int[11];
    assign data_write_data_12 = data_write_data_int[12];
    assign data_write_data_13 = data_write_data_int[13];
    assign data_write_data_14 = data_write_data_int[14];
    assign data_write_data_15 = data_write_data_int[15];
    assign data_write_data_16 = data_write_data_int[16];
    assign data_write_data_17 = data_write_data_int[17];
    assign data_write_data_18 = data_write_data_int[18];
    assign data_write_data_19 = data_write_data_int[19];
    assign data_write_data_20 = data_write_data_int[20];
    assign data_write_data_21 = data_write_data_int[21];
    assign data_write_data_22 = data_write_data_int[22];
    assign data_write_data_23 = data_write_data_int[23];
    assign data_write_data_24 = data_write_data_int[24];
    assign data_write_data_25 = data_write_data_int[25];
    assign data_write_data_26 = data_write_data_int[26];
    assign data_write_data_27 = data_write_data_int[27];
    assign data_write_data_28 = data_write_data_int[28];
    assign data_write_data_29 = data_write_data_int[29];
    assign data_write_data_30 = data_write_data_int[30];
    assign data_write_data_31 = data_write_data_int[31];

    // Connect data read data inputs
    assign data_read_data_int[0]  = data_read_data_0;
    assign data_read_data_int[1]  = data_read_data_1;
    assign data_read_data_int[2]  = data_read_data_2;
    assign data_read_data_int[3]  = data_read_data_3;
    assign data_read_data_int[4]  = data_read_data_4;
    assign data_read_data_int[5]  = data_read_data_5;
    assign data_read_data_int[6]  = data_read_data_6;
    assign data_read_data_int[7]  = data_read_data_7;
    assign data_read_data_int[8]  = data_read_data_8;
    assign data_read_data_int[9]  = data_read_data_9;
    assign data_read_data_int[10] = data_read_data_10;
    assign data_read_data_int[11] = data_read_data_11;
    assign data_read_data_int[12] = data_read_data_12;
    assign data_read_data_int[13] = data_read_data_13;
    assign data_read_data_int[14] = data_read_data_14;
    assign data_read_data_int[15] = data_read_data_15;
    assign data_read_data_int[16] = data_read_data_16;
    assign data_read_data_int[17] = data_read_data_17;
    assign data_read_data_int[18] = data_read_data_18;
    assign data_read_data_int[19] = data_read_data_19;
    assign data_read_data_int[20] = data_read_data_20;
    assign data_read_data_int[21] = data_read_data_21;
    assign data_read_data_int[22] = data_read_data_22;
    assign data_read_data_int[23] = data_read_data_23;
    assign data_read_data_int[24] = data_read_data_24;
    assign data_read_data_int[25] = data_read_data_25;
    assign data_read_data_int[26] = data_read_data_26;
    assign data_read_data_int[27] = data_read_data_27;
    assign data_read_data_int[28] = data_read_data_28;
    assign data_read_data_int[29] = data_read_data_29;
    assign data_read_data_int[30] = data_read_data_30;
    assign data_read_data_int[31] = data_read_data_31;

endmodule
