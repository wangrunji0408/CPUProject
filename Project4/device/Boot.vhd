library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity Boot is
	port(
		rst, clk: in std_logic; -- rst is not real rst. give me rst=0 when want me work
		start_addr : in u16;
		-- FLASH --
		flash_addr: out u16; -- 22 downto 1, first 6 block
		flash_data: inout u16;
		flash_sr7: in std_logic;
		CE0, BYTE, OE, WE: out std_logic;
		-- RAM2 --
		ram2_addr: out u18;
		ram2_data: out u16;
		isWrite: out std_logic;
		done: out std_logic
	);
end Boot;

architecture arch of Boot is

	signal now_addr:u16;
	signal status: integer := 0;
	signal finish: std_logic;
	constant end_addr:u16 := x"0220";

begin
	CE0 <= '0';
	BYTE <= '1';
	

	process(rst, clk)
	begin
		if rst = '0'
		then
			done <= '0';
			finish <= '0';
			now_addr <= start_addr;
			status <= 0;
			OE <= '1';
			WE <= '1';
			isWrite <= '0';
		elsif rising_edge(clk) and finish = '0'
		then
			case(status) is
				when 0 =>
					if now_addr = end_addr
					then 
						done <= '1';
						finish <= '1';
					else
						isWrite <= '0';
						WE <= '0';
						flash_data <= x"00ff";
						status <= 1;
					end if;
				when 1=>
					WE <= '1';
					status <= 2;
				when 2=>
					OE <= '0';
					flash_addr <= now_addr;
					flash_data <= (others =>'Z');
					status <= 3;
				when 3 =>
					ram2_data <= flash_data;
					ram2_addr <= "00" & now_addr;
					status <= 4;
				when 4 =>
					if flash_sr7 = '1'
					then
						isWrite <= '1';
						OE <= '1';
						now_addr <= now_addr + 1;
						status <= 0;
					end if;
				when others => null;
			end case;
		end if;
	end process;

end arch;


