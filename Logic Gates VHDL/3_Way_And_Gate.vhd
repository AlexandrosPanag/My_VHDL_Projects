library IEEE;
use IEEE.std_logic_1164.all;

entity tripleandGate is

    port(A_inp : in std_logic;      -- First input
         B_inp : in std_logic;      -- Second input
         C_inp : in std_logic;      -- Third input
         Y_outp : out std_logic);   -- Output

end tripleandGate;


architecture tripleandLogic of tripleandGate is

 begin
    
    Y <= A AND B AND C;

end tripleandLogic;