library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 执行模块
entity EX is
	port (
		------ 从ID读入 ------
		ex_in: in ID_MEM_Data;
		aluInput: in AluInput;

		------ 输出到MEM ------
		ex_out: out ID_MEM_Data;
		aluOut: out u16
	) ;
end EX;

architecture arch of EX is	

	signal aluOut_t: u16;
begin

	alu0: entity work.Alu port map (aluInput.op, aluInput.a, aluInput.b, aluOut_t);

	aluOut <= aluOut_t;

	process( ex_in, aluOut_t )
	begin
		ex_out <= ex_in;
		if ex_in.writeReg.enable = '1' and ex_in.isLW = '0' then -- 用ALUout的值写寄存器
			ex_out.writeReg.data <= aluOut_t;
		end if;
	end process ;

end arch ; -- arch
