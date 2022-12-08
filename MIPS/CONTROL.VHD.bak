-- ECE 3055 Computer Architecture and Operating Systems
--
-- MIPS Processor VHDL Behavioral Model
--		
-- control module (implements MIPS control unit)
--
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332
-- 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 	
	SIGNAL Opcode 		    : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	SIGNAL RegDst 		    : OUT 	STD_LOGIC;
	SIGNAL ALUSrc 		    : OUT 	STD_LOGIC;
	SIGNAL MemtoReg 	   : OUT 	STD_LOGIC;
	SIGNAL RegWrite 	   : OUT 	STD_LOGIC;
	SIGNAL DD_RegWrite_f : OUT STD_LOGIC; -- new, for forwarding logic
	SIGNAL D_RegWrite_f : OUT STD_LOGIC; -- new, for forwarding logic
	SIGNAL MemRead 		   : OUT 	STD_LOGIC;
	SIGNAL MemWrite 	   : OUT 	STD_LOGIC;
	SIGNAL Branch 		    : OUT 	STD_LOGIC;
	SIGNAL ALUop 		     : OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 ); 
	SIGNAL clock, reset	: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, Lw, Sw, Beq 	            : STD_LOGIC;
	
	-- As per suggested convention, pipelined signals are prefixed with one, two, or three D's 
	-- depending on how many pipeline registers they go through. This is the convention followed
	-- in ALL modules. 
	SIGNAL  D_ALUSrc                           : STD_LOGIC;
	--SIGNAL  D_RegDst                           : STD_LOGIC;
	SIGNAL  D_ALUOp                            : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL  DD_Branch, DD_MemWrite, DD_MemRead : STD_LOGIC;
	SIGNAL  D_Branch, D_MemWrite, D_MemRead    : STD_LOGIC;
	SIGNAL  DDD_RegWrite, DDD_MemtoReg         : STD_LOGIC;
	SIGNAL  DD_RegWrite, DD_MemtoReg           : STD_LOGIC;
	SIGNAL  D_RegWrite, D_MemtoReg             : STD_LOGIC;

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	   <=  '1'  WHEN  Opcode = "000000"  ELSE '0';
	Lw           <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw           <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
  Beq          <=  '1'  WHEN  Opcode = "000100"  ELSE '0';
  --D_RegDst    	  <=  R_format;
  RegDst         <=  R_format;
 	D_ALUSrc  	    <=  Lw OR Sw;
	--DDD_MemtoReg 	   <=  Lw;
	DD_MemtoReg    <= Lw;
  DDD_RegWrite 	   <=  R_format OR Lw;
  DD_MemRead 	    <=  Lw;
  DD_MemWrite  	  <=  Sw; 
 	--DD_Branch       <=  Beq;
 	Branch <= Beq;
	D_ALUOp( 1 ) 	 <=  R_format;
	D_ALUOp( 0 ) 	 <=  Beq; 
	
PROCESS
	BEGIN
	  WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
	  -- Synchronous reset for control signals
	  If (reset = '1') THEN
	    ALUSrc <= '0';
	    --DD_MemtoReg <= '0';
	    D_MemtoReg <= '0';
	    MemtoReg <= '0';
	    DD_RegWrite <= '0';
	    D_RegWrite <= '0';
	    RegWrite <= '0';
	    D_MemRead <= '0';
	    MemRead <= '0';
	    D_MemWrite <= '0';
	    MemWrite <= '0';
	    --D_Branch <= '0';
	    --Branch <= '0';
	    ALUop <= "00";
	  ELSE  
	   -- pipelining: 
	   -- EX control signals
	   --RegDst <= D_RegDst;
	   ALUSrc <= D_ALUSrc;
	   ALUop <= D_ALUOp;
	   
	   -- MEM control signals
	   --D_Branch <= DD_Branch;
	   --Branch <= D_Branch;
	   D_MemWrite <= DD_MemWrite;
	   MemWrite <= D_MemWrite;
	   D_MemRead <= DD_MemRead;
	   MemRead <= D_MemRead;
	   
	   -- WB control signals
	   --DD_MemtoReg <= DDD_MemtoReg;
	   D_MemtoReg <= DD_MemtoReg;
	   MemtoReg <= D_MemtoReg;
	   DD_RegWrite <= DDD_RegWrite;
	   DD_RegWrite_f <= DDD_RegWrite; -- new
	   D_RegWrite <= DD_RegWrite;
	   D_RegWrite_f <= DD_RegWrite; -- new
	   RegWrite <= D_RegWrite;
	  END IF;
END PROCESS;
	
END behavior;


