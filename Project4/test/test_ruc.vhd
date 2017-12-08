library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestRuc is
end TestRuc;

architecture arch of TestRuc is	

	signal ram1addr, ram2addr: u18;
	signal ram1data, ram2data: u16;
	signal ram1read, ram1write, ram1enable: std_logic;
	signal ram2read, ram2write, ram2enable: std_logic;

	signal uart_data_ready, uart_tbre, uart_tsre: std_logic;	-- UART flags 
	signal uart_read, uart_write: std_logic;					-- UART lock
	signal uart2_data_write, uart2_data_read: u16;
	signal uart2_data_ready, uart2_tbre, uart2_tsre: std_logic;
	signal uart2_read, uart2_write: std_logic;

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

	signal count: natural;
	signal data: u16;

	signal rst, clk50: std_logic;
	
begin

	process
	begin
		clk50 <= '1'; wait for 10 ns;
		clk50 <= '0'; wait for 10 ns;
	end process;

	process
	begin
		rst <= '0'; wait for 10 ns;
		rst <= '1'; wait for 10 ns;
		wait for 5 us;
		report "Test End" severity error;
	end process ; -- 

	ram1: entity work.MockRam
		port map (rst, ram1addr, ram1data, ram1read, ram1write, ram1enable);
	ram2: entity work.MockRam
		port map (rst, ram2addr, ram2data, ram2read, ram2write, ram2enable);
	uart: entity work.MockUart
		port map (rst, ram1enable, ram1data, uart_read, uart_write, uart_data_ready, uart_tbre, uart_tsre);

	ruc: entity work.RamUartCtrl 
		port map ( rst, clk50, 
			'0', x"0000", x"0000",
			mem_type, mem_addr, mem_write_data, mem_read_data, mem_busy, if_addr, if_data, if_canread,
			pixel_ram1_addr, pixel_ram1_data, pixel_canread,			
			ram1addr, ram2addr, ram1data, ram2data, ram1read, ram1write, ram1enable, ram2read, ram2write, ram2enable,
			uart_data_ready, uart_tbre, uart_tsre, uart_read, uart_write,
			uart2_data_write, uart2_data_read, uart2_data_ready, uart2_tbre, uart2_tsre, uart2_read, uart2_write,
			buf0.write, buf0.read, buf0.isBack, buf0.canwrite, buf0.canread, buf0.data_write, buf0.data_read);

	process(rst, clk50)
		variable addr: u16 := x"0000";
	begin
		if rst = '0' then
			mem_type <= None;
			mem_addr <= x"0000";
			mem_write_data <= x"0000";
			count <= 0;
			addr := x"0000";
		elsif rising_edge(clk50) then
			count <= count + 1;
			case count  is
			when 0 => 
				mem_type <= TestUart;
			when 1 =>
				mem_type <= TestUart;			
				if mem_read_data(1) = '0' then --can't read
					count <= count;
				else
					mem_type <= ReadUart;				
				end if;
			when 2 => 
				mem_type <= WriteRam1;
				mem_addr <= addr;
				mem_write_data <= mem_read_data + 1; 
			when 3 => 
				mem_type <= ReadRam1;
				mem_addr <= addr;
			when 4 =>
				mem_type <= WriteRam2;
				mem_addr <= addr;
				mem_write_data <= mem_read_data + 1; 				
			when 5 =>
				mem_type <= ReadRam2;
				mem_addr <= addr;
				if addr /= x"0010" then
					count <= 2;
					addr := addr + 1;
				end if;
			when 6 =>
				data <= mem_read_data + 1; 
				mem_type <= TestUart;				
			when 7 => 
				mem_type <= TestUart;
				if mem_read_data(0) = '0' then --can't write
					count <= count;
				end if;
			when 8 =>
				mem_type <= WriteUart;
				mem_write_data <= data;
			when 9 => 
				mem_type <= None;			
				addr := x"0000";
				count <= 0;
			when others => count <= 0;
			end case ;
		end if;
	end process ; -- 
	
end arch ; -- arch
