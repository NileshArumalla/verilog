
// alu.v - ALU module

module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,       // operands
    input       [3:0] ALUControl,         // ALU control
    output reg  [WIDTH-1:0] alu_out,    // ALU output
    output      Zero                    // zero flag
);


always @(a, b, ALUControl) begin
    case (ALUControl)
        4'b0000:  alu_out <= a + b;       // ADD
        4'b0001:  alu_out <= a + ~b + 1;  // SUB
        4'b0010:  alu_out <= a & b;       // AND
        4'b0011:  alu_out <= a | b;       // OR
		  4'b1101:  alu_out <= ($unsigned(a) >= $unsigned(b) ? 1 : 0); //BGEU
        4'b0101:  begin		  // SLT
								if (a[31] != b[31]) begin
									 if (a[31] == 1'b1) begin
										  alu_out <= 1;   // a negative, b positive → a < b
									 end else begin
										  alu_out <= 0;   // a positive, b negative → a > b
									 end
								end else begin
									 // both have same sign, so just compare normally
									 if (a < b)
										  alu_out <= 1;
									 else
										  alu_out <= 0;
								end
//                     if (a[31] != b[31]) alu_out <= a[31] ? 0 : 1;
//                     else alu_out <= a < b ? 1 : 0;
                 end
			4'b1111:begin
					if ($unsigned(a) < $unsigned(b)) alu_out <= 1;
					else alu_out <= 0;	
		         end			
	     4'b0110: alu_out <= a ^ b;         // xor
        4'b0111: alu_out <= a >> b[4:0];   // srl
        4'b0100: alu_out <= a << b[4:0];   // sll
        4'b1000: alu_out <= a >>> b[4:0];  // sra
//		  4'b1001
        default: alu_out = 0;
    endcase
end

assign Zero = (alu_out == 0) ? 1'b1 : 1'b0;

endmodule

