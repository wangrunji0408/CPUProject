library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity FakeRam is
	port (
		addr: in u18;
		data: inout u16;
		read, write, enable: in std_logic
	) ;
end FakeRam;

architecture arch of FakeRam is	
	type TRam is array (20 downto 0) of u16;
	signal ram: TRam;
begin
	process( enable, read, write, addr )
	begin
		data <= (others => 'Z');
		if enable = '1' and rising_edge(write) then
			ram(to_integer(addr)) <= data after 1 ns;
		end if;
		if enable = '1' and falling_edge(read) then
			data <= (others => 'X');
		end if;
		if enable = '1' and read = '0' then
			data <= ram(to_integer(addr)) after 1 ns;
		end if;
	end process ;
end arch ; -- arch
