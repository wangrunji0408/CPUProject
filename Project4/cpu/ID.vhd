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
		reg1_addr, reg2_addr: out RegAddr;
		reg1_data, reg2_data: in u16;

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

		aluInput: out AluInput
	) ;
end ID;

architecture arch of ID is	
begin
    process (inst, pc, reg1_data, reg2_data, exeWriteReg, memWriteReg)
        variable opcode : InstOpcode;
        variable subopcode : InstOpcode;
        variable oprx : RegAddr;
        variable opu : u2;
        variable im3 : u3;
    begin
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
        opcode := getOp(inst);
        case(opcode) is
            when INST_ADDIU =>
                reg1_addr <= getRx(inst);
                reg1_enable <= '1';
                aluInput <= (OP_ADD, reg1_data, signExtend(getIm8(inst)));
                writeReg <= ('1', reg1_addr, x"0000");
            when INST_ADDIU3 =>
                reg1_addr <= getRx(inst);
                reg1_enable <= '1';
                reg2_addr <= getRy(inst);
                aluInput <= (OP_ADD, reg1_data, signExtend4(inst(3 downto 0)));
                writeReg <= ('1', reg2_addr, x"0000");
            when INST_ADDSP3 =>
                reg1_addr <= getRx(inst);
                reg2_addr <= REG_SP;
                reg2_enable <= '1';
                aluInput <= (OP_ADD, reg2_data, signExtend(getIm8(inst)));
                writeReg <= ('1', reg1_addr, x"0000");
            when INST_B =>
                branch <= ('1', '0', signExtend11(inst(10 downto 0)), x"0000");
            when INST_BEQZ =>
                reg1_addr <= getRx(inst);
                reg1_enable <= '1';
                if (reg1_data = x"0000") then
                    branch <= ('1', '0', signExtend(getIm8(inst)), x"0000");
                end if;
            when INST_BNEZ =>
                reg1_addr <= getRx(inst);
                reg1_enable <= '1';
                if (reg1_data /= x"0000") then
                    branch <= ('1', '0', signExtend(getIm8(inst)), x"0000");
                end if;
            when INST_LI =>
                reg1_addr <= getRx(inst);
                aluInput <= (OP_ADD, zeroExtend(getIm8(inst)), x"0000");
                writeReg <= ('1', reg1_addr, x"0000");
            when INST_LW =>
                isLW <= '1';
                reg1_addr <= getRx(inst);
                reg1_enable <= '1';
                reg2_addr <= getRy(inst);
                aluInput <= (OP_ADD, reg1_data, signExtend5(inst(4 downto 0)));
                writeReg <= ('1', reg2_addr, x"0000");
            when INST_LW_SP =>
                isLW <= '1';
                reg1_addr <= getRx(inst);
                reg2_addr <= REG_SP;
                reg2_enable <= '1';
                aluInput <= (OP_ADD, reg2_data, signExtend(getIm8(inst)));
                writeReg <= ('1', reg1_addr, x"0000");
            when INST_NOP =>
            when INST_SW =>
                isSW <= '1';
                reg1_addr <= getRx(inst);
                reg1_enable <= '1';
                reg2_addr <= getRy(inst);
                reg2_enable <= '1';
                writeMemData <= reg2_data;
                aluInput <= (OP_ADD, reg1_data, signExtend5(inst(4 downto 0)));
            when INST_SW_SP =>
                isSW <= '1';
                reg1_addr <= getRx(inst);
                reg1_enable <= '1';
                reg2_addr <= REG_SP;
                reg2_enable <= '1';
                writeMemData <= reg1_data;
                aluInput <= (OP_ADD, reg2_data, signExtend(getIm8(inst)));
            when INST_SET0 =>
                oprx := getRx(inst);
                case(oprx) is
                    when x"3" =>  -- ADDSP
                        reg1_addr <= REG_SP;
                        reg1_enable <= '1';
                        aluInput <= (OP_ADD, reg1_data, signExtend(getIm8(inst)));
                        writeReg <= ('1', reg1_addr, x"0000");
                    when x"2" =>  -- SW_RS
                        isSW <= '1';
                        reg1_addr <= REG_SP;
                        reg1_enable <= '1';
                        reg2_addr <= REG_RA;
                        reg2_enable <= '1';
                        writeMemData <= reg2_data;
                        aluInput <= (OP_ADD, reg1_data, signExtend(getIm8(inst)));
                    when x"0" =>  -- BTEQZ
                        reg1_addr <= REG_T;
                        reg1_enable <= '1';
                        if (reg1_data = x"0000") then
                            branch <= ('1', '0', signExtend(getIm8(inst)), x"0000");
                        end if;
                    when x"4" =>  -- MTSP
                        reg1_addr <= REG_SP;
                        reg2_addr <= getRy(inst);
                        reg2_enable <= '1';
                        writeReg <= ('1', reg1_addr, x"0000");
                        aluInput <= (OP_ADD, reg2_data, x"0000");
                    when others => null;
                end case;
            when INST_SET1 =>
                subopcode := getSubOp(inst);
                case(subopcode) is
                    when "01100" =>  -- AND
                        reg1_addr <= getRx(inst);
                        reg1_enable <= '1';
                        reg2_addr <= getRy(inst);
                        reg2_enable <= '1';
                        writeReg <= ('1', reg1_addr, x"0000");
                        aluInput <= (OP_AND, reg1_data, reg2_data);
                    when "01010" =>  -- CMP
                        reg1_addr <= getRx(inst);
                        reg1_enable <= '1';
                        reg2_addr <= getRy(inst);
                        reg2_enable <= '1';
                        if (reg1_data = reg2_data) then
                            writeReg <= ('1', REG_T, x"0000");
                        else
                            writeReg <= ('1', REG_T, x"0000");
                            aluInput <= (OP_ADD, x"0001", x"0000");
                        end if;
                    when "00000" =>
                        oprx := getRy(inst);
                        if (oprx = x"0") then  -- JR
                            reg1_addr <= getRx(inst);
                            reg1_enable <= '1';
                            branch <= ('0', '1', x"0000", reg1_data);
                        elsif (oprx = x"2") then  -- MFPC
                            reg1_addr <= getRx(inst);
                            writeReg <= ('1', reg1_addr, x"0000");
                            aluInput <= (OP_ADD, pc, x"0000");
                        end if;
                    when "01111" =>  -- NOT
                        reg1_addr <= getRx(inst);
                        reg2_addr <= getRy(inst);
                        reg2_enable <= '1';
                        writeReg <= ('1', reg1_addr, x"0000");
                        aluInput <= (OP_NOT, reg2_data, x"0000");
                    when "01101" =>  -- OR
                        reg1_addr <= getRx(inst);
                        reg1_enable <= '1';
                        reg2_addr <= getRy(inst);
                        reg2_enable <= '1';
                        writeReg <= ('1', reg1_addr, x"0000");
                        aluInput <= (OP_OR, reg1_data, reg2_data);
                    when "00010" =>  -- SLT
                        reg1_addr <= getRx(inst);
                        reg1_enable <= '1';
                        reg2_addr <= getRy(inst);
                        reg2_enable <= '1';
                        if (reg1_data < reg2_data) then
                            writeReg <= ('1', REG_T, x"0000");
                            aluInput <= (OP_ADD, x"0001", x"0000");
                        else
                            writeReg <= ('1', REG_T, x"0000");
                        end if;
                    when others => null;
                end case;
            when INST_SET2 =>
                opu := inst(1 downto 0);
                if (opu = "01") then  -- ADDU
                    reg1_addr <= getRx(inst);
                    reg1_enable <= '1';
                    reg2_addr <= getRy(inst);
                    reg2_enable <= '1';
                    writeReg <= ('1', getRz(inst), x"0000");
                    aluInput <= (OP_ADD, reg1_data, reg2_data);
                elsif (opu = "11") then  -- SUBU
                    reg1_addr <= getRx(inst);
                    reg1_enable <= '1';
                    reg2_addr <= getRy(inst);
                    reg2_enable <= '1';
                    writeReg <= ('1', getRz(inst), x"0000");
                    aluInput <= (OP_SUB, reg1_data, reg2_data);
                end if;
            when INST_SET3 =>
                subopcode := getSubOp(inst);
                if (subopcode = "00000") then  -- MFIH
                    reg1_addr <= getRx(inst);
                    reg2_addr <= REG_IH;
                    reg2_enable <= '1';
                    writeReg <= ('1', reg1_addr, x"0000");
                    aluInput <= (OP_ADD, reg2_data, x"0000");
                elsif (subopcode = "00001") then  -- MTIH
                    reg1_addr <= REG_IH;
                    reg2_addr <= getRx(inst);
                    reg2_enable <= '1';
                    writeReg <= ('1', reg1_addr, x"0000");
                    aluInput <= (OP_ADD, reg2_data, x"0000");
                end if;
            when INST_SET4 =>
                opu := inst(1 downto 0);
                if (opu = "00") then  -- SLL
                    im3 := inst(4 downto 2);
                    reg1_addr <= getRx(inst);
                    reg2_addr <= getRy(inst);
                    reg2_enable <= '1';
                    writeReg <= ('1', reg1_addr, x"0000");
                    if (im3 = "000") then
                        aluInput <= (OP_SLL, reg2_data, x"0008");
                    else
                        aluInput <= (OP_SLL, reg2_data, x"000" & "0" & im3);
                    end if;
                elsif (opu = "11") then  -- SRA
                    im3 := inst(4 downto 2);
                    reg1_addr <= getRx(inst);
                    reg2_addr <= getRy(inst);
                    reg2_enable <= '1';
                    writeReg <= ('1', reg1_addr, x"0000");
                    if (im3 = "000") then
                        aluInput <= (OP_SRA, reg2_data, x"0008");
                    else
                        aluInput <= (OP_SRA, reg2_data, x"000" & "0" & im3);
                    end if;
                elsif (opu = "10") then  -- SRL
                    im3 := inst(4 downto 2);
                    reg1_addr <= getRx(inst);
                    reg2_addr <= getRy(inst);
                    reg2_enable <= '1';
                    writeReg <= ('1', reg1_addr, x"0000");
                    if (im3 = "000") then
                        aluInput <= (OP_SRL, reg2_data, x"0008");
                    else
                        aluInput <= (OP_SRL, reg2_data, x"000" & "0" & im3);
                    end if;
                end if;
            when others => null;
        end case;
    end process;

end arch ; -- arch
