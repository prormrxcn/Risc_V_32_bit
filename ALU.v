module ALU #( width = 32)
(
    input [width-1:0] a, b,
    input [3:0] alu_ctrl,
    input clk, rst,
    output logic [width-1:0] result ,
    output logic alu_zero
); 


    logic [width-1:0] a_reg, b_reg;
    logic [width-1:0] cla_a , cla_b , cla_results;
    logic cla_cin , cla_cout;

    CLa_32_bit #(.WIDTH(width)) sum (
        .a(cla_a),
        .b(cla_b),
        .SUM(cla_results),
        .Cin(cla_cin),
        .Cout(cla_cout)
    );

    typedef enum logic [3:0] { aDD , SUb , aND, ORR , XOR , SLL , SRL , SLT , SLTU , NOT} alu_ctrl_case;

    alu_ctrl_case alu_ctrl_reg;

    always_ff @(posedge clk or negedge rst) begin : blockName
        if(!rst)begin
            alu_ctrl_reg <= aDD;
            a_reg <= 0;
            b_reg <= 0;
        end else begin
            a_reg <= a;
            b_reg <= b;
            alu_ctrl_reg <= alu_ctrl_case'(alu_ctrl);
        end
    end

    always_comb begin : alu_block
    cla_a = '0;
    cla_b = '0;
    cla_cin = 0;
    result = '0;
        case (alu_ctrl_reg)
            aDD :  begin // add
                cla_a = a_reg;
                cla_b = b_reg;
                cla_cin = 1'b0;
                result = cla_results;
            end
            SUb : begin // sub
                cla_a = a_reg;
                cla_b = ~(b_reg);
                cla_cin = 1'b1;
                result = cla_results;
            end // 
            aND : begin
                result = a_reg & b_reg;
            end
            ORR : begin
                result = a_reg | b_reg;
            end
            XOR : begin
                result = a_reg ^ b_reg;
            end
            SLL : begin
                result = a_reg << b_reg[4:0];
            end
            SRL : begin
                result = a_reg >> b_reg[4:0];
            end
            SLT : begin
                cla_a = a_reg;
                cla_b = ~b_reg;
                cla_cin = 1'b1;
                result = {'0 , cla_results[width-1]^((a_reg[width - 1]^b_reg[width - 1]) & (cla_results[width - 1]^a_reg[width - 1]))};
            end
            SLTU : begin
                cla_a = a_reg;
                cla_b = ~b_reg;
                cla_cin = 1'b1;
                result = {'0 , ~cla_cout};
            end
            NOT : result = ~a_reg;
            default: ;
        endcase
        alu_zero = (result == 0);
    end

endmodule


module CLa_32_bit #(
    parameter WIDTH = 16
) (
    input logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             Cin,
    output logic [WIDTH-1:0] SUM,
    output logic             Cout
);
    logic [WIDTH/4:0] carry;
    assign carry[0] = Cin;
    generate
        for (genvar i = 0; i < WIDTH; i = i + 4) begin : cla_blocks
            CLa cla_inst_i (
                .a(a[i+3:i]),
                .b(b[i+3:i]),
                .Cin(carry[i/4]),
                .SUM(SUM[i+3:i]),
                .Cout(carry[i/4+1])
            );
        end
    endgenerate
    assign Cout = carry[WIDTH/4];
endmodule

module CLa #(
    parameter CLa_WIDTH = 4
) (
    input logic [CLa_WIDTH-1:0] a,
    input  logic [CLa_WIDTH-1:0] b,
    input  logic             Cin,
    output logic [CLa_WIDTH-1:0] SUM,
    output logic             Cout
);
    logic [CLa_WIDTH-1:0] P; // Pralu_ctrlagate
    logic [CLa_WIDTH-1:0] G; // Generate
    logic [CLa_WIDTH:0]   C; // Carry

    assign P = a ^ b;
    assign G = a & b;
    assign C[0] = Cin;

    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    assign C[4] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & C[0]);
    assign SUM = P ^ C[CLa_WIDTH-1:0];
    assign Cout = C[CLa_WIDTH];
endmodule


module alu_tb ();

reg [31:0] a , b;
reg [2:0] alu_ctrl;
wire alu_zero;
wire [31:0] result;

ALU dut(.*);

integer i;

initial begin
    a = 0;
    b = 0;
    $display("ALU_ZERO : %d " , alu_zero);
    #5 
    a = 10;
    b = 5;
    for ( i = 0 ; i < 8 ; i=i+1) begin
        alu_ctrl = i[2:0];
        #1
        $display("alu_ctrl : %d || a = %d || b = %d || result = %d", alu_ctrl , a , b , result );
    end
    #5
    a = 100;
    b = 150;
    for ( i = 0 ; i < 8 ; i=i+1) begin
        alu_ctrl = i[2:0];
        #1
        $display("alu_ctrl : %d || a = %d || b = %d || result = %d", alu_ctrl , a , b , result );
    end
    $finish;
end
    
endmodule