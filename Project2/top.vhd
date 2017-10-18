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
		  flag: out std_logic
		);
	end component;

	signal op: u4;
	signal a, b ,s: u16;
	signal flag: std_logic;
	signal status: integer := 0;	

begin

	alu0: ALU port map (op, a, b, s, flag);

	process(clk,rst)
	begin
		if rst = '0'
		then 
			status <= 0;
		elsif rising_edge(clk)
		then 
			if status = 3
			then
				status <= 0;
			else
				status <= status + 1;
			end if;
		end if;
		
		if status = 0
		then
			a <= input;
		elsif status = 1
		then
			b <= input;
		elsif status = 2
		then
			op <= input(3 downto 0);
			fout <= s;
		elsif status = 3
		then
			fout <= (15 downto 0=>flag);
		end if;

	end process;

end arch ; -- arch
