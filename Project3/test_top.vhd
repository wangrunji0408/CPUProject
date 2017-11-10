library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestTop is
end TestTop;

architecture arch of TestTop is	

	component Top is
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

			digit0raw, digit1raw: out std_logic_vector(6 downto 0)
		) ;
	end component;

	component FakeRam is
		port (
			addr: in u18;
			data: inout u16;
			read, write, enable: in std_logic
		) ;
	end component;

	procedure press (signal b: out std_logic) is
	begin
		b <= '0'; wait for 100 ns; b <= '1'; wait for 100 ns;
	end procedure;

	signal clk, rst: std_logic;
	signal clk11, clk50: std_logic;
	signal switch: u16;
	signal light: u16;
	
	signal ram1addr, ram2addr: u18;
	signal ram1data, ram2data: u16;
	signal ram1read, ram1write, ram1enable: std_logic;
	signal ram2read, ram2write, ram2enable: std_logic;

	signal uart_data_ready, uart_tbre, uart_tsre: std_logic;	-- UART flags 
	signal uart_read, uart_write: std_logic;					-- UART lock

	signal ps2_clk, ps2_data: std_logic;

	signal vga_r, vga_g, vga_b: u3;
	signal vga_vs, vga_hs: std_logic;

	signal digit0raw, digit1raw: std_logic_vector(6 downto 0);

begin
	top0: Top port map (clk, rst, clk11, clk50, switch, light,
						ram1addr, ram2addr, ram1data, ram2data, 
						ram1read, ram1write, ram1enable, ram2read, ram2write, ram2enable,
						uart_data_ready, uart_tbre, uart_tsre, uart_read, uart_write,
						ps2_clk, ps2_data,
						vga_r, vga_g, vga_b, vga_vs, vga_hs,
						digit0raw, digit1raw);
	ram1: FakeRam port map (ram1addr, ram1data, ram1read, ram1write, ram1enable);
	ram2: FakeRam port map (ram2addr, ram2data, ram2read, ram2write, ram2enable);

	process
	begin
		-- init
		rst <= '1'; clk <= '1';
		clk11 <= '1'; clk50 <= '1';
		switch <= to_u16(0);

		press(rst);		
		for i in 0 to 50 loop 
			press(clk); 
		end loop ;


		assert(false) report "Top: Test Success." severity note;
		wait;
	end process ;
end arch ; -- arch
