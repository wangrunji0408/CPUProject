library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 访存模块
entity MEM is
	port (		
		------ 对外接口 ------

		-- mem_type: out MEMType; --
		-- mem_addr: out u16;     --
		-- mem_write_data: out u16; --
		mem_read_data: in u16;

		------ 从EX读入 ------

		writeReg: in RegPort;		
		isLW, isSW: in std_logic;

		------ 输出到Reg ------

		writeRegOut: out RegPort
	) ;
end MEM;

architecture arch of MEM is	
	signal isCom: boolean;
begin

	-- BF01 0位：是否能写 1位：是否能读

	writeRegOut.enable <= writeReg.enable;
	writeRegOut.addr   <= writeReg.addr;

	writeRegOut.data <= mem_read_data when isLW = '1' else 
						x"0000" when isSW = '1' else
						writeReg.data ;

end arch ; -- arch
