library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity DataBuffer is
	port (
		rst, write, read, isBack: in std_logic; -- enable=0
		data_write: in u8;
		data_read: out u8;
		buf: buffer DataBufInfo
	) ;
end DataBuffer;

architecture arch of DataBuffer is		
begin

	process( rst, write, read )
		variable wp, rp: natural;
	begin
		buf.writePos <= wp; buf.readPos <= rp;
		if rst = '0' then
			buf.data <= (others => x"00");
			wp := 0; rp := 0;
		else
			if falling_edge(write) then
				if isBack = '1' then
					if wp = 0 then wp := 63; else wp := wp - 1; end if;
				else
					buf.data(buf.writePos) <= data_write;
					if wp = 63 then wp := 0; else wp := wp + 1; end if;
				end if;
			end if;
			if falling_edge(read) then
				data_read <= buf.data(rp);
				if rp = 63 then rp := 0; else rp := rp + 1; end if;
			end if;
		end if;
	end process ; -- 

end arch ; -- arch
