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
