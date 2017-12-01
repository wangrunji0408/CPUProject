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
	begin
		if rst = '0' then
			buf.data <= (others => x"00");
			buf.writePos <= 0; buf.readPos <= 0;
		else
			if falling_edge(write) then
				if isBack = '1' then
					buf.writePos <= buf.writePos - 1;
				else
					buf.data(buf.writePos) <= data_write;
					buf.writePos <= buf.writePos + 1;
				end if;
			end if;
			if falling_edge(read) then
				data_read <= buf.data(buf.readPos);	
				buf.readPos <= buf.readPos + 1;
			end if;
		end if;
	end process ; -- 

end arch ; -- arch
