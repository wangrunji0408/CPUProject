library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Base is
	subtype u32 is unsigned(31 downto 0);
	subtype u16 is unsigned(15 downto 0);
	subtype u18 is unsigned(17 downto 0);
	subtype u8 is unsigned(7 downto 0);
	subtype u5 is unsigned(4 downto 0);
	subtype u4 is unsigned(3 downto 0);
	subtype u3 is unsigned(2 downto 0);

	subtype Inst is u16;
	subtype InstOpcode is u5;
	subtype AluOpcode is u4;
	subtype RegAddr is u3;

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

	type RegPort is record
		enable: std_logic;
		addr, data: u16;
	end record;

	type AluInput is record
		op: u4;
		a, b: u16;
	end record;

	-- 控制信号定义（临时）
	type TRegDst is (Rx, Ry, Rz);
	type TRegWrite is (None, Reg, SP, T, RA, IH);
	type TMemToReg is (ALU, MDR);
	type TAluSrcA is (A, PC);
	type TAluSrcB is (B, One, IR);
	type TIorD is (PC, ALU);
	type TPCSrc is (ALU, ALUout);
	
	function toBitStr (x: unsigned) return string;
	function toString (x: unsigned) return string;
	function to_u4 (x: integer) return u4;
	function to_u16 (x: integer) return u16;
	function DisplayNumber (number: u4) return std_logic_vector;

	function signExtend (number: u16) return u32;

	-- Get part from instruction
	function getOp (x: Inst) return InstOpcode;
	function getRx (x: Inst) return RegAddr;
	function getRy (x: Inst) return RegAddr;
	function getRz (x: Inst) return RegAddr;
	function getIm8 (x: Inst) return u8;

	-- define ALU op
	constant OP_ADD: 	AluOpcode := to_u4(0); 
	constant OP_SUB: 	AluOpcode := to_u4(1); 
	constant OP_AND: 	AluOpcode := to_u4(2); 
	constant OP_OR: 	AluOpcode := to_u4(3); 
	constant OP_XOR: 	AluOpcode := to_u4(4); 
	constant OP_NOT: 	AluOpcode := to_u4(5); 
	constant OP_SLL: 	AluOpcode := to_u4(6); 
	constant OP_SRL: 	AluOpcode := to_u4(7); 
	constant OP_SRA: 	AluOpcode := to_u4(8); 
	constant OP_ROL: 	AluOpcode := to_u4(9); 

	-- define Instruction op
	constant INST_ADDIU: 	InstOpcode := "01001";
	constant INST_ADDIU3: 	InstOpcode := "01000";
	constant INST_ADDSP3: 	InstOpcode := "00000";
	constant INST_ADDSP: 	InstOpcode := "01100";	-- warn: same 0
	constant INST_ADDU: 	InstOpcode := "11100";	-- warn: same 2
	constant INST_AND: 		InstOpcode := "11101";	-- warn: same 1
	constant INST_B: 		InstOpcode := "00010";
	constant INST_BEQZ: 	InstOpcode := "00100";
	constant INST_BNEZ: 	InstOpcode := "00101";
	constant INST_BTEQZ: 	InstOpcode := "01100";	-- warn: same 0
	constant INST_BTNEZ: 	InstOpcode := "01100";	-- warn: same 0
	constant INST_CMP: 		InstOpcode := "11101";	-- warn: same 1
	constant INST_CMPI: 	InstOpcode := "01110";
	constant INST_INT: 		InstOpcode := "11111";
	constant INST_JALR: 	InstOpcode := "11101";	-- warn: same 1
	constant INST_JR: 		InstOpcode := "11101";	-- warn: same 1
	constant INST_JRRA: 	InstOpcode := "11101";	-- warn: same 1
	constant INST_LI: 		InstOpcode := "01101";
	constant INST_LW: 		InstOpcode := "10011";
	constant INST_LW_SP: 	InstOpcode := "10010";
	constant INST_MFIH: 	InstOpcode := "11110";	-- warn: same 3
	constant INST_MFPC: 	InstOpcode := "11101";	-- warn: same 1
	constant INST_MOVE: 	InstOpcode := "01111";
	constant INST_MTIH: 	InstOpcode := "11110";	-- warn: same 3
	constant INST_MTSP: 	InstOpcode := "01100";	-- warn: same 0
	constant INST_NEG: 		InstOpcode := "11101";	-- warn: same 1
	constant INST_NOT: 		InstOpcode := "11101";	-- warn: same 1
	constant INST_NOP: 		InstOpcode := "00001";
	constant INST_OR: 		InstOpcode := "11101";	-- warn: same 1
	constant INST_SLL: 		InstOpcode := "00110";	-- warn: same 4
	constant INST_SLLV: 	InstOpcode := "11101";	-- warn: same 1
	constant INST_SLT: 		InstOpcode := "11101";	-- warn: same 1
	constant INST_SLTI: 	InstOpcode := "01010";
	constant INST_SLTU: 	InstOpcode := "11101";	-- warn: same 1
	constant INST_SLTUI: 	InstOpcode := "01011";
	constant INST_SRA: 		InstOpcode := "00110";	-- warn: same 4
	constant INST_SRAV: 	InstOpcode := "11101";	-- warn: same 1
	constant INST_SRL: 		InstOpcode := "00110";	-- warn: same 4
	constant INST_SRLV: 	InstOpcode := "11101";	-- warn: same 1
	constant INST_SUBU: 	InstOpcode := "11100";	-- warn: same 2
	constant INST_SW: 		InstOpcode := "11011";
	constant INST_SW_RS: 	InstOpcode := "01100";	-- warn: same 0
	constant INST_SW_SP: 	InstOpcode := "11010";
	constant INST_XOR: 		InstOpcode := "11101";	-- warn: same 1
	
end package ;

package body Base is

	function getOp (x: Inst) return InstOpcode is
	begin
		return x(15 downto 11);
	end function;
	
	function getRx (x: Inst) return RegAddr is
	begin
		return x(10 downto 8);
	end function;

	function getRy (x: Inst) return RegAddr is
	begin
		return x(7 downto 5);
	end function;
	
	function getRz (x: Inst) return RegAddr is
	begin
		return x(4 downto 2);
	end function;

	function getIm8 (x: Inst) return u8 is
	begin
		return x(7 downto 0);
	end function;

	function signExtend (number: u16) return u32 is
	begin
		if number(15) = '0' then
			return x"0000" & number;
		else
			return x"FFFF" & number;
		end if;
	end function;
	
	function toBitStr (x: unsigned) return string is 
	begin
		return integer'image(to_integer(x));
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
