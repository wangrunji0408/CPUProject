library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 寄存器堆
entity Reg is
	port (
		rst, clk: in std_logic;
		ctrl: in MidCtrl;
		write: in RegPort;
		read1, read2: in RegPort;	-- read.data is null, unable to read.
		read1_dataout, read2_dataout: out u16;
		d_regs: out RegData;		-- for debug

		sir6: in SaveInR6:= ('0', x"0000")
	) ;
end Reg;

architecture arch of Reg is	

	signal Regs: RegData;

begin
	d_regs <= Regs;

	read1_dataout <= Regs(to_integer(read1.addr)) when read1.enable = '1' 
					 else x"0000";
	read2_dataout <= Regs(to_integer(read2.addr)) when read2.enable = '1' 
					else x"0000";

	process(rst, clk)
	begin
		if rst = '0' then
			Regs <= (others => x"0000");
		elsif rising_edge(clk) then
			if write.enable = '1' then
				Regs(to_integer(write.addr)) <= write.data;
			end if;
			if sir6.enable = '1' then
				Regs(6) <= sir6.pc;
			end if;
		end if;
	end process;

end arch ; -- arch
