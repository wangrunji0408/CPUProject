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

	signal color, color_out: TColor;
	signal vga_x, vga_y: integer;
	signal clk_vga: std_logic;

	signal ascii_new: std_logic;
	signal ascii_code: std_logic_vector(6 downto 0);

	signal ram1, ram2: RamPort;
	signal uartIn: UartFlags;
	signal uartOut: UartCtrl;

	signal digit0, digit1: u4;

	signal uart_data: u16;
	
begin

	digit0raw <= DisplayNumber(digit0);
	digit1raw <= DisplayNumber(digit1);

	light <= (others => '0');

	ps2: entity work.ps2_keyboard_to_ascii 
		port map (clk50, ps2_clk, ps2_data, ascii_new, ascii_code);
	digit1 <= unsigned("0" & ascii_code(6 downto 4));
	digit0 <= unsigned(ascii_code(3 downto 0));

	make_clk_vga : process( clk50 )
	begin
		if rst = '0' then
			clk_vga <= '1';
		elsif rising_edge(clk50) then
			clk_vga <= not clk_vga;
		end if;
	end process ; -- make_clk_vga

	renderer0: entity work.Renderer 
		port map (rst, clk_vga, vga_x, vga_y, color);	
	vga1: entity work.vga_controller 
		--generic map (1440,80,152,232,'0',900,1,3,28,'1') -- 60Hz clk=106Mhz
		-- generic map (1024,24,136,160,'0',768,3,6,29,'0') -- 60Hz clk=65Mhz
		generic map (640,16,96,48,'0',480,10,2,33,'0') -- 60Hz clk=25Mhz		
		port map (clk_vga, rst, color, color_out, vga_hs, vga_vs, vga_x, vga_y);
	vga_r <= unsigned(color_out(8 downto 6));
	vga_g <= unsigned(color_out(5 downto 3));
	vga_b <= unsigned(color_out(2 downto 0));

	ram1addr <= ram1.addr; 
	ram1data <= ram1.data; 
	ram1enable <= ram1.enable; 
	ram1read <= ram1.read; 
	ram1write <= ram1.write; 
	ram2addr <= ram2.addr; 
	ram2data <= ram2.data; 
	ram2enable <= ram2.enable; 
	ram2read <= ram2.read; 
	ram2write <= ram2.write; 
	uartIn.data_ready <= uart_data_ready;
	uartIn.tbre <= uart_tbre;
	uartIn.tsre <= uart_tsre;
	uart_read <= uartOut.read;
	uart_write <= uartOut.write;
	uart_data <= uartOut.data; -- TODO bind uart_data
	cpu0: entity work.CPU 
		port map (rst, clk50, ram1, ram2, ram1data, ram2data, uartIn, uartOut); 
	
end arch ; -- arch
