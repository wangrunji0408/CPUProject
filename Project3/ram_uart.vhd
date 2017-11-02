library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity RamUart is
	port (
		clk, rst, clk11: in std_logic;
		switch: in u16;
		light: out u16;
		
		ram1addr, ram2addr: out u18;
		ram1data, ram2data: inout u16;
		ram1read, ram1write, ram1enable: out std_logic;
		ram2read, ram2write, ram2enable: out std_logic;

		uart_data_ready, uart_tbre, uart_tsre: in std_logic;	-- UART flags 
		uart_read, uart_write: out std_logic;					-- UART lock

		digit0, digit1: out u4
	) ;
end RamUart;

architecture arch of RamUart is	
	type TStatus is (ReadUART, WriteRam1, ReadRam1, WriteRam2, ReadRam2, WriteUART);
	signal status: TStatus;
	signal count: integer := 0;
	signal data: u16;
	signal addr: u18;
begin
	digit0 <= to_u4(TStatus'pos(status));
	digit1 <= to_u4(count);

	light <= data;

	process(rst, clk11)
		variable lastclk: std_logic;
		variable pressclk: boolean;
	begin
		if rst = '0' then
			status <= ReadUART;
			count <= 0;
			uart_read <= '1'; uart_write <= '1';
			ram1read <= '1'; ram1write <= '1'; ram1enable <= '1';
			ram2read <= '1'; ram2write <= '1'; ram2enable <= '1';
			data <= to_u16(0);
			lastclk := '1';
		elsif rising_edge(clk11) then
			pressclk := clk = '1' and lastclk = '0';
			lastclk := clk;
			count <= count + 1;
			case status is
			when ReadUART =>
				case count is 
				when 0 => ram1data <= (others => 'Z');
				when 1 => 
					if uart_data_ready = '1' then uart_read <= '0';
					else count <= count; end if;
				when 2 => 
					data <= ram1data + 1; uart_read <= '1';
				when 3 => 
					if pressclk then count <= 0; status <= WriteRam1; 
					else count <= count; end if;
				when others => count <= 0;
				end case;
			when WriteRam1 =>
				case count is 
				when 0 => addr <= "00" & switch;
				when 1 => ram1enable <= '0'; ram1addr <= addr; ram1data <= data;
				when 2 => ram1write <= '0';
				when 3 => ram1write <= '1';
				when 4 => 
					if pressclk then count <= 0; status <= ReadRam1; 
					else count <= count; end if;
				when others => count <= 0;
				end case;
			when ReadRAM1 =>
				case count is 
				when 0 => ram1read <= '0'; ram1addr <= addr; ram1data <= (others => 'Z');
				when 1 => data <= ram1data + 1;
				when 2 => ram1enable <= '1'; ram1read <= '1';
				when 3 =>
					if pressclk then count <= 0; status <= WriteRAM2; 
					else count <= count; end if;
				when others => count <= 0;
				end case;
			when WriteRam2 =>
				case count is 
				when 0 => addr <= "00" & switch;
				when 1 => ram2enable <= '0'; ram2addr <= addr; ram2data <= data;
				when 2 => ram2write <= '0';
				when 3 => ram2write <= '1';
				when 4 => 
					if pressclk then count <= 0; status <= ReadRAM2; 
					else count <= count; end if;
				when others => count <= 0;
				end case;
			when ReadRAM2 =>
				case count is 
				when 0 => ram2read <= '0'; ram2addr <= addr; ram2data <= (others => 'Z');
				when 1 => data <= ram2data + 1;
				when 2 => ram2enable <= '1'; ram2read <= '1';
				when 3 =>
					if pressclk then count <= 0; status <= WriteUART; 
					else count <= count; end if;
				when others => count <= 0;
				end case;
			when WriteUART =>
				case count is 
				when 0 => uart_write <= '1'; ram1data <= data;
				when 1 => uart_write <= '0';
				when 2 => if uart_tbre /= '1' then count <= count; end if;
				when 3 => if uart_tsre /= '1' then count <= count; end if;
				when 4 => 
					if pressclk then count <= 0; status <= ReadUART; 
					else count <= count; end if;
				when others => count <= 0;
				end case;
			when others => null;
			end case;
		end if;
	end process ; -- 
end arch ; -- arch
