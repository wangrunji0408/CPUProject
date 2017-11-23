library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 访存模块
entity MEM is
	port (		
		------ 对外接口 ------

		mem_type: out MEMType;
		mem_addr: out u16;
		mem_write_data: out u16;
		mem_read_data: in u16;
		mem_busy: in std_logic;	-- 串口操作可能很慢，busy=1表示尚未完成

		------ 输出到Ctrl ------

		-- 当读串口时，请求暂停，直到data_ready
		stallReq: out std_logic;

		------ 从EX读入 ------

		writeReg: in RegPort;		
		isLW, isSW: in std_logic;
		writeMemData: in u16;
		aluOut: in u16;

		------ 输出到Reg ------

		writeRegOut: out RegPort
	) ;
end MEM;

architecture arch of MEM is	
begin

	-- BF01 0位：是否能写 1位：是否能读
	mem_type <= None;
	mem_addr <= x"0000";
	mem_write_data <= x"0000";
	stallReq <= mem_busy;
	writeRegOut <= (writeReg.enable, writeReg.addr, aluOut);

end arch ; -- arch
