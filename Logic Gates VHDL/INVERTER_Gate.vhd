library IEEE;
use IEEE.std_logic_1164.all;

entity inverterGate is

    port(A_inp : in std_logic;      -- First input
         Y_outp : out std_logic);   -- Inverted Output

end inverterGate;


architecture inverterLogic of inverterGate is

 begin
    
    Y <= NOT A;

end inverterLogic;