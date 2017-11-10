library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity Top is
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
end Top;

architecture arch of Top is	
	component RamProj is
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
	end component;

	component UartProj is
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
	end component;

	component RamUart is
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
	end component;

	signal digit0, digit1: u4;
begin

	digit0raw <= DisplayNumber(digit0);
	digit1raw <= DisplayNumber(digit1);

	vga_r <= "000"; vga_g <= "000"; vga_b <= "000"; vga_vs <= '1'; vga_hs <= '1'; 

	-- RAM Only
	-- uart_read <= '1'; uart_write <= '1';
	-- ramproj0: RamProj port map (clk, rst, switch, light, 
	-- 							ram1addr, ram2addr, 
	-- 							ram1data, ram2data, 
	-- 							ram1read, ram1write, ram1enable, 
	-- 							ram2read, ram2write, ram2enable,
	-- 							digit0, digit1);

	-- UART Only
	-- ram1read <= '1'; ram1write <= '1'; ram1enable <= '1';
	-- ram2read <= '1'; ram2write <= '1'; ram2enable <= '1';
	-- ram2addr <= (others => 'Z');
	-- uart0:   UartProj port map (clk11, rst, switch, light, 
	-- 							ram1addr, ram1data,
	-- 							uart_data_ready, uart_tbre, uart_tsre, uart_read, uart_write, 
	-- 							digit0, digit1);

	-- RAM & UART
	ramuart0: RamUart port map (clk, rst, clk11, switch, light, 
								ram1addr, ram2addr, 
								ram1data, ram2data, 
								ram1read, ram1write, ram1enable, 
								ram2read, ram2write, ram2enable,
								uart_data_ready, uart_tbre, uart_tsre, uart_read, uart_write, 
								digit0, digit1);
	
end arch ; -- arch
