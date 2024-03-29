library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestRucTop is
	port (
		clk, rst: in std_logic;
		clk11, clk50: in std_logic;
		switch: in u16;
		light: out u16;
		
		ram1addr, ram2addr: out u18;
		ram1data, ram2data: inout u16;
		ram1read, ram1write, ram1enable: out std_logic;
		ram2read, ram2write, ram2enable: out std_logic;

		uart_data_ready, uart_tbre, uart_tsre: in std_logic;	-- UART flags 
		uart_read, uart_write: out std_logic;					-- UART lock

		ps2_clk, ps2_data: in std_logic;

		vga_r, vga_g, vga_b: out u3;
		vga_vs, vga_hs: out std_logic;

		digit0raw, digit1raw: out std_logic_vector(6 downto 0);
		key: in std_logic_vector(3 downto 0)
	) ;
end TestRucTop;

architecture arch of TestRucTop is	

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

	signal digit0, digit1: u4;

	signal count: natural;
	signal data: u16;

	signal uart2_data_write, uart2_data_read: u16;
	signal uart2_data_ready, uart2_tbre, uart2_tsre: std_logic;
	signal uart2_read, uart2_write: std_logic;

	signal buf0: DataBufPort;
	
begin

	digit0raw <= DisplayNumber(digit0);
	digit1raw <= DisplayNumber(digit1);

	light <= (others => '0');
	digit1 <= to_u4(count);

	vga_r <= o"0"; vga_g <= o"0"; vga_b <= o"0";
	vga_vs <= '0'; vga_hs <= '0';

	digit0 <= to_u4(count);
	

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
