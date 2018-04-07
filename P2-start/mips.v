////////////////////////////////////////////////////////////////
//  Filename     : mips.v
//  Module       : MIPS
//  Author       : L. Nazhand-Ali
//  Description  : single cycle MIPS 
//   
//     The top module of the single cycle MIPS is presented in this
//  file. You need to edit this module to complete the data path for
//  some of the instructions in your project.


module MIPS(clk, reset);

   input clk;
   input reset;

   // instruction and PC related wires
   wire [31:0] instruction;
   wire [31:0] PCplus4;
   wire [31:0] PC;
   
   // decoder related wires
   wire [5:0]  op, func;
   wire [4:0]  rs, rt, rd, shft;
   wire [15:0] imm16;
   wire [25:0] target;
   
   // control related wires
   wire        regWrite, regDst;
   wire        memRead, memWrite, memToReg;
   wire        extCntrl, ALUSrc;
   wire [3:0]  ALUCntrl;
   wire        branch, jump;

   // ALU related wires
   wire [31:0] A, B, ALUout;
   wire        zero;

   // register file related wires
   wire [31:0] regData2;
   wire [4:0]  regDstAddr;

   // immediate related wires
   wire [31:0] immExtended;
   
   // The addition of data memory wires
   wire [31:0] dMout, dMuxout;
   
   //Shift wires
   wire [31:0] shout, addresult, bmuxout, bnmuxo, andout, beqando;
   wire notbeqn, isBranchOut;

   ///////////////////////////////////////////////
   // Put your new wires below this line
   //For the lw and sw instructions, they use the data memory, so I added a data memory segement
   DMEM data_mem
	(
	    .data_out(dMout),
		.clk(clk),
		.writeCntrl_in(memWrite),
		.readCntrl_in(memRead),
		.address_in(ALUout),
		.writeData_in(regData2)
	);
   
   //Based on the single cycle datapath for lw and sw from the class slides,
   //lw and sw need a datamem and mux to handle the data mem output
   MUX32_2X1 datamemMUX 
     (
      .value_out(dMuxout),
      .value0_in(ALUout),
      .value1_in(dMout),
      .select_in(memToReg)
      );
    //Group 3
	//To impelment group three we need to add a shift left two and an and gate based off of the hw4 solution
	SHIFT2 twostep(
	.word_out(shout),
	.word_in(immExtended)
	);
	
	ADDER32 shfadd(
	.result_out(addresult),
	.a_in(PCplus4),
	.b_in(shout)
	);
	and isBranch(isBranchOut, branch, op[0]);
	and cntand(andout[0], zero, branch); //Cntrl and
	and aluand(beqando[0], notbeqn, isBranchOut); //bne alu and
    not notgate(notbeqn, zero);	
	
	MUX32_2X1 addmux(
	.value_out(bmuxout),
      .value0_in(PCplus4),
      .value1_in(addresult),
      .select_in(bnmuxo[0])
	  );
	  
	MUX32_2X1 andmux(
	.value_out(bnmuxo),
      .value0_in(andout),
      .value1_in(beqando),
      .select_in(op[0])
	  );
	
	
	
   //////////////////////////////////////////////
   

   // instantiation of instruction memory
   IMEM	imem
     (
      .instruction_out(instruction),
      .address_in(PC)
      );


   // instantiation of register file
   REG_FILE reg_file
     (
      .clk(clk),
      .data1_out(A),
      .data2_out(regData2),
      .readAddr1_in(rs),
      .readAddr2_in(rt),
      .writeAddr_in(regDstAddr),
      .writeData_in(dMuxout),
      .writeCntrl_in(regWrite)
      );

   // instantiation of PC register
   PC_REG pc_reg
     (
      .clk(clk),
      .reset(reset),
      .PC_out(PC),
      .PC_in(bmuxout)
      );

   // instantiation of the decoder
   MIPS_DECODE	mips_decode
     (
      .instruction_in(instruction), 
      .op_out(op), 
      .func_out(func), 
      .rs_out(rs), 
      .rt_out(rt), 
      .rd_out(rd), 
      .shft_out(shft), 
      .imm16_out(imm16), 
      .target_out(target)
      );

   // instantiation of the control unit
   MIPS_CONTROL mips_control
     (
      .op_in(op),
      .func_in(func),
      .branch_out(branch), 
      .regWrite_out(regWrite), 
      .regDst_out(regDst), 
      .extCntrl_out(extCntrl), 
      .ALUSrc_out(ALUSrc), 
      .ALUCntrl_out(ALUCntrl), 
      .memWrite_out(memWrite),
      .memRead_out(memRead),
      .memToReg_out(memToReg), 
      .jump_out(jump)
      );

   // instantiation of the ALU
   MIPS_ALU mips_alu
     (
      .ALUCntrl_in(ALUCntrl), 
      .A_in(A), 
      .B_in(B), 
      .ALU_out(ALUout), 
      .zero_out(zero)
      );

   // instantiation of the sign/zero extender
   EXTEND extend
     (
      .word_out(immExtended),
      .halfWord_in(imm16),
      .extendCntrl_in(extCntrl)
      );

   // instantiation of a 32-bit adder used for computing PC+4
   ADDER32 plus4Adder
     (
      .result_out(PCplus4),
      .a_in(32'd4), 
      .b_in(PC)
      );

   // instantiation of a 32-bit MUX used for selecting between immediate and register as the second source of ALU
   MUX32_2X1 aluMux
     (
      .value_out(B),
      .value0_in(regData2), 
      .value1_in(immExtended), 
      .select_in(ALUSrc)
      );

   // instantiation of a 5-bit MUX used for selecting between RT or RD as the destination address of the operation
   MUX5_2X1 regMUX 
     (
      .value_out(regDstAddr),
      .value0_in(rt),
      .value1_in(rd),
      .select_in(regDst)
      );

endmodule