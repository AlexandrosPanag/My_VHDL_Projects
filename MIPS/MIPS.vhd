-- ECE 3055 Computer Architecture and Operating Systems
--
-- MIPS Processor VHDL Behavioral Model
--				
-- Top Level Structural Model for MIPS Processor Core
--
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MIPS IS

	PORT( reset, clock					 : IN 	STD_LOGIC; 

		-- Output important signals to pins for easy display in Simulator
		PC						          : OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Branch_out, Zero_out, Memwrite_out, 
		Regwrite_out					     : OUT 	STD_LOGIC );
END 	MIPS;

ARCHITECTURE structure OF MIPS IS

	COMPONENT Ifetch
   	     PORT(	Instruction	 : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		PC_plus_4_out 		  : OUT STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        		D_PC_plus_4_f     : OUT STD_LOGIC_VECTOR( 9 DOWNTO 0 ); -- new, goes into ID for branching
        		Add_result 			    : IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        		Branch 				       : IN 	STD_LOGIC;
        		branch_add_result : IN STD_LOGIC_VECTOR( 7 DOWNTO 0 ); -- new
       	  Equal             : IN  STD_LOGIC; -- new, confirms beq
        	 flush             : IN  STD_LOGIC; -- new
        		Zero 				         : IN 	STD_LOGIC;
        		PC_out 				       : OUT STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        		clock,reset 		    : IN 	STD_LOGIC );
	END COMPONENT; 

	COMPONENT Idecode
 	     PORT(	read_data_1 	    : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		read_data_2 		      : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		Instruction 		      : IN 	 STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		D_PC_plus_4_f       : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 ); -- for branching
        		read_data 			       : IN 	 STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		ALU_result 			      : IN 	 STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		ALU_in_A            : OUT  STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- new
			    ALU_in_B            : OUT  STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- new
			    ALU_Result_branch_f : IN STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- new, input to forwarding mux
        		register_file_write_data : IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		D_register_file_write_data_branch_f : IN STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- new, one of inputs to forwarding mux
        		DD_RegWrite_f       : IN  STD_LOGIC; -- new, for forwarding logic
	        D_RegWrite_f        : IN  STD_LOGIC; -- new, for forwarding logic
        		RegWrite, MemtoReg 	: IN 	 STD_LOGIC;
        		RegDst 				         : IN 	 STD_LOGIC;
        		Branch              : IN   STD_LOGIC; -- new, controlling branching
        		branch_add_result   : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			    Equal               : OUT  STD_LOGIC; -- new, for comparing 
			    flush               : OUT  STD_LOGIC; -- new, when branching, flush next instruction
        		Sign_extend 		      : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		clock, reset		      : IN 	 STD_LOGIC );
	END COMPONENT;

	COMPONENT control
	     PORT( 	Opcode 				   : IN 	 STD_LOGIC_VECTOR( 5 DOWNTO 0 );
             	RegDst 				   : OUT 	STD_LOGIC;
             	ALUSrc 			   	: OUT 	STD_LOGIC;
             	MemtoReg 			  : OUT 	STD_LOGIC;
             	RegWrite 			  : OUT 	STD_LOGIC;
             	DD_RegWrite_f : OUT  STD_LOGIC; -- new, for forwarding logic
	            D_RegWrite_f  : OUT  STD_LOGIC; -- new, for forwarding logic
             	MemRead 			   : OUT 	STD_LOGIC;
             	MemWrite 			  : OUT 	STD_LOGIC;
             	Branch 				   : OUT 	STD_LOGIC;
             	ALUop 				    : OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
             	clock, reset		: IN 	 STD_LOGIC );
	END COMPONENT;

	COMPONENT  Execute
   	     PORT(	Read_data_1 		      : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
                Read_data_2 		     : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
                Read_data_2_branch_out  : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- (edited)
                ALU_in_A           : IN STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
			          ALU_in_B           : IN STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
               	Sign_Extend 		     : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Function_opcode		  : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
               	ALUOp 				         : IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
               	ALUSrc 				        : IN 	STD_LOGIC;
               	Zero 				          : OUT	STD_LOGIC;
               	ALU_Result 			     : OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	ALU_Result_branch_f : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- new, input to forwarding mux
               	Add_Result 			     : OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
               	PC_plus_4 			      : IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
               	clock, reset		     : IN 	STD_LOGIC );
	END COMPONENT;


	COMPONENT dmemory
	     PORT(	read_data 			      : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	        ALU_result            : IN   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	        ALU_result_branch_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0 );
        		address 			           : IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        		write_data 			        : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		MemtoReg              : IN STD_LOGIC;
         	register_file_write_data : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- new, decide writeback data here
         	D_register_file_write_data_branch_f : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- new, one of inputs to forwarding mux
        		MemRead, Memwrite 	   : IN 	STD_LOGIC;
        		Clock,reset			        : IN 	STD_LOGIC );
	END COMPONENT;

					-- declare signals used to connect VHDL components
				  -- (added a few for new signals)
	SIGNAL PC_plus_4 		  : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL read_data_1 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Read_data_2_branch_out: STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- (edited)
	SIGNAL Sign_Extend 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Add_result 		 : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL ALU_result 		 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL ALU_result_branch : STD_LOGIC_VECTOR( 31 DOWNTO 0);
	SIGNAL read_data 		  : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL ALUSrc 			    : STD_LOGIC;
	SIGNAL Branch 			    : STD_LOGIC;
	SIGNAL RegDst 			    : STD_LOGIC;
	SIGNAL Regwrite 		   : STD_LOGIC;
	SIGNAL Zero 			      : STD_LOGIC;
	SIGNAL MemWrite 		   : STD_LOGIC;
	SIGNAL MemtoReg 		   : STD_LOGIC;
	SIGNAL MemRead 			   : STD_LOGIC;
	SIGNAL ALUop 			     : STD_LOGIC_VECTOR(  1 DOWNTO 0 );
	SIGNAL Instruction		 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	
	SIGNAL ALU_in_A      : STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
	SIGNAL ALU_in_B      : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL DD_RegWrite_f : STD_LOGIC; -- new, for forwarding logic
  SIGNAL D_RegWrite_f  : STD_LOGIC; -- new, for forwarding logic
	SIGNAL register_file_write_data            : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL D_register_file_write_data_branch_f : STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- new, one of inputs to forwarding mux
	SIGNAL ALU_Result_branch_f : STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- new, input to forwarding mux
	SIGNAL branch_add_result   : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL Equal         : STD_LOGIC;
	SIGNAL flush         : STD_LOGIC;
	SIGNAL D_PC_plus_4_f : STD_LOGIC_VECTOR( 9 DOWNTO 0 ); -- new, goes into ID for branching
 
 -- SIGNAL write_register: STD_LOGIC_VECTOR( 4 DOWNTO 0 ); 
