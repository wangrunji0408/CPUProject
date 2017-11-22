library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity MockUart is
	port (
		ram1enable: in std_logic;
		ram1data: inout u16;
		read, write: in std_logic;				-- UART lock		
		data_ready, tbre, tsre: out std_logic	-- UART flags 
	) ;
end MockUart;

architecture arch of MockUart is	
begin

	process
		constant zzzz: u16 := (others => 'Z');
		variable data: u16;
		variable dataToRead: u16 := x"1000";
	begin
		if ram1enable = '0' then --disable
			ram1data <= zzzz;
			data_ready <= '0'; tbre <= '0'; tsre <= '0';
		elsif read = '0' and write = '0' then
			report "UART read = write = 0. Mess!"
			severity warning;
		else
			if falling_edge(write) then
				data := ram1data;
				tbre <= '0'; tsre <= '0';
			elsif rising_edge(write) then
				wait for 100 ns;
				tbre <= '1';
				wait for 1 us;
				tsre <= '1';
				report "Write UART: " & toHex(data(7 downto 4)) & toHex(data(3 downto 0)) 
					severity note;
			end if;

			if read = '1' and ram1data = zzzz then
				data_ready <= '1';
			elsif falling_edge(read) then
				wait for 100 ns;
				ram1data <= dataToRead;
				dataToRead := dataToRead + 1;
				report "Read UART: " & toHex(dataToRead(7 downto 4)) & toHex(dataToRead(3 downto 0)) 
					severity note;
			end if;
		end if;
	end process ; -- 

end arch ; -- arch
