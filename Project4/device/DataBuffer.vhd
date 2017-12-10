library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity DataBuffer is
	port (
		rst, write, read, isBack: in std_logic; -- enable=0
		canwrite, canread: out std_logic;
		data_write: in u8;
		data_read: out u8;
		buf: buffer DataBufInfo
	) ;
end DataBuffer;

architecture arch of DataBuffer is	
	function add(x: natural) return natural is
	begin if x = 31 then return 0; else return x + 1; end if;
	end function;

	function sub(x: natural) return natural is
	begin if x = 0 then return 31; else return x - 1; end if;
	end function;
begin

	canread <= '1' when buf.readPos /= buf.writePos else '0';
	canwrite <= '1' when add(buf.writePos) /= buf.readPos else '0';

	process( rst, write, read )
		variable wp, rp: natural;
	begin
		buf.writePos <= wp; buf.readPos <= rp;
		if rst = '0' then
			buf.data <= (others => x"00");
			wp := 0; rp := 0;
		else
			if rising_edge(write) then
				if isBack = '1' then
					wp := sub(wp);
				else
					buf.data(buf.writePos) <= data_write;
					wp := add(wp);
				end if;
			end if;
			if falling_edge(read) then
				data_read <= buf.data(rp);
				rp := add(rp);
			end if;
		end if;
	end process ; -- 

end arch ; -- arch
