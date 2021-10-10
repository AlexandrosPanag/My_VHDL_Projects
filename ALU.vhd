-- Execute module (implements the data ALU and Branch Address Adder
-- for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY ALU_MIPS IS
PORT(
Read_data_1 : IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
Read_data_2 : IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
Sign_extend : IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
Function_opcode : IN STD_LOGIC_VECTOR( 5 DOWNTO 0 );
ALUOp : IN STD_LOGIC_VECTOR( 1 DOWNTO 0 );
ALU_output_mux : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
ALU_Result : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
Add_Result : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
PC_plus_1 : IN STD_LOGIC_VECTOR( 7 DOWNTO 0 );
ALU_ctl : IN STD_LOGIC_VECTOR( 2 DOWNTO 0 );
clock, reset : IN STD_LOGIC );
END ALU_MIPS;

ARCHITECTURE behavior OF ALU_MIPS IS
signal result: std_logic_vector(31 downto 0);
SIGNAL Ainput, Binput : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Branch_Add : STD_LOGIC_VECTOR( 7 DOWNTO 0 );


BEGIN
Ainput <= Read_data_1; --declaring A input
Binput <= Read_data_2; --declaring B input



	
-- Adder to compute Branch Address
Branch_Add <= PC_plus_1( 7 DOWNTO 0 ) + Sign_extend( 1 DOWNTO 0 ) ;
Add_result <= Branch_Add( 7 DOWNTO 0 );

PROCESS ( ALU_ctl, Ainput, Binput )
BEGIN
-- Select ALU operation
CASE ALU_ctl IS
-- ALU performs ALUresult = A_input AND B_input
WHEN "000" => 
ALU_output_mux  <= Ainput AND Binput;

-- ALU performs ALUresult = A_input OR B_input
WHEN "001" => 
ALU_output_mux  <= Ainput OR Binput;

-- ALU performs ADD ALUresult = A_input + B_input
WHEN "010" => 
ALU_output_mux  <= Ainput + Binput;

-- ALU performs SUB ALUresult = A_input - B_input
WHEN "011" => 
ALU_output_mux  <= Ainput - Binput ;

-- ALU performs ALUresult = A_input XOR B_input
WHEN "100" => 
ALU_output_mux  <= Ainput NAND Binput;

-- ALU performs ALUresult = A_input NAND B_input
WHEN "101" => 
ALU_output_mux  <= Ainput XOR Binput;

-- ALU performs ALUresult = A_Input XNOR B_INPUT
WHEN "110" => 
ALU_output_mux  <= Ainput XNOR Binput;           

-- ALU performs SLT
WHEN "111" =>	ALU_output_mux 	<= Ainput - Binput ;
 	 	WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;


END CASE;
END PROCESS;
END behavior;