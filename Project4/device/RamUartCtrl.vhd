library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- RAM1 RAM2 UART 协调读写模块
entity RamUartCtrl is
	port (
		rst, clk: in std_logic;
		------ 对MEM接口 ------
		mem_type: in MEMType;
		mem_addr: in u16;
		mem_write_data: in u16;
		mem_read_data: out u16;
		mem_busy: out std_logic;	-- 串口操作可能很慢，busy=1表示尚未完成
		------ 对IF接口 ------
		if_addr: in u16;
		if_data: out u16;
		if_canread: out std_logic; -- 当MEM操作RAM2时不可读
		------ RAM接口 ------
		ram1addr, ram2addr: out u18;
		ram1data, ram2data: inout u16;
		ram1read, ram1write, ram1enable: out std_logic;
		ram2read, ram2write, ram2enable: out std_logic;
		------ UART接口 ------
		uart_data_ready, uart_tbre, uart_tsre: in std_logic;	-- UART flags 
		uart_read, uart_write: out std_logic					-- UART lock
	) ;
end RamUartCtrl;

architecture arch of RamUartCtrl is	

	signal uart_write_busy: std_logic;
	signal count: natural range 0 to 15;	

begin

	process( mem_type, ram1data, ram2data, mem_addr, mem_write_data, if_addr, uart_write_busy, uart_data_ready )
	begin
		mem_read_data <= x"0000";
		if_canread <= '1'; if_data <= ram2data;
		mem_busy <= '0';
		-- RAM默认输出
		ram1enable <= '1'; ram1read <= '1'; ram1write <= '1';
		ram1addr <= "00" & mem_addr; ram1data <= (others => 'Z');
		ram2enable <= '0'; ram2read <= '0'; ram2write <= '1';
		ram2addr <= "00" & if_addr; ram2data <= (others => 'Z');
		-- UART默认输出
		uart_read <= '1'; -- uart_write <= '1';

		case( mem_type ) is
		when None => null;
		when ReadRam1 =>
			ram1enable <= '0'; ram1read <= '0';
			mem_read_data <= ram1data;
		when WriteRam1 =>
			ram1enable <= '0'; ram1write <= clk; 
			ram1data <= mem_write_data;
		when ReadRam2 =>
			ram2addr <= "00" & mem_addr;
			mem_read_data <= ram2data;
			if_canread <= '0'; if_data <= x"0000";
		when WriteRam2 =>
			ram2read <= '1'; ram2write <= clk; 
			ram2addr <= "00" & mem_addr;
			ram2data <= mem_write_data;
			if_canread <= '0'; if_data <= x"0000";
		when ReadUart =>
			if uart_data_ready = '0' then
				mem_busy <= '1';
			else
				uart_read <= '0';
				mem_read_data <= ram1data;
			end if;
		when WriteUart =>
			mem_busy <= uart_write_busy;
			ram1data <= mem_write_data;
			-- 其它工作交给下面时序逻辑
		end case ;
	end process ; -- 

	write_uart : process( rst, clk )
	begin
		if rst = '0' or mem_type /= WriteUart then
			uart_write <= '1';
			uart_write_busy <= '0';
			count <= 0;
		elsif falling_edge(clk) then
			count <= count + 1;
			case count is 
			when 0 => uart_write_busy <= '1'; 
			when 1 => uart_write <= '0';
			when 2 to 9 => null;
			when 10 => uart_write <= '1';
			when 11 => if uart_tbre /= '1' then count <= count; end if;
			when 12 => if uart_tsre /= '1' then count <= count; end if;
			when 13 => uart_write_busy <= '0'; count <= 0;
			when others => count <= 0;
			end case;
		end if;
	end process ; -- write_uart

end arch ; -- arch
