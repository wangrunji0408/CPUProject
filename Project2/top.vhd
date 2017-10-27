library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity Top is
	port (
		clk, rst: in std_logic;
		input: in u16;
		fout: out u16
	) ;
end Top;

architecture arch of Top is

	component ALU is
		port (
		  op: in u4;
		  a: in u16;
		  b: in u16;
		  s: out u16;
		  cf, zf, sf, vf: out std_logic
		);
	end component;

	signal op: u4;
	signal a, b ,s: u16;
	signal cf,zf,sf,vf: std_logic;
	signal status: integer := 0;	

begin

	alu0: ALU port map (op, a, b, s, cf,zf,sf,vf);

	process(clk,rst)
	begin
		if rst = '0'
		then 
			status <= 0;
			fout <= x"FFFF";
		elsif rising_edge(clk)
		then 
			status <= status + 1;
			if status = 0 then
				a <= input;
				fout <= input;
			elsif status = 1 then
				b <= input;
				fout <= input;
			elsif status = 2 then
				op <= input(3 downto 0);
				fout <= input;
			elsif status = 3 then
				fout <= s;
			elsif status = 4 then
				fout <= x"000" & cf & zf & sf & vf;
				--(
				--	15 downto 12=> cf,
				--	11 downto 8 => zf,
				--	7  downto 4 => sf,
				--	3  downto 0 => vf
				--);
				status <= 0;
			end if;
		end if;
	end process;

end arch ; -- arch
