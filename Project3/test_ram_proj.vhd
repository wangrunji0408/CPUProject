library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestRamProj is
end TestRamProj;

architecture arch of TestRamProj is	

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
	signal switch: u16;
	signal light: u16;
	
	signal ram1addr, ram2addr: u18;
	signal ram1data, ram2data: u16;
	signal ram1read, ram1write, ram1enable: std_logic;
	signal ram2read, ram2write, ram2enable: std_logic;

	signal digit0, digit1: u4;

begin
	ramproj0: RamProj port map (clk, rst, switch, light,
								ram1addr, ram2addr, ram1data, ram2data, 
								ram1read, ram1write, ram1enable, ram2read, ram2write, ram2enable,
								digit0, digit1);
	ram1: FakeRam port map (ram1addr, ram1data, ram1read, ram1write, ram1enable);
	ram2: FakeRam port map (ram2addr, ram2data, ram2read, ram2write, ram2enable);

	process
	begin
		-- init
		rst <= '1'; clk <= '1';
		switch <= to_u16(0);

		press(rst);		
		for i in 0 to 50 loop 
			press(clk); 
		end loop ;

		assert(false) report "RamProj: Test Success." severity note;
		wait;
	end process ;
end arch ; -- arch
