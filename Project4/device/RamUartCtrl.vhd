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
		mem_busy: out std_logic;
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
		uart_read, uart_write: out std_logic;					-- UART lock
		------ 串口2 ------
		uart2_data_write: out u16;
		uart2_data_read: in u16;
		uart2_data_ready, uart2_tbre, uart2_tsre: in std_logic;
		uart2_read, uart2_write: out std_logic
	) ;
end RamUartCtrl;

architecture arch of RamUartCtrl is	
	signal uart_busy: std_logic;
begin

	process( mem_type, clk, ram1data, ram2data, mem_addr, mem_write_data, if_addr, uart_busy )
	begin
		mem_read_data <= x"0000";
		if_canread <= '1'; if_data <= ram2data;
		mem_busy <= '0';
		-- RAM默认输出
		ram1enable <= '1'; ram1read <= '1'; ram1write <= '1';
		ram1addr <= "00" & mem_addr; ram1data <= (others => 'Z');
		ram2enable <= '0'; ram2read <= '0'; ram2write <= '1';
		ram2addr <= "00" & if_addr; ram2data <= (others => 'Z');
		-- UART 默认输出
		uart_read <= '1'; uart_write <= '1';
		uart2_read <= '1'; uart2_write <= '1';
		uart2_data_write <= x"0000";

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
			uart_read <= '0';
			mem_read_data <= ram1data;
			mem_busy <= uart_busy;
		when WriteUart =>
			uart_write <= clk;
			ram1data <= mem_write_data;
		when TestUart =>
			mem_read_data <= (0 => uart_tsre and uart_tbre, 1 => uart_data_ready, others => '0');
		when ReadUart2 =>
			uart2_read <= '0';
			mem_read_data <= uart2_data_read;
			mem_busy <= uart_busy;
		when WriteUart2 =>
			uart2_write <= clk;
			uart2_data_write <= mem_write_data;
		when TestUart2 =>
			mem_read_data <= (0 => uart2_tsre and uart2_tbre, 1 => uart2_data_ready, others => '0');
		end case ;
	end process ; -- 

	-- 两个周期读串口
	read_uart_busy : process( rst, clk )
		-- variable last_type: MEMType;
	begin
		if rst = '0' then
			uart_busy <= '1';
			-- last_type := None;
		elsif rising_edge(clk) then
			if (mem_type = ReadUart or mem_type = ReadUart2) then
				uart_busy <= '0';
			else
				uart_busy <= '1';
			end if;
			-- last_type := mem_type;
		end if;
	end process ; -- read_uart_busy

end arch ; -- arch
