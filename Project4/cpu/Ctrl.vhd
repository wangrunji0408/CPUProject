library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 控制模块
-- 接受MEM暂停请求，检测寄存器冲突，发出暂停指令
entity Ctrl is
	port (
		-- 全局重置/暂停
		rst, pause: in std_logic;
		-- 当IF无法取指时，暂停
		if_canread: in std_logic;
		-- 当MEM读串口时，请求暂停
		mem_stallReq: in std_logic;
		-- 当EX阶段指令为LW，且要写入的寄存器与ID阶段读寄存器冲突时，暂停ID及之前
		-- (其它写寄存器指令可走数据旁路解决冲突)
		ex_isLW: in std_logic;
		ex_writeReg: in RegAddr;
		id_readReg1, id_readReg2: in RegPort;
		-- 给挡板的暂停/清除信号 4PC 3IF/ID 2ID/EX 1EX/MEM 0Reg(Write)
		stall, clear: out std_logic_vector(4 downto 0) 
	) ;
end Ctrl;

architecture arch of Ctrl is	
begin
	process( rst, pause, ex_isLW, ex_writeReg, id_readReg1, id_readReg2, mem_stallReq )
	begin
		stall <= "00000";
		clear <= "00000";
		
		if rst = '0' then
			clear <= "11111";
		elsif pause = '1' then
			stall <= "11111";
		elsif mem_stallReq = '1' then
			stall <= "11110";
		elsif ex_isLW = '1' and ((id_readReg1.enable = '1' and ex_writeReg = id_readReg1.addr)
			 or (id_readReg2.enable = '1' and ex_writeReg = id_readReg2.addr)) then
			stall <= "11000";
			clear <= "00100";
		elsif if_canread = '0' then
			stall <= "10000";
			clear <= "01000";
		end if;
	end process ;

end arch ; -- arch
