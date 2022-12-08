-- ECE 3055 Computer Architecture and Operating Systems
--
-- MIPS Processor VHDL Behavioral Model
--			
--  Idecode module (implements the register file)
--
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332
-- 
LIBRARY IEEE; 			
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Idecode IS
	  PORT(	read_data_1	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data_2	  : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Instruction   : IN 	 STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			D_PC_plus_4_f : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 ); -- for branching
			read_data 	   : IN 	 STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_result	   : IN 	 STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_in_A      : OUT  STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
			ALU_in_B      : OUT  STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
			ALU_Result_branch_f : IN STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- new, input to forwarding mux
			register_file_write_data : IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			D_register_file_write_data_branch_f : IN STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- new, one of inputs to forwarding mux
			RegWrite 	    : IN 	 STD_LOGIC;
			DD_RegWrite_f : IN   STD_LOGIC; -- new, forwarding logic
			D_RegWrite_f  : IN   STD_LOGIC; -- new, forwarding logic
			MemtoReg 	    : IN 	 STD_LOGIC;
			RegDst 		     : IN 	 STD_LOGIC;
			Branch        : IN   STD_LOGIC; -- new, controlling branching
			branch_add_result : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			Equal         : OUT  STD_LOGIC; -- new, for comparing 
			flush         : OUT  STD_LOGIC; -- new, when branching, flush next instruction
			--PC_plus_4     : IN   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend   : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			clock,reset	  : IN 	 STD_LOGIC );
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );

	SIGNAL register_array				          : register_file;
	SIGNAL write_register_address 	   	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_data				             	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_register_1_address	   	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL read_register_2_address	   	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_1	  	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_0	  	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL Instruction_immediate_value	: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	
	SIGNAL D_read_data_1, D_read_data_2: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL D_Sign_extend               : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL DDD_write_register_address  : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL DD_write_register_address   : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL D_write_register_address    : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	
	SIGNAL read_register_1_address_branch : STD_LOGIC_VECTOR( 4 DOWNTO 0 ); -- new, feeds into forwarding unit (IF/ID.Rs)
	SIGNAL read_register_2_address_branch : STD_LOGIC_VECTOR( 4 DOWNTO 0 ); -- new, feeds into forwarding unit (IF/ID.Rt)
	SIGNAL DD_write_register_address_branch : STD_LOGIC_VECTOR( 4 DOWNTO 0 ); -- new, goes into forwarding unit (ID/EX.Rd)
	SIGNAL D_write_register_address_branch : STD_LOGIC_VECTOR( 4 DOWNTO 0); -- new, goes into forwarding unit (EX/MEM.Rd)
  SIGNAL D_ALU_in_A : STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
  SIGNAL D_ALU_in_B : STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 	
  SIGNAL D_flush    : STD_LOGIC;
  
BEGIN
  	 read_register_1_address 	   <= Instruction( 25 DOWNTO 21 );
   	read_register_2_address 	   <= Instruction( 20 DOWNTO 16 );
   	read_register_1_address_branch <= Instruction( 25 DOWNTO 21 ); -- new, goes into forwarding
   	read_register_2_address_branch <= Instruction( 20 DOWNTO 16 ); -- new, goes into forwarding
   	write_register_address_1	   <= Instruction( 15 DOWNTO 11 );
   	write_register_address_0 	  <= Instruction( 20 DOWNTO 16 );
   	Instruction_immediate_value <= Instruction( 15 DOWNTO 0 );

   -- Read Register 1 Operation
	D_read_data_1 <= register_array( 
			      CONV_INTEGER( read_register_1_address ) );

	-- Read Register 2 Operation		 
	D_read_data_2 <= register_array( 
			      CONV_INTEGER( read_register_2_address ) );

	-- Mux for Register Write Address
  	DDD_write_register_address <= write_register_address_1 
			WHEN RegDst = '1'  			ELSE write_register_address_0;

	-- Mux to bypass data memory for Rformat instructions
	--write_data <= ALU_result( 31 DOWNTO 0 ) 
   --     	WHEN ( MemtoReg = '0' ) 	ELSE read_data;

	-- Sign Extend 16-bits to 32-bits
    	D_Sign_extend <= X"0000" & Instruction_immediate_value
		WHEN Instruction_immediate_value(15) = '0'
		ELSE	X"FFFF" & Instruction_immediate_value;

  -- forwarding mux to decide ALU input 1
  D_ALU_in_A <= ALU_Result_branch_f 
    WHEN (DD_RegWrite_f = '1' AND (DD_write_register_address_branch /= 0) AND (DD_write_register_address_branch = read_register_1_address_branch)) 
  ELSE 
  D_register_file_write_data_branch_f 
    WHEN (D_RegWrite_f = '1' 
          AND (D_write_register_address_branch /= 0) 
          --AND NOT(DD_RegWrite_f = '1' AND (DD_write_register_address_branch /= 0))
            --AND (DD_write_register_address_branch /= read_register_1_address_branch)
          AND (D_write_register_address_branch = read_register_1_address_branch))
  ELSE D_read_data_1;
    
  -- forwarding mux to decide ALU input 2
   D_ALU_in_B <= ALU_Result_branch_f 
    WHEN (DD_RegWrite_f = '1' AND (DD_write_register_address_branch /= 0) AND (DD_write_register_address_branch = read_register_2_address_branch)) 
  ELSE 
  D_register_file_write_data_branch_f
    WHEN (D_RegWrite_f = '1' 
          AND (D_write_register_address_branch /= 0) 
          --AND NOT(DD_RegWrite_f = '1' AND (DD_write_register_address_branch /= 0)) 
            --AND (DD_write_register_address_branch /= read_register_2_address_branch)
          AND (D_write_register_address_branch = read_register_2_address_branch))
  ELSE D_read_data_2;
   
  -- computes branch address  
    branch_add_result <= D_PC_plus_4_f( 9 DOWNTO 2 ) + D_Sign_extend( 7 DOWNTO 0 );
    Equal <= '1' WHEN (D_ALU_in_A = D_ALU_in_B) ELSE '0';
    flush <= '1' WHEN ((Branch = '1') AND (D_ALU_in_A = D_ALU_in_B)) ELSE '0';
    
PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT;
		IF reset = '1' AND clock = '1' THEN
			-- Initial register values on reset are register = reg#
			-- use loop to automatically generate reset logic 
			-- for all registers
			FOR i IN 0 TO 31 LOOP
				register_array(i) <= CONV_STD_LOGIC_VECTOR( i, 32 );
 			END LOOP;

		-- Write back to register - don't write to register 0
  		ELSIF RegWrite = '1' AND write_register_address /= 0 AND NOT(clock) = '1'THEN
		      --register_array( CONV_INTEGER( write_register_address)) <= write_data;
		      register_array( CONV_INTEGER( write_register_address)) <= register_file_write_data;
		END IF;
	END PROCESS;
	
	PROCESS
	BEGIN
	  -- pipelining
	  WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
	   --read_data_1 <= D_read_data_1;
	   --read_data_2 <= D_read_data_2;
	   Sign_extend <= D_Sign_extend;
	   DD_write_register_address <= DDD_write_register_address;
	   D_write_register_address <= DD_write_register_address;
	   write_register_address <= D_write_register_address;
	   
	   DD_write_register_address_branch <= DDD_write_register_address; -- for forwarding (ID/EX.Rd)
	   D_write_register_address_branch <= DD_write_register_address; -- for forwarding (EX/MEM.Rd)
	   ALU_in_A <= D_ALU_in_A;
	   ALU_in_B <= D_ALU_in_B;
	   
	END PROCESS;
END behavior;


