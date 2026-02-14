module alu_control (
    input      [1:0] ALUOp,
    input      [2:0] funct3,
    input      [6:0] funct7,
    output reg [2:0] ALUControl
);

    always @(*) begin

        case (ALUOp)

            // Load/Store/JALR/AUIPC
            2'b00: begin
                ALUControl = 3'b000; // ADD
            end

            // Branch
            2'b01: begin
                ALUControl = 3'b001; // SUB
            end

            // R-Type / I-Type ALU
            2'b10: begin
                case (funct3)

                    3'b000: begin
                        if (funct7[5] == 1'b1)
                            ALUControl = 3'b001; // SUB
                        else
                            ALUControl = 3'b000; // ADD
                    end

                    3'b111: ALUControl = 3'b010; // AND
                    3'b110: ALUControl = 3'b011; // OR
                    3'b100: ALUControl = 3'b100; // XOR
                    3'b010: ALUControl = 3'b101; // SLT

                    default: ALUControl = 3'b000;

                endcase
            end

            default: begin
                ALUControl = 3'b000;
            end

        endcase

    end

endmodule

