library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity ClkDiv is
	port (
		rst, clkin: in std_logic;
		clkout: buffer std_logic
	) ;
end ClkDiv;

architecture arch of ClkDiv is	
begin
	process( rst, clkin )
	begin
		if rst = '0' then
			clkout <= '1';
		elsif rising_edge(clkin) then
			clkout <= not clkout;
		end if;
	end process ; -- 
end arch ; -- arch
