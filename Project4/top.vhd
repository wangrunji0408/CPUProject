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

	component vga_controller IS
	GENERIC(
		h_pixels :  INTEGER   := 1920;  --horiztonal display width in pixels
		h_fp     :  INTEGER   := 128;   --horiztonal front porch width in pixels
		h_pulse  :  INTEGER   := 208;   --horiztonal sync pulse width in pixels
		h_bp     :  INTEGER   := 336;   --horiztonal back porch width in pixels
		h_pol    :  STD_LOGIC := '0';   --horizontal sync pulse polarity (1 = positive, 0 = negative)
		v_pixels :  INTEGER   := 1200;  --vertical display width in rows
		v_fp     :  INTEGER   := 1;     --vertical front porch width in rows
		v_pulse  :  INTEGER   := 3;     --vertical sync pulse width in rows
		v_bp     :  INTEGER   := 38;    --vertical back porch width in rows
		v_pol    :  STD_LOGIC := '1');  --vertical sync pulse polarity (1 = positive, 0 = negative)
	PORT(
		pixel_clk :  IN   STD_LOGIC;  --pixel clock at frequency of VGA mode being used
		reset_n   :  IN   STD_LOGIC;  --active low asycnchronous reset
		color_in  :  IN   TColor;
		color_out :  OUT  TColor;
		h_sync    :  OUT  STD_LOGIC;  --horiztonal sync pulse
		v_sync    :  OUT  STD_LOGIC;  --vertical sync pulse
		column    :  OUT  INTEGER;    --horizontal pixel coordinate
		row       :  OUT  INTEGER    --vertical pixel coordinate
	);
	END component;

	signal color, color_out: TColor;
	signal vga_x, vga_y: integer;
	signal clk_vga: std_logic;

	component ps2_keyboard_to_ascii IS
	GENERIC(
		clk_freq                  : INTEGER := 50_000_000; --system clock frequency in Hz
		ps2_debounce_counter_size : INTEGER := 8);         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
	PORT(
		clk        : IN  STD_LOGIC;                     --system clock input
		ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
		ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
		ascii_new  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
		ascii_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)); --ASCII value
	END component;

	signal ascii_new: std_logic;
	signal ascii_code: std_logic_vector(6 downto 0);

	component Renderer is
		port (
			rst, clk: in std_logic;
			vga_x, vga_y: in integer;
			color: out TColor
		) ;
	end component;

	component CPU is
	port (
		clk, rst: in std_logic;
		
		ram1, ram2: out RamPort;
		ram1_datain, ram2_datain: in u16;

		uartIn: in UartFlags;
		uartOut: out UartCtrl
	) ;
	end component;

	signal digit0, digit1: u4;

	signal uart_data: u16;
	
begin

	digit0raw <= DisplayNumber(digit0);
	digit1raw <= DisplayNumber(digit1);

	light <= (others => '0');

	ps2: ps2_keyboard_to_ascii port map (clk50, ps2_clk, ps2_data, ascii_new, ascii_code);
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

	renderer0: Renderer port map (rst, clk_vga, vga_x, vga_y, color);	
	vga1: vga_controller 
		--generic map (1440,80,152,232,'0',900,1,3,28,'1') -- 60Hz clk=106Mhz
		-- generic map (1024,24,136,160,'0',768,3,6,29,'0') -- 60Hz clk=65Mhz
		generic map (640,16,96,48,'0',480,11,2,31,'0') -- 60Hz clk=25Mhz		
		port map (clk_vga, rst, color, color_out, vga_hs, vga_vs, vga_x, vga_y);
	vga_r <= unsigned(color_out(8 downto 6));
	vga_g <= unsigned(color_out(5 downto 3));
	vga_b <= unsigned(color_out(2 downto 0));

	cpu0: CPU port map (rst, clk50, 
						ram1.addr => ram1addr, 
						ram1.data => ram1data, 
						ram1.enable => ram1enable, 
						ram2.addr => ram2addr, 
						ram2.data => ram2data, 
						ram2.enable => ram2enable, 
						ram1_datain => ram1data,
						ram2_datain => ram2data,
						uartIn.data_ready => uart_data_ready, 
						uartIn.tbre => uart_tbre, 
						uartIn.tsre => uart_tsre, 
						uartOut.read => uart_read, 
						uartOut.write => uart_write, 
						uartOut.data => uart_data); -- TODO bind uart_data
	
end arch ; -- arch
