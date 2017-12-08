library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Base is
	subtype u32 is unsigned(31 downto 0);
	subtype u23 is unsigned(22 downto 0);
	subtype u16 is unsigned(15 downto 0);
	subtype u18 is unsigned(17 downto 0);
    subtype u11 is unsigned(10 downto 0);
	subtype u8 is unsigned(7 downto 0);
	subtype u5 is unsigned(4 downto 0);
	subtype u4 is unsigned(3 downto 0);
	subtype u3 is unsigned(2 downto 0);
    subtype u2 is unsigned(1 downto 0);

	subtype Inst is u16;
	subtype InstOpcode is u5;
	subtype AluOpcode is u4;
	subtype RegAddr is u4;
	subtype TColor is std_logic_vector(8 downto 0); 	--颜色：[R2R1R0 G2G1G0 B2B1B0]
	type RegData is array (0 to 15) of u16;
	type DataBuf is array (0 to 63) of u8;
	type DataBufPort is record
		write, read, isBack: std_logic;
		canwrite, canread: std_logic;
		data_write, data_read: u8;
	end record;
	type DataBufInfo is record
		data: DataBuf;
		writePos, readPos: natural;
	end record;

	type LineBuf is array (0 to 15) of u8;
	type ShellBuf is array (0 to 15) of LineBuf;
	type ShellBufInfo is record
		data: ShellBuf;
		x, y: natural;
	end record;

	type Config is record
		byte_mode: std_logic;
		com1_keyboard: std_logic;
		pixel_mode: std_logic;
	end record;

	-- 特殊寄存器。和通用寄存器一起，统一编码为4位地址。
	constant REG_SP: RegAddr := x"8";
	constant REG_IH: RegAddr := x"9";
	constant REG_RA: RegAddr := x"A";
	constant REG_T:  RegAddr := x"B";

	type AluOp is (
		OP_NOP,
		OP_ADD, OP_SUB, OP_AND, OP_OR , OP_XOR, 
		OP_NOT, OP_SLL, OP_SRL, OP_SRA, OP_ROL,
		OP_LTU, OP_LTS, OP_EQ -- 分别对应 SLTUI SLT CMP 指令，输出0/1
	);

	type AluFlag is record
		cf, zf, sf, vf: std_logic;
	end record;

	type VGA is record
		r, g, b: u3;
		vs, hs: std_logic;
	end record;

	type PS2 is record
		clk, data: std_logic;
	end record;

	type UartPort is record
		data_ready, tbre, tsre: std_logic;
		write, read: std_logic;
		data_write, data_read: u16; -- is ram1_data
	end record;

	type FlashCtrl is record
		byte, ce, ce1, ce2, oe, rp, sts, vpen, we: std_logic;
	end record;

	type PCBranch is record
		enable: std_logic;
		target: u16;
	end record;

	type SaveInR6 is record
		enable: std_logic;
		pc: u16;
	end record;

	type RegPort is record
		enable: std_logic;
		addr: RegAddr;
		data: u16;
	end record;

	type AluInput is record
		op: AluOp;
		a, b: u16;
	end record;

	type IFCachePort is record
		enable: std_logic;
		pc, inst: u16;
	end record;

	type RamPort is record
		enable, read, write: std_logic;
		addr: u18;
		data: u16;
	end record;

	type MEMType is (
		None, 
		ReadRam1, WriteRam1, ReadRam2, WriteRam2, 
		ReadUart, WriteUart, TestUart,
		ReadUart2, WriteUart2, TestUart2,
		ReadBuf, WriteBuf, TestBuf
	);

	type InstType is (
		I_AND, I_OR, I_ADDU, I_SUBU, I_SLT, I_CMP,
		I_ADDIU, I_ADDIU3, I_ADDSP, I_ADDSP3, I_SLL, I_SRA, I_SRL, I_SLTUI, I_NOT, I_LI,
		I_MFIH, I_MFPC, I_MTIH, I_MTSP,
		I_B, I_BEQZ, I_BNEZ, I_BTEQZ, I_JR,
		I_LW, I_LW_SP, I_SW, I_SW_SP, I_SW_RS,
		I_NOP,
		I_ERR
	);

	type CPUMode is (STEP, BREAK_POINT);
	type MidCtrl is (PASS, STALL, CLEAR, STORE, RESTORE);
	type MidCtrls is array (4 downto 0) of MidCtrl;

	type IF_Data is record
		pc: u16;
		branch: PCBranch;
		isRefetch: std_logic;
	end record;

	type IF_ID_Data is record
		pc: u16;
		inst: Inst;
	end record;

	type ID_EX_Data is record
		writeReg: RegPort;
		isLW: std_logic;
		isSW: std_logic;
		writeMemData: u16;
		aluInput: AluInput;
	end record;

	type EX_MEM_Data is record
		writeReg: RegPort;
		isLW: std_logic;
		isSW: std_logic;
		mem_type: MEMType;
		mem_addr: u16;
		mem_write_data: u16;
	end record;

	type IOEvent is record
		pc: u16;
		mode: MEMType;
		addr, data: u16;
	end record;
	type IODebug is array (0 to 15) of IOEvent;

	type CPUDebug is record
		step: natural;
		mode: CPUMode;
		breakPointPC: u16;
		regs: RegData;
		instType: InstType;
		if_in: IF_Data;
		id_in: IF_ID_Data;
		ex_in: ID_EX_Data;
		mem_in: EX_MEM_Data;
		mem_out: RegPort;
	end record;

	constant NULL_IFCACHEPORT : IFCachePort := ('0', x"0000", x"0000");	
	constant NULL_REGPORT : RegPort := ('0', x"0", x"0000");
	constant NULL_RAMPORT : RamPort := ('1', '1', '1', "00" & x"0000", x"0000");
	constant NULL_ALUINPUT : AluInput := (OP_NOP, x"0000", x"0000");
	constant NULL_PCBRANCH : PCBranch := ('0', x"0000");
	constant NULL_IOEVENT: IOEvent := (x"0000", None, x"0000", x"0000");
	constant NULL_IF_DATA: IF_Data := (x"0000", NULL_PCBRANCH, '0');
	constant NULL_IF_ID_DATA: IF_ID_Data := (x"0000", x"0000");
	constant NULL_ID_EX_DATA: ID_EX_Data := (NULL_REGPORT, '0', '0', x"0000", NULL_ALUINPUT);	
	constant NULL_EX_MEM_DATA: EX_MEM_Data := (NULL_REGPORT, '0', '0', None, x"0000", x"0000");
	
	function charToU8 (x: character) return u8;
	function charToU4 (x: natural) return u4;
	function to_u4 (x: integer) return u4;
	function to_u16 (x: integer) return u16;
	function toString (x: unsigned) return string;
	function DisplayNumber (number: u4) return std_logic_vector;

	function signExtend (number: u8) return u16;
    function signExtend4 (number: u4) return u16;
    function signExtend5 (number: u5) return u16;
    function signExtend11 (number: u11) return u16;
	function zeroExtend (number: u8) return u16;
	function shiftExtend (number: u3) return u16;

	-- Get part from instruction
	function getOp (x: Inst) return InstOpcode;
	function getSubOp (x: Inst) return InstOpcode;
	function getRx (x: Inst) return RegAddr;
	function getRy (x: Inst) return RegAddr;
	function getRz (x: Inst) return RegAddr;
	function getIm8 (x: Inst) return u8;

	-- define Instruction op
	constant INST_ADDIU: 	InstOpcode := "01001";  -- first
	constant INST_ADDIU3: 	InstOpcode := "01000";  -- first
    constant INST_ADDSP3:   InstOpcode := "00000";  -- first
	constant INST_B: 		InstOpcode := "00010";  -- first
	constant INST_BEQZ: 	InstOpcode := "00100";  -- first
	constant INST_BNEZ: 	InstOpcode := "00101";  -- first
	constant INST_LI: 		InstOpcode := "01101";  -- first
	constant INST_LW: 		InstOpcode := "10011";  -- first
	constant INST_LW_SP: 	InstOpcode := "10010";  -- first
	constant INST_NOP: 		InstOpcode := "00001";  -- first
	constant INST_SLTUI: 	InstOpcode := "01011";
	constant INST_SW: 		InstOpcode := "11011";  -- first
	constant INST_SW_SP: 	InstOpcode := "11010";  -- first
    
    constant INST_SET0:     InstOpcode := "01100";
	-- constant INST_ADDSP: 	InstOpcode := "01100";	-- first warn: same 0 "01100011"
	-- constant INST_SW_RS: 	InstOpcode := "01100";	-- warn: same 0 "01100010"
	-- constant INST_BTEQZ: 	InstOpcode := "01100";	-- first warn: same 0 "01100000"
	-- constant INST_MTSP: 	InstOpcode := "01100";	-- first warn: same 0 "01100100"
    
    constant INST_SET1:     InstOpcode := "11101";
	-- constant INST_AND: 		InstOpcode := "11101";	-- first warn: same 1 "11101 01100"
	-- constant INST_JR: 		InstOpcode := "11101";	-- first warn: same 1 "11101 000 00000"
	-- constant INST_CMP: 		InstOpcode := "11101";	-- first warn: same 1 "11101 01010"
	-- constant INST_MFPC: 	InstOpcode := "11101";	-- first warn: same 1 "11101 010 00000"
	-- constant INST_NOT: 		InstOpcode := "11101";	-- warn: same 1 "11101 01111"
	-- constant INST_OR: 		InstOpcode := "11101";	-- first warn: same 1 "11101 01101"
	-- constant INST_SLT: 		InstOpcode := "11101";	-- warn: same 1 "11101 00010"
    
    constant INST_SET2:     InstOpcode := "11100";
	-- constant INST_ADDU: 	InstOpcode := "11100";	-- first warn: same 2 "11100 01"
	-- constant INST_SUBU: 	InstOpcode := "11100";	-- first warn: same 2 "11100 11"
    
    
	constant INST_SET3: 	InstOpcode := "11110";
	-- constant INST_MFIH: 	InstOpcode := "11110";	-- first warn: same 3 "11110 00000"
	-- constant INST_MTIH: 	InstOpcode := "11110";	-- first warn: same 3 "11110 00001"
    
    constant INST_SET4: 	InstOpcode := "00110";
	constant INST_SLL: 		InstOpcode := "00110";	-- first warn: same 4 "00110 00"
	constant INST_SRA: 		InstOpcode := "00110";	-- first warn: same 4 "00110 11"
	constant INST_SRL: 		InstOpcode := "00110";	-- warn: same 4 "00110 10"
    
