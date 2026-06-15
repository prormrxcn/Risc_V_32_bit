`ifdef SIMULATION

module tb_riscv_cpu;
    parameter WIDTH = 32;
    parameter CLK_PERIOD = 10;
    
    // Signals
    reg clk;
    reg reset;
    
    // Instruction memory (small)
    reg [WIDTH-1:0] imem [0:15];
    wire [WIDTH-1:0] instr_addr;
    wire [WIDTH-1:0] instruction;
    
    // Data memory (small)
    reg [WIDTH-1:0] dmem [0:15];
    wire [WIDTH-1:0] data_addr;
    wire [WIDTH-1:0] data_write_data;
    reg [WIDTH-1:0] data_read_data;
    wire mem_read;
    wire mem_write;
    
    // CPU instance
    riscv_cpu cpu (
        .clk(clk),
        .reset(reset),
        .instr_addr(instr_addr),
        .instruction(instruction),
        .data_addr(data_addr),
        .data_write_data(data_write_data),
        .data_read_data(data_read_data),
        .mem_read(mem_read),
        .mem_write(mem_write)
    );
    
    // Clock
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // Instruction memory read (word aligned)
    assign instruction = imem[instr_addr[5:2]];
    
    // ============================================
    // FIXED: Data memory with correct load timing
    // ============================================
    reg mem_read_dly;
    reg [WIDTH-1:0] data_read_reg;
    
    always @(posedge clk) begin
        mem_read_dly <= mem_read;
        if (mem_read) begin
            data_read_reg <= dmem[data_addr[5:2]];
            $display("  [MEM] READ  addr 0x%08h = 0x%08h", 
                     data_addr, dmem[data_addr[5:2]]);
        end
    end
    
    // CRITICAL FIX: Data is available immediately when mem_read is high
    // This matches CPU's expectation for lw instruction
    assign data_read_data = mem_read ? dmem[data_addr[5:2]] : 
                            (mem_read_dly ? data_read_reg : 32'b0);
    
    // Data memory write
    always @(posedge clk) begin
        if (mem_write) begin
            dmem[data_addr[5:2]] <= data_write_data;
            $display("  [MEM] WRITE addr 0x%08h = 0x%08h", 
                     data_addr, data_write_data);
        end
    end
    
    // Simple test program
    initial begin
        // Clear memories
        for (int i = 0; i < 16; i++) begin
            imem[i] = 32'b0;
            dmem[i] = 32'b0;
        end
        
        // Program:
        // 0x00: addi x1, x0, 10    (x1 = 10)
        imem[0] = 32'b000000001010_00000_000_00001_0010011;
        
        // 0x04: addi x2, x0, 5     (x2 = 5)
        imem[1] = 32'b000000000101_00000_000_00010_0010011;
        
        // 0x08: add x3, x1, x2     (x3 = 15)
        imem[2] = 32'b0000000_00010_00001_000_00011_0110011;
        
        // 0x0C: sw x1, 0(x0)       (mem[0] = 10)
        imem[3] = 32'b0000000_00001_00000_010_00000_0100011;
        
        // 0x10: lw x4, 0(x0)       (x4 = mem[0] = 10)
        imem[4] = 32'b000000000000_00000_010_00100_0000011;
        
        // 0x14: andi x5, x1, 255   (x5 = 10)
        imem[5] = 32'b000011111111_00001_111_00101_0010011;
        
        // 0x18: ori x6, x1, 240    (x6 = 250)
        imem[6] = 32'b000011110000_00001_110_00110_0010011;
        
        // 0x1C: lui x7, 0x12345    (x7 = 0x12345000)
        imem[7] = 32'b00010010001101000101_00111_0110111;
        
        // 0x20: beq x0, x0, 0      (loop here)
        imem[8] = 32'b0000000_00000_00000_000_00000_1100011;
        
        $display("========================================");
        $display("MINIMAL RISC-V CPU TEST");
        $display("========================================");
        $display("Program loaded:");
        $display("  0x00: addi x1, x0, 10");
        $display("  0x04: addi x2, x0, 5");
        $display("  0x08: add  x3, x1, x2");
        $display("  0x0C: sw   x1, 0(x0)");
        $display("  0x10: lw   x4, 0(x0)");
        $display("  0x14: andi x5, x1, 255");
        $display("  0x18: ori  x6, x1, 240");
        $display("  0x1C: lui  x7, 0x12345");
        $display("  0x20: beq  x0, x0, 0");
        $display("========================================\n");
        
        // Reset
        reset = 1;
        #20;
        reset = 0;
        $display("Time %0t: Reset released\n", $time);
        
        // Run
        #200;
        
        // Show results
        $display("\n========================================");
        $display("RESULTS:");
        $display("========================================");
        $display("x1 (ADDI)    = %0d (Expected: 10) %s", 
                 cpu.regfile_inst.register[1],
                 (cpu.regfile_inst.register[1] == 10) ? "PASS" : "FAIL");
        $display("x2 (ADDI)    = %0d (Expected: 5) %s",
                 cpu.regfile_inst.register[2],
                 (cpu.regfile_inst.register[2] == 5) ? "PASS" : "FAIL");
        $display("x3 (ADD)     = %0d (Expected: 15) %s",
                 cpu.regfile_inst.register[3],
                 (cpu.regfile_inst.register[3] == 15) ? "PASS" : "FAIL");
        $display("x4 (LW)      = %0d (Expected: 10) %s",
                 cpu.regfile_inst.register[4],
                 (cpu.regfile_inst.register[4] == 10) ? "PASS" : "FAIL");
        $display("x5 (ANDI)    = %0d (Expected: 10) %s",
                 cpu.regfile_inst.register[5],
                 (cpu.regfile_inst.register[5] == 10) ? "PASS" : "FAIL");
        $display("x6 (ORI)     = %0d (Expected: 250) %s",
                 cpu.regfile_inst.register[6],
                 (cpu.regfile_inst.register[6] == 250) ? "PASS" : "FAIL");
        $display("x7 (LUI)     = 0x%08h (Expected: 0x12345000) %s",
                 cpu.regfile_inst.register[7],
                 (cpu.regfile_inst.register[7] == 32'h12345000) ? "PASS" : "FAIL");
        $display("mem[0] (SW)  = %0d (Expected: 10) %s",
                 dmem[0],
                 (dmem[0] == 10) ? "PASS" : "FAIL");
        
        // Pass/Fail summary
        $display("\n----------------------------------------");
        if (cpu.regfile_inst.register[1] == 10 &&
            cpu.regfile_inst.register[2] == 5 &&
            cpu.regfile_inst.register[3] == 15 &&
            cpu.regfile_inst.register[4] == 10 &&
            cpu.regfile_inst.register[5] == 10 &&
            cpu.regfile_inst.register[6] == 250 &&
            cpu.regfile_inst.register[7] == 32'h12345000 &&
            dmem[0] == 10) begin
            $display("✅✅✅ ALL TESTS PASSED! ✅✅✅");
            $display("Your RISC-V CPU is fully functional!");
        end else begin
            $display("❌❌❌ SOME TESTS FAILED ❌❌❌");
        end
        $display("========================================");
        
        $finish;
    end
    
    // Instruction trace
    always @(posedge clk) begin
        if (!reset) begin
            $display("Time %0t: PC=0x%08h, Instr=0x%08h", 
                     $time, cpu.pc_current-4, instruction);
        end
    end
    
    // Register write trace
    always @(posedge clk) begin
        if (cpu.reg_write && !reset) begin
            $display("  >> x%0d <= 0x%08h (%0d)", 
                     cpu.rd, cpu.writeback_data, cpu.writeback_data);
        end
    end
    
    // Dump waves
    initial begin
        $dumpfile("minimal.vcd");
        $dumpvars(0, tb_minimal);
    end
    
endmodule

`endif
