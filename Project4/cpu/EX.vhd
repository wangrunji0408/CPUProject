library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 执行模块
entity EX is
	port (
		------ 从ID读入 ------
		aluInput: in AluInput;

		------ 输出到MEM ------
		aluOut: out u16
	) ;
end EX;

architecture arch of EX is	
begin

end arch ; -- arch
