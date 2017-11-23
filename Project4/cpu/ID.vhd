library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 译码模块
entity ID is
	port (
		------ 从IF输入 ------

		inst: in Inst;
		pc: in u16;

		------ 寄存器接口 ------

		-- enable和addr同时也输出到Ctrl模块，以判断寄存器冲突 
		reg1_enable, reg2_enable: out std_logic;
		reg1_addr_origin, reg2_addr_origin: out RegAddr;
		reg1_data_origin, reg2_data_origin: in u16;

		------ 输出到PC ------

		branch: out PCBranch;

		------ 旁路信息输入 ------

		-- 正处于执行/访存阶段的指令，是否要写寄存器
		-- 若是，enable=1，并给出地址和数据
		-- 判断是否是正在读的寄存器，若是，直接输出给EX
		exeWriteReg, memWriteReg: in RegPort;

		------ 输出到MEM ------

		-- 正处于此阶段的指令，是否要写寄存器
		-- 若是，enable=1，并给出地址，数据属性无效 
		writeReg: out RegPort;

		-- 正处于此阶段的指令，是否为LW
		-- 若是，在MEM阶段，writeReg.data <= Mem[ALUOut]
		isLW: out std_logic;

		-- 正处于此阶段的指令，是否为SW
		-- 若是，在MEM阶段，Mem[ALUOut] <= writeMemData
		isSW: out std_logic;
		writeMemData: out u16;

		------ 输出到EX ------

		aluInput: out AluInput;
		
		------ 调试信息 ------
		
		instType: out InstType
	) ;
end ID;

architecture arch of ID is	
	signal reg1_data, reg2_data: u16;
	signal reg1_addr, reg2_addr: RegAddr;
