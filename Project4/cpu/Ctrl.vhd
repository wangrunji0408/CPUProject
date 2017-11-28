library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 控制模块
-- 响应外部输入，生成控制信号
-- 在运行时：接受MEM暂停请求，检测寄存器冲突，发出暂停指令
entity Ctrl is
	port (
		-- 控制信号
		rst, clk, btn0, btn1: in std_logic;
		-- 断点PC
		pc: in u16;
		breakPointPC: in u16;
		-- 当IF无法取指时，暂停
		if_canread: in std_logic;
		-- 当MEM读串口时，请求暂停
		mem_stallReq: in std_logic;
		-- 当EX阶段指令为LW，且要写入的寄存器与ID阶段读寄存器冲突时，暂停ID及之前
		-- (其它写寄存器指令可走数据旁路解决冲突)
		ex_isLW: in std_logic;
		ex_writeReg: in RegAddr;
		id_readReg1, id_readReg2: in RegPort;
		-- 给挡板的信号 4/IF 3IF/ID 2ID/EX 1EX/MEM 0Reg(Write)
		ctrls: out MidCtrls;
		count: buffer natural;
		mode: buffer CPUMode
	) ;
end Ctrl;

architecture arch of Ctrl is
	signal gctrl: MidCtrl;
begin
	process( gctrl, ex_isLW, ex_writeReg, id_readReg1, id_readReg2, mem_stallReq, if_canread, pc, breakPointPC, mode )
	begin
		-- 注意
		-- IF IF/ID 的控制必须同步
		--   因为IF依赖于ID的跳转信号
		if gctrl /= PASS then
			ctrls <= (others => gctrl);
		elsif mode = BREAK_POINT and pc = breakPointPC then
			ctrls <= (others => STALL);
		elsif mem_stallReq = '1' then
			ctrls <= (STALL, STALL, STALL, STALL, PASS);
		elsif ex_isLW = '1' and ((id_readReg1.enable = '1' and ex_writeReg = id_readReg1.addr)
			 or (id_readReg2.enable = '1' and ex_writeReg = id_readReg2.addr)) then
			ctrls <= (STALL, STALL, CLEAR, PASS, PASS);
		elsif if_canread = '0' then
			ctrls <= (STALL, STALL, CLEAR, PASS, PASS);
		else
			ctrls <= (others => PASS);		
		end if;
	end process ;

	process( rst, clk )
		variable last_btn0, last2_btn0, last_btn1: std_logic;
		variable btn0_t: std_logic_vector(2 downto 0);
	begin
		if rst = '0' then 
			gctrl <= CLEAR;
			mode <= STEP; 
			count <= 0;
			last_btn0 := '1';
			last2_btn0 := '1'; 
			last_btn1 := '1'; 
		elsif rising_edge(clk) then

			-- 按钮控制 btn0
			btn0_t := last2_btn0 & last_btn0 & btn0;
			case btn0_t is
				when "111" => 							-- 不按按钮时 ...
					if mode = STEP then	
						gctrl <= STALL;
					elsif mode = BREAK_POINT then
						gctrl <= PASS;
					end if;
				when "110" => 		gctrl <= STORE;		-- 按下按钮时 暂存输出
				when "000"|"100" => gctrl <= CLEAR;		-- 按住按钮时 清空
				when "001" => 		gctrl <= RESTORE;	-- 松开按钮时 恢复输出
				when "011" => 		gctrl <= PASS;		-- 下一周期时 正常
				when others => null;
			end case ;

			-- 计数
			if gctrl = PASS then
				count <= count + 1;
			end if;

			-- 切换模式 btn1
			if last_btn1 = '0' and btn1 = '1' then
				if mode = STEP then mode <= BREAK_POINT;
				else 				mode <= STEP; 
				end if;
			end if;
			
			last2_btn0 := last_btn0;
			last_btn0 := btn0;
			last_btn1 := btn1;
		end if;
	end process ;

end arch ; -- arch
