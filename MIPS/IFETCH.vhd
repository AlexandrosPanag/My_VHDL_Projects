-- ECE 3055 Computer Architecture and Operating Systems
--
-- MIPS Processor VHDL Behavioral Model
--
-- Ifetch module (provides the PC and instruction memory) 
-- 
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332
-- 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Ifetch IS
	PORT(	 SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	SIGNAL PC_plus_4_out	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	SIGNAL D_PC_plus_4_f : OUT STD_LOGIC_VECTOR( 9 DOWNTO 0 ); -- new, goes into ID for branching
        	SIGNAL Add_result 		 : IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	SIGNAL Branch 			    : IN 	STD_LOGIC;
        	SIGNAL branch_add_result : IN STD_LOGIC_VECTOR( 7 DOWNTO 0 ); -- new
        	SIGNAL Equal         : IN  STD_LOGIC; -- new, confirms beq
        	SIGNAL flush         : IN  STD_LOGIC; -- new
        	SIGNAL Zero 			      : IN 	STD_LOGIC;
      		 SIGNAL PC_out 			    : OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	SIGNAL clock, reset 	: IN 	STD_LOGIC);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
   TYPE INST_MEM IS ARRAY (0 to 12) of STD_LOGIC_VECTOR (31 DOWNTO 0); -- (edited)
   SIGNAL iram : INST_MEM := (
      --X"00000000",   -- nop
      --X"8C020000",   -- lw $2,0 ;memory(00)=55555555
      --X"8C030004",   -- lw $3,4 ;memory(04)=AAAAAAAA
      --X"00430820",   -- add $1,$2,$3
      --X"AC010008",   -- sw $1,3 ;memory(0C)=FFFFFFFF
      --X"1022FFFF",   -- beq $1,$2,-4  
      --X"1021FFFA"    -- beq $1,$1,-24 (Assume delay slot present, so it  
                     -- New PC = PC+4-24 = PC-20
                    
                     -- pipeline program:
        --X"00000000", -- nop
        --X"8C2A0014", -- lw  $10, 20($1), ($10 = 0x55555555) 
        --X"00435822", -- sub $11, $2, $3  ($11 = -1)
        --X"00646020", -- add $12, $3, $4  ($12 = 7)
        --X"8C2D0018", -- lw  $13, 24($1)  ($13 = 0xAAAAAAAA)
        --X"00A67020", -- add $14, $5, $6  ($14 = 11 = 0xB)
        --X"00000000", -- nop
        --X"00000000", -- nop
        --X"00000000", -- nop
        --X"00000000", -- nop
        --X"00000000"  -- I added enough extra instructions so the last non-nop instruction could be 
                     -- executed fully
      
      	   -- forwarding program
      X"00000000", -- nop
      X"00612024", -- and $4, $3, $1 ($4 = 0011&0001 = 1) 
      X"00244025", -- or  $8, $1, $4 ($4 = 0010|0001 = 3)
      X"00841822", -- sub $3, $4, $4 ($3 = 1 - 1 = 0)
      X"00832820", -- add $5, $4, $3 ($5 = 1 + 0 = 1)
      X"00C70824", -- and $1, $6, $7 ($1 = 0110&0111 = 0110 = 6)
      X"00000000", 
      X"00000000", 
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000"             
                                
                                -- branching test program
      --X"00000000",
      --X"10040002",  --         beq $0, $4, label1 (not taken)
      --X"00444020",  --         add $8, $2, $4     ($8 = 6)
      --X"00A12820",  --         add $5, $5, $1     ($5 = 6)
      --X"11050001",  -- label1: beq $8, $5, label2 (taken)
      --X"00A42822",  --         sub $5, $5, $4     (flushed)
      --X"10A6FFFF",  -- label2: beq $5, $6, label2 (taken - infinite loop)
      --X"1000FFFF",  -- label3: beq $0, $0, label3
      --X"00000000",
      --X"00000000",
      --X"00000000",
      --X"00000000",
      --X"00000000"
   );
    
	SIGNAL PC, PC_plus_4 	   : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL next_PC, Mem_Addr : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL D_Instruction     : STD_LOGIC_VECTOR(31 DOWNTO 0 );
	SIGNAL D_PC              : STD_LOGIC_VECTOR( 9 DOWNTO 0 ); -- may not need
	SIGNAL DD_PC_plus_4      : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL D_PC_plus_4       : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL DD_PC_plus_4_f    : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	
BEGIN 										
		PC(1 DOWNTO 0) <= "00";

		-- copy output signals - allows read inside module
		PC_out 			<= PC;
		PC_plus_4_out 	<= DD_PC_plus_4;
        
		-- send address to inst. memory address register
		Mem_Addr <= Next_PC;

		-- Adder to increment PC by 4 - (edited)      
     	DD_PC_plus_4( 9 DOWNTO 2 )  <= PC( 9 DOWNTO 2 ) + 1;
     	DD_PC_plus_4( 1 DOWNTO 0 )  <= "00";
			DD_PC_plus_4_f <= DD_PC_plus_4;
						
     	-- Mux to select Branch Address or PC + 4     
		--Next_PC  <= Add_result WHEN ( (Branch='1') AND ( Zero='1' ) ) ELSE
		Next_PC <= branch_add_result WHEN ((Branch = '1') AND (Equal = '1')) ELSE -- works for branching
                       X"00" WHEN Reset = '1' ELSE
  	          		   DD_PC_plus_4( 9 DOWNTO 2 );
  	          		   
	PROCESS
		BEGIN
			WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
			IF reset = '1' THEN
				   PC( 9 DOWNTO 2) <= "00000000";
			ELSE 
				   PC( 9 DOWNTO 2 ) <= next_PC;
			END IF;
			
			--IF flush = '1' THEN
			   --D_Instruction <= X"00000000";
			--ELSE 
			   D_Instruction <= iram(CONV_INTEGER(Mem_Addr));
			--END IF;
	END PROCESS;
	
	PROCESS
	BEGIN
	  -- pipelining
	  WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
	   IF flush = '1' THEN -- flushing IF/ID pipeline register
	     Instruction <= X"00000000";
	   ELSE
	     Instruction <= D_Instruction;
	   END IF;
	   
	   D_PC_plus_4 <= DD_PC_plus_4;
	   PC_plus_4 <= D_PC_plus_4;
	   
	   D_PC_plus_4_f <= DD_PC_plus_4_f;
	END PROCESS;
	
END behavior;


