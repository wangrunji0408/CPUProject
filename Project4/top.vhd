library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity Top is
	port (
		clk, rst: in std_logic;
		clk11, clk50_in: in std_logic;
		switch: in u16;
		light: out u16;
		
		ram1addr, ram2addr: out u18;
		ram1data, ram2data: inout u16;
		ram1read, ram1write, ram1enable: out std_logic;
		ram2read, ram2write, ram2enable: out std_logic;

		uart_data_ready, uart_tbre, uart_tsre: in std_logic;	-- UART flags 
		uart_read, uart_write: out std_logic;					-- UART lock

		u_rxd: in std_logic;
		u_txd: out std_logic;	-- 串口2

		flash_addr: out u23;
		flash_data: inout u16;
		flash_ctrl: out FlashCtrl;

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
	signal rst_cpu, rst_boot: std_logic;

	signal ascii_new: std_logic;
	signal ascii_code: std_logic_vector(6 downto 0);

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

	signal uart2_data_write, uart2_data_read: u16;
	signal uart2_data_read_lv: std_logic_vector(7 downto 0);
	signal uart2_data_ready, uart2_tbre, uart2_tsre: std_logic;
	signal uart2_read, uart2_write: std_logic;

	-- 状态机 --
	signal finish_boot: boolean := false;
	
	-- 对Boot接口 --
	signal start_addr, end_addr, ram2_start_addr : u16;
	signal done : std_logic := '0';
	signal flash_addr_16 : u16;
	signal CE0, BYTE, OE, WE : std_logic;
	signal flash_ram2_addr : u16;
	signal flash_ram2_data : u16;
	signal flash_write_ram2 : std_logic;

	-- Boot 接管RamUart --
	signal mem_type_boot : MEMType;
	signal mem_addr_boot  : u16;
	signal mem_write_data_boot : u16;

	-- 调试信息与其他 --
	signal digit0, digit1: u4;

	signal clk_stable: std_logic;
	signal key_stable: std_logic_vector(3 downto 0);
	signal clk50, clk40, clk25, clk_cpu: std_logic;

	signal debug: CPUDebug;
	signal io: IODebug;
	signal buf: DataBufInfo;
	
begin

	process(rst, clk11)
		variable count: integer;
	begin
		if rst = '0'
		then
			finish_boot <= false;
			rst_boot <= '0';
			count := 0;
		elsif rising_edge(clk11) and not finish_boot
		then
			case( count ) is
				when 0 => 
					start_addr <= x"0000";
					end_addr <= x"0220";
					ram2_start_addr <= x"0000";
					count := 1;
				when 1 => 
					rst_boot <= '1';
					if done = '1' then
						rst_boot <= '0';
						count := 2;
					end if;
				when 2 => 
					start_addr <= x"4000";
					end_addr <= x"5000";
					ram2_start_addr <= x"4000";
					count := 3;
				when 3 => 
					rst_boot <= '1';
					if done = '1' then
						rst_boot <= '0';
						count := 4;
					end if;
				when 4 =>
					finish_boot <= true;
				when others =>
					count := 0;
			end case ;
		end if;
	end process;


	digit0raw <= DisplayNumber(digit0);
	digit1raw <= DisplayNumber(digit1);

	light <= x"00" & "000" & uart2_data_ready & uart2_tbre & uart2_tsre & uart2_read & uart2_write;
	digit0 <= uart2_data_read(7 downto 4);
	digit1 <= uart2_data_read(3 downto 0);

	-- 稳定按钮信号
	deb: entity work.debounce port map(clk50, clk, clk_stable);
	deb_keys: for i in 0 to 3 generate
		deb_key: entity work.debounce port map(clk50, key(i), key_stable(i));
	end generate ;

	ps2: entity work.ps2_keyboard_to_ascii 
		port map (clk50, ps2_clk, ps2_data, ascii_new, ascii_code);

	make_clk25 : process( clk50 )
	begin
		if rst = '0' then
			clk25 <= '1';
		elsif rising_edge(clk50) then
			clk25 <= not clk25;
		end if;
	end process ; -- make_clk25

	dcm40: entity work.DCM port map (clk50_in, rst, clk40, clk50);
	-- clk50 <= clk50_in;
	clk_vga <= clk25;
	clk_cpu <= clk25;

	renderer0: entity work.Renderer 
		port map (rst, clk_vga, vga_x, vga_y, color, debug, io, buf);	
	vga1: entity work.vga_controller 
		--generic map (1440,80,152,232,'0',900,1,3,28,'1') -- 60Hz clk=106Mhz
		-- generic map (1024,24,136,160,'0',768,3,6,29,'0') -- 60Hz clk=65Mhz
		generic map (640,16,96,48,'0',480,10,2,33,'0') -- 60Hz clk=25Mhz		
		port map (clk_vga, rst, color, color_out, vga_hs, vga_vs, vga_x, vga_y);
	vga_r <= unsigned(color_out(8 downto 6));
	vga_g <= unsigned(color_out(5 downto 3));
	vga_b <= unsigned(color_out(2 downto 0));

	flash_addr <= "000000" & flash_addr_16 & "0";
--	flash_data <= (others => 'Z');
	flash_ctrl <= (BYTE, CE0, '0', '0',OE, '1', '1', '1', WE); --what is STS??
		
	rst_cpu <= rst when finish_boot else '0';

	uart2: entity work.uart 
		port map (rst, clk11, u_rxd, uart2_read, uart2_write, 
			std_logic_vector(uart2_data_write(7 downto 0)), uart2_data_read_lv, 
			uart2_data_ready, open, open, uart2_tbre, uart2_tsre, u_txd);
	uart2_data_read(7 downto 0) <= unsigned(uart2_data_read_lv);
	uart2_data_read(15 downto 8) <= x"00";

	mem_type_boot <= mem_type when finish_boot else
				 WriteRam2 when flash_write_ram2 = '1' else
				 None;
	mem_addr_boot <= mem_addr when finish_boot else
				 flash_ram2_addr;

	mem_write_data_boot <= mem_write_data when finish_boot else
					   flash_ram2_data;

	ruc: entity work.RamUartCtrl 
		port map ( rst, clk_cpu, 
			mem_type_boot, mem_addr_boot, mem_write_data_boot, mem_read_data, mem_busy, if_addr, if_data, if_canread,
			ram1addr, ram2addr, ram1data, ram2data, ram1read, ram1write, ram1enable, ram2read, ram2write, ram2enable,
			uart_data_ready, uart_tbre, uart_tsre, uart_read, uart_write,
			uart2_data_write, uart2_data_read, uart2_data_ready, uart2_tbre, uart2_tsre, uart2_read, uart2_write);

	boot: entity work.Boot
		port map(rst_boot, clk11, 
			start_addr, end_addr, ram2_start_addr, flash_addr_16, flash_data,
			CE0, BYTE, OE, WE, flash_ram2_addr, flash_ram2_data, flash_write_ram2,
			done);

	
	cpu0: entity work.CPU 
		port map (rst, clk_cpu, clk_stable, key_stable(3),
			mem_type, mem_addr, mem_write_data, mem_read_data, mem_busy, if_addr, if_data, if_canread, 
			switch, debug); 

	logger: entity work.IOLogger port map (rst, clk_cpu, debug.id_in.pc,
			mem_type, mem_addr, mem_write_data, mem_read_data, mem_busy, io);

end arch ; -- arch
