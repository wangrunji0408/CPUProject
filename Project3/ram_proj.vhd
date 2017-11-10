library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity RamProj is
	port (
		clk, rst: in std_logic;
		switch: in u16;
		light: out u16;
		
		ram1addr, ram2addr: out u18;
		ram1data, ram2data: inout u16;
		ram1read, ram1write, ram1enable: out std_logic;
		ram2read, ram2write, ram2enable: out std_logic;

		digit0, digit1: out u4
	) ;
end RamProj;

architecture arch of RamProj is	
	type TStatus is (WriteRAM1, ReadRAM1, WriteRAM2, ReadRAM2);
	signal status: TStatus := WriteRAM1;
	signal count: integer := 0;
	signal addr, data: u16;
	signal ram1writeEqualsClk, ram2writeEqualsClk: boolean;
	signal showRam1Data: boolean;
begin
	digit0 <= to_u4(TStatus'pos(status));
	digit1 <= to_u4(count);

	ram1addr <= "00" & addr when status = WriteRAM1 or status = ReadRAM1
				else (others => '0');
	ram2addr <= "00" & addr when status = WriteRAM2 or status = ReadRAM2
				else (others => '0');
	ram1data <= data when status = WriteRAM1
				else (others => 'Z') when status = ReadRAM1
				else (others => '0');
	ram2data <= data when status = WriteRAM2
				else (others => 'Z') when status = ReadRAM2
				else (others => '0');

	ram1write <= clk when ram1writeEqualsClk else '1';
	ram2write <= clk when ram2writeEqualsClk else '1';

	light <= x"FFFF" when rst = '0' 
		else addr(7 downto 0) & ram1data(7 downto 0) when showRam1Data
		else addr(7 downto 0) & data(7 downto 0);

	process(rst, clk)
		variable addrBegin: u16;
	begin
		if rst = '0' then
			ram1enable <= '1'; ram1read <= '1';
			ram2enable <= '1'; ram2read <= '1';
			status <= WriteRAM1;
			count <= 0;
			data <= to_u16(0); addr <= to_u16(0);
			ram1writeEqualsClk <= false; ram2writeEqualsClk <= false; showRam1Data <= false;
		elsif rising_edge(clk) then
			count <= count + 1;
			case status is
			when WriteRAM1 =>
				case count is 
				when 0 => addr <= switch; addrBegin := switch; ram1enable <= '0';
				when 1 => data <= switch; ram1writeEqualsClk <= true;
				when 2 => ram1writeEqualsClk <= false;	-- writing 1
				when 3|5|7|9|11|13|15|17|19 => 	addr <= addr + 1; data <= data + 1; ram1writeEqualsClk <= true;
				when 4|6|8|10|12|14|16|18|20 => ram1writeEqualsClk <= false;	-- writing 2,3...10
				when 21 => count <= 0; status <= ReadRAM1;
				when others => count <= 0;
				end case;
			when ReadRAM1 =>
				case count is 
				when 0 => addr <= addrBegin; ram1read <= '0'; showRam1Data <= true;
				when 1 to 9 => addr <= addr + 1;
				when 10 => count <= 0; status <= WriteRAM2; showRam1Data <= false;
				when others => count <= 0;
				end case;
			when others => null;
			end case;
		end if;
	end process ; -- 
end arch ; -- arch
