library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity DCM is
	port ( 
		CLKIN_IN        : in    std_logic; 
		RST_IN          : in    std_logic; 
		CLKFX_OUT       : out   std_logic; 
		CLKIN_IBUFG_OUT : out   std_logic; 
		CLK0_OUT        : out   std_logic
	);
end DCM;

architecture mock of DCM is	

begin

end mock ; -- arch
