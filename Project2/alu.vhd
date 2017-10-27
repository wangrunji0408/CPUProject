library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use work.Base.all;

entity ALU is
	port (
		op: in u4;
		a: in u16;
		b: in u16;
		s: out u16;
		cf, zf, sf, vf: out std_logic
	) ;
end ALU;

architecture arch of ALU is
	
begin
	calc : process(a, b, op)
        variable temp : u16;
	begin
        cf <= '0';
        zf <= '0';
		sf <= '0';
		vf <= '0';
		case( op ) is
			when "0000" =>       --ADD
                temp := a + b;
                if (to_integer(temp) < to_integer(a)) then
                    cf <= '1';
                end if;
                if (temp = "0000000000000000") then
                    zf <= '1';
                end if;
                if (temp(15) = '1') then
                    sf <= '1';
                end if;
                if ((temp(15) = '1') /= (a(15) = '1')) and ((a(15) = '1') = (b(15) = '1')) then
                    vf <= '1';
                end if;
                s <= temp;
			when "0001" =>       --SUB
                temp := a - b;
                if (to_integer(a) < to_integer(b)) then
                    cf <= '1';
                end if;
                if (temp = "0000000000000000") then
                    zf <= '1';
                end if;
                if (temp(15) = '1') then
                    sf <= '1';
                end if;
                if ((temp(15) = '1') /= (a(15) = '1')) and ((a(15) = '1') = (b(15) = '0')) then
                    vf <= '1';
                end if;
                s <= temp;
            when "0010" =>       --AND 
                temp := a and b;
                if (temp = "0000000000000000") then
                    zf <= '1';
                end if;
                if (temp(15) = '1') then
                    sf <= '1';
                end if;
                s <= temp;
            when "0011" =>       --OR
                temp := a or b;
                if (temp = "0000000000000000") then
                    zf <= '1';
                end if;
                if (temp(15) = '1') then
                    sf <= '1';
                end if;
                s <= temp;
            when "0100" =>       --XOR
                temp := a xor b;
                if (temp = "0000000000000000") then
                    zf <= '1';
                end if;
                if (temp(15) = '1') then
                    sf <= '1';
                end if;
                s <= temp;
            when "0101" =>       --NOT
                temp := not a;
                if (temp = "0000000000000000") then
                    zf <= '1';
                end if;
                if (temp(15) = '1') then
                    sf <= '1';
                end if;
                s <= temp;
            when "0110" =>       --SLL
                temp := a sll to_integer(b);
                if (temp = "0000000000000000") then
                    zf <= '1';
                end if;
                if (temp(15) = '1') then
                    sf <= '1';
                end if;
                s <= temp;
            when "0111" =>       --SRL
                temp := a srl to_integer(b);
                if (temp = "0000000000000000") then
                    zf <= '1';
                end if;
                if (temp(15) = '1') then
                    sf <= '1';
                end if;
                s <= temp;
            when "1000" =>       --SAR
                temp := unsigned(shift_right(signed(a), to_integer(b)));
                if (temp = "0000000000000000") then
                    zf <= '1';
                end if;
                if (temp(15) = '1') then
                    sf <= '1';
                end if;
                s <= temp;
            when "1001" =>       --ROL
                temp := a rol to_integer(b);
                if (temp = "0000000000000000") then
                    zf <= '1';
                end if;
                if (temp(15) = '1') then
                    sf <= '1';
                end if;
                s <= temp;
			when others => s <= to_unsigned(0, 16);
		end case ;
	end process ; -- calc

end arch ; -- arch
