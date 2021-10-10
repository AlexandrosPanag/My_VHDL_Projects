library IEEE;
use IEEE.std_logic_1164.all;

entity xorGate is

    port(A_inp : in std_logic;      -- First input
         B_inp : in std_logic;      -- Second input
         Y_outp : out std_logic);   -- Output

end xorGate;


architecture xorLogic of xorGate is

 begin
    
    Y <= A XOR B;

end xorLogic;