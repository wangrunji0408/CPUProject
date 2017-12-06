library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity Hard_term is
    port(
        clk, rst : in std_logic;
        
        -- 从shell到hard_term
        ci_read: out std_logic;
        ci_canread: in std_logic;
        ci_data: in character;
        
        --从hard_term到shell
        co_write: out std_logic;
        co_canwrite: in std_logic;
        co_data: out character;
        
        --从buffer到hard_term
        bi_read: out std_logic;
        bi_canread: in std_logic;
        bi_data: in u8;
        
        --从hard_term到buffer
        bo_write: out std_logic;
        bo_canwrite: in std_logic;
        bo_data: out u8;
        
    );
end Hard_term;


architecture arch of Hard_term is
    type TStatus is (ReadShell, WriteBuffer, ReadBuffer, WriteShell);
    signal status: TStatus;
    signal count: integer := 0;
begin
    cmd <= T_REG when cmdIn(1) = 'R' else
            T_ASM when cmdIn(1) = 'A' else
            T_UASM when cmdIn(1) = 'U' else
            T_GO when cmdIn(1) = 'G' else
            T_DATA when cmdIn(1) = 'D' else
            T_NULL when others;

    process (clk, rst, ci_canread, ci_data, co_canwrite, co_data, bi_canread, bi_data, bo_canwrite, bo_data)
        variable cmdIn: string(1 to 32);
        variable chr: character;
        variable len: integer;
    begin
        if rst = '0' then
            count <= 0;
            ci_read <= '1';
            co_write <= '1';
            bi_read <= '1';
            bo_write <= '1';
            cmdIn := (others => ' ');
        elsif rising_edge(clk) then
            count <= count + 1;
            case status is
            when ReadShell =>
                case count is
                when 0 =>
                    if (ci_canread = '1') then
                        ci_read <= '0';
                    else
                        count <= count;
                    end if;
                    
                when others => count <= 0;
                end case;
            when WriteBuffer =>
            
            when ReadBuffer =>
            
            when WriteShell =>
                
                
            
            when others => null;
            end case;
        end if;
    end process;
    
end arch;