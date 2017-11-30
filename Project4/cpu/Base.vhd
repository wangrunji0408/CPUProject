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
	type DataBufInfo is record
		data: DataBuf;
		writePos, readPos: natural range 0 to 63;
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

	type UartFlags is record
		data_ready, tbre, tsre: std_logic;
	end record;

	type UartCtrl is record
		read, write: std_logic;
		data: u16; -- is ram1_data
	end record;

	type FlashCtrl is record
		byte, ce, ce1, ce2, oe, rp, sts, vpen, we: std_logic;
	end record;

	type PCBranch is record
		isOffset, isJump: std_logic;
		offset, target: u16;
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

	type RamPort is record
		enable, read, write: std_logic;
		addr: u18;
		data: u16;
	end record;

	type MEMType is (
		None, 
		ReadRam1, WriteRam1, ReadRam2, WriteRam2, 
		ReadUart, WriteUart, TestUart,
		ReadUart2, WriteUart2, TestUart2
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
	end record;

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
		ex_in, mem_in: ID_MEM_Data;
		ex_in_aluInput: AluInput;
		mem_in_aluOut: u16;
		mem_out: RegPort;
	end record;

	constant NULL_REGPORT : RegPort := ('0', x"0", x"0000");
	constant NULL_RAMPORT : RamPort := ('1', '1', '1', "00" & x"0000", x"0000");
	constant NULL_ALUINPUT : AluInput := (OP_NOP, x"0000", x"0000");
	constant NULL_PCBRANCH : PCBranch := ('0', '0', x"0000", x"0000");
	constant NULL_IOEVENT: IOEvent := (x"0000", None, x"0000", x"0000");	
	
	function toStr2 (x: u16) return string;
	function toStr16 (x: u16) return string;
	function toHex8 (x: u8) return string;
	function charToU8 (x: character) return u8;
	function charToU4 (x: character) return u4;
	function toHex (x: u4) return character;
	function toString (x: unsigned) return string;
	function showInst (x: InstType) return string;
	function to_u4 (x: integer) return u4;
	function to_u16 (x: integer) return u16;
	constant show_IOEvent_Title: string(1 to 17) := " PC     Addr Data";
	function show_IOEvent (x: IOEvent) return string; -- len = 17
	function show_Mode (mode: CPUMode; pc: u16) return string; --len=15
	function show_AluOp(x: AluOp) return string; --len=3
	function show_AluInput (x: AluInput) return string; --len=17
	function show_RegPort (x: RegPort) return string; --len=7
	function show_Branch (x: PCBranch) return string; --len=6
	function show_IF_Data (x: IF_Data) return string; --len=11
	function show_IF_ID_Data (x: IF_ID_Data) return string;	--len=21
	function show_ID_MEM_Data (x: ID_MEM_Data) return string; --len=15
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

	function toStr2 (x: u16) return string is 
		variable s: string(1 to 16);
	begin
		for i in 1 to 16 loop
			case x(i-1) is
				when '0' => s(i) := '0';
				when '1' => s(i) := '1';
				when 'Z' => s(i) := 'Z';
				when 'U' => s(i) := 'U';
				when 'X' => s(i) := 'X';
				when others => s(i) := '?';
			end case ;
		end loop ; -- 
		return s;
	end function;

	function toStr16 (x: u16) return string is 
		variable hex : string(1 to 4);
		variable fourbit : u4;
	begin
		for i in 3 downto 0 loop
			fourbit:=x(((i*4)+3) downto (i*4));
			hex(4-I) := toHex(fourbit);
		end loop;
		return hex;
	end function;

	function toHex8 (x: u8) return string is
	begin
		return toHex(x(7 downto 4)) & toHex(x(3 downto 0));
	end function;

	function charToU8 (x: character) return u8 is
	begin
		return to_unsigned(character'pos(x), 8);
	end function;

	function charToU4 (x: character) return u4 is
	begin
		case( x ) is
			when '0' => return x"0";
			when '1' => return x"1";
			when '2' => return x"2";
			when '3' => return x"3";
			when '4' => return x"4";
			when '5' => return x"5";
			when '6' => return x"6";
			when '7' => return x"7";
			when '8' => return x"8";
			when '9' => return x"9";
			when 'a'|'A' => return x"A";
			when 'b'|'B' => return x"B";
			when 'c'|'C' => return x"C";
			when 'd'|'D' => return x"D";
			when 'e'|'E' => return x"E";
			when 'f'|'F' => return x"F";		
			when others => return x"0";
		end case ;
	end function;

	function toHex (x: u4) return character is 
	begin
		case x is
			when "0000" => return '0';
			when "0001" => return '1';
			when "0010" => return '2';
			when "0011" => return '3';
			when "0100" => return '4';
			when "0101" => return '5';
			when "0110" => return '6';
			when "0111" => return '7';
			when "1000" => return '8';
			when "1001" => return '9';
			when "1010" => return 'A';
			when "1011" => return 'B';
			when "1100" => return 'C';
			when "1101" => return 'D';
			when "1110" => return 'E';
			when "1111" => return 'F';
			when "ZZZZ" => return 'z';
			when "UUUU" => return 'u';
			when "XXXX" => return 'x';
			when others => return '?';
		end case;
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

	function show_Mode (mode: CPUMode; pc: u16) return string is -- len = 15
	begin
		case( mode ) is
		when STEP => 		return "Step           ";
		when BREAK_POINT => return "BreakPoint=" & toStr16(pc);
		end case;
	end function;

	function show_IOEvent (x: IOEvent) return string is -- len = 17
		variable mode_str: string(1 to 2) := "--";
	begin
		case( x.mode ) is
			when ReadRam1 => mode_str := "R1";
			when ReadRam2 => mode_str := "R2";
			when ReadUart => mode_str := "RU";
			when ReadUart2 => mode_str := "RS";
			when WriteRam1 => mode_str := "W1";
			when WriteRam2 => mode_str := "W2";
			when WriteUart => mode_str := "WU";
			when WriteUart2 => mode_str := "WS";
			when TestUart => mode_str := "TU";
			when TestUart2 => mode_str := "TS";
			when others => null;
		end case ;
		return toStr16(x.pc) & " " & mode_str & " " & toStr16(x.addr) & " " & toStr16(x.data);
	end function;

	function show_AluInput (x: AluInput) return string is -- len = 17
	begin
		return "ALU:" & show_AluOp(x.op) & " " & toStr16(x.a) & " " & toStr16(x.b);
	end function;

	function show_RegPort (x: RegPort) return string is -- len = 7
	begin
		if x.enable = '0' then return "NULLREG";
		else return "R" & toHex(x.addr) & "=" & toStr16(x.data);
		end if;
	end function;

	function show_Branch (x: PCBranch) return string is --len=6
	begin
		if x.isOffset = '1' then
			return "+=" & toStr16(x.offset);
		elsif x.isJump = '1' then
			return "<=" & toStr16(x.target);
		else
			return "++    ";
		end if;
	end function;

	function show_IF_Data (x: IF_Data) return string is --len=11
	begin
		return toStr16(x.pc) & " " & show_Branch(x.branch);
	end function;

	function show_IF_ID_Data (x: IF_ID_Data) return string is -- len = 21
	begin
		return toStr16(x.pc) & " " & toStr2(x.inst); 
	end function;

	function show_ID_MEM_Data (x: ID_MEM_Data) return string is -- len = 15
		variable s: string(1 to 8) := " --     ";
	begin
		if x.isLW = '1' then 		s := " LW     ";
		elsif x.isSW = '1' then 	s := " SW " & toStr16(x.writeMemData);
		end if;
		return show_RegPort(x.writeReg) & s;
	end function;

	function show_AluOp(x: AluOp) return string is
	begin
		case( x ) is
			when OP_NOP => return "NOP";
			when OP_ADD => return "ADD"; 
			when OP_SUB => return "SUB"; 
			when OP_AND => return "AND"; 
			when OP_OR  => return "OR "; 
			when OP_XOR => return "XOR"; 
			when OP_NOT => return "NOT"; 
			when OP_SLL => return "SLL"; 
			when OP_SRL => return "SRL"; 
			when OP_SRA => return "SRA"; 
			when OP_ROL => return "ROL";
			when OP_LTU => return "LTU"; 
			when OP_LTS => return "LTS"; 
			when OP_EQ  => return "EQ ";
			when others => return "???";
		end case ;
	end function;

	function showInst (x: InstType) return string is
	begin
		case( x ) is
			when I_AND => 		return "AND   "; 
			when I_OR => 		return "OR    "; 
			when I_ADDU => 		return "ADDU  "; 
			when I_SUBU => 		return "SUBU  "; 
			when I_SLT => 		return "SLT   "; 
			when I_CMP => 		return "CMP   ";
			when I_ADDIU => 	return "ADDIU "; 
			when I_ADDIU3 => 	return "ADDIU3"; 
			when I_ADDSP => 	return "ADDSP "; 
			when I_ADDSP3 => 	return "ADDSP3"; 
			when I_SLL => 		return "SLL   "; 
			when I_SRA => 		return "SRA   "; 
			when I_SRL => 		return "SRL   "; 
			when I_SLTUI => 	return "SLTUI "; 
			when I_NOT => 		return "NOT   "; 
			when I_LI => 		return "LI    ";
			when I_MFIH => 		return "MFIH  "; 
			when I_MFPC => 		return "MFPC  "; 
			when I_MTIH => 		return "MTIH  "; 
			when I_MTSP => 		return "MTSP  ";
			when I_B => 		return "B     "; 
			when I_BEQZ => 		return "BEQZ  "; 
			when I_BNEZ => 		return "BNEZ  "; 
			when I_BTEQZ => 	return "BTEQZ "; 
			when I_JR => 		return "JR    ";
			when I_LW => 		return "LW    "; 
			when I_LW_SP => 	return "LW_SP "; 
			when I_SW => 		return "SW    "; 
			when I_SW_SP => 	return "SW_SP "; 
			when I_SW_RS => 	return "SW_RS ";
			when I_NOP => 		return "NOP   ";
			when I_ERR => 		return "ERROR!";
			when others => 		return "others";
		end case ;
	end function;
	
end package body;
