# My VHDL Projects
VHDL (VHSIC Hardware Description Language) is becoming increasingly popular as a way to capture complex digital electronic circuits for both simulation and synthesis. Digital circuits captured using VHDL can be easily simulated, are more likely to be synthesizable into multiple target technologies, and can be archived for later modification and reuse.
In his introduction to A VHDL Primer (Prentice Hall, 1992), Jayaram Bhasker writes, "VHDL is a large and complex language with many complex constructs that have complex semantic meanings...". This statement, with its possibly record-breaking three instances of the word "complex", reflects a common and for the most part correct perception about VHDL: it is a large and complicated language.

VHDL is a rich and powerful language. But is VHDL really so hard to learn and use? VHDL is not impenetrable, if you follow well-established coding conventions and borrow liberally from sample circuits such as those found in this introduction.

Compiler (IDE) used / programs were tested on : https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/download.html
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALU
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


With VHDL, we can build an ALU Operator that given with the right signs can perform the following actions : with "000" it can perform ADD logical operation, with "001" it can perform OR logical operation , with "010" it can perform the ADD which adds the signs, with "011" it can perform subtraction between the two signs, with "100" it can perform NAND logical operation, with "101" it can perform XOR Operation, with "110" XNOR Logical operation and with "111" ALU performs SLT operation. ALU Program can also be extended in order to build an entire MIPS Processor with the right additional tools.
