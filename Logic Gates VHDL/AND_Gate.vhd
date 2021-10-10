library IEEE;
use IEEE.std_logic_1164.all;

entity andGate is

    port(A_inp : in std_logic;      -- First input
         B_inp : in std_logic;      -- Second input
         Y_outp : out std_logic);   -- Output

end andGate;


architecture andLogic of andGate is

 begin
    
    Y <= A AND B;

end andLogic;