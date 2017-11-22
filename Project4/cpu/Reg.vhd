library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 寄存器堆
entity Reg is
	port (
		rst, clk: in std_logic;
		write: in RegPort;
		read1, read2: in RegPort;	-- read.data is null, unable to read.
		read1_dataout, read2_dataout: out u16;
		d_regs: out RegData		-- for debug
	) ;
end Reg;

architecture arch of Reg is	

	-- for debug show wave
	signal d_write_enable, d_read1_enable, d_read2_enable: std_logic;
	signal d_write_addr, d_read1_addr, d_read2_addr: RegAddr;
	signal d_write_data: u16;

	--inner data
	signal Regs:RegData;

begin
	-- 1. $0=0
	-- 2. 读使能无效时，输出0
	-- 3. 时钟上升沿时，若写使能生效，将数据写入 

	d_regs <= Regs;

	read1_dataout <= Regs(to_integer(read1.addr)) when read1.enable = '1' 
					 else x"0000";
	read2_dataout <= Regs(to_integer(read2.addr)) when read2.enable = '1' 
					else x"0000";

	process(rst, clk)
	begin
		if rst = '0'
		then
			Regs <= (others => x"0000");
		elsif rising_edge(clk)
		then
			if write.enable = '1' and write.addr /= x"0"
			then
				Regs(to_integer(write.addr)) <= write.data;
			end if;
		end if;
	end process;
	-- for debug show wave
	d_write_enable <= write.enable;
	d_read1_enable <= read1.enable;
	d_read2_enable <= read2.enable;
	d_write_addr <= write.addr;
	d_read1_addr <= read1.addr;
	d_read2_addr <= read2.addr;
	d_write_data <= write.data;

end arch ; -- arch
