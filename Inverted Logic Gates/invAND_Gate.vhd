library IEEE;
use IEEE.std_logic_1164.all;

entity invandGate is

    port(A_inp : in std_logic;      -- First input
         B_inp : in std_logic;      -- Second input
         Y_outp : out std_logic);   -- Output

end invandGate;


architecture invandLogic of invandGate is

 begin
    
    Y <= A NAND B;

end invandLogic;