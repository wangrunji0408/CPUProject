library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;
use work.Show.all;

entity MockUart is
	port (
		rst, ram1enable: in std_logic;
		ram1data: inout u16;
		read, write: in std_logic;				-- UART lock		
		data_ready, tbre, tsre: out std_logic	-- UART flags 
	) ;
end MockUart;

architecture arch of MockUart is	
begin

	process(rst, read, write, ram1data)
		constant zzzz: u16 := (others => 'Z');
		variable data: u8;
		variable dataToRead: u8;
		variable i: natural := 0;
		type ReadDatas is array (0 to 127) of u8;
		constant datas: ReadDatas := (
			-- Case1: Execute fib program
			charToU8('G'), x"00", x"40",
			charToU8('R'),
			-- Case2: Write 4000=0800 4001=0801 then read
			charToU8('A'), 
			x"00", x"40", x"00", x"08",
			x"01", x"40", x"01", x"08",
			x"00", x"00",
			charToU8('D'), x"00", x"40", x"02", x"00",
			charToU8('U'), x"00", x"40", x"02", x"00",
			others => x"00"
		);
	begin
		if rst = '0' then --disable
			ram1data <= zzzz;
			data_ready <= '0'; tbre <= '0'; tsre <= '0';
		elsif read = '0' and write = '0' then
			report "UART read = write = 0. Mess!" severity warning;
		elsif rising_edge(rst) then
			data_ready <= '1'; tbre <= '1'; tsre <= '1';
		else
			if falling_edge(write) then
				data := ram1data(7 downto 0);
				tbre <= '0'; tsre <= '0';
			elsif rising_edge(write) then
				tbre <= '1' after 150 ns;
				tsre <= '1' after 300 ns;
				report "Write UART: "  & toHex8(data);
			end if;

			if rising_edge(read) then
				ram1data <= zzzz;	
				data_ready <= '1' after 500 ns;
			elsif falling_edge(read) then
				data_ready <= '0';
				dataToRead := datas(i);
				ram1data <= x"00" & dataToRead;				
				report "Read UART: " & toHex8(dataToRead);
				i := (i + 1) mod datas'length;	
			end if;
		end if;
	end process ; -- 

end arch ; -- arch
