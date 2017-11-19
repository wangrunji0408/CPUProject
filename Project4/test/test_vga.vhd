library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestVGA is
end TestVGA;

architecture arch of TestVGA is

	signal rst, clk_vga: std_logic;
	signal color, color_out: TColor;
	signal vga_hs, vga_vs: std_logic;
	signal vga_x, vga_y: natural;

begin
	vga1: entity work.vga_controller 
		--generic map (1440,80,152,232,'0',900,1,3,28,'1') -- 60Hz clk=106Mhz
		-- generic map (1024,24,136,160,'0',768,3,6,29,'0') -- 60Hz clk=65Mhz
		generic map (640,16,96,48,'0',480,10,2,33,'0') -- 60Hz clk=25Mhz		
	port map (clk_vga, rst, color, color_out, vga_hs, vga_vs, vga_x, vga_y);

	process
	begin
		clk_vga <= '0'; wait for 20 ns;
		clk_vga <= '1'; wait for 20 ns;
	end process;

	process
	begin
		rst <= '0';	wait for 10 ns;
		rst <= '1';	wait for 10 ns;
		wait for 20 ms;
		assert(false) report "Test End" severity error;
		wait;
	end process;

end arch ; -- arch
