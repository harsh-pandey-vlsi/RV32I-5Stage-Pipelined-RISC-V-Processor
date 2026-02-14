# RV32I 5-Stage Pipelined RISC-V Processor

## Overview

This project implements a **32-bit RV32I 5-stage pipelined RISC-V processor** in synthesizable Verilog. The design follows a classical pipeline architecture with stage isolation and control signal propagation across pipeline registers.

The processor is verified using a SystemVerilog testbench with waveform-based validation.

> Phase 3 Implementation — Structural pipelining (no hazard handling).

---

## Architecture

### Pipeline Stages

- **IF** – Instruction Fetch  
- **ID** – Decode + Register Read + Immediate Generation  
- **EX** – ALU + Branch Logic  
- **MEM** – Data Memory Access  
- **WB** – Write Back  

Pipeline registers:
- IF/ID  
- ID/EX  
- EX/MEM  
- MEM/WB  

---

## Supported Instructions (RV32I Subset)

**R-Type:** ADD, SUB, AND, OR, XOR, SLT  
**I-Type:** ADDI, ANDI, ORI, LW, JALR  
**S-Type:** SW  
**B-Type:** BEQ, BNE  
**U-Type:** LUI, AUIPC  
**J-Type:** JAL  

---

## Key Design Features

- Fully synthesizable Verilog RTL  
- Modular stage-based design  
- Control signal propagation across pipeline  
- Signed comparison (SLT) support  
- Harvard-style memory separation  
- SystemVerilog self-checking testbench  
- Waveform-validated pipeline timing  

---

## Pipeline Behavior

Instruction overlap example:

Cycle 1: I1 IF
Cycle 2: I1 ID | I2 IF
Cycle 3: I1 EX | I2 ID | I3 IF
Cycle 4: I1 MEM| I2 EX | I3 ID | I4 IF
Cycle 5: I1 WB | I2 MEM| I3 EX | I4 ID | I5 IF


Throughput: **1 instruction per cycle**  
Latency: **5 cycles per instruction**

---

## Simulation

Supported simulators:
- Questa / ModelSim  
- Riviera  
- EDA Playground  

Waveform signals to inspect:
- `pc`
- `if_id_instr`
- `id_ex_rd`
- `ex_mem_rd`
- `mem_wb_rd`
- `write_back_data`
- `rf.regs[x]`

---

## Limitations

- No data hazard detection  
- No forwarding unit  
- No load-use stall logic  
- No branch flush  

Programs must avoid RAW dependencies.

---

Author

Harsh Pandey
Electronics & Communication Engineering

