library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestID is
end TestID;

architecture arch of TestID is

	type TestCase is record
		-- description
		title: string(1 to 10);
		-- input
		inst: Inst;
		pc: u16;
		exe_writeReg: RegPort;
		mem_writeReg: RegPort;
		-- output
		reg1, reg2: RegPort;	-- .data is input
		branch: PCBranch;	
		writeReg: RegPort;
		isLW: std_logic;
		isSW: std_logic;
		writeMemData: u16;
		aluInput: AluInput;
	end record;

	signal clk, rst: std_logic;	
	signal p: TestCase;
	signal regData: RegData := (others => x"0000");
	
	type TestCases is array (0 to 1) of TestCase;

	constant cases: TestCases := ( -- 每个test_case对应一个时钟周期
		(
			title => "ADDIU     ",
			inst => INST_ADDIU & o"2" & x"FF",
			pc => x"0000",
			exe_writeReg => NULL_REGPORT,
			mem_writeReg => NULL_REGPORT,
			-- output
			reg1 => ('1', x"2", x"0002"),
			reg2 => NULL_REGPORT,
			branch => NULL_PCBRANCH,	
			writeReg => ('1', x"2", x"0000"),
			isLW => '0',
			isSW => '0',
			writeMemData => x"0000",
			aluInput => (OP_ADD, x"0002", x"FFFF")
		),
		(
			title => "ADDIU     ",
			inst => INST_ADDIU & o"2" & x"FF",
			pc => x"0000",
			exe_writeReg => NULL_REGPORT,
			mem_writeReg => NULL_REGPORT,
			-- output
			reg1 => ('1', x"2", x"0002"),
			reg2 => NULL_REGPORT,
			branch => NULL_PCBRANCH,	
			writeReg => ('1', x"2", x"0000"),
			isLW => '0',
			isSW => '0',
			writeMemData => x"0000",
			aluInput => (OP_ADD, x"0002", x"FFFF")
		)
	);

begin
	
	reg0: entity work.MockReg port map (p.reg1, p.reg2, p.reg1.data, p.reg2.data, regData);
	make_reg_data: for i in 0 to 15 generate
		regData(i) <= to_u16(i);
	end generate ;

	id0: entity work.ID port map (p.inst, p.pc, 
			p.reg1.enable, p.reg2.enable, p.reg1.addr, p.reg2.addr, p.reg1.data, p.reg2.data,
			p.branch, p.exe_writeReg, p.mem_writeReg, 
			p.writeReg, p.isLW, p.isSW, p.writeMemData, 
			p.aluInput);

	process
	begin
		clk <= '0'; wait for 10 ns;
		clk <= '1'; wait for 10 ns;
	end process;

	process
		variable std: TestCase;
	begin
		rst <= '0';	wait for 10 ns;
		rst <= '1';	wait for 10 ns;

		for i in cases'length loop
			std := cases(i);
			p.inst <= std.inst;
			p.pc <= std.pc;
			p.exe_writeReg <= std.exe_writeReg;
			p.mem_writeReg <= std.mem_writeReg;
			wait for 18 ns;

			assert p.reg1 = std.reg1
				report "Failed at case " & integer'image(i) & ". Reg1"
				severity error;
			assert p.reg2 = std.reg2
				report "Failed at case " & integer'image(i) & ". Reg2"
				severity error;
			assert p.branch = std.branch
				report "Failed at case " & integer'image(i) & ". branch"
				severity error;
			assert p.writeReg = std.writeReg
				report "Failed at case " & integer'image(i) & ". writeReg"
				severity error;
			assert p.isLW = std.isLW
				report "Failed at case " & integer'image(i) & ". isLW"
				severity error;
			assert p.isSW = std.isSW
				report "Failed at case " & integer'image(i) & ". isSW"
				severity error;
			assert p.writeMemData = std.writeMemData
				report "Failed at case " & integer'image(i) & ". writeMemData"
				severity error;
			assert p.aluInput = std.aluInput
				report "Failed at case " & integer'image(i) & ". aluInput"
				severity error;
		
			-- asserts ...
			wait for 2 ns;
		end loop ; -- 

		assert(false) report "Test End" severity error;
		wait;
	end process;

end arch ; -- arch
