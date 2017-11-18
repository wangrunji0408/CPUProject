library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity FontROM is
	port (
		clka : IN STD_LOGIC;
		addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
		douta : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
	) ;
end FontROM;

architecture mock of FontROM is	

begin

end mock ; -- arch
