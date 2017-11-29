library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestMEM is
end TestMEM;

architecture arch of TestMEM is

	type TestCase is record
		-- input
		writeReg: RegPort;		
		isLW, isSW: std_logic;
		writeMemData: u16;
		aluOut: u16;
		mem_read_data: u16;
		mem_busy: std_logic;
		-- output
		stallReq: std_logic;	
		writeRegOut: RegPort;
		mem_type: MEMType;
		mem_addr: u16;
		mem_write_data: u16;
	end record;

	signal p: TestCase;
	
	type TestCases is array (0 to 15) of TestCase;

	constant cases: TestCases := ( -- 每个test_case对应一个时钟周期
		( -- 只写寄存器
			writeReg => ('1', x"B", x"0000"),	
			isLW => '0',
			isSW => '0',
			writeMemData => x"0000",
			aluOut => x"ABCD",
			mem_read_data => x"0000",
			mem_busy => '0',
			-- output
			stallReq => '0',	
			writeRegOut => ('1', x"B", x"ABCD"),
			mem_type => None,
			mem_addr => x"0000",
			mem_write_data => x"0000"
		),
		( -- 读指令区
			writeReg => ('1', x"2", x"0000"),	
			isLW => '1',
			isSW => '0',
			writeMemData => x"0000",
			aluOut => x"4002",
			mem_read_data => x"ABCD",
			mem_busy => '0',
			-- output
			stallReq => '0',	
			writeRegOut => ('1', x"2", x"ABCD"),
			mem_type => ReadRAM2,
			mem_addr => x"4002",
			mem_write_data => x"0000"
		),
		( -- 读数据区
			writeReg => ('1', x"3", x"0000"),	
			isLW => '1',
			isSW => '0',
			writeMemData => x"0000",
			aluOut => x"8002",
			mem_read_data => x"DCBA",
			mem_busy => '0',
			-- output
			stallReq => '0',	
			writeRegOut => ('1', x"3", x"DCBA"),
			mem_type => ReadRAM1,
			mem_addr => x"8002",
			mem_write_data => x"0000"
		),
		( -- 写系统程序（禁止）
			writeReg => NULL_REGPORT,	
			isLW => '0',
			isSW => '1',
			writeMemData => x"ABCD",
			aluOut => x"0001",
			mem_read_data => x"0000",
			mem_busy => '0',
			-- output
			stallReq => '0',
			writeRegOut => NULL_REGPORT,
			mem_type => None,
			mem_addr => x"0001",
			mem_write_data => x"ABCD"
		),
		( -- 写用户程序
			writeReg => NULL_REGPORT,	
			isLW => '0',
			isSW => '1',
			writeMemData => x"ABCD",
			aluOut => x"4001",
			mem_read_data => x"0000",
			mem_busy => '0',
			-- output
			stallReq => '0',
			writeRegOut => NULL_REGPORT,
			mem_type => WriteRAM2,
			mem_addr => x"4001",
			mem_write_data => x"ABCD"
		),
		( -- 写数据区
			writeReg => NULL_REGPORT,	
			isLW => '0',
			isSW => '1',
			writeMemData => x"DCBA",
			aluOut => x"8002",
			mem_read_data => x"0000",
			mem_busy => '0',
			-- output
			stallReq => '0',
			writeRegOut => NULL_REGPORT,
			mem_type => WriteRAM1,
			mem_addr => x"8002",
			mem_write_data => x"DCBA"
		),
		( -- 读串口 BF00
			writeReg => ('1', x"2", x"0000"),
			isLW => '1',
			isSW => '0',
			writeMemData => x"0000",
			aluOut => x"BF00",
			mem_read_data => x"ABCD",
			mem_busy => '0',
			-- output
			stallReq => '0',
			writeRegOut => ('1', x"2", x"ABCD"),
			mem_type => ReadUart,
			mem_addr => x"0000",
			mem_write_data => x"0000"
		),
		( -- 读串口 BF01
			writeReg => ('1', x"2", x"0000"),
			isLW => '1',
			isSW => '0',
			writeMemData => x"0000",
			aluOut => x"BF01",
			mem_read_data => x"0003",
			mem_busy => '0',
			-- output
			stallReq => '0',
			writeRegOut => ('1', x"2", x"0003"),
			mem_type => TestUart,
			mem_addr => x"0000",
			mem_write_data => x"0000"
		),
		( -- 读串口 BF02
			writeReg => ('1', x"2", x"0000"),
			isLW => '1',
			isSW => '0',
			writeMemData => x"0000",
			aluOut => x"BF02",
			mem_read_data => x"ABCD",
			mem_busy => '0',
			-- output
			stallReq => '0',
			writeRegOut => ('1', x"2", x"ABCD"),
			mem_type => ReadUart2,
			mem_addr => x"0000",
			mem_write_data => x"0000"
		),
		( -- 读串口 BF03
			writeReg => ('1', x"2", x"0000"),
			isLW => '1',
			isSW => '0',
			writeMemData => x"0000",
			aluOut => x"BF03",
			mem_read_data => x"0002",
			mem_busy => '0',
			-- output
			stallReq => '0',
			writeRegOut => ('1', x"2", x"0002"),
			mem_type => TestUart2,
			mem_addr => x"0000",
			mem_write_data => x"0000"
		),
		( -- 读串口 busy
			writeReg => ('1', x"2", x"0000"),
			isLW => '1',
			isSW => '0',
			writeMemData => x"0000",
			aluOut => x"BF00",
			mem_read_data => x"0000",
			mem_busy => '1',
			-- output
			stallReq => '1',
			writeRegOut => ('1', x"2", x"0000"),
			mem_type => ReadUart,
			mem_addr => x"0000",
			mem_write_data => x"0000"
		),
		( -- 写串口 BF00
			writeReg => NULL_REGPORT,
			isLW => '0',
			isSW => '1',
			writeMemData => x"00AB",
			aluOut => x"BF00",
			mem_read_data => x"0000",
			mem_busy => '0',
			-- output
			stallReq => '0',
			writeRegOut => NULL_REGPORT,
			mem_type => WriteUart,
			mem_addr => x"0000",
			mem_write_data => x"00AB"
		),
		( -- 写串口 BF02
			writeReg => NULL_REGPORT,
			isLW => '0',
			isSW => '1',
			writeMemData => x"00AB",
			aluOut => x"BF02",
			mem_read_data => x"0000",
			mem_busy => '0',
			-- output
			stallReq => '0',
			writeRegOut => NULL_REGPORT,
			mem_type => WriteUart2,
			mem_addr => x"0000",
			mem_write_data => x"00AB"
		),
		( -- 写串口 BF01 无效
			writeReg => NULL_REGPORT,
			isLW => '0',
			isSW => '1',
			writeMemData => x"00AB",
			aluOut => x"BF01",
			mem_read_data => x"0000",
			mem_busy => '0',
			-- output
			stallReq => '0',
			writeRegOut => NULL_REGPORT,
			mem_type => None,
			mem_addr => x"0000",
			mem_write_data => x"0000"
		),
		( -- 写串口 BF03 无效
			writeReg => NULL_REGPORT,
			isLW => '0',
			isSW => '1',
			writeMemData => x"00AB",
			aluOut => x"BF03",
			mem_read_data => x"0000",
			mem_busy => '0',
			-- output
			stallReq => '0',
			writeRegOut => NULL_REGPORT,
			mem_type => None,
			mem_addr => x"0000",
			mem_write_data => x"0000"
		),
		( -- 写串口 busy
			writeReg => NULL_REGPORT,
			isLW => '0',
			isSW => '1',
			writeMemData => x"00AB",
			aluOut => x"BF00",
			mem_read_data => x"0000",
			mem_busy => '1',
			-- output
			stallReq => '1',
			writeRegOut => NULL_REGPORT,
			mem_type => WriteUart,
			mem_addr => x"0000",
			mem_write_data => x"00AB"
		)
	);

