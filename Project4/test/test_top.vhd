library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestTop is
end TestTop;

architecture arch of TestTop is	

	signal clk, rst, btn3: std_logic;
	signal clk11, clk50: std_logic;

	signal ram1addr, ram2addr: u18;
	signal ram1data, ram2data: u16;
	signal ram1read, ram1write, ram1enable: std_logic;
	signal ram2read, ram2write, ram2enable: std_logic;

	signal uart_data_ready, uart_tbre, uart_tsre: std_logic;	-- UART flags 
	signal uart_read, uart_write: std_logic;					-- UART lock
	signal uart2_data, uart2_data_write, uart2_data_read: u16;
	signal uart2_data_ready, uart2_tbre, uart2_tsre: std_logic;
	signal uart2_read, uart2_write: std_logic;

	------ 对MEM接口 ------
	signal mem_type: MEMType;
	signal mem_addr: u16;
	signal mem_write_data: u16;
	signal mem_read_data: u16;
	signal mem_busy: std_logic;	-- 串口操作可能很慢，busy=1表示尚未完成
	------ 对IF接口 ------
	signal if_addr: u16;
	signal if_data: u16;
	signal if_canread: std_logic; -- 当MEM操作RAM2时不可读

	signal debug: CPUDebug;
	signal io: IODebug;
	
begin

	process
	begin
		clk50 <= '1'; wait for 10 ns;
		clk50 <= '0'; wait for 10 ns;
	end process;

	process
	begin
		clk <= '1'; btn3 <= '1';
		rst <= '0'; wait for 10 ns;
		rst <= '1'; wait for 10 ns;
		btn3 <= '0'; wait for 50 ns;
		btn3 <= '1'; wait for 50 ns;
		wait;
	end process ; -- 

	ruc: entity work.RamUartCtrl 
		port map ( rst, clk50, 
			mem_type, mem_addr, mem_write_data, mem_read_data, mem_busy, if_addr, if_data, if_canread,
			ram1addr, ram2addr, ram1data, ram2data, ram1read, ram1write, ram1enable, ram2read, ram2write, ram2enable,
			uart_data_ready, uart_tbre, uart_tsre, uart_read, uart_write,
			uart2_data_write, uart2_data_read, uart2_data_ready, uart2_tbre, uart2_tsre, uart2_read, uart2_write);
	cpu0: entity work.CPU 
		port map (rst, clk50, clk, btn3,
			mem_type, mem_addr, mem_write_data, mem_read_data, mem_busy, if_addr, if_data, if_canread, 
			x"FFFF", debug); 
	logger: entity work.IOLogger port map (rst, clk50, debug.id_in.pc,
			mem_type, mem_addr, mem_write_data, mem_read_data, mem_busy, io);

	ram1: entity work.MockRam
		generic map (ID => 1, SIZE => 32768, OFFSET => 32768)
		port map (rst, ram1addr, ram1data, ram1read, ram1write, ram1enable);
	ram2: entity work.MockRam
		generic map (ID => 2, SIZE => 32768, KERNEL_PATH => "../exe/kernel.bin", PROG_PATH => "../exe/Term_test/test_uart2.bin")
		port map (rst, ram2addr, ram2data, ram2read, ram2write, ram2enable);
	uart: entity work.MockUart
		port map (ram1enable, ram1data, uart_read, uart_write, uart_data_ready, uart_tbre, uart_tsre);
	uart2: entity work.MockUart
		port map (rst, uart2_data, uart2_read, uart2_write, uart2_data_ready, uart2_tbre, uart2_tsre);
	uart2_data_read <= uart2_data;
	uart2_data <= uart2_data_write when uart2_read = '1' else (others => 'Z');
	
end arch ; -- arch
