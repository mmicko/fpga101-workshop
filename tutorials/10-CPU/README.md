# Grom-8 FPGA

This CPU implementation is made for purely educational purposes, in order to learn various constructs in Verilog.
It is far from perfect, but includes all needed features one CPU needs.

GROM-8 is simple 8-bit CPU, with :
* 4 general purpose registers
* 12 bit address bus and PC (program counter)
* Code and data segment registers (CS,DS) (4 bit)
* Stack pointer (SP) (12 bit)
* 8-bit ALU with C-carry, Z-zero and S-sign flags


Instruction set
================================

|7..4|3..2|1..0 |2nd   |Instruction  |
|----|----|-----|------|-------------|
|0000|dst |src  |      |MOV dst, src|
|0001|00  |reg  |      |ADD reg    			|
|0001|01  |reg  |      |SUB reg    			|
|0001|10  |reg  |      |ADC reg    			|
|0001|11  |reg  |      |SBC reg    			|
|0010|00  |reg  |      |AND reg    			|
|0010|01  |reg  |      |OR  reg    			|
|0010|10  |reg  |      |NOT reg    			|
|0010|11  |reg  |      |XOR reg    			|
|0011|00  |reg  |      |INC reg    			|
|0011|01  |reg  |      |DEC reg    			|
|0011|10  |reg  |      |CMP reg    			|
|0011|11  |reg  |      |TST reg    			|
|0100|00  |00   |      |SHL|
|0100|00  |01   |      |SHR|
|0100|00  |10   |      |SAL|
|0100|00  |11   |      |SAR|
|0100|01  |00   |      |ROL|
|0100|01  |01   |      |ROR|
|0100|01  |10   |      |RCL              	|
|0100|01  |11   |      |RCR             	|
|0100|10  |reg  |      |PUSH reg|
|0100|11  |reg  |      |POP reg|
|0101|dst |src  |      |LOAD dst, [src]|
|0110|dst |src  |      |STORE [dst], src|
|0111|00  |reg  |      |MOV CS, reg|
|0111|01  |reg  |      |MOV DS, reg|
|0111|10  |00   |      |PUSH CS|
|0111|10  |01   |      |PUSH DS|
|0111|10  |10   |      |???|
|0111|10  |11   |      |???|
|0111|11  |00   |      |???|
|0111|11  |01   |      |???|
|0111|11  |10   |      |RET|
|0111|11  |11   |      |HLT|
|1000|00  |00   |val   |JMP  val 			|
|1000|00  |01   |val   |JC   val 			|
|1000|00  |10   |val   |JNC  val 			|
|1000|00  |11   |val   |JM   val 			|
|1000|01  |00   |val   |JP   val 			|
|1000|01  |01   |val   |JZ   val 			|
|1000|01  |10   |val   |JNZ  val 			|
|1000|01  |11   |val   |???				|
|1000|10  |00   |val   |JR   val 			|
|1000|10  |01   |val   |JRC  val 			|
|1000|10  |10   |val   |JRNC val 			|
|1000|10  |11   |val   |JRM  val 			|
|1000|11  |00   |val   |JRP  val 			|
|1000|11  |01   |val   |JRZ  val 			|
|1000|11  |10   |val   |JRNZ val 			|
|1000|11  |11   |val   |???|
|1001|high|     |low   |JUMP addr|
|1010|high|     |low   |CALL addr|
|1011|high|     |low   |MOV SP,addr|
|1100|xx  |reg  |val   |IN reg,[val]|
|1101|xx  |reg  |val   |OUT [val],reg|
|1110|xx  |00   |val   |MOV CS,val|
|1110|xx  |01   |val   |MOV DS,val|
|1110|xx  |10   |val   |???|
|1110|xx  |11   |val   |???|
|1111|00  |reg  |val   |MOV reg, val|
|1111|01  |reg  |val   |LOAD reg, [val]|
|1111|10  |reg  |val   |STORE [val], reg|
|1111|11  |xx   |val   |???|
