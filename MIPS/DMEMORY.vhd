-- ECE 3055 Computer Architecture and Operating Systems
--
-- MIPS Processor VHDL Behavioral Model
--						
--  Dmemory module (implements the data
--  memory for the MIPS computer)
--
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332
-- 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY dmemory IS
	PORT(	read_data 			      : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	       ALU_result        : IN   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	       ALU_result_branch_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0 );
        	address 			        : IN  	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	write_data 			     : IN 	 STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	MemtoReg          : IN STD_LOGIC;
        	register_file_write_data : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- new, decide writeback data here
        	D_register_file_write_data_branch_f : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- new, one of inputs to forwarding mux
	   		MemRead, Memwrite 	: IN 	 STD_LOGIC;
            clock,reset		 	 : IN 	 STD_LOGIC );
END dmemory;

ARCHITECTURE behavior OF dmemory IS 
  TYPE DATA_RAM IS ARRAY (0 to 31) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL ram: DATA_RAM := ( 
      -- I didn't want to alter the memory structure, so a "word" here is really just a byte. 
      X"55", -- "word 1"
      X"55", -- 
      X"55",
      X"55", 
      X"AA", -- "word 5"
      X"AA",
      X"AA",
      X"AA",
      X"00", -- 
      X"00",
      X"00",
      X"00",
      X"00", -- 
      X"00",
      X"00",
      X"00",
      X"00", -- 
      X"00",
      X"00",
      X"00", -- 
      X"55", -- "word 21"
      X"55",
      X"55",
      X"55",
      X"55", -- 
      X"AA", -- "word 25"
      X"AA",
      X"AA",
      X"AA", -- 28
      X"00",
      X"00",
      X"00"
   );
   SIGNAL D_ALU_result_branch : STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
   SIGNAL D_read_data      : STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
   
   SIGNAL ram_read_data : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
   SIGNAL D_register_file_write_data : STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
  
   BEGIN
     
     --D_ALU_result_branch <= ALU_result; 
     
       PROCESS(clock, MemRead, Memwrite, address)
           BEGIN
               IF (clock = '0' and clock'EVENT) THEN
                   IF (MemRead = '1') THEN
                      --D_read_data (7 DOWNTO 0)   <= ram(CONV_INTEGER(address));
                      --D_read_data (15 DOWNTO 8)  <= ram(CONV_INTEGER(address+1));
                      --D_read_data (23 DOWNTO 16) <= ram(CONV_INTEGER(address+2));
                      --D_read_data (31 DOWNTO 24) <= ram(CONV_INTEGER(address+3));
                      ram_read_data (7 DOWNTO 0)   <= ram(CONV_INTEGER(address));
                      ram_read_data (15 DOWNTO 8)  <= ram(CONV_INTEGER(address+1));
                      ram_read_data (23 DOWNTO 16) <= ram(CONV_INTEGER(address+2));
                      ram_read_data (31 DOWNTO 24) <= ram(CONV_INTEGER(address+3));
                   ELSIF (Memwrite = '1') THEN
                      ram(CONV_INTEGER(address))   <= write_data (7 DOWNTO 0);
                      ram(CONV_INTEGER(address+1)) <= write_data (15 DOWNTO 8);
                      ram(CONV_INTEGER(address+2)) <= write_data (23 DOWNTO 16);
                      ram(CONV_INTEGER(address+3)) <= write_data (31 DOWNTO 24);   
                   END IF;
               END IF;               
       END PROCESS;

       -- new, moved WB mux here       
       D_register_file_write_data <= ALU_result( 31 DOWNTO 0 ) 
        	WHEN ( MemtoReg = '0' ) 	ELSE ram_read_data;
       D_register_file_write_data_branch_f <= ALU_result( 31 DOWNTO 0 )
         WHEN (MemtoReg = '0' )  ELSE ram_read_data;
       
  PROCESS
	BEGIN
	  -- pipelining
	  WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
	   --read_data <= D_read_data;
	   ALU_result_branch_out <= D_ALU_result_branch; 
	   
	   register_file_write_data <= D_register_file_write_data;
	END PROCESS;
   END behavior;
  

