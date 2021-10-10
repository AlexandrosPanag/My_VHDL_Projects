library IEEE;
use IEEE.std_logic_1164.all;

entity xnorGate is

    port(A_inp : in std_logic;      -- First input
         B_inp : in std_logic;      -- Second input
         Y_outp : out std_logic);   -- Output

end xnorGate;


architecture norLogic of norGate is

 begin
    
    Y <= A XNOR B;

end xnorLogic;