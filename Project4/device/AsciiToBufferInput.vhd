library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity AsciiToBufferInput is
	port (
		rst, asciiNew: in std_logic;
		asciiCode: in std_logic_vector(6 downto 0);
		byteMode: in std_logic;
		write: out std_logic;
		data_write: buffer u8
	) ;
end AsciiToBufferInput;

architecture arch of AsciiToBufferInput is
	signal buf: u4;
	signal high: std_logic;
	signal char: character;
begin

	char <= character'val(to_integer(unsigned(asciiCode)));

	process( asciiNew )
	begin
		if rst = '0' then
			buf <= x"0";
			high <= '0';
			write <= '1';
		elsif asciiNew = '0' then
			write <= '1';
		elsif rising_edge(asciiNew) then
			if byteMode = '1' then
				if high = '1' then
					data_write <= charToU4(char) & buf;
					write <= '0';
				else
					buf <= charToU4(char);
				end if;
				high <= not high;				
			else
				data_write <= unsigned('0' & asciiCode);
				write <= '0';
			end if;
		end if;

		if byteMode = '0' then
			high <= '0';
		end if;
	end process ; -- 

end arch ; -- arch
