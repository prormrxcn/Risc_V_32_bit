module register_file #(
    parameter width = 32 
) (
    input wire we, 
    input wire clk,
    input wire reset,  // ADD THIS
    input wire [4:0] addr1,
    input wire [4:0] addr2,
    input wire [4:0] addr3,
    input wire [width-1:0] wdata,
    output wire [width-1:0] rdata1,
    output wire [width-1:0] rdata2
);
    reg [width-1:0] register [0:31];
    
    // Initialize all registers to 0 on reset
    integer i;
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                register[i] <= {width{1'b0}};
            end
        end else if (we && addr3 != 0) begin
            register[addr3] <= wdata;
            $display("Time %0t: REGISTER WRITE x%0d = 0x%08h", $time, addr3, wdata);
        end
    end

    // Read ports (combinational)
    assign rdata1 = (addr1 != 0) ? register[addr1] : {width{1'b0}};
    assign rdata2 = (addr2 != 0) ? register[addr2] : {width{1'b0}};
    
endmodule

`ifdef SIMULATION

module tb_register_file();

    parameter width = 32;
    parameter CLK_PERIOD = 10; 
    
    reg                             clk;
    reg                             we;
    reg  [4:0]                      addr1;
    reg  [4:0]                      addr2;
    reg  [4:0]                      addr3;
    reg  [width-1:0]                wdata;
    wire [width-1:0]                rdata1;
    wire [width-1:0]                rdata2;
    reg reset;
    reg  [width-1:0]                expected_rdata1;
    reg  [width-1:0]                expected_rdata2;
    
    integer                         error_count = 0;
    integer                         test_count = 0;
    
    register_file #(
        .width(width)
    ) uut (
        .clk(clk),
        .we(we),
        .reset(reset),
        .addr1(addr1),
        .addr2(addr2),
        .addr3(addr3),
        .wdata(wdata),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );
    
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    initial begin
        we = 0;
        addr1 = 0;
        addr2 = 0;
        addr3 = 0;
        wdata = 0;
        
        #20;
        
        $display("==========================================================");
        $display("Starting RISC-V Register File Testbench");
        $display("==========================================================");
        $display("Time: %0t ns", $time);
        
        $display("\n[Test 1] Verifying x0 is hardwired to zero");
        test_count = test_count + 1;
        
        @(posedge clk);
        we = 1;
        addr3 = 0;
        wdata = 32'hDEADBEEF;
        addr1 = 0;  
        addr2 = 5;  
        
        @(posedge clk);
        #1; 
        
        check_output("x0 write ignored", 
                     0, rdata1, 
                     "x0 should remain 0 after write attempt");
        
        $display("\n[Test 2] Write to x1, read back");
        test_count = test_count + 1;
        
        @(posedge clk);
        we = 1;
        addr3 = 1;
        wdata = 32'hA5A5A5A5;
        addr1 = 1;
        addr2 = 2;  
        
        @(posedge clk);
        #1;
        
        check_output("x1 write/read", 
                     32'hA5A5A5A5, rdata1, 
                     "x1 should contain written value");
        
        $display("\n[Test 3] Write to multiple registers");
        
        @(posedge clk);
        addr3 = 2;
        wdata = 32'h12345678;
        addr1 = 2;
        addr2 = 1;  
        
        @(posedge clk);
        #1;
        test_count = test_count + 1;
        check_output("x2 write", 32'h12345678, rdata1, "x2 should be 0x12345678");
        
        test_count = test_count + 1;
        check_output("x1 retention", 32'hA5A5A5A5, rdata2, "x1 should retain previous value");
        
        $display("\n[Test 4] Boundary testing - x15 and x31");
        
        @(posedge clk);
        addr3 = 15;
        wdata = 32'hF0F0F0F0;
        addr1 = 15;
        
        @(posedge clk);
        #1;
        test_count = test_count + 1;
        check_output("x15 write", 32'hF0F0F0F0, rdata1, "x15 should be 0xF0F0F0F0");
        
        @(posedge clk);
        addr3 = 31;
        wdata = 32'h0F0F0F0F;
        addr1 = 31;
        
        @(posedge clk);
        #1;
        test_count = test_count + 1;
        check_output("x31 write", 32'h0F0F0F0F, rdata1, "x31 should be 0x0F0F0F0F");
        
        $display("\n[Test 5] Simultaneous read/write to same register");
        test_count = test_count + 1;
        
        @(posedge clk);
        we = 1;
        addr3 = 7;           
        wdata = 32'hBEEFCAFE;
        addr1 = 7;           
        addr2 = 15;          
        
        @(posedge clk);
        #1;
        
        check_output("simultaneous read/write (read old value)", 
                     32'h00000000, rdata1,  
                     "Read during write should return old value");
        
        @(posedge clk);
        we = 0;  
        addr1 = 7;
        
        @(posedge clk);
        #1;
        test_count = test_count + 1;
        check_output("verify write completed", 
                     32'hBEEFCAFE, rdata1, 
                     "x7 should now contain written value");
        
        $display("\n[Test 6] Write pattern to all 32 registers");
        
        for (int i = 1; i < 32; i++) begin
            @(posedge clk);
            we = 1;
            addr3 = i;
            wdata = i * 32'h01010101;  
            
            if (i > 1) begin
                addr1 = i-1;
                @(posedge clk);
                #1;
                test_count = test_count + 1;
                check_output($sformatf("x%0d retention", i-1), 
                             (i-1) * 32'h01010101, rdata1, 
                             $sformatf("x%0d should hold pattern", i-1));
            end
        end
        
        $display("\n[Test 7] Read back all registers");
        
        we = 0;  
        
        for (int i = 1; i < 32; i++) begin
            @(posedge clk);
            addr1 = i;
            @(posedge clk);
            #1;
            test_count = test_count + 1;
            check_output($sformatf("x%0d readback", i), 
                         i * 32'h01010101, rdata1, 
                         $sformatf("x%0d should retain pattern", i));
        end
        
        $display("\n[Test 8] Verify x0 still zero");
        test_count = test_count + 1;
        
        addr1 = 0;
        @(posedge clk);
        #1;
        check_output("x0 final check", 0, rdata1, "x0 should still be 0");
        
        $display("\n[Test 9] Random access stress test");
        
        repeat (50) begin
            @(posedge clk);
            we = $random;
            addr3 = $random % 32;
            wdata = $random;
            
            addr1 = $random % 32;
            addr2 = $random % 32;
            
            @(posedge clk);
            #1;
            
        end
        test_count = test_count + 50;
        
        #20;
        $display("\n==========================================================");
        $display("TEST COMPLETE");
        $display("Total tests: %0d", test_count);
        if (error_count == 0) begin
            $display("RESULT: ALL TESTS PASSED ✓");
        end else begin
            $display("RESULT: %0d TESTS FAILED ✗", error_count);
        end
        $display("==========================================================");
        
        #20;
        $finish;
    end
    
    task check_output;
        input [256:0] test_name;  
        input [31:0]  expected;
        input [31:0]  actual;
        input [256:0] message;
        begin
            if (expected === actual) begin
                $display("  ✓ %s: Expected 0x%08X, Got 0x%08X", 
                         test_name, expected, actual);
            end else begin
                $display("  ✗ %s: Expected 0x%08X, Got 0x%08X - %s", 
                         test_name, expected, actual, message);
                error_count = error_count + 1;
            end
        end
    endtask
    
endmodule
`endif
