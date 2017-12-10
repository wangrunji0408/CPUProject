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
	signal uart2: UartPort;
	signal uart2_data: u16;

	signal buf0: DataBufPort;	

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
	------ 对PixelReader接口 ------
	signal pixel_ram1_addr: u16;
	signal pixel_ram1_data: u16;
	signal pixel_canread: std_logic; -- 当MEM操作RAM1时不可读
	signal pixel_x, pixel_y: natural;
	signal pixel_data: u16;

	signal debug: CPUDebug;
	signal io: IODebug;
	signal cfg: Config;
	
	signal intt: std_logic;
	signal intt_code: u4;
	
begin

	cfg <= (others => '0');

	process
	begin
		clk50 <= '1'; wait for 10 ns;
		clk50 <= '0'; wait for 10 ns;
	end process;

	process
	begin
		clk <= '1'; btn3 <= '1';
		intt <= '0';
		rst <= '0'; wait for 10 ns;
		rst <= '1'; wait for 10 ns;
		btn3 <= '0'; wait for 50 ns;
		btn3 <= '1'; wait for 50 ns;
		wait for 6900 ns;
		intt_code <= "0010";
		intt <= '1'; wait for 20 ns;
		intt <= '0';
		wait;
	end process ; -- 

	process
	begin
		py : for i in 0 to 60 loop
			pixel_y <= i;
			px : for j in 0 to 80 loop
				pixel_x <= j;
				wait for 320 ns;
			end loop ; -- px
		end loop ; -- identifier
	end process;

	pr: entity work.PixelReader
		port map (rst, clk50, pixel_x, pixel_y, pixel_data, pixel_ram1_addr, pixel_ram1_data, pixel_canread);

	ruc: entity work.RamUartCtrl 
		port map ( rst, clk50, 
			'0', x"0000", x"0000",
			mem_type, mem_addr, mem_write_data, mem_read_data, mem_busy, if_addr, if_data, if_canread,
			pixel_ram1_addr, pixel_ram1_data, pixel_canread,
			ram1addr, ram2addr, ram1data, ram2data, ram1read, ram1write, ram1enable, ram2read, ram2write, ram2enable,
			uart_data_ready, uart_tbre, uart_tsre, uart_read, uart_write,
			uart2.data_write, uart2.data_read, uart2.data_ready, uart2.tbre, uart2.tsre, uart2.read, uart2.write,
			buf0.write, buf0.read, buf0.isBack, buf0.canwrite, buf0.canread, buf0.data_write, buf0.data_read);
	cpu0: entity work.CPU 
		port map (rst, clk50, clk, btn3, cfg,
			mem_type, mem_addr, mem_write_data, mem_read_data, mem_busy, if_addr, if_data, if_canread, 
			x"FFFF", debug, intt, intt_code); 
	logger: entity work.IOLogger port map (rst, clk50, debug.id_in.pc,
			mem_type, mem_addr, mem_write_data, mem_read_data, mem_busy, io);

	buf: entity work.DataBuffer
		port map (rst, buf0.write, buf0.read, buf0.isBack, buf0.canwrite, buf0.canread, buf0.data_write, buf0.data_read, open);
	ram1: entity work.MockRam
		generic map (ID => 1, SIZE => 32768, OFFSET => 32768)
		port map (rst, ram1addr, ram1data, ram1read, ram1write, ram1enable);
	ram2: entity work.MockRam
		generic map (ID => 2, SIZE => 32768, KERNEL_PATH => "../exe/new_k.bin", PROG_PATH => "../exe/Term_test/fib.bin")
		port map (rst, ram2addr, ram2data, ram2read, ram2write, ram2enable);
	uart: entity work.MockUart
		port map (rst, ram1enable, ram1data, uart_read, uart_write, uart_data_ready, uart_tbre, uart_tsre);
	uart2_e: entity work.MockUart
		port map (rst, '1', uart2_data, uart2.read, uart2.write, uart2.data_ready, uart2.tbre, uart2.tsre);
	uart2.data_read <= uart2_data;
	uart2_data <= uart2.data_write when uart2.read = '1' else (others => 'Z');
	
end arch ; -- arch
