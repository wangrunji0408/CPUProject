library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 渲染器用到的字符串化函数
package Show is
	
	function toStr2 (x: u16) return string;
	function toStr16 (x: u16) return string;
	function toHex8 (x: u8) return string;
	function toHex (x: u4) return character;
	function showInst (x: InstType) return string;
	constant show_IOEvent_Title: string(1 to 17) := " PC     Addr Data";
	function show_IOEvent (x: IOEvent) return string; -- len = 17
	function show_Mode (mode: CPUMode; pc: u16) return string; --len=15
	function show_MEMType (x: MEMType) return string; --len=2	
	function show_AluOp(x: AluOp) return string; --len=3
	function show_AluInput (x: AluInput) return string; --len=17
	function show_RegPort (x: RegPort) return string; --len=7
	function show_Branch (x: PCBranch) return string; --len=6
	function show_IF_Data (x: IF_Data) return string; --len=11
	function show_IF_ID_Data (x: IF_ID_Data) return string;	--len=21
	function show_ID_EX_Data (x: ID_EX_Data) return string; --len=15
	function show_EX_MEM_Data (x: EX_MEM_Data) return string; --len=20
    
end package ;

package body Show is

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

	function show_Mode (mode: CPUMode; pc: u16) return string is -- len = 15
	begin
		case( mode ) is
		when STEP => 		return "Step           ";
		when BREAK_POINT => return "BreakPoint=" & toStr16(pc);
		end case;
	end function;

	function show_MEMType (x: MEMType) return string is -- len = 2
	begin
		case( x ) is
			when ReadRam1 => return "R1";
			when ReadRam2 => return "R2";
			when ReadUart => return "RU";
			when ReadUart2 => return "RS";
			when WriteRam1 => return "W1";
			when WriteRam2 => return "W2";
			when WriteUart => return "WU";
			when WriteUart2 => return "WS";
			when TestUart => return "TU";
			when TestUart2 => return "TS";
			when others => return "--";
		end case ;
	end function;

	function show_IOEvent (x: IOEvent) return string is -- len = 17
	begin
		return toStr16(x.pc) & " " & show_MEMType(x.mode) & " " & toStr16(x.addr) & " " & toStr16(x.data);
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
		if x.enable = '1' then
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

	function show_ID_EX_Data (x: ID_EX_Data) return string is -- len = 15
		variable s: string(1 to 8) := " --     ";
	begin
		if x.isLW = '1' then 		s := " LW     ";
		elsif x.isSW = '1' then 	s := " SW " & toStr16(x.writeMemData);
		end if;
		return show_RegPort(x.writeReg) & s;
	end function;

	function show_EX_MEM_Data (x: EX_MEM_Data) return string is -- len = 20
	begin
		return show_RegPort(x.writeReg) & " " & show_MEMType(x.mem_type) & " " & toStr16(x.mem_addr) & " " & toStr16(x.mem_write_data);
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