begin
	
	mem0: entity work.MEM port map (
		p.mem_type, p.mem_addr, p.mem_write_data, p.mem_read_data, p.mem_busy,
		p.stallReq, p.writeReg, p.isLW, p.isSW, p.writeMemData, 
		p.aluOut, p.writeRegOut);

	process
		variable std: TestCase;
	begin
		for i in cases'length loop
			std := cases(i);
			p.writeReg <= std.writeReg;	
			p.isLW <= std.isLW;	
			p.isSW <= std.isSW;	
			p.writeMemData <= std.writeMemData;	
			p.aluOut <= std.aluOut;	
			p.mem_read_data <= std.mem_read_data;	
			p.mem_busy <= std.mem_busy;	
			wait for 18 ns;

			assert p.stallReq = std.stallReq
				report "Failed at case " & integer'image(i) & ". stallReq"
				severity error;
			assert p.writeRegOut = std.writeRegOut
				report "Failed at case " & integer'image(i) & ". writeRegOut"
				severity error;
			assert p.mem_type = std.mem_type
				report "Failed at case " & integer'image(i) & ". mem_type " & MEMTYPE'image(p.mem_type) & "!=" & MEMTYPE'image(std.mem_type)
				severity error;
			assert p.mem_addr = std.mem_addr
				report "Failed at case " & integer'image(i) & ". mem_addr " & toStr16(p.mem_addr) &"!="& toStr16(std.mem_addr)
				severity error;
			assert p.mem_write_data = std.mem_write_data
				report "Failed at case " & integer'image(i) & ". mem_write_data " & toStr16(p.mem_write_data) & "!=" & toStr16(std.mem_write_data)
				severity error;
			wait for 2 ns;

		end loop ; -- 

		assert(false) report "Test End" severity error;
		wait;
	end process;

end arch ; -- arch