BEGIN
	-- copy important signals to output pins for easy 
	-- display in Simulator
   Instruction_out 	<= Instruction;
   ALU_result_out 	 <= ALU_result;
   --read_data_1_out 	<= read_data_1;
   read_data_1_out  <= ALU_in_A;
   --read_data_2_out 	<= read_data_2;
   read_data_2_out  <= ALU_in_B;
   write_data_out  	<= read_data WHEN MemtoReg = '1' ELSE ALU_result;
   Branch_out 		    <= Branch;
   Zero_out 		      <= Zero;
   RegWrite_out 	   <= RegWrite;
   MemWrite_out 	   <= MemWrite;	

  -- connect the 5 MIPS components   
  IFE : Ifetch
	PORT MAP (	Instruction  => Instruction,
    	    	PC_plus_4_out  	=> PC_plus_4,
    	    	D_PC_plus_4_f   => D_PC_plus_4_f,
				Add_result 		     => Add_result,
				Branch 			        => Branch,
				branch_add_result => branch_add_result,
   	    Equal             => Equal, 
      	 flush             => flush, 
				Zero 			          => Zero,
				PC_out 			        => PC,        		
				clock 			         => clock,  
				reset 			         => reset );

   ID : Idecode
   	PORT MAP (	read_data_1 	=> read_data_1,
        		read_data_2 	     => read_data_2,
        		Instruction 	     => Instruction,
        		D_PC_plus_4_f     => D_PC_plus_4_f, 
        		read_data 		      => read_data,
				ALU_result 		   => ALU_result_branch,
				ALU_in_A        => ALU_in_A, 
			  ALU_in_B        => ALU_in_B,
			  ALU_Result_branch_f      => ALU_Result_branch_f,
				register_file_write_data => register_file_write_data,
				D_register_file_write_data_branch_f => D_register_file_write_data_branch_f,
				RegWrite 		     => RegWrite,
				DD_RegWrite_f   => DD_RegWrite_f,
	      D_RegWrite_f    => D_RegWrite_f,
				MemtoReg 		     => MemtoReg,
				RegDst 		      	=> RegDst,
				Branch          => Branch,
				branch_add_result => branch_add_result,
     	  Equal             => Equal, 
      	 flush             => flush,
				Sign_extend 	     => Sign_Extend,
    		  clock 			         => clock,  
				reset 		         	=> reset );


   CTL:   control
	PORT MAP ( 	Opcode 		=> Instruction( 31 DOWNTO 26 ),
				RegDst 			     => RegDst,
				ALUSrc 			     => ALUSrc,
				MemtoReg 		    => MemtoReg,
				RegWrite 	  	  => RegWrite,
				DD_RegWrite_f  => DD_RegWrite_f,
	      D_RegWritef    => D_RegWrite_f,
				MemRead 		     => MemRead,
				MemWrite    	  => MemWrite,
				Branch 			     => Branch,
				ALUop 			      => ALUop,
        clock 	  	     => clock,
				reset 			      => reset );

   EXE:  Execute
  	PORT MAP (	Read_data_1 	 => read_data_1,
           	Read_data_2 	   => read_data_2,
           	Read_data_2_branch_out => Read_data_2_branch_out,
           	ALU_in_A        => ALU_in_A, 
			      ALU_in_B        => ALU_in_B,
				Sign_extend 	       => Sign_Extend,
          --  Function_opcode	=> Instruction( 5 DOWNTO 0 ),
				Function_opcode     => Sign_Extend( 5 DOWNTO 0 ),
				ALUOp 			           => ALUop,
				ALUSrc 			          => ALUSrc,
				Zero 			            => Zero,
        ALU_Result	    	    => ALU_Result,
        ALU_Result_branch_f => ALU_Result_branch_f,
				Add_Result 	   	    => Add_Result,
				PC_plus_4		         => PC_plus_4,
        Clock			            => clock,
				Reset			            => reset );

   MEM:  dmemory
	PORT MAP (	read_data 	   => read_data,
	      ALU_result         => ALU_Result,
	      ALU_result_branch_out => ALU_result_branch, 
				address 		         => ALU_Result (7 DOWNTO 0),
				-- write_data 		=> read_data_2, -- (edited)
				write_data         => Read_data_2_branch_out,
				MemtoReg           => MemtoReg,
       	register_file_write_data            => register_file_write_data,
       	D_register_file_write_data_branch_f => D_register_file_write_data_branch_f,
				MemRead 		   => MemRead, 
				Memwrite 		  => MemWrite, 
        clock 			    => clock,  
				reset 		    	=> reset );
END structure;

