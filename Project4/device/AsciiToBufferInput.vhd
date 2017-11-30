library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity AsciiToBufferInput is
	port (
		rst, clk: in std_logic;
		asciiNew: in std_logic;
		asciiCode: in std_logic_vector(6 downto 0);
		byteMode: in std_logic;
		write, isBack: out std_logic;
		data_write: buffer u8
	) ;
end AsciiToBufferInput;

architecture arch of AsciiToBufferInput is
	signal buf: u4;
	signal high: std_logic;
	signal char: natural range 0 to 255;
begin

	char <= to_integer(unsigned(asciiCode));
	isBack <= '1' when asciiCode = "0001000" else '0';

	process( rst, clk )
		variable lastAsciiNew: std_logic;
	begin
		if rst = '0' then
			buf <= x"0";
			high <= '1';
			write <= '1';
			lastAsciiNew := '0';
		elsif rising_edge(clk) then
			write <= '1';
			if lastAsciiNew = '0' and asciiNew = '1' then
				if asciiCode = "0001000" then
					write <= '0';
					high <= '1';			
				elsif byteMode = '1' then
					if high = '1' then
						buf <= charToU4(char);
					else
						data_write <= buf & charToU4(char);
						write <= '0';
					end if;
					high <= not high;				
				else
					data_write <= unsigned('0' & asciiCode);
					write <= '0';
				end if;
			end if;
			if byteMode = '0' then
				high <= '1';
			end if;
			lastAsciiNew := asciiNew;
		end if;
	end process ; -- 

end arch ; -- arch
