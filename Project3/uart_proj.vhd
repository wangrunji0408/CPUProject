library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity UartProj is
	port (
		clk11, rst: in std_logic;
		switch: in u16;
		light: out u16;
		
		ram1addr: out u18;
		ram1data: inout u16;

		uart_data_ready, uart_tbre, uart_tsre: in std_logic;	-- UART flags 
		uart_read, uart_write: out std_logic;					-- UART lock

		digit0, digit1: out u4
	) ;
end UartProj;

architecture arch of UartProj is	
	type TStatus is (ReadUART, WriteUART);
	signal status: TStatus;
	signal count: integer := 0;
	signal data: u16;
begin
	digit0 <= to_u4(TStatus'pos(status));
	digit1 <= to_u4(count);

	light <= data;

	process(rst, clk11)
	begin
		if rst = '0' then
			status <= ReadUART;
			count <= 0;
			uart_read <= '1'; uart_write <= '1';
			data <= to_u16(0);
		elsif rising_edge(clk11) then
			count <= count + 1;
			case status is
			when ReadUART =>
				case count is 
				when 0 => uart_read <= '1'; ram1data <= (others => 'Z');
				when 1 => 
					if uart_data_ready = '1' then uart_read <= '0';
					else count <= 0; end if;
				when 2 => 
					data <= ram1data + 1; uart_read <= '1';
					count <= 0; status <= WriteUART; -- next status
				when others => count <= 0;
				end case;
			when WriteUART =>
				case count is 
				when 0 => ram1data <= data;
				when 1 => uart_write <= '0'; 
				when 2 => uart_write <= '1';
				when 3 => if uart_tbre /= '1' then count <= count; end if;
				when 4 => if uart_tsre /= '1' then count <= count; end if;
				when 5 => count <= 0; status <= ReadUART;
				when others => count <= 0;
				end case;
			when others => null;
			end case;
		end if;
	end process ; -- 
end arch ; -- arch
