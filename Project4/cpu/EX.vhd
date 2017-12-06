library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 执行模块
entity EX is
	port (
		------ 从ID读入 ------
		ex_in: in ID_EX_Data;

		------ 输出到MEM ------
		ex_out: out EX_MEM_Data;
		cache_update: out IFCachePort		
	) ;
end EX;

architecture arch of EX is	
	signal isCom: boolean;
	signal aluOut: u16;
	alias isLW: std_logic is ex_in.isLW;
	alias isSW: std_logic is ex_in.isSW;
begin

	alu0: entity work.Alu port map (ex_in.aluInput.op, ex_in.aluInput.a, ex_in.aluInput.b, aluOut);

	process( ex_in, aluOut )
	begin
		ex_out.writeReg <= ex_in.writeReg;
		if ex_in.writeReg.enable = '1' and ex_in.isLW = '0' then -- 用ALUout的值写寄存器
			ex_out.writeReg.data <= aluOut;
		end if;
	end process ;

	-- 写RAM2时，更新取指缓存
	cache_update <= ('1', aluOut, ex_in.writeMemData) when isSW = '1' and aluOut(15 downto 14) = "01"
					else NULL_IFCACHEPORT;

	ex_out.isLW <= isLW;
	ex_out.isSW <= isSW;

	isCom <= aluOut(15 downto 4) = x"bf0";
	ex_out.mem_type <= ReadUart when isLW = '1' and aluOut = x"bf00" else
						WriteUart when isSW = '1' and aluOut = x"bf00" else
						TestUart when isLW = '1' and aluOut = x"bf01" else
						ReadUart2 when isLW = '1' and aluOut = x"bf02" else
						WriteUart2 when isSW = '1' and aluOut = x"bf02" else
						TestUart2 when isLW = '1' and aluOut = x"bf03" else
						ReadBuf when isLW = '1' and aluOut = x"bf04" else
						WriteBuf when isSW = '1' and aluOut = x"bf04" else
						TestBuf when isLW = '1' and aluOut = x"bf05" else
						None when isCom else
						ReadRam2 when isLW = '1' and aluOut(15) = '0' else
						ReadRam1 when isLW = '1' else
						None when isSW = '1' and aluOut(15 downto 14) = "00" else -- Can not write < 0x4000
						WriteRam2 when isSW = '1' and aluOut(15) = '0' else
						WriteRam1 when isSW = '1' else
						None;
	ex_out.mem_addr <= aluOut when (isLW = '1' or isSW = '1') and not isCom else 
						x"0000";
	ex_out.mem_write_data <= ex_in.writeMemData when isSW = '1' and (not isCom or aluOut = x"bf00" or aluOut = x"bf02" or aluOut = x"bf04") else 
								x"0000";

	-- process( isLW, isSW, aluOut )
	-- 	variable mem_type: MEMType;
	-- begin
	-- 	ex_out.mem_type <= mem_type;
	-- 	mem_type := None;
	-- 	if isLW = '1' then
	-- 		if aluOut(15) = '0' then
	-- 			mem_type := ReadRam2;
	-- 		else
	-- 			mem_type := ReadRam1;
	-- 		end if;
	-- 		case( aluOut ) is
	-- 			when x"bf00" => mem_type := ReadUart;
	-- 			when x"bf01" => mem_type := TestUart;
	-- 			when x"bf02" => mem_type := ReadUart2;
	-- 			when x"bf03" => mem_type := TestUart2;				
	-- 			when x"bf04" => mem_type := ReadBuf;
	-- 			when x"bf05" => mem_type := TestBuf;
	-- 			when others => null;
	-- 		end case ;
	-- 	elsif isSW = '1' then
	-- 		if aluOut(15) = '0' then
	-- 			mem_type := WriteRam2;
	-- 		else
	-- 			mem_type := WriteRam1;
	-- 		end if;
	-- 		case( aluOut ) is
	-- 			when x"bf00" => mem_type := WriteUart;
	-- 			when x"bf02" => mem_type := WriteUart2;
	-- 			when x"bf04" => mem_type := WriteBuf;
	-- 			when others => null;
	-- 		end case ;
	-- 		if aluOut(15 downto 14) = "00" then
	-- 			mem_type := None; -- Can not write < 0x4000
	-- 		end if;
	-- 	end if;
	-- end process ; -- identifier

end arch ; -- arch
