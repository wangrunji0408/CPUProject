library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestID is
end TestID;

architecture arch of TestID is

	type TestCase is record
		-- description
		instType: InstType;
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
	
	type TestCases is array (0 to 11) of TestCase;

	constant cases: TestCases := ( -- 每个test_case对应一个时钟周期
		(-- ADDIU
			inst => INST_ADDIU & o"2" & x"FF",
			pc => x"0000",
			exe_writeReg => NULL_REGPORT,
			mem_writeReg => NULL_REGPORT,
			-- output
			instType => I_ADDIU,			
			reg1 => ('1', x"2", x"0002"),
			reg2 => NULL_REGPORT,
			branch => NULL_PCBRANCH,	
			writeReg => ('1', x"2", x"0000"),
			isLW => '0',
			isSW => '0',
			writeMemData => x"0000",
			aluInput => (OP_ADD, x"0002", x"FFFF")
		),
        (-- ADDIU3
			inst => INST_ADDIU3 & o"2" & "001" & "01111",
			pc => x"0000",
			exe_writeReg => NULL_REGPORT,
			mem_writeReg => NULL_REGPORT,
			-- output
			instType => I_ADDIU3,			
			reg1 => ('1', x"2", x"0002"),
			reg2 => ('0', x"1", x"0000"),
			branch => NULL_PCBRANCH,	
			writeReg => ('1', x"1", x"0000"),
			isLW => '0',
			isSW => '0',
			writeMemData => x"0000",
			aluInput => (OP_ADD, x"0002", x"FFFF")
		),
        (-- ADDSP3
			inst => INST_ADDSP3 & o"2" & x"FF",
			pc => x"0000",
			exe_writeReg => NULL_REGPORT,
			mem_writeReg => NULL_REGPORT,
			-- output
			instType => I_ADDSP3,			
			reg1 => ('0', x"2", x"0000"),
			reg2 => ('1', REG_SP, x"0008"),
			branch => NULL_PCBRANCH,	
			writeReg => ('1', x"2", x"0000"),
			isLW => '0',
			isSW => '0',
			writeMemData => x"0000",
			aluInput => (OP_ADD, x"0008", x"FFFF")
		),
        (-- B
			inst => INST_B & "111" & x"FF",
			pc => x"0000",
			exe_writeReg => NULL_REGPORT,
			mem_writeReg => NULL_REGPORT,
			-- output
			instType => I_B,			
			reg1 => NULL_REGPORT,
			reg2 => NULL_REGPORT,
			branch => ('1', '0', x"FFFF", x"0000"),	
			writeReg => NULL_REGPORT,
			isLW => '0',
			isSW => '0',
			writeMemData => x"0000",
			aluInput => NULL_ALUINPUT
		),
        (-- BEQZ
			inst => INST_BEQZ & o"2" & x"FF",
			pc => x"0000",
			exe_writeReg => NULL_REGPORT,
			mem_writeReg => NULL_REGPORT,
			-- output
			instType => I_BEQZ,			
			reg1 => ('1', x"2", x"0002"),
			reg2 => NULL_REGPORT,
			branch => NULL_PCBRANCH,	
			writeReg => NULL_REGPORT,
			isLW => '0',
			isSW => '0',
			writeMemData => x"0000",
			aluInput => NULL_ALUINPUT
		),
        (-- BEQZ
			inst => INST_BEQZ & "000" & x"FF",
			pc => x"0000",
			exe_writeReg => NULL_REGPORT,
			mem_writeReg => NULL_REGPORT,
			-- output
			instType => I_BEQZ,			
			reg1 => ('1', x"0", x"0000"),
			reg2 => NULL_REGPORT,
			branch => ('1', '0', x"FFFF", x"0000"),	
			writeReg => NULL_REGPORT,
			isLW => '0',
			isSW => '0',
			writeMemData => x"0000",
			aluInput => NULL_ALUINPUT
		),
        (-- BENE
			inst => INST_BNEZ & o"2" & x"FF",
			pc => x"0000",
			exe_writeReg => NULL_REGPORT,
			mem_writeReg => NULL_REGPORT,
			-- output
			instType => I_BNEZ,			
			reg1 => ('1', x"2", x"0002"),
			reg2 => NULL_REGPORT,
			branch => ('1', '0', x"FFFF", x"0000"),	
			writeReg => NULL_REGPORT,
			isLW => '0',
			isSW => '0',
			writeMemData => x"0000",
			aluInput => NULL_ALUINPUT
		),
        (-- BNEZ
			inst => INST_BNEZ & "000" & x"FF",
			pc => x"0000",
			exe_writeReg => NULL_REGPORT,
			mem_writeReg => NULL_REGPORT,
			-- output
			instType => I_BNEZ,			
			reg1 => ('1', x"0", x"0000"),
			reg2 => NULL_REGPORT,
			branch => NULL_PCBRANCH,	
			writeReg => NULL_REGPORT,
			isLW => '0',
			isSW => '0',
			writeMemData => x"0000",
			aluInput => NULL_ALUINPUT
		),
        (-- LI
			inst => INST_LI & o"2" & x"FF",
			pc => x"0000",
			exe_writeReg => NULL_REGPORT,
			mem_writeReg => NULL_REGPORT,
			-- output
			instType => I_LI,			
			reg1 => ('0', x"2", x"0000"),
			reg2 => NULL_REGPORT,
			branch => NULL_PCBRANCH,	
			writeReg => ('1', x"2", x"0000"),
			isLW => '0',
			isSW => '0',
			writeMemData => x"0000",
			aluInput => (OP_ADD, x"00FF", x"0000")
		),
        (-- LW
			inst => INST_LW & "001" & "010" & "11111",
			pc => x"0000",
			exe_writeReg => NULL_REGPORT,
			mem_writeReg => NULL_REGPORT,
			-- output
			instType => I_LW,			
			reg1 => ('1', x"1", x"0001"),
			reg2 => ('0', x"2", x"0000"),
			branch => NULL_PCBRANCH,	
			writeReg => ('1', x"2", x"0000"),
			isLW => '1',
			isSW => '0',
			writeMemData => x"0000",
			aluInput => (OP_ADD, x"0001", x"FFFF")
		),
		(-- EXE旁路生效
			inst => INST_ADDIU & o"2" & x"FF",
			pc => x"0000",
			exe_writeReg => ('1', x"2", x"AAAA"),
			mem_writeReg => ('1', x"2", x"BBBB"),
			-- output
			instType => I_ADDIU,
			reg1 => ('1', x"2", x"0002"),
			reg2 => NULL_REGPORT,
			branch => NULL_PCBRANCH,	
			writeReg => ('1', x"2", x"0000"),
			isLW => '0',
			isSW => '0',
			writeMemData => x"0000",
			aluInput => (OP_ADD, x"AAAA", x"FFFF")
		),
		(-- MEM旁路生效
			inst => INST_ADDIU & o"2" & x"FF",
			pc => x"0000",
			exe_writeReg => NULL_REGPORT,
			mem_writeReg => ('1', x"2", x"BBBB"),
			-- output
			instType => I_ADDIU,
			reg1 => ('1', x"2", x"0002"),
			reg2 => NULL_REGPORT,
			branch => NULL_PCBRANCH,	
			writeReg => ('1', x"2", x"0000"),
			isLW => '0',
			isSW => '0',
			writeMemData => x"0000",
			aluInput => (OP_ADD, x"BBBB", x"FFFF")
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
			p.aluInput, p.instType);

	process
		variable std: TestCase;
	begin
		for i in cases'length loop
			std := cases(i);
			p.inst <= std.inst;
			p.pc <= std.pc;
			p.exe_writeReg <= std.exe_writeReg;
			p.mem_writeReg <= std.mem_writeReg;
			wait for 18 ns;

			assert p.instType = std.instType
				report "Failed at case " & integer'image(i) & ": " & InstType'image(std.instType) & ". instType"
				severity error;
			if std.instType /= I_ERR then
			assert p.reg1 = std.reg1
				report "Failed at case " & integer'image(i) & ": " & InstType'image(std.instType) & ". Reg1"
				severity error;
			assert p.reg2 = std.reg2
				report "Failed at case " & integer'image(i) & ": " & InstType'image(std.instType) & ". Reg2 = " & tostring(p.reg2.data)
				severity error;
			assert p.branch = std.branch
				report "Failed at case " & integer'image(i) & ": " & InstType'image(std.instType) & ". branch"
				severity error;
			assert p.writeReg = std.writeReg
				report "Failed at case " & integer'image(i) & ": " & InstType'image(std.instType) & ". writeReg = " & tostring(p.reg2.addr)
				severity error;
			assert p.isLW = std.isLW
				report "Failed at case " & integer'image(i) & ": " & InstType'image(std.instType) & ". isLW"
				severity error;
			assert p.isSW = std.isSW
				report "Failed at case " & integer'image(i) & ": " & InstType'image(std.instType) & ". isSW"
				severity error;
			assert p.writeMemData = std.writeMemData
				report "Failed at case " & integer'image(i) & ": " & InstType'image(std.instType) & ". writeMemData"
				severity error;
			assert p.aluInput = std.aluInput
				report "Failed at case " & integer'image(i) & ": " & InstType'image(std.instType) & ". aluInput = " & tostring(p.aluInput.b)
				severity error;
			end if;			
		
			wait for 2 ns;
		end loop ; -- 

		assert(false) report "Test End" severity error;
		wait;
	end process;

end arch ; -- arch
