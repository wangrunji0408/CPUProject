library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity CPU is
	port (
		rst, clk, btn: in std_logic;
		step_mode: in std_logic;
		
		------ MEM访问RAM/串口的接口 ------
		mem_type: out MEMType;
		mem_addr: out u16;
		mem_write_data: out u16;
		mem_read_data: in u16;
		mem_busy: in std_logic;	-- 串口操作可能很慢，busy=1表示尚未完成
		------ IF读RAM2接口 ------
		if_addr: out u16;
		if_data: in u16;
		if_canread: in std_logic; -- 当MEM操作RAM2时不可读

		debug: out CPUDebug
	) ;
end CPU;

architecture arch of CPU is	

	signal branch: PCBranch;
	signal if_out, id_in: IF_ID_Data;
	signal reg1, reg2: RegPort;
	signal mem_out: RegPort;
	signal id_out, ex_in, ex_out, mem_in: ID_MEM_Data;
	signal id_out_aluInput, ex_in_aluInput: AluInput;
	signal ex_out_aluOut, mem_in_aluOut: u16;
	signal mem_stallReq: std_logic;
	signal stall, clear: std_logic_vector(4 downto 0);
	signal pause: std_logic;
	signal step: natural;
	
begin

	debug.step <= step;
	debug.branch <= branch;
	debug.id_in <= id_in;
	debug.ex_in <= ex_in;
	debug.mem_in <= mem_in;
	debug.mem_out <= mem_out;
	debug.ex_in_aluInput <= ex_in_aluInput;
	debug.mem_in_aluOut <= mem_in_aluOut;

	process( rst, clk )
		variable last_btn: std_logic;
	begin
		if rst = '0' then 
			step <= 0;
			last_btn := '1';
			pause <= '1';
		elsif rising_edge(clk) then
			if step_mode = '1' then
				pause <= '1';
				if last_btn = '0' and btn = '1' then -- press btn
					step <= step + 1;	
					pause <= '0';
				end if;
			else
				pause <= '0';
			end if;
			last_btn := btn;
		end if;
	end process ;

	pc0: entity work.PC port map (rst, clk, stall(4), branch, if_out.pc);
	if0: entity work.InstFetch port map (if_out.pc, if_out.inst, if_addr, if_data, if_canread);
	id0: entity work.ID port map (id_in.inst, id_in.pc, 
			reg1.enable, reg2.enable, reg1.addr, reg2.addr, reg1.data, reg2.data,
			branch, ex_out.writeReg, mem_out, 
			id_out.writeReg, id_out.isLW, id_out.isSW, id_out.writeMemData, id_out_aluInput,
			debug.instType);
	ex0: entity work.EX port map (ex_in_aluInput, ex_out_aluOut);	ex_out <= ex_in;
	mem0: entity work.MEM port map (
			mem_type, mem_addr, mem_write_data, mem_read_data, mem_busy,
			mem_stallReq, mem_in.writeReg, mem_in.isLW, mem_in.isSW, mem_in.writeMemData, 
			mem_in_aluOut, mem_out);
	reg0: entity work.Reg port map (rst, clk, mem_out, reg1, reg2, reg1.data, reg2.data, debug.regs);
	ctrl0: entity work.Ctrl port map (rst, pause, if_canread, mem_stallReq, ex_in.isLW, ex_in.writeReg.addr, reg1.addr, reg2.addr, stall, clear);

	if_id0: entity work.IF_ID port map (rst, clk, stall(3), clear(3),
			if_out.pc, if_out.inst, id_in.pc, id_in.inst);
	id_ex0: entity work.ID_EX port map (rst, clk, stall(2), clear(2),
			id_out.writeReg, id_out.isLW, id_out.isSW, id_out.writeMemData, id_out_aluInput,
			ex_in.writeReg, ex_in.isLW, ex_in.isSW, ex_in.writeMemData, ex_in_aluInput);
	ex_mem0: entity work.EX_MEM port map (rst, clk, stall(1), clear(1),
			ex_out.writeReg, ex_out.isLW, ex_out.isSW, ex_out.writeMemData, ex_out_aluOut,
			mem_in.writeReg, mem_in.isLW, mem_in.isSW, mem_in.writeMemData, mem_in_aluOut);
	
end arch ; -- arch
