library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity IOLogger is
	port (
		rst, clk: in std_logic;
		pc: in u16;
		------ 对MEM接口 ------
		mem_type: in MEMType;
		mem_addr: in u16;
		mem_write_data: in u16;
		mem_read_data: in u16;
		mem_busy: in std_logic;		
		------ Debug ------
		info: buffer IODebug
	) ;
end IOLogger;

architecture arch of IOLogger is

	signal newEvent_f: boolean;
begin

	process( rst, clk )
		variable last_type: MEMType;
		variable last_addr: u16;
		variable newEvent, testAgain: boolean;
		variable data: u16;
		variable info_v: IODebug;
	begin
		info <= info_v;
		newEvent_f <= newEvent;

		if rst = '0' then
			info_v := (others => NULL_IOEVENT);
			last_type := None;
			last_addr := x"0000";
		elsif rising_edge(clk) then
			newEvent := mem_type /= None and (mem_type /= last_type or mem_addr /= last_addr);
			testAgain := (mem_type = TestUart and info_v(0).mode = TestUart) 
						or (mem_type = TestUart2 and info_v(0).mode = TestUart2);

			if newEvent and testAgain then
				info_v(0).data := mem_read_data;
			elsif newEvent then
				move : for i in 15 downto 1 loop
					info_v(i) := info_v(i-1);
				end loop ;

				if mem_type = ReadUart or mem_type = ReadRam1 or mem_type = ReadRam2 
					or mem_type = TestUart or mem_type = TestUart2 then
					data := mem_read_data;
				else
					data := mem_write_data;
				end if;

				info_v(0) := (pc, mem_type, mem_addr, data);
			end if;

			last_type := mem_type;
			last_addr := mem_addr;
		end if;
	end process ;

end arch ; -- arch
