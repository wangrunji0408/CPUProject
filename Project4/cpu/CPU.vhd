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

	component PC is
	port (
		rst, clk, stall: in std_logic;
		branch: in PCBranch;
		pc: out u16
	) ;
	end component;

	component InstFetch is
	port (
		rst, clk: in std_logic;
		pc: in u16;
		inst: out Inst;
		
		------ RAM2接口 ------
		ram2: out RamPort;
		ram2_datain: in u16
	) ;
	end component;

	component ID is
	port (
		------ 从IF输入 ------
		inst: in Inst;
		pc: in u16;
		------ 寄存器接口 ------
		reg1_enable, reg2_enable: out std_logic;
		reg1_addr, reg2_addr: out RegAddr;
		reg1_data, reg2_data: in u16;
		------ 输出到PC ------
		branch: out PCBranch;
		------ 旁路信息输入 ------
		exeWriteReg, memWriteReg: in RegPort;
		------ 输出到MEM ------
		writeReg: out RegPort;
		isLW: out std_logic;
		isSW: out std_logic;
		writeMemData: out u16;
		------ 输出到EX ------
		aluInput: out AluInput
	) ;
	end component;

	component EX is
	port (
		aluInput: in AluInput;
		aluOut: out u16
	) ;
	end component;

	component MEM is
	port (
		rst, clk: in std_logic;
		------ RAM1接口 ------
		ram1: out RamPort;
		ram1_datain: in u16;
		------ UART接口 ------
		uartIn: in UartFlags;
		uartOut: out UartCtrl;
		------ 输出到Ctrl ------
		stallReq: out std_logic;
		------ 从EX读入 ------
		writeReg: in RegPort;		
		isLW, isSW: in std_logic;
		writeMemData: in u16;
		aluOut: in u16;
		------ 输出到Reg ------
		writeRegOut: out RegPort
	) ;
	end component;

	component Reg is
	port (
		rst, clk: in std_logic;		
		write: in RegPort;
		read1, read2: in RegPort;	-- read.data is null, unable to read.
		read1_dataout, read2_dataout: out u16
	) ;
	end component;

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

	pc0: PC port map (rst, clk, '0', branch, pc_value);
	if0: InstFetch port map (rst, clk, pc_value, inst, ram2, ram2_datain);
	id0: ID port map (inst, pc_value, reg1.enable, reg2.enable, reg1.addr, reg2.addr, reg1.data, reg2.data,
						branch, ex_out.writeReg, mem_out, 
						id_out.writeReg, id_out.isLW, id_out.isSW, id_out.writeMemData, 
						id_out_aluInput);
	ex0: EX port map (ex_in_aluInput, ex_out_aluOut);	ex_out <= ex_in;
	mem0: MEM port map (rst, clk, ram1, ram1_datain, uartIn, uartOut, mem_stallReq, 
						mem_in.writeReg, mem_in.isLW, mem_in.isSW, mem_in.writeMemData, 
						mem_in_aluOut, mem_out);
	reg0: Reg port map (rst, clk, mem_out, reg1, reg2);
	
end arch ; -- arch
