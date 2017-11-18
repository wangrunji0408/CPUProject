library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 访存模块
entity MEM is
	port (
		rst, clk: in std_logic;
		
		------ RAM1接口 ------

		ram1: out RamPort;
		ram1_datain: in u16;

		------ UART接口 ------

		uartIn: in UartFlags;
		uartOut: out UartCtrl;

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

end arch ; -- arch
