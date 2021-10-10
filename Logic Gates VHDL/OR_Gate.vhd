library IEEE;
use IEEE.std_logic_1164.all;

entity orGate is

    port(A_inp : in std_logic;      -- First input
         B_inp : in std_logic;      -- Second input
         Y_outp : out std_logic);   -- Output

end orGate;


architecture orLogic of orGate is

 begin
    
    Y <= A OR B;

end orLogic;
