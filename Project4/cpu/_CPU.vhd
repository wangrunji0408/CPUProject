library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity CPU is
	port (
		rst, clk, btn0, btn1: in std_logic;
		cfg: in Config;
		
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
		debug: out CPUDebug;

		out_intt: in std_logic
	) ;
end CPU;

architecture arch of CPU is	

	signal out_for_if, if_in, ori_if_in: IF_Data;
	signal if_out, id_in: IF_ID_Data;
	signal id_out, ex_in: ID_EX_Data;
	signal ex_out, mem_in: EX_MEM_Data;
	signal reg1, reg2, mem_out: RegPort;	
	signal if_stallReq, mem_stallReq: std_logic;

	signal	sir6: SaveInR6;

	signal step: natural;
	signal mode: CPUMode;
	signal ctrls: MidCtrls;

	signal ifc_add, ifc_update, ifc_query, ifc_result: IFCachePort;

	signal reg_ihh, intt: std_logic;
	
begin

	debug.if_in <= if_in;
	debug.id_in <= id_in;
	debug.ex_in <= ex_in;
	debug.mem_in <= NULL_EX_MEM_Data;
	debug.mem_out <= mem_out;
	debug.step <= step;	
	debug.mode <= mode;
	debug.breakPointPC <= breakPointPC;

	ctrl0: entity work.Ctrl port map (rst, clk, btn0, btn1, 
			id_in.pc, breakPointPC,
			if_stallReq, mem_stallReq, ex_in.isLW, ex_in.writeReg.addr, reg1, reg2,
			ctrls, step, mode);	
	
	ifc: entity work.IFCache port map (rst, clk, ifc_add, ifc_update, ifc_query, ifc_result);

	if0: entity work.InstFetch port map (
			if_in.pc, if_in.branch, if_in.isRefetch,
			if_out.pc, if_out.inst, if_stallReq,
			ruc_if_addr, ruc_if_data, ruc_if_canread,
			ifc_add, ifc_query, ifc_result ); 
			out_for_if.pc <= if_out.pc;
			out_for_if.isRefetch <= if_stallReq;
	id0: entity work.ID port map (id_in.inst, id_in.pc, 
			reg1.enable, reg2.enable, reg1.addr, reg2.addr, reg1.data, reg2.data,
			out_for_if.branch, ex_out.writeReg, mem_out, 
			id_out.writeReg, id_out.isLW, id_out.isSW, id_out.writeMemData, id_out.aluInput,
			debug.instType);
	ex0: entity work.EX port map (ex_in, ex_out, ifc_update, cfg.com1_keyboard);

	mem_type <= mem_in.mem_type;
	mem_addr <= mem_in.mem_addr;
	mem_write_data <= mem_in.mem_write_data;
	mem_stallReq <= mem_busy;
	mem0: entity work.MEM port map (mem_read_data, mem_in.writeReg, mem_in.isLW, mem_in.isSW, mem_out);
	
	id_if0: entity work.ID_IF port map (rst, clk, ctrls(4), out_for_if, ori_if_in);
	if_id0: entity work.IF_ID port map (rst, clk, ctrls(3), if_out, id_in);
	id_ex0: entity work.ID_EX port map (rst, clk, ctrls(2), id_out, ex_in);
	ex_mem0: entity work.EX_MEM port map (rst, clk, ctrls(1), ex_out, mem_in);
	reg0: entity work.Reg port map (rst, clk, ctrls(0), 
			mem_out, reg1, reg2, reg1.data, reg2.data, debug.regs,
			sir6, reg_ihh);

	intt <= out_intt and reg_ihh;
	if_in.pc        <= ori_if_in.pc;
	if_in.isRefetch <= ori_if_in.isRefetch when out_intt='0' else '0';
	if_in.branch    <= ori_if_in.branch when out_intt='0' else 
					   ('1', x"0006");

	sir6.enable <= out_intt;
	sir6.pc <=  ori_if_in.branch.target when ori_if_in.branch.enable='1' else
				ori_if_in.pc;

	
end arch ; -- arch
