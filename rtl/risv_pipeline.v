module riscv_pipeline (
    input clk,
    input rst
);

    // =========================
    // Global Wires (declare once)
    // =========================

    wire [31:0] pc, pc_next, instr;

    wire [31:0] if_id_pc, if_id_instr;

    wire [31:0] id_ex_pc, id_ex_rd1, id_ex_rd2, id_ex_imm;
    wire [4:0]  id_ex_rs1, id_ex_rs2, id_ex_rd;
    wire [2:0]  id_ex_funct3;
    wire [6:0]  id_ex_funct7;
    wire        id_ex_RegWrite, id_ex_MemRead, id_ex_MemWrite;
    wire        id_ex_MemToReg, id_ex_ALUSrc;
    wire        id_ex_Branch, id_ex_Jump;
    wire [1:0]  id_ex_ALUOp;

    wire [31:0] ex_mem_alu_result, ex_mem_rd2;
    wire [4:0]  ex_mem_rd;
    wire        ex_mem_RegWrite, ex_mem_MemRead;
    wire        ex_mem_MemWrite, ex_mem_MemToReg;

    wire [31:0] mem_wb_mem_data, mem_wb_alu_result;
    wire [4:0]  mem_wb_rd;
    wire        mem_wb_RegWrite, mem_wb_MemToReg;

    wire [31:0] write_back_data;

    // =========================
    // IF STAGE
    // =========================

    pc pc_inst (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc)
    );

    instr_mem imem (
        .addr(pc),
        .instr(instr)
    );

    assign pc_next = pc + 4;

    if_id if_id_reg (
        .clk(clk),
        .rst(rst),
        .pc_in(pc),
        .instr_in(instr),
        .pc_out(if_id_pc),
        .instr_out(if_id_instr)
    );

    // =========================
    // ID STAGE
    // =========================

    wire [6:0] opcode = if_id_instr[6:0];
    wire [4:0] rs1 = if_id_instr[19:15];
    wire [4:0] rs2 = if_id_instr[24:20];
    wire [4:0] rd  = if_id_instr[11:7];
    wire [2:0] funct3 = if_id_instr[14:12];
    wire [6:0] funct7 = if_id_instr[31:25];

    wire RegWrite, MemRead, MemWrite, MemToReg;
    wire ALUSrc, Branch, Jump;
    wire [1:0] ALUOp;

    control_unit ctrl (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .ALUSrc(ALUSrc),
        .Branch(Branch),
        .Jump(Jump),
        .ALUOp(ALUOp)
    );

    wire [31:0] rd1, rd2;

    reg_file rf (
        .clk(clk),
        .we(mem_wb_RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(mem_wb_rd),
        .wd(write_back_data),
        .rd1(rd1),
        .rd2(rd2)
    );

    wire [31:0] imm_out;

    imm_gen imm (
        .instr(if_id_instr),
        .imm_out(imm_out)
    );

    id_ex id_ex_reg (
        .clk(clk),
        .rst(rst),
        .pc_in(if_id_pc),
        .rd1_in(rd1),
        .rd2_in(rd2),
        .imm_in(imm_out),
        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd),
        .funct3_in(funct3),
        .funct7_in(funct7),
        .RegWrite_in(RegWrite),
        .MemRead_in(MemRead),
        .MemWrite_in(MemWrite),
        .MemToReg_in(MemToReg),
        .ALUSrc_in(ALUSrc),
        .Branch_in(Branch),
        .Jump_in(Jump),
        .ALUOp_in(ALUOp),
        .pc_out(id_ex_pc),
        .rd1_out(id_ex_rd1),
        .rd2_out(id_ex_rd2),
        .imm_out(id_ex_imm),
        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),
        .rd_out(id_ex_rd),
        .funct3_out(id_ex_funct3),
        .funct7_out(id_ex_funct7),
        .RegWrite_out(id_ex_RegWrite),
        .MemRead_out(id_ex_MemRead),
        .MemWrite_out(id_ex_MemWrite),
        .MemToReg_out(id_ex_MemToReg),
        .ALUSrc_out(id_ex_ALUSrc),
        .Branch_out(id_ex_Branch),
        .Jump_out(id_ex_Jump),
        .ALUOp_out(id_ex_ALUOp)
    );

    // =========================
    // EX STAGE
    // =========================

    wire [2:0] ALUControl;

    alu_control alu_ctrl (
        .ALUOp(id_ex_ALUOp),
        .funct3(id_ex_funct3),
        .funct7(id_ex_funct7),
        .ALUControl(ALUControl)
    );

    wire [31:0] alu_in2 =
        (id_ex_ALUSrc) ? id_ex_imm : id_ex_rd2;

    wire [31:0] alu_result;
    wire zero;

    alu alu_inst (
        .a(id_ex_rd1),
        .b(alu_in2),
        .alu_ctrl(ALUControl),
        .result(alu_result),
        .zero(zero)
    );

    ex_mem ex_mem_reg (
        .clk(clk),
        .rst(rst),
        .alu_result_in(alu_result),
        .zero_in(zero),
        .rd2_in(id_ex_rd2),
        .rd_in(id_ex_rd),
        .RegWrite_in(id_ex_RegWrite),
        .MemRead_in(id_ex_MemRead),
        .MemWrite_in(id_ex_MemWrite),
        .MemToReg_in(id_ex_MemToReg),
        .Branch_in(id_ex_Branch),
        .Jump_in(id_ex_Jump),
        .alu_result_out(ex_mem_alu_result),
        .zero_out(),
        .rd2_out(ex_mem_rd2),
        .rd_out(ex_mem_rd),
        .RegWrite_out(ex_mem_RegWrite),
        .MemRead_out(ex_mem_MemRead),
        .MemWrite_out(ex_mem_MemWrite),
        .MemToReg_out(ex_mem_MemToReg),
        .Branch_out(),
        .Jump_out()
    );

    // =========================
    // MEM STAGE
    // =========================

    wire [31:0] mem_read_data;

    data_mem dmem (
        .clk(clk),
        .MemRead(ex_mem_MemRead),
        .MemWrite(ex_mem_MemWrite),
        .addr(ex_mem_alu_result),
        .write_data(ex_mem_rd2),
        .read_data(mem_read_data)
    );

    mem_wb mem_wb_reg (
        .clk(clk),
        .rst(rst),
        .mem_data_in(mem_read_data),
        .alu_result_in(ex_mem_alu_result),
        .rd_in(ex_mem_rd),
        .RegWrite_in(ex_mem_RegWrite),
        .MemToReg_in(ex_mem_MemToReg),
        .mem_data_out(mem_wb_mem_data),
        .alu_result_out(mem_wb_alu_result),
        .rd_out(mem_wb_rd),
        .RegWrite_out(mem_wb_RegWrite),
        .MemToReg_out(mem_wb_MemToReg)
    );

    // =========================
    // WB STAGE
    // =========================

    assign write_back_data =
        (mem_wb_MemToReg) ?
            mem_wb_mem_data :
            mem_wb_alu_result;

endmodule
