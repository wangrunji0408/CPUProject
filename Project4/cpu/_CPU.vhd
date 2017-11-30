library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity CPU is
	port (
		rst, clk, btn0, btn1: in std_logic;
		
		------ MEM访问RAM/串口的接口 ------
		mem_type: out MEMType;
		mem_addr: out u16;
		mem_write_data: out u16;
		mem_read_data: in u16;
		mem_busy: in std_logic;	-- 串口操作可能很慢，busy=1表示尚未完成
		------ IF读RAM2接口 ------
		ruc_if_addr: out u16;
		ruc_if_data: in u16;
		ruc_if_canread: in std_logic; -- 当MEM操作RAM2时不可读

		breakPointPC: in u16;
		debug: out CPUDebug
	) ;
end CPU;

architecture arch of CPU is	

	signal out_for_if, if_in: IF_Data;
	signal if_out, id_in: IF_ID_Data;
	signal id_out, ex_in, ex_out, mem_in: ID_MEM_Data;
	signal id_out_aluInput, ex_in_aluInput: AluInput;
	signal ex_out_aluOut, mem_in_aluOut: u16;
	signal reg1, reg2, mem_out: RegPort;	
	signal mem_stallReq: std_logic;

	signal step: natural;
	signal mode: CPUMode;
	signal ctrls: MidCtrls;
	
begin

	debug.if_in <= if_in;
	debug.id_in <= id_in;
	debug.ex_in <= ex_in;
	debug.mem_in <= mem_in;
	debug.mem_out <= mem_out;
	debug.ex_in_aluInput <= ex_in_aluInput;
	debug.mem_in_aluOut <= mem_in_aluOut;
	debug.step <= step;	
	debug.mode <= mode;
	debug.breakPointPC <= breakPointPC;

	ctrl0: entity work.Ctrl port map (rst, clk, btn0, btn1, 
		id_in.pc, breakPointPC,
		ruc_if_canread, mem_stallReq, ex_in.isLW, ex_in.writeReg.addr, reg1, reg2,
		ctrls, step, mode);	

	if0: entity work.InstFetch port map (
			if_in.pc, if_in.branch, 
			if_out.pc, if_out.inst, 
			ruc_if_addr, ruc_if_data, ruc_if_canread); out_for_if.pc <= if_out.pc;
	id0: entity work.ID port map (id_in.inst, id_in.pc, 
			reg1.enable, reg2.enable, reg1.addr, reg2.addr, reg1.data, reg2.data,
			out_for_if.branch, ex_out.writeReg, mem_out, 
			id_out.writeReg, id_out.isLW, id_out.isSW, id_out.writeMemData, id_out_aluInput,
			debug.instType);
	ex0: entity work.EX port map (ex_in, ex_in_aluInput, ex_out, ex_out_aluOut);	
	mem0: entity work.MEM port map (
			mem_type, mem_addr, mem_write_data, mem_read_data, mem_busy,
			mem_stallReq, mem_in.writeReg, mem_in.isLW, mem_in.isSW, mem_in.writeMemData, 
			mem_in_aluOut, mem_out);
	
	id_if0: entity work.ID_IF port map (rst, clk, ctrls(4), out_for_if, if_in);
	if_id0: entity work.IF_ID port map (rst, clk, ctrls(3), if_out, id_in);
	id_ex0: entity work.ID_EX port map (rst, clk, ctrls(2),
			id_out.writeReg, id_out.isLW, id_out.isSW, id_out.writeMemData, id_out_aluInput,
			ex_in.writeReg, ex_in.isLW, ex_in.isSW, ex_in.writeMemData, ex_in_aluInput);
	ex_mem0: entity work.EX_MEM port map (rst, clk, ctrls(1),
			ex_out.writeReg, ex_out.isLW, ex_out.isSW, ex_out.writeMemData, ex_out_aluOut,
			mem_in.writeReg, mem_in.isLW, mem_in.isSW, mem_in.writeMemData, mem_in_aluOut);
	reg0: entity work.Reg port map (rst, clk, ctrls(0), 
			mem_out, reg1, reg2, reg1.data, reg2.data, debug.regs);
	
end arch ; -- arch