end package ;

package body Base is

	function getOp (x: Inst) return InstOpcode is
	begin
		return x(15 downto 11);
	end function;
    
    function getSubOp (x: Inst) return InstOpcode is
	begin
		return x(4 downto 0);
	end function;
	
	function getRx (x: Inst) return RegAddr is
	begin
		return "0" & x(10 downto 8);
	end function;

	function getRy (x: Inst) return RegAddr is
	begin
		return "0" & x(7 downto 5);
	end function;
	
	function getRz (x: Inst) return RegAddr is
	begin
		return "0" & x(4 downto 2);
	end function;

	function getIm8 (x: Inst) return u8 is
	begin
		return x(7 downto 0);
	end function;

	function signExtend (number: u8) return u16 is
	begin
		if number(7) = '0' then
			return x"00" & number;
		else
			return x"FF" & number;
		end if;
	end function;
    
    function signExtend4 (number: u4) return u16 is
    begin
        if number(3) = '0' then
            return x"000" & number;
        else
            return x"FFF" & number;
        end if;
    end function;
    
    function signExtend5 (number: u5) return u16 is
    begin
        if number(4) = '0' then
            return x"00" & "000" & number;
        else
            return x"FF" & "111" & number;
        end if;
    end function;
    
    function signExtend11 (number: u11) return u16 is
    begin
        if number(10) = '0' then
            return "00000" & number;
        else
            return "11111" & number;
        end if;
    end function;
    
	function zeroExtend (number: u8) return u16 is
	begin
		return x"00" & number;
	end function;

	function shiftExtend (number: u3) return u16 is
	begin
		if (number = "000") then
			return x"0008";
		else
			return x"000" & "0" & number;
		end if;
	end function;

	function charToU8 (x: character) return u8 is
	begin
		return to_unsigned(character'pos(x), 8);
	end function;

	function charToU4 (x: natural) return u4 is
	begin
		case( x ) is
			when 48 => return x"0";
			when 49 => return x"1";
			when 50 => return x"2";
			when 51 => return x"3";
			when 52 => return x"4";
			when 53 => return x"5";
			when 54 => return x"6";
			when 55 => return x"7";
			when 56 => return x"8";
			when 57 => return x"9";
			when 65|97 => return x"A";
			when 66|98 => return x"B";
			when 67|99 => return x"C";
			when 68|100 => return x"D";
			when 69|101 => return x"E";
			when 70|102 => return x"F";		
			when others => return x"0";
		end case ;
	end function;

	function toString (x: unsigned) return string is 
	begin
		return integer'image(to_integer(x));
	end function;

	function to_u4 (x: integer) return u4 is 
	begin
		return to_unsigned(x, 4);
	end function;

	function to_u16 (x: integer) return u16 is 
	begin
		return to_unsigned(x, 16);
	end function;

	function DisplayNumber (number: u4)
		return std_logic_vector is -- gfedcba
	begin
		case number is
			when "0000" => return "0111111"; --0;
			when "0001" => return "0000110"; --1;
			when "0010" => return "1011011"; --2;
			when "0011" => return "1001111"; --3;
			when "0100" => return "1100110"; --4;
			when "0101" => return "1101101"; --5;
			when "0110" => return "1111101"; --6;
			when "0111" => return "0000111"; --7;
			when "1000" => return "1111111"; --8;
			when "1001" => return "1101111"; --9;
			when "1010" => return "1110111"; --A;
			when "1011" => return "1111100"; --B;
			when "1100" => return "0111001"; --C;
			when "1101" => return "1011110"; --D;
			when "1110" => return "1111001"; --E;
			when "1111" => return "1110001"; --F;
			when others => return "0000000";
		end case;
	end function;

end package body;
