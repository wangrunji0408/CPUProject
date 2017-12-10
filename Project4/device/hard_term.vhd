library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity HardTerm is
    port(
        rst, clk : in std_logic;
        
        -- 从shell到hard_term
        ci_read: out std_logic;
        ci_canread: in std_logic;
        ci_data: in u8;
        
        --从hard_term到shell
        co_write: out std_logic;
        co_canwrite: in std_logic;
        co_data: out u8;
        
        --从buffer到hard_term
        bi_read: out std_logic;
        bi_canread: in std_logic;
        bi_data: in u8;
        
        --从hard_term到buffer
        bo_write: out std_logic;
        bo_canwrite: in std_logic;
        bo_data: out u8;
        
        --调试用
        count: buffer integer;
        cmd: out TermCmd
    );
end HardTerm;


architecture arch of HardTerm is
    type TStatus is (GetOK, ReadShell, CmdA, CmdD, CmdG, CmdU, CmdR);
    signal status: TStatus;
    signal inst: u16;
begin

    process (clk, rst, ci_canread, ci_data, co_canwrite, bi_canread, bi_data, bo_canwrite)
        type datastr is array (1 to 32) of u8;
        variable cmdIn, dataOut: datastr;
        variable chr: character;
        variable lenCmd, lenData, cnt1, cnt2: integer;
        variable addr, im, mips: u16;
        variable len: u8;
        variable opcode : InstOpcode;
        variable subopcode : InstOpcode;
        variable opu : u2;
        variable aluOp: AluOp;
        variable oprx : u4;
    begin
        if rst = '0' then
            count <= 0;
            ci_read <= '1';
            co_write <= '1';
            bi_read <= '1';
            bo_write <= '1';
            cmd <= T_NULL;
            cmdIn := (others => x"00");
            dataOut := (others => x"20");
            lenCmd := 0;
            lenData := 0;
            cnt1 := 0;
            cnt2 := 0;
            status <= GetOK;
        elsif rising_edge(clk) then
            count <= count + 1;
            case status is
            when GetOK =>
                case count is
                when 0 =>
                    if (bi_canread = '1') then
                        bi_read <= '0';
                    else
                        count <= count;
                    end if;
                when 1 =>
                    lenData := lenData + 1;
                    dataOut(lenData) := bi_data;
                    bi_read <= '1';
                    if (bi_data = x"0D") then
                        cnt2 := cnt2 + 1;
                    else
                        count <= 0;
                    end if;
                when 2 =>
                    if (co_canwrite = '1') then
                        co_data <= dataOut(cnt2);
                        co_write <= '0';
                    else
                        count <= count;
                    end if;
                when 3 =>
                    cnt2 := cnt2 + 1;
                    co_write <= '1';
                when 4 =>
                    if (cnt2 = 5) then
                        status <= ReadShell;
                        cnt2 := 0;
                        dataOut := (others => x"20");
                        count <= 0;
                    else
                        count <= 2;
                    end if;
                when others => count <= 0;
                end case;
            when ReadShell =>
                case count is
                when 0 =>
                    if (co_canwrite = '1') then
                        co_data <= x"3E";
                        co_write <= '0';
                    else
                        count <= count;
                    end if;
                when 1 =>
                    co_write <= '1';
                when 2 =>
                    if (co_canwrite = '1') then
                        co_data <= x"3E";
                        co_write <= '0';
                    else
                        count <= count;
                    end if;
                when 3 =>
                    co_write <= '1';
                when 4 =>
                    if (ci_canread = '1') then
                        ci_read <= '0';
                    else
                        count <= count;
                    end if;
                when 5 =>            
                    ci_read <= '1';
                    if (ci_data = x"0D") then
                        count <= 0;
                        case cmdIn(1) is
                        when x"41" =>
                            cmd <= T_ASM;
                            status <= CmdA;
                        when x"44" =>
                            cmd <= T_DATA;
                            status <= CmdD;
                        when x"47" =>
                            cmd <= T_GO;
                            status <= CmdG;
                        when x"52" =>
                            cmd <= T_REG;
                            status <= CmdR;
                        when x"55" =>
                            cmd <= T_UASM;
                            status <= CmdU;
                        when others =>
                            cmd <= T_NULL;
                            lenCmd := 0;
                        end case;
                    else                        
                        lenCmd := lenCmd + 1;
                        cmdIn(lenCmd) := ci_data;
                        count <= 4;
                    end if;
                when others => count <= 0;
                end case;
            when CmdA =>
                case count is 
                when 0 =>
                    if (bo_canwrite = '1') then
                        bo_data <= x"41";
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 1 =>
                    bo_write <= '1';
                when 2 =>
                    if (bo_canwrite = '1') then
                        if (lenCmd >= 6) then
                            bo_data(7 downto 4) <= toData(cmdIn(5));
                            bo_data(3 downto 0) <= toData(cmdIn(6));
                            addr(7 downto 4) := toData(cmdIn(5));
                            addr(3 downto 0) := toData(cmdIn(6));
                        else
                            bo_data <= x"00";
                            addr(7 downto 0) := x"00";
                        end if;
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 3 =>   --addr low
                    bo_write <= '1';
                when 4 =>
                    if (bo_canwrite = '1') then
                        if (lenCmd >= 6) then
                            bo_data(7 downto 4) <= toData(cmdIn(3));
                            bo_data(3 downto 0) <= toData(cmdIn(4));
                            addr(15 downto 12) := toData(cmdIn(3));
                            addr(11 downto 8) := toData(cmdIn(4));
                        else
                            bo_data <= x"40";
                            addr(15 downto 8) := x"40";
                        end if;                    
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 5 =>   --addr high
                    bo_write <= '1';
                    dataOut(1) := x"5B";
                    dataOut(2) := toAscii(addr(15 downto 12));
                    dataOut(3) := toAscii(addr(11 downto 8));
                    dataOut(4) := toAscii(addr(7 downto 4));
                    dataOut(5) := toAscii(addr(3 downto 0));
                    dataOut(6) := x"5D";
                when 6 =>
                    if (co_canwrite = '1') then
                        cnt2 := cnt2 + 1;
                        co_data <= dataOut(cnt2);
                        co_write <= '0';
                    else
                        count <= count;
                    end if;
                when 7 =>
                    co_write <= '1';
                    if (cnt2 = 6) then
                        cnt2 := 0;
                        dataOut := (others => x"20");
                        cmdIn := (others => x"00");
                        lenCmd := 0;
                    else
                        count <= 6;
                    end if;
                when 8 =>       --wait for input
                    if (ci_canread = '1') then
                        ci_read <= '0';
                    else
                        count <= count;
                    end if;
                when 9 =>
                    if (ci_data = x"0D") then
                        if (lenCmd = 0) then
                            addr := x"0000"; 
                        else
                            null;
                        end if;
                    else                        
                        lenCmd := lenCmd + 1;
                        cmdIn(lenCmd) := ci_data;
                        ci_read <= '1';
                        count <= 8;
                    end if;
                when 10 =>
                    --ASM
                    if (cmdIn(1 to 6) = (x"41", x"44", x"44", x"49", x"55", x"33")) then --ADDIU3
                        mips(15 downto 11) := "01000";
                        mips(10 downto 8) := toData(cmdIn(8))(2 downto 0);
                        mips(7 downto 5) := toData(cmdIn(11))(2 downto 0);
                        mips(4 downto 0) := "0" & toData(cmdIn(13));
                    elsif (cmdIn(1 to 5) = (x"41", x"44", x"44", x"49", x"55")) then --ADDIU
                        mips(15 downto 11) := "01001";
                        mips(10 downto 8) := toData(cmdIn(8))(2 downto 0);
                        mips(7 downto 4) := toData(cmdIn(10));
                        mips(3 downto 0) := toData(cmdIn(11));
                    elsif (cmdIn(1 to 6) = (x"41", x"44", x"44", x"53", x"50", x"33")) then --ADDSP3
                        mips(15 downto 11) := "00000";
                        mips(10 downto 8) := toData(cmdIn(8))(2 downto 0);
                        mips(7 downto 4) := toData(cmdIn(11));
                        mips(3 downto 0) := toData(cmdIn(12));
                    elsif (cmdIn(1 to 5) = (x"41", x"44", x"44", x"53", x"50")) then --ADDSP
                        mips(15 downto 8) := "01100011";
                        mips(7 downto 4) := toData(cmdIn(7));
                        mips(3 downto 0) := toData(cmdIn(8));
                    elsif (cmdIn(1 to 4) = (x"41", x"44", x"44", x"55")) then --ADDU
                        mips(15 downto 11) := "11100";
                        mips(10 downto 8) := toData(cmdIn(7))(2 downto 0);
                        mips(7 downto 5) := toData(cmdIn(10))(2 downto 0);
                        mips(4 downto 2) := toData(cmdIn(13))(2 downto 0);
                        mips(1 downto 0) := "01";
                    elsif (cmdIn(1 to 3) = (x"41", x"4E", x"44")) then --AND
                        mips(15 downto 11) := "11101";
                        mips(10 downto 8) := toData(cmdIn(6))(2 downto 0);
                        mips(7 downto 5) := toData(cmdIn(8))(2 downto 0);
                        mips(4 downto 0) := "01100";
                    elsif (cmdIn(1 to 4) = (x"42", x"45", x"51", x"5A")) then --BEQZ
                        mips(15 downto 11) := "00100";
                        mips(10 downto 8) := toData(cmdIn(7))(2 downto 0);
                        mips(7 downto 4) := toData(cmdIn(9));
                        mips(3 downto 0) := toData(cmdIn(10));
                    elsif (cmdIn(1 to 4) = (x"42", x"4E", x"45", x"5A")) then --BNEZ
                        mips(15 downto 11) := "00101";
                        mips(10 downto 8) := toData(cmdIn(7))(2 downto 0);
                        mips(7 downto 4) := toData(cmdIn(9));
                        mips(3 downto 0) := toData(cmdIn(10));
                    elsif (cmdIn(1 to 5) = (x"42", x"54", x"45", x"51", x"5A")) then --BTEQZ
                        mips(15 downto 8) := "01100000";
                        mips(7 downto 4) := toData(cmdIn(7));
                        mips(3 downto 0) := toData(cmdIn(8));
                    elsif (cmdIn(1) = x"42") then --B
                        mips(15 downto 11) := "00010";
                        mips(7 downto 4) := toData(cmdIn(3));
                        mips(3 downto 0) := toData(cmdIn(4));
                        if (mips(7) = '1') then
                            mips(10 downto 8) := "111";
                        else
                            mips(10 downto 8) := "000";
                        end if;
                    elsif (cmdIn(1 to 3) = (x"43", x"4D" ,x"50")) then --CMP
                        mips(15 downto 11) := "11101";
                        mips(10 downto 8) := toData(cmdIn(6))(2 downto 0);
                        mips(7 downto 5) := toData(cmdIn(8))(2 downto 0);
                        mips(4 downto 0) := "01010";
                    elsif (cmdIn(1 to 2) = (x"4A", x"52")) then --JR
                        mips(15 downto 11) := "11101";
                        mips(10 downto 8) := toData(cmdIn(5))(2 downto 0);
                        mips(7 downto 0) := "00000000";
                    elsif (cmdIn(1 to 2) = (x"4C", x"49")) then --LI
                        mips(15 downto 11) := "01101";
                        mips(10 downto 8) := toData(cmdIn(5))(2 downto 0);
                        mips(7 downto 4) := toData(cmdIn(7));
                        mips(3 downto 0) := toData(cmdIn(8));
                    elsif (cmdIn(1 to 5) = (x"4C", x"57", x"5F", x"53", x"50")) then --LW_SP
                        mips(15 downto 11) := "10010";
                        mips(10 downto 8) := toData(cmdIn(8))(2 downto 0);
                        mips(7 downto 4) := toData(cmdIn(10));
                        mips(3 downto 0) := toData(cmdIn(11));
                    elsif (cmdIn(1 to 2) = (x"4C", x"57")) then --LW
                        mips(15 downto 11) := "10011";
                        mips(10 downto 8) := toData(cmdIn(5))(2 downto 0);
                        mips(7 downto 5) := toData(cmdIn(8))(2 downto 0);
                        mips(3 downto 0) := toData(cmdIn(10));
                        if (mips(3) = '1') then
                            mips(4) := '1';
                        else
                            mips(4) := '0';
                        end if;
                    elsif (cmdIn(1 to 4) = (x"4D", x"46", x"49", x"48")) then --MFIH
                        mips(15 downto 11) := "11110";
                        mips(10 downto 8) := toData(cmdIn(7))(2 downto 0);
                        mips(7 downto 0) := "00000000";
                    elsif (cmdIn(1 to 4) = (x"4D", x"46", x"50", x"43")) then --MFPC
                        mips(15 downto 11) := "11110";
                        mips(10 downto 8) := toData(cmdIn(7))(2 downto 0);
                        mips(7 downto 0) := "01000000";
                    elsif (cmdIn(1 to 4) = (x"4D", x"54", x"49" ,x"48")) then --MTIH
                        mips(15 downto 11) := "11110";
                        mips(10 downto 8) := toData(cmdIn(7))(2 downto 0);
                        mips(7 downto 0) := "00000001";
                    elsif (cmdIn(1 to 4) = (x"4D", x"54", x"53" ,x"50")) then --MTSP
                        mips(15 downto 8) := "01100100";
                        mips(7 downto 5) := toData(cmdIn(7))(2 downto 0);
                        mips(4 downto 0) := "00000";
                    elsif (cmdIn(1 to 3) = (x"4E", x"4F", x"54")) then --NOT
                        mips(15 downto 11) := "11101";
                        mips(10 downto 8) := toData(cmdIn(6))(2 downto 0);
                        mips(7 downto 5) := toData(cmdIn(8))(2 downto 0);
                        mips(4 downto 0) := "01111";
                    elsif (cmdIn(1 to 3) = (x"4E", x"4F", x"50")) then --NOP
                        mips := "0000100000000000";
                    elsif (cmdIn(1 to 2) = (x"4F", x"52")) then --OR
                        mips(15 downto 11) := "11101";
                        mips(10 downto 8) := toData(cmdIn(5))(2 downto 0);
                        mips(7 downto 5) := toData(cmdIn(8))(2 downto 0);
                        mips(4 downto 0) := "01101";
                    elsif (cmdIn(1 to 3) = (x"53", x"4C", x"4C")) then --SLL
                        mips(15 downto 11) := "00110";
                        mips(10 downto 8) := toData(cmdIn(6))(2 downto 0);
                        mips(7 downto 5) := toData(cmdIn(8))(2 downto 0);
                        mips(4 downto 2) := toData(cmdIn(11))(2 downto 0);
                        mips(1 downto 0) := "00";
                    elsif (cmdIn(1 to 3) = (x"53", x"4C", x"54")) then --SLT
                        mips(15 downto 11) := "11101";
                        mips(10 downto 8) := toData(cmdIn(6))(2 downto 0);
                        mips(7 downto 5) := toData(cmdIn(8))(2 downto 0);
                        mips(4 downto 0) := "00010";
                    elsif (cmdIn(1 to 3) = (x"53", x"52", x"41")) then --SRA
                        mips(15 downto 11) := "00110";
                        mips(10 downto 8) := toData(cmdIn(6))(2 downto 0);
                        mips(7 downto 5) := toData(cmdIn(8))(2 downto 0);
                        mips(4 downto 2) := toData(cmdIn(11))(2 downto 0);
                        mips(1 downto 0) := "11";
                    elsif (cmdIn(1 to 3) = (x"53", x"52", x"4C")) then --SRL
                        mips(15 downto 11) := "00110";
                        mips(10 downto 8) := toData(cmdIn(6))(2 downto 0);
                        mips(7 downto 5) := toData(cmdIn(8))(2 downto 0);
                        mips(4 downto 2) := toData(cmdIn(11))(2 downto 0);
                        mips(1 downto 0) := "10";
                    elsif (cmdIn(1 to 4) = (x"53", x"55", x"42", x"55")) then --SUBU
                        mips(15 downto 11) := "11100";
                        mips(10 downto 8) := toData(cmdIn(7))(2 downto 0);
                        mips(7 downto 5) := toData(cmdIn(10))(2 downto 0);
                        mips(4 downto 2) := toData(cmdIn(13))(2 downto 0);
                        mips(1 downto 0) := "11";
                    elsif (cmdIn(1 to 5) = (x"53", x"57", x"5F", x"53", x"50")) then --SW_SP
                        mips(15 downto 11) := "11010";
                        mips(10 downto 8) := toData(cmdIn(8))(2 downto 0);
                        mips(7 downto 4) := toData(cmdIn(10));
                        mips(3 downto 0) := toData(cmdIn(11));
                    elsif (cmdIn(1 to 5) = (x"53", x"57", x"5F", x"52", x"53")) then --SW_RS
                        mips(15 downto 8) := "01100010";
                        mips(7 downto 4) := toData(cmdIn(7));
                        mips(3 downto 0) := toData(cmdIn(8));
                    elsif (cmdIn(1 to 2) = (x"53", x"57")) then --SW
                        mips(15 downto 11) := "11011";
                        mips(10 downto 8) := toData(cmdIn(5))(2 downto 0);
                        mips(7 downto 5) := toData(cmdIn(8))(2 downto 0);
                        mips(3 downto 0) := toData(cmdIn(10));
                        if (mips(3) = '1') then
                            mips(4) := '1';
                        else
                            mips(4) := '0';
                        end if;
                    else
                        mips := x"FFFF";
                    end if;
                when 11 =>          
                    if (mips = x"FFFF") then
                        dataOut(1 to 6) := (x"45", x"52", x"52", x"4F", x"52", x"0D");
                    else
                        count <= 14;
                    end if;
                when 12 =>          --send error
                    if (co_canwrite = '1') then
                        cnt2 := cnt2 + 1;
                        co_data <= dataOut(cnt2);
                        co_write <= '0';
                    else
                        count <= count;
                    end if;
                when 13 =>
                    co_write <= '1';
                    if (dataOut(cnt2) = x"0D") then
                        cnt2 := 0;
                        dataOut := (others => x"20");
                        count <= 6;
                    else
                        count <= 12;
                    end if;
                when 14 =>          --write mips
                    if (addr = x"0000") then    --back judgement
                        cmdIn := (others => x"00");
                        dataOut := (others => x"20");
                        count <= 0;
                        status <= ReadShell;
                    else
                        if (bo_canwrite = '1') then
                            bo_write <= '0';
                            bo_data <= addr(7 downto 0);
                        else
                            count <= count;
                        end if;
                    end if;
                when 15 =>          --addr low
                    bo_write<= '1';
                when 16 =>
                    if (bo_canwrite = '1') then
                        bo_write <= '0';
                        bo_data <= addr(15 downto 8);
                    else
                        count <= count;
                    end if;
                when 17 =>          --addr high
                    bo_write<= '1';
                when 18 =>
                    if (bo_canwrite = '1') then
                        bo_write <= '0';
                        bo_data <= mips(15 downto 8);
                    else
                        count <= count;
                    end if;
                when 19 =>          --mips low
                    
                    bo_write<= '1';
                when 20 =>
                    if (bo_canwrite = '1') then
                        bo_data <= mips(15 downto 8);
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 21 =>          --mips high
                    bo_write<= '1';
                    count <= 8;
                when others => count <= 0;
                end case;
            when CmdD =>
                case count is 
                when 0 =>
                    if (bo_canwrite = '1') then
                        bo_data <= x"44";
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 1 =>
                    
                    bo_write <= '1';
                when 2 =>           --addr low
                    if (bo_canwrite = '1') then
                        if (lenCmd >= 6) then
                            bo_data(7 downto 4) <= toData(cmdIn(5));
                            bo_data(3 downto 0) <= toData(cmdIn(6));
                            addr(7 downto 4) := toData(cmdIn(5));
                            addr(3 downto 0) := toData(cmdIn(6));
                        else
                            bo_data <= x"00";
                            addr(7 downto 0) := x"00";
                        end if;
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 3 =>           
                    bo_write <= '1';
                when 4 =>           --addr high
                    if (bo_canwrite = '1') then
                        if (lenCmd >= 6) then
                            bo_data(7 downto 4) <= toData(cmdIn(3));
                            bo_data(3 downto 0) <= toData(cmdIn(4));
                            addr(15 downto 12) := toData(cmdIn(3));
                            addr(11 downto 8) := toData(cmdIn(4));
                        else
                            bo_data <= x"80";
                            addr(15 downto 8) := x"80";
                        end if;
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 5 =>           
                    bo_write <= '1';
                when 6 =>           --get length low
                    if (bo_canwrite = '1') then
                        if (lenCmd >= 9) then
                            bo_data(7 downto 4) <= toData(cmdIn(8));
                            bo_data(3 downto 0) <= toData(cmdIn(9));
                            len(7 downto 4) := toData(cmdIn(8));
                            len(3 downto 0) := toData(cmdIn(9));
                        else
                            bo_data <= x"0A";
                            len := x"0A";
                        end if;
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 7 =>           
                    bo_write <= '1';
                when 8 =>           --get length high
                    if (bo_canwrite = '1') then
                        bo_data <= x"00";
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 9 =>           
                    bo_write <= '1';
                when 10 =>          --read low
                    if (bi_canread = '1') then
                        bi_read <= '0';
                        cnt1 := cnt1 + 1;
                    else
                        count <= count;
                    end if;
                when 11 =>
                    dataOut(1) := x"5B";
                    dataOut(2) := toAscii(addr(15 downto 12));
                    dataOut(3) := toAscii(addr(11 downto 8));
                    dataOut(4) := toAscii(addr(7 downto 4));
                    dataOut(5) := toAscii(addr(3 downto 0));
                    dataOut(6) := x"5D";
                    dataOut(7 to 10) := (x"20", x"20", x"20", x"20");
                    dataOut(13) := toAscii(bi_data(7 downto 4));
                    dataOut(14) := toAscii(bi_data(3 downto 0));
                    bi_read <= '1';
                when 12 =>      --read high
                    if (bi_canread = '1') then
                        bi_read <= '0';
                    else
                        count <= count;
                    end if;
                when 13 =>
                    dataOut(11) := toAscii(bi_data(7 downto 4));
                    dataOut(12) := toAscii(bi_data(3 downto 0));
                    dataOut(15) := x"0D";
                    bi_read <= '1';
                when 14 =>
                    if (co_canwrite = '1') then
                        cnt2 := cnt2 + 1;
                        co_data <= dataOut(cnt2);
                        co_write <= '0';
                    else
                        count <= count;
                    end if;
                when 15 =>
                    co_write <= '1';
                    if (dataOut(cnt2) = x"0D") then
                        cnt2 := 0;
                        dataOut := (others => x"20");
                        if (to_unsigned(cnt1, 8) = len) then
                            cnt1 := 0;
                            cmdIn := (others => x"00");
                            lenCmd := 0;
                            len := x"00";
                            status <= ReadShell;
                        else
                            addr := addr + 1;
                            count <= 10;
                        end if;
                    else
                        count <= 14;
                    end if;
                when others => count <= 0;
                end case;
            
            when CmdG =>
                case count is 
                when 0 =>
                    if (bo_canwrite = '1') then
                        bo_data <= x"47";
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 1 =>
                    bo_write <= '1';
                when 2 =>       --addr low
                    if (bo_canwrite = '1') then
                        if (lenCmd >= 6) then
                            bo_data(7 downto 4) <= toData(cmdIn(5));
                            bo_data(3 downto 0) <= toData(cmdIn(6));
                            addr(7 downto 4) := toData(cmdIn(5));
                            addr(3 downto 0) := toData(cmdIn(6));
                        else
                            bo_data <= x"00";
                            addr(7 downto 0) := x"00";
                        end if;
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 3 =>
                    bo_write <= '1';
                when 4 =>       --addr high
                    if (bo_canwrite = '1') then
                        if (lenCmd >= 6) then
                            bo_data(7 downto 4) <= toData(cmdIn(3));
                            bo_data(3 downto 0) <= toData(cmdIn(4));
                            addr(15 downto 12) := toData(cmdIn(3));
                            addr(11 downto 8) := toData(cmdIn(4));
                        else
                            bo_data <= x"40";
                            addr(15 downto 8) := x"40";
                        end if;                        
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 5 =>
                    bo_write <= '1';
                when 6 =>
                    if (bi_canread = '1') then
                        bi_read <= '0';
                    else
                        count <= count;
                    end if;
                when 7 =>
                    if (bi_data = x"07") then
                        count <= 0;
                        bi_read <= '1';
                        lenCmd := 0;
                        cmdIn := (others => x"00");
                        cnt2 := 0;
                        dataOut := (others => x"20");
                        status <= ReadShell;
                    else 
                        null;
                    end if;
                when 8 =>
                    if (co_canwrite = '1') then
                        co_data <= bi_data;
                        co_write <= '0';
                    else
                        count <= count;
                    end if;
                when 9 =>
                    bi_read <= '1';
                    co_write <= '1';
                    count <= 6;
                when others => count <= 0;
                end case;
            
            when CmdR =>
                case count is 
                when 0 =>
                    if (bo_canwrite = '1') then
                        bo_data <= x"52";
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 1 =>
                    bo_write <= '1';
                when 2 =>       --read low
                    if (bi_canread = '1') then
                        bi_read <= '0';
                        cnt1 := cnt1 + 1;
                    else
                        count <= count;
                    end if;
                when 3 =>
                    dataOut(1 to 3) := (x"52", (x"2F" + to_unsigned(cnt1, 8)), x"3D");
                    dataOut(6) := toAscii(bi_data(7 downto 4));
                    dataOut(7) := toAscii(bi_data(3 downto 0));
                    bi_read <= '1';
                when 4 =>       --read high
                    if (bi_canread = '1') then
                        bi_read <= '0';
                    else
                        count <= count;
                    end if;
                when 5 =>
                    dataOut(4) := toAscii(bi_data(7 downto 4));
                    dataOut(5) := toAscii(bi_data(3 downto 0));
                    dataOut(8) := x"0D";
                    bi_read <= '1';
                when 6 =>
                    if (co_canwrite = '1') then                        
                        cnt2 := cnt2 + 1;
                        co_data <= dataOut(cnt2);
                        co_write <= '0';
                    else
                        count <= count;
                    end if;
                when 7 =>
                    co_write <= '1';
                    if (dataOut(cnt2) = x"0D") then
                        cnt2 := 0;
                        dataOut := (others => x"20");
                        if (cnt1 = 6) then
                            cnt1 := 0;
                            cmdIn := (others => x"00");
                            lenCmd := 0;
                            status <= ReadShell;
                        else
                            count <= 2;
                        end if;
                    else
                        count <= 6;
                    end if;
                when others => count <= 0;
                end case;
            
            when CmdU =>
                case count is 
                when 0 =>
                    if (bo_canwrite = '1') then
                        bo_data <= x"55";
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 1 =>
                    bo_write <= '1';
                when 2 =>   --addr low
                    if (bo_canwrite = '1') then
                        bo_write <= '0';
                        if (lenCmd >= 6) then
                            bo_data(7 downto 4) <= toData(cmdIn(5));
                            bo_data(3 downto 0) <= toData(cmdIn(6));
                            addr(7 downto 4) := toData(cmdIn(5));
                            addr(3 downto 0) := toData(cmdIn(6));
                        else
                            bo_data <= x"00";
                            addr(7 downto 0) := x"00";
                        end if;
                    else
                        count <= count;
                    end if;
                when 3 =>
                    bo_write <= '1';
                when 4 =>   --addr high
                    if (bo_canwrite = '1') then
                        bo_write <= '0';
                        if (lenCmd >= 6) then
                            bo_data(7 downto 4) <= toData(cmdIn(3));
                            bo_data(3 downto 0) <= toData(cmdIn(4));
                            addr(15 downto 12) := toData(cmdIn(3));
                            addr(11 downto 8) := toData(cmdIn(4));
                        else
                            bo_data <= x"40";
                            addr(15 downto 8) := x"40";
                        end if;                        
                    else
                        count <= count;
                    end if;
                when 5 =>
                    bo_write <= '1';
                when 6 =>       --get length low
                    if (bo_canwrite = '1') then
                        if (lenCmd >= 9) then
                            bo_data(7 downto 4) <= toData(cmdIn(8));
                            bo_data(3 downto 0) <= toData(cmdIn(9));
                            len(7 downto 4) := toData(cmdIn(8));
                            len(3 downto 0) := toData(cmdIn(9));
                        else
                            bo_data <= x"0A";
                            len := x"0A";
                        end if;
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 7 =>
                    bo_write <= '1';
                when 8 =>       --get length high
                    if (bo_canwrite = '1') then
                        bo_data <= x"00";
                        bo_write <= '0';
                    else
                        count <= count;
                    end if;
                when 9 =>
                    bo_write <= '1';
                when 10 =>       --read low
                    if (bi_canread = '1') then
                        bi_read <= '0';
                        cnt1 := cnt1 + 1;
                    else
                        count <= count;
                    end if;
                when 11 =>
                    dataOut(1) := x"5B";
                    dataOut(2) := toAscii(addr(15 downto 12));
                    dataOut(3) := toAscii(addr(11 downto 8));
                    dataOut(4) := toAscii(addr(7 downto 4));
                    dataOut(5) := toAscii(addr(3 downto 0));
                    dataOut(6) := x"5D";
                    dataOut(7) := x"20";
                    dataOut(8) := x"28";
                    dataOut(11) := toAscii(bi_data(7 downto 4));
                    dataOut(12) := toAscii(bi_data(3 downto 0));
                    dataOut(13) := x"29";
                    inst(7 downto 0) <= bi_data;
                    bi_read <= '1';
                when 12 =>      --read high
                    if (bi_canread = '1') then
                        bi_read <= '0';
                    else
                        count <= count;
                    end if;
                when 13 =>
                    dataOut(9) := toAscii(bi_data(7 downto 4));
                    dataOut(10) := toAscii(bi_data(3 downto 0));
                    inst(15 downto 8) <= bi_data;
                    dataOut(32) := x"0D";
                    bi_read <= '1';
                    
                    --UASM
                    opcode := inst(15 downto 11);
                    case(opcode) is
                        when INST_ADDIU =>
                            dataOut(15 to 21) := (x"41", x"44", x"44", x"49", x"55", x"20", x"20");
                            dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                            im := signExtend(getIm8(inst));
                            dataOut(25) := toAscii(im(15 downto 12));
                            dataOut(26) := toAscii(im(11 downto 8));
                            dataOut(27) := toAscii(im(7 downto 4));
                            dataOut(28) := toAscii(im(3 downto 0));
                        when INST_ADDIU3 =>
                            dataOut(15 to 21) := (x"41", x"44", x"44", x"49", x"55", x"33" ,x"20");
                            dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                            dataOut(25 to 27) := (x"52", (x"30" + getRy(inst)), x"20");
                            im := signExtend4(inst(3 downto 0));
                            dataOut(28) := toAscii(im(15 downto 12));
                            dataOut(29) := toAscii(im(11 downto 8));
                            dataOut(30) := toAscii(im(7 downto 4));
                            dataOut(31) := toAscii(im(3 downto 0));
                        when INST_ADDSP3 =>
                            dataOut(15 to 21) := (x"41", x"44", x"44", x"53", x"50", x"33", x"20");
                            dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                            im := signExtend(getIm8(inst));
                            dataOut(25) := toAscii(im(15 downto 12));
                            dataOut(26) := toAscii(im(11 downto 8));
                            dataOut(27) := toAscii(im(7 downto 4));
                            dataOut(28) := toAscii(im(3 downto 0));
                        when INST_B =>
                            dataOut(15 to 21) := (x"42", x"20", x"20", x"20", x"20" ,x"20", x"20");
                            im := signExtend11(inst(10 downto 0));
                            dataOut(22) := toAscii(im(15 downto 12));
                            dataOut(23) := toAscii(im(11 downto 8));
                            dataOut(24) := toAscii(im(7 downto 4));
                            dataOut(25) := toAscii(im(3 downto 0));
                        when INST_BEQZ =>
                            dataOut(15 to 21) := (x"42", x"45", x"51", x"5A", x"20", x"20", x"20");
                            dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                            im := signExtend(getIm8(inst));
                            dataOut(25) := toAscii(im(15 downto 12));
                            dataOut(26) := toAscii(im(11 downto 8));
                            dataOut(27) := toAscii(im(7 downto 4));
                            dataOut(28) := toAscii(im(3 downto 0));
                        when INST_BNEZ =>
                            dataOut(15 to 21) := (x"42", x"4E", x"45", x"5A", x"20", x"20", x"20");
                            dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                            im := signExtend(getIm8(inst));
                            dataOut(25) := toAscii(im(15 downto 12));
                            dataOut(26) := toAscii(im(11 downto 8));
                            dataOut(27) := toAscii(im(7 downto 4));
                            dataOut(28) := toAscii(im(3 downto 0));
                        when INST_LI =>
                            dataOut(15 to 21) := (x"4C", x"49", x"20", x"20", x"20", x"20", x"20");
                            dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                            im := signExtend(getIm8(inst));
                            dataOut(25) := toAscii(im(15 downto 12));
                            dataOut(26) := toAscii(im(11 downto 8));
                            dataOut(27) := toAscii(im(7 downto 4));
                            dataOut(28) := toAscii(im(3 downto 0));
                        when INST_LW =>
                            dataOut(15 to 21) := (x"4C", x"57", x"20", x"20" ,x"20", x"20", x"20");
                            dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                            dataOut(25 to 27) := (x"52", (x"30" + getRy(inst)), x"20");
                            im := signExtend5(inst(4 downto 0));
                            dataOut(28) := toAscii(im(15 downto 12));
                            dataOut(29) := toAscii(im(11 downto 8));
                            dataOut(30) := toAscii(im(7 downto 4));
                            dataOut(31) := toAscii(im(3 downto 0));
                        when INST_LW_SP =>
                            dataOut(15 to 21) := (x"4C", x"57", x"5F", x"53", x"50", x"20", x"20");
                            dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                            im := signExtend(getIm8(inst));
                            dataOut(25) := toAscii(im(15 downto 12));
                            dataOut(26) := toAscii(im(11 downto 8));
                            dataOut(27) := toAscii(im(7 downto 4));
                            dataOut(28) := toAscii(im(3 downto 0));
                        when INST_NOP =>
                            dataOut(15 to 21) := (x"4E", x"4F", x"50", x"20", x"20", x"20", x"20");
                        when INST_SW =>
                            dataOut(15 to 21) := (x"53", x"57", x"20", x"20", x"20", x"20", x"20");
                            dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                            dataOut(25 to 27) := (x"52", (x"30" + getRy(inst)), x"20");
                            im := signExtend5(inst(4 downto 0));
                            dataOut(28) := toAscii(im(15 downto 12));
                            dataOut(29) := toAscii(im(11 downto 8));
                            dataOut(30) := toAscii(im(7 downto 4));
                            dataOut(31) := toAscii(im(3 downto 0));
                        when INST_SW_SP =>
                            dataOut(15 to 21) := (x"53", x"57", x"5F", x"53", x"50", x"20", x"20");
                            dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                            im := signExtend(getIm8(inst));
                            dataOut(25) := toAscii(im(15 downto 12));
                            dataOut(26) := toAscii(im(11 downto 8));
                            dataOut(27) := toAscii(im(7 downto 4));
                            dataOut(28) := toAscii(im(3 downto 0));
                        when INST_SET0 =>
                            oprx := getRx(inst);
                            case oprx is
                                when x"3" =>  -- ADDSP
                                    dataOut(15 to 21) := (x"41", x"44", x"44", x"53", x"50", x"20", x"20");
                                    im := signExtend11(inst(10 downto 0));
                                    dataOut(22) := toAscii(im(15 downto 12));
                                    dataOut(23) := toAscii(im(11 downto 8));
                                    dataOut(24) := toAscii(im(7 downto 4));
                                    dataOut(25) := toAscii(im(3 downto 0));
                                when x"2" =>  -- SW_RS
                                    dataOut(15 to 21) := (x"53", x"57", x"5F", x"52", x"53", x"20", x"20");
                                    im := signExtend11(inst(10 downto 0));
                                    dataOut(22) := toAscii(im(15 downto 12));
                                    dataOut(23) := toAscii(im(11 downto 8));
                                    dataOut(24) := toAscii(im(7 downto 4));
                                    dataOut(25) := toAscii(im(3 downto 0));
                                when x"0" =>  -- BTEQZ
                                    dataOut(15 to 21) := (x"42", x"54", x"45", x"51", x"5A", x"20", x"20");
                                    im := signExtend11(inst(10 downto 0));
                                    dataOut(22) := toAscii(im(15 downto 12));
                                    dataOut(23) := toAscii(im(11 downto 8));
                                    dataOut(24) := toAscii(im(7 downto 4));
                                    dataOut(25) := toAscii(im(3 downto 0));
                                when x"4" =>  -- MTSP
                                    dataOut(15 to 21) := (x"4D", x"54", x"53", x"50", x"20", x"20", x"20");
                                    dataOut(22 to 23) := (x"52", (x"30" + getRx(inst)));
                                when others => null;
                            end case;
                        when INST_SET1 =>
                            subopcode := getSubOp(inst);
                            if subopcode = "00000" then 
                                oprx := getRy(inst);
                                if (oprx = x"0") then  -- JR
                                    dataOut(15 to 21) := (x"4A", x"52", x"20", x"20", x"20", x"20", x"20");
                                    dataOut(22 to 23) := (x"52", (x"30" + getRx(inst)));
                                elsif (oprx = x"2") then  -- MFPC
                                    dataOut(15 to 21) := (x"4D", x"46", x"50", x"43", x"20", x"20", x"20");
                                    dataOut(22 to 23) := (x"52", (x"30" + getRx(inst)));
                                else
                                    null;
                                end if;
                            else
                                case subopcode is
                                    when "01100" =>  -- AND
                                        dataOut(15 to 21) := (x"41", x"4E", x"44", x"20", x"20", x"20", x"20");
                                        dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                                        dataOut(25 to 27) := (x"52", (x"30" + getRy(inst)), x"20");
                                    when "01010" =>  -- CMP
                                        dataOut(15 to 21) := (x"43", x"4D", x"50", x"20", x"20", x"20", x"20");
                                        dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                                        dataOut(25 to 27) := (x"52", (x"30" + getRy(inst)), x"20");
                                    when "01111" =>  -- NOT
                                        dataOut(15 to 21) := (x"4E", x"4F", x"54", x"20", x"20", x"20", x"20");
                                        dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                                        dataOut(25 to 27) := (x"52", (x"30" + getRy(inst)), x"20");
                                    when "01101" =>  -- OR
                                        dataOut(15 to 21) := (x"4F", x"52", x"20", x"20", x"20", x"20", x"20");
                                        dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                                        dataOut(25 to 27) := (x"52", (x"30" + getRy(inst)), x"20");
                                    when "00010" =>  -- SLT
                                        dataOut(15 to 21) := (x"53", x"4C", x"54", x"20", x"20", x"20", x"20");
                                        dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                                        dataOut(25 to 27) := (x"52", (x"30" + getRy(inst)), x"20");
                                    when others => null;
                                end case;
                            end if;
                        when INST_SET2 =>
                            opu := inst(1 downto 0);
                            if (opu = "01") then  -- ADDU
                                dataOut(15 to 21) := (x"41", x"44", x"44", x"55", x"20", x"20", x"20");
                                dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                                dataOut(25 to 27) := (x"52", (x"30" + getRy(inst)), x"20");
                                dataOut(28 to 30) := (x"52", (x"30" + getRz(inst)), x"20");
                            elsif (opu = "11") then  -- SUBU
                                dataOut(15 to 21) := (x"53", x"55", x"42", x"55", x"20", x"20", x"20");
                                dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                                dataOut(25 to 27) := (x"52", (x"30" + getRy(inst)), x"20");
                                dataOut(28 to 30) := (x"52", (x"30" + getRz(inst)), x"20");
                            else
                                null;
                            end if;  
                        when INST_SET3 =>
                            subopcode := getSubOp(inst);    
                            if (subopcode = "00000") then  -- MFIH
                                dataOut(15 to 21) := (x"4D", x"46", x"49", x"48", x"20", x"20", x"20");
                                dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                            elsif (subopcode = "00001") then  -- MTIH
                                dataOut(15 to 21) := (x"4D", x"54", x"49", x"48", x"20", x"20", x"20");
                                dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                            else
                                null;
                            end if;
                            
                        when INST_SET4 =>
                            opu := inst(1 downto 0);
                            if (opu = "00") then  -- SLL
                                dataOut(15 to 21) := (x"53", x"4C", x"4C", x"20", x"20", x"20", x"20");
                                dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                                dataOut(25 to 27) := (x"52", (x"30" + getRy(inst)), x"20");
                                dataOut(28 to 29) := ((x"30" + getRz(inst)), x"20");
                            elsif (opu = "11") then  -- SRA
                                dataOut(15 to 21) := (x"53", x"52", x"41", x"20", x"20", x"20", x"20");
                                dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                                dataOut(25 to 27) := (x"52", (x"30" + getRy(inst)), x"20");
                                dataOut(28 to 29) := ((x"30" + getRz(inst)), x"20");
                            elsif (opu = "10") then  -- SRL
                                dataOut(15 to 21) := (x"53", x"52", x"4C", x"20", x"20", x"20", x"20");
                                dataOut(22 to 24) := (x"52", (x"30" + getRx(inst)), x"20");
                                dataOut(25 to 27) := (x"52", (x"30" + getRy(inst)), x"20");
                                dataOut(28 to 29) := ((x"30" + getRz(inst)), x"20");
                            else
                                null;
                            end if;
                        when others => null;
                    end case;
                    
                    
                when 14 =>
                    if (co_canwrite = '1') then                            
                        cnt2 := cnt2 + 1;
                        co_data <= dataOut(cnt2);
                        co_write <= '0';
                    else
                        count <= count;
                    end if;
                when 15 =>
                    co_write <= '1';
                    if (dataOut(cnt2) = x"0D") then
                        cnt2 := 0;
                        dataOut := (others => x"00");
                        if (to_unsigned(cnt1, 8) = len) then
                            cnt1 := 0;
                            cmdIn := (others => x"00");
                            lenCmd := 0;
                            status <= ReadShell;
                        else
                            addr := addr + 1;
                            count <= 10;
                        end if;
                    else
                        count <= 14;
                    end if;
                when others => count <= 0;
                end case;
            when others => null;
            end case;
        end if;
    end process;
    
end arch;
