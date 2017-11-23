library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 访存模块
entity MEM is
	port (		
		------ 对外接口 ------

		mem_type: out MEMType; --
		mem_addr: out u16;     --
		mem_write_data: out u16; --
		mem_read_data: in u16;
		mem_busy: in std_logic;	-- 串口操作可能很慢，busy=1表示尚未完成

		------ 输出到Ctrl ------

		-- 当读串口时，请求暂停，直到data_ready
		stallReq: out std_logic; --

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
	stallReq <= mem_busy;

	writeRegOut.enable <= writeReg.enable;
	writeRegOut.addr   <= writeReg.addr;

	mem_type <= ReadUart when isLW = '1' and aluOut = x"bf00" else
			   WriteUart when isSW = '1' and aluOut = x"bf00" else
			   ReadRam2 when isLW = '1' and aluOut < x"8000" else
			   ReadRam1 when isLW = '1' else
			   WriteRam2 when isSW = '1' and aluOut < x"8000" else
			   WriteRam1 when isSW = '1' else
			   None;
	mem_addr <= aluOut when isLW = '1' or isSW = '1' else 
				x"0000";
	writeRegOut.data <= x"0003" when isLW = '1' and aluOut = x"bf01" else 
						mem_read_data when isLW = '1' else 
						x"0000" when isSW = '1' else
						aluOut ;
	mem_write_data <= writeMemData when isSW = '1' else 
						x"0000";


--	if isLW = '1'
--	then
--		if aluOut > x"bf01"
--		then 
--			mem_type = None;
--		elsif aluOut = x"bf01"
--		then
--			mem_type = None;
--			writeRegOut.data <= (0=>mem_busy, others=>'0');
--		elsif aluOut = x"bf00"
--		then
--			mem_type = ReadUart;
--			writeRegOut.data <= mem_read_data;
--		else
--			mem_type = ReadRam1 when aluOut<x"8000" else ReadRam2;
--			mem_addr <= aluOut;
--			writeRegOut.data <= mem_read_data;
--		end if;
--	elsif isSW = '1'
--	then
--		if aluOut > x"bf00"
--		then
--			mem_type = None;
--		elsif aluOut = x"bf00"
--		then
--			mem_type = WriteUart;
--			mem_write_data <= writeReg.data;
--		end if;
--	end if;
--			

end arch ; -- arch
