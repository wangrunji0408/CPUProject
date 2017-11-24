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

	process(ram1enable, read, write, ram1data)
		constant zzzz: u16 := (others => 'Z');
		variable data: u8;
		variable dataToRead: u8;
		variable i: natural := 0;
		type ReadDatas is array (0 to 4) of u8;
		constant datas: ReadDatas := (
			--charToU8('R'), x"01"
			-- show mem 0x0008 to 0x0009
			charToU8('D'), x"08", x"00", x"02", x"00"
		);
	begin
		if ram1enable = '0' then --disable
			ram1data <= zzzz;
			data_ready <= '0'; tbre <= '0'; tsre <= '0';
		elsif read = '0' and write = '0' then
			report "UART read = write = 0. Mess!" severity warning;
		else
			if falling_edge(write) then
				data := ram1data(7 downto 0);
				tbre <= '0'; tsre <= '0';
			elsif rising_edge(write) then
				tbre <= '1' after 100 ns;
				tsre <= '1' after 1100 ns;
				report "Write UART: "  & toHex8(data);
			end if;

			if read = '1' then
				data_ready <= '1';
			elsif falling_edge(read) then
				dataToRead := datas(i);
				ram1data <= x"00" & dataToRead;
				report "Read UART: " & toHex8(dataToRead);
				i := (i + 1) mod datas'length;
			end if;
		end if;
	end process ; -- 

end arch ; -- arch
