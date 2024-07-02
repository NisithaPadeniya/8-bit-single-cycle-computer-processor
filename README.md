# 8-bit-single-cycle-computer-processor
An 8-bit single cycle processor with an arithmetic logic unit (ALU), data memory, data cache, control logic, register file, instruction memory and instruction cache using ARM Assembly and Verilog HDL.

Simplified Digram
```
+-----------------+
|   Instruction   |           +-------+            +--------------+
|    Fetch (IF)   |  ----->   |       |   Load/    |              |
|      Stage      |           |  MEM  |   Store    |    Memory    |
+-----------------+           | Stage |   Access   |    Hierarchy |
                              |       |            |              |
+-----------------+           +-------+            +--------------+
| Instruction     |              |
|   Decode (ID)   |           +-------+
|      Stage      |  -------  |       |
+-----------------+           |  EX   |
                              | Stage |
+-----------------+           |       |
|    Execution    |           +-------+
|     (EX) Stage  |              |
+-----------------+              v
                                  |
+-----------------+           +-------+
|   Memory        |  <----    |       |
|   Access (MEM)  |           |  WB   |
|     Stage       |           | Stage |
+-----------------+           +-------+
```
