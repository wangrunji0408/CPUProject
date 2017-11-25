library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity Alu is
	port (
		op: in AluOp;
		a, b: in u16;
		s: out u16
	) ;
end Alu;

architecture arch of Alu is	
begin
    
    calc : process (op, a, b)
        variable temp : u16;
    begin
        s <= x"0000";
        case(op) is
            when OP_NOP =>
            when OP_ADD =>
                s <= a + b;
            when OP_SUB =>
                s <= a - b;
            when OP_AND =>
                s <= a and b;
            when OP_OR =>
                s <= a or b;
            when OP_XOR =>
                s <= a xor b;
            when OP_NOT =>
                s <= not a;
            when OP_SLL =>
                s <= a sll to_integer(b);
            when OP_SRL =>
                s <= a srl to_integer(b); 
            when OP_SRA =>
                s <= unsigned(shift_right(signed(a), to_integer(b)));
            when OP_ROL =>
                s <= a rol to_integer(b);
            when OP_LTU =>
                if a < b then
                    s <= x"0001";
                end if;
            when OP_LTS =>
                if signed(a) < signed(b) then
                    s <= x"0001";
                end if;
            when OP_EQ =>
                if a /= b then
                    s <= x"0001";
                end if;
            when others => s <= x"0000";
        end case;
    end process;
	
end arch ; -- arch