begin

	reg1_addr_origin <= reg1_addr;
	reg2_addr_origin <= reg2_addr;

	reg1_data <= exeWriteReg.data when exeWriteReg.enable = '1' and exeWriteReg.addr = reg1_addr
			else memWriteReg.data when memWriteReg.enable = '1' and memWriteReg.addr = reg1_addr
			else reg1_data_origin;

	reg2_data <= exeWriteReg.data when exeWriteReg.enable = '1' and exeWriteReg.addr = reg2_addr
			else memWriteReg.data when memWriteReg.enable = '1' and memWriteReg.addr = reg2_addr
			else reg2_data_origin;

	process (inst, pc, reg1_data, reg2_data)
		variable opcode : InstOpcode;
		variable subopcode : InstOpcode;
		variable oprx : RegAddr;
		variable opu : u2;
		variable aluOp: AluOp;
		variable b: u16;
	begin
		instType <= I_ERR;
		reg1_enable <= '0';
		reg2_enable <= '0';
		reg1_addr <= x"0";
		reg2_addr <= x"0";
		branch <= NULL_PCBRANCH;
		writeReg <= NULL_REGPORT;
		isLW <= '0';
		isSW <= '0';
		writeMemData <= x"0000";
		aluInput <= NULL_ALUINPUT;
		opcode := inst(15 downto 11); -- getOp() will fail when using ISim
		case(opcode) is
			when INST_ADDIU =>
				instType <= I_ADDIU;
				reg1_enable <= '1'; reg1_addr <= getRx(inst);
				aluInput <= (OP_ADD, reg1_data, signExtend(getIm8(inst)));
				writeReg <= ('1', reg1_addr, x"0000");
			when INST_ADDIU3 =>
				instType <= I_ADDIU3;
				reg1_enable <= '1'; reg1_addr <= getRx(inst);
				reg2_enable <= '1'; reg2_addr <= getRy(inst);
				aluInput <= (OP_ADD, reg1_data, signExtend4(inst(3 downto 0)));
				writeReg <= ('1', reg2_addr, x"0000");
			when INST_ADDSP3 =>
				instType <= I_ADDSP3;            
				reg1_enable <= '1'; reg1_addr <= getRx(inst);
				reg2_enable <= '1'; reg2_addr <= REG_SP;
				aluInput <= (OP_ADD, reg2_data, signExtend(getIm8(inst)));
				writeReg <= ('1', reg1_addr, x"0000");
			when INST_B =>
				instType <= I_B;            
				branch <= ('1', '0', signExtend11(inst(10 downto 0)), x"0000");
			when INST_BEQZ =>
				instType <= I_BEQZ;            
				reg1_enable <= '1'; reg1_addr <= getRx(inst);
				if (reg1_data = x"0000") then
					branch <= ('1', '0', signExtend(getIm8(inst)), x"0000");
				end if;
			when INST_BNEZ =>
				instType <= I_BNEZ;            
				reg1_enable <= '1'; reg1_addr <= getRx(inst);
				if (reg1_data /= x"0000") then
					branch <= ('1', '0', signExtend(getIm8(inst)), x"0000");
				end if;
			when INST_LI =>
				instType <= I_LI;            
				reg1_enable <= '1'; reg1_addr <= getRx(inst);
				aluInput <= (OP_ADD, zeroExtend(getIm8(inst)), x"0000");
				writeReg <= ('1', reg1_addr, x"0000");
			when INST_LW =>
				instType <= I_LW;            
				isLW <= '1';
				reg1_enable <= '1'; reg1_addr <= getRx(inst);
				reg2_enable <= '1'; reg2_addr <= getRy(inst);
				aluInput <= (OP_ADD, reg1_data, signExtend5(inst(4 downto 0)));
				writeReg <= ('1', reg2_addr, x"0000");
			when INST_LW_SP =>
				instType <= I_LW_SP;            
				isLW <= '1';
				reg1_enable <= '1'; reg1_addr <= getRx(inst);
				reg2_enable <= '1'; reg2_addr <= REG_SP;
				aluInput <= (OP_ADD, reg2_data, signExtend(getIm8(inst)));
				writeReg <= ('1', reg1_addr, x"0000");
			when INST_NOP =>
				instType <= I_NOP;
			when INST_SW =>
				instType <= I_SW;            
				isSW <= '1';
				reg1_enable <= '1'; reg1_addr <= getRx(inst);
				reg2_enable <= '1'; reg2_addr <= getRy(inst);
				writeMemData <= reg2_data;
				aluInput <= (OP_ADD, reg1_data, signExtend5(inst(4 downto 0)));
			when INST_SW_SP =>
				instType <= I_SW_SP;
				isSW <= '1';
				reg1_enable <= '1'; reg1_addr <= getRx(inst);
				reg2_enable <= '1'; reg2_addr <= REG_SP;
				writeMemData <= reg1_data;
				aluInput <= (OP_ADD, reg2_data, signExtend(getIm8(inst)));
			when INST_SET0 =>
				oprx := getRx(inst);
				case oprx is
					when x"3" =>  -- ADDSP
						instType <= I_ADDSP;            
						reg1_enable <= '1'; reg1_addr <= REG_SP;
						aluInput <= (OP_ADD, reg1_data, signExtend(getIm8(inst)));
						writeReg <= ('1', reg1_addr, x"0000");
					when x"2" =>  -- SW_RS
						instType <= I_SW_RS;            
						isSW <= '1';
						reg1_enable <= '1'; reg1_addr <= REG_SP;
						reg2_enable <= '1'; reg2_addr <= REG_RA;
						writeMemData <= reg2_data;
						aluInput <= (OP_ADD, reg1_data, signExtend(getIm8(inst)));
					when x"0" =>  -- BTEQZ
						instType <= I_BTEQZ;            
						reg1_enable <= '1'; reg1_addr <= REG_T;
						if (reg1_data = x"0000") then
							branch <= ('1', '0', signExtend(getIm8(inst)), x"0000");
						end if;
					when x"4" =>  -- MTSP
						instType <= I_MTSP;
						reg1_enable <= '1'; reg1_addr <= REG_SP;
						reg2_enable <= '1'; reg2_addr <= getRy(inst);
						writeReg <= ('1', reg1_addr, x"0000");
						aluInput <= (OP_ADD, reg2_data, x"0000");
					when others => null;
				end case;
			when INST_SET1 =>
				subopcode := getSubOp(inst);
				if subopcode = "00000" then 
					oprx := getRy(inst);
					if (oprx = x"0") then  -- JR
						instType <= I_JR;
						reg1_enable <= '1'; reg1_addr <= getRx(inst);
						branch <= ('0', '1', x"0000", reg1_data);
					elsif (oprx = x"2") then  -- MFPC
						instType <= I_MFPC;
						reg1_enable <= '1'; reg1_addr <= getRx(inst);
						writeReg <= ('1', reg1_addr, x"0000");
						aluInput <= (OP_ADD, pc, x"0000");
					end if;
				else
					reg1_enable <= '1'; reg1_addr <= getRx(inst);
					reg2_enable <= '1'; reg2_addr <= getRy(inst);
					writeReg <= ('1', reg1_addr, x"0000");
					case subopcode is
						when "01100" =>  -- AND
							instType <= I_AND;
							aluInput <= (OP_AND, reg1_data, reg2_data);
						when "01010" =>  -- CMP
							instType <= I_CMP;
							writeReg <= ('1', REG_T, x"0000");
							aluInput <= (OP_EQ, reg1_data, reg2_data);
						when "01111" =>  -- NOT
							instType <= I_NOT;
							aluInput <= (OP_NOT, reg2_data, x"0000");
						when "01101" =>  -- OR
							instType <= I_OR;
							aluInput <= (OP_OR, reg1_data, reg2_data);
						when "00010" =>  -- SLT
							instType <= I_SLT;
							writeReg <= ('1', REG_T, x"0000");
							aluInput <= (OP_LTS, reg1_data, reg2_data);
						when others => null;
					end case;
				end if;
			when INST_SET2 =>
				opu := inst(1 downto 0);
				if (opu = "01") then  -- ADDU
					instType <= I_ADDU;
					aluOp := OP_ADD;
				elsif (opu = "11") then  -- SUBU
					instType <= I_SUBU;
					aluOp := OP_SUB;
				end if;
				reg1_enable <= '1'; reg1_addr <= getRx(inst);
				reg2_enable <= '1'; reg2_addr <= getRy(inst);
				writeReg <= ('1', getRz(inst), x"0000");
				aluInput <= (aluOp, reg1_data, reg2_data);                
			when INST_SET3 =>
				subopcode := getSubOp(inst);                
				if (subopcode = "00000") then  -- MFIH
					instType <= I_MFIH;
					reg1_addr <= getRx(inst);
					reg2_addr <= REG_IH;
				elsif (subopcode = "00001") then  -- MTIH
					instType <= I_MTIH;
					reg1_addr <= REG_IH;
					reg2_addr <= getRx(inst);
				end if;
				reg1_enable <= '1';
				reg2_enable <= '1';
				writeReg <= ('1', reg1_addr, x"0000");
				aluInput <= (OP_ADD, reg2_data, x"0000");
			when INST_SET4 =>
				opu := inst(1 downto 0);
				if (opu = "00") then  -- SLL
					instType <= I_SLL;
					aluOp := OP_SLL;
				elsif (opu = "11") then  -- SRA
					instType <= I_SRA;
					aluOp := OP_SRA;                    
				elsif (opu = "10") then  -- SRL
					instType <= I_SRL;
					aluOp := OP_SRL;
				end if;
				reg1_enable <= '1'; reg1_addr <= getRx(inst);
				reg2_enable <= '1'; reg2_addr <= getRy(inst);
				writeReg <= ('1', reg1_addr, x"0000");
				aluInput <= (aluOp, reg2_data, shiftExtend(inst(4 downto 2)));
			when others => null;
		end case;
	end process;

end arch ; -- arch
