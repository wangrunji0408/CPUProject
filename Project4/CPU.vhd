library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity CPU is
	port (
		clk, rst: in std_logic;
		
		ram1, ram2: out RamPort;
		ram1_datain, ram2_datain: in u16;

		uartIn: in UartFlags;
		uartOut: out UartCtrl
	) ;
end CPU;

architecture arch of CPU is	

	type IF_ID_Data is record
		pc: u16;
		inst: Inst;
	end record;

	type ID_MEM_Data is record
		writeReg: RegPort;
		isLW: std_logic;
		isSW: std_logic;
		writeMemData: u16;
	end record;

	signal branch: PCBranch;
	signal pc_value: u16;
	signal inst: Inst;
	signal reg1, reg2: RegPort;
	signal mem_out: RegPort;
	signal id_out, ex_in, ex_out, mem_in: ID_MEM_Data;
	signal id_out_aluInput, ex_in_aluInput: AluInput;
	signal ex_out_aluOut, mem_in_aluOut: u16;
	signal mem_stallReq: std_logic;
	
begin

	pc0: entity work.PC port map (rst, clk, '0', branch, pc_value);
	if0: entity work.InstFetch port map (rst, clk, pc_value, inst, ram2, ram2_datain);
	id0: entity work.ID port map (inst, pc_value, reg1.enable, reg2.enable, reg1.addr, reg2.addr, reg1.data, reg2.data,
						branch, ex_out.writeReg, mem_out, 
						id_out.writeReg, id_out.isLW, id_out.isSW, id_out.writeMemData, 
						id_out_aluInput);
	ex0: entity work.EX port map (ex_in_aluInput, ex_out_aluOut);	ex_out <= ex_in;
	mem0: entity work.MEM port map (rst, clk, ram1, ram1_datain, uartIn, uartOut, mem_stallReq, 
						mem_in.writeReg, mem_in.isLW, mem_in.isSW, mem_in.writeMemData, 
						mem_in_aluOut, mem_out);
	reg0: entity work.Reg port map (rst, clk, mem_out, reg1, reg2);
	
end arch ; -- arch
