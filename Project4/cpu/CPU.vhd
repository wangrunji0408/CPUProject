library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity CPU is
	port (
		clk, rst: in std_logic;
		
		ram1addr, ram2addr: out u18;
		ram1data, ram2data: inout u16;
		ram1read, ram1write, ram1enable: out std_logic;
		ram2read, ram2write, ram2enable: out std_logic;

		uart_data_ready, uart_tbre, uart_tsre: in std_logic;	-- UART flags 
		uart_read, uart_write: out std_logic					-- UART lock
	) ;
end CPU;

architecture arch of CPU is	

	component PC is
	port (
		rst, clk, stall: in std_logic;
		isOffset, isJump: in std_logic;
		offset, target: in u16;
		pc: out u16
	) ;
	end component;

	component InstFetch is
	port (
		rst, clk: in std_logic;
		pc: in u16;
		inst: out Inst;
		
		------ RAM2接口 ------
		ram2addr: out u18;
		ram2data: inout u16;
		ram2read, ram2write, ram2enable: out std_logic
	) ;
	end component;

	component ID is
	port (
		------ 从IF输入 ------
		inst: in Inst;
		pc: in u16;
		------ 寄存器接口 ------
		reg1_enable, reg2_enable: out std_logic;
		reg1_addr, reg2_addr: out u16;
		reg1_data, reg2_data: in u16;
		------ 输出到PC ------
		isOffset, isJump: out std_logic;
		offset, target: out u16;
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

	signal isOffset, isJump: std_logic;
	signal offset, target: u16;
	signal pc_value: u16;
	signal inst: Inst;
	signal reg1, reg2: RegPort;
	
begin

	pc0: PC port map (rst, clk, '0', isOffset, isJump, offset, target, pc_value);
	if0: InstFetch port map (rst, clk, pc_value, inst, ram2addr, ram2data, ram2read, ram2write, ram2enable);
	-- id0: ID port map (inst, pc_value, reg1.enable, reg2.enable, reg1.addr, reg2.addr, reg1.data, reg2.data,
						-- isOffset, isJump, offset, target);
	
end arch ; -- arch
