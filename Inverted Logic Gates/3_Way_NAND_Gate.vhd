library IEEE;
use IEEE.std_logic_1164.all;

entity triplenandGate is

    port(A_inp : in std_logic;      -- First input
         B_inp : in std_logic;      -- Second input
         C_inp : in std_logic;      -- Third input
         Y_outp : out std_logic);   -- Output

end triplenandGate;


architecture triplenandLogic of triplenandGate is

 begin
    
    Y <= NOT(A AND B AND C);

end triplenandLogic;