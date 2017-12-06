library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity Hard_term is
    port(
        clk, rst : in std_logic;
        cmdIn : in string(1 to 16);         --输入的指令 换行符结束
        data_in :in u16;              -- 
        addr, data_out : out u16;                 --需要读写的地址和数据
        cmd : out TermCmd;
        show : out string(1 to 32);
    );
end Hard_term;

architecture arch of Hard_term is
    variable cmdAddr, cmdLen: u16;
begin
    cmd <= T_REG when cmdIn(1) = 'R' else
            T_ASM when cmdIn(1) = 'A' else
            T_UASM when cmdIn(1) = 'U' else
            T_GO when cmdIn(1) = 'G' else
            T_DATA when cmdIn(1) = 'D' else
            T_NULL when others;
            
    cmdAddr <= 
            
    process (cmdIn)
    
    end process;
    
end arch;