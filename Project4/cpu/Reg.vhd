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
		read1_dataout, read2_dataout: out u16
	) ;
end Reg;

architecture arch of Reg is	

	-- for debug show wave
	signal d_write_enable, d_read1_enable, d_read2_enable: std_logic;
	signal d_write_addr, d_read1_addr, d_read2_addr: RegAddr;
	signal d_write_data: u16;

begin
	-- 1. $0=0
	-- 2. 读使能无效时，输出0
	-- 3. 时钟上升沿时，若写使能生效，将数据写入 

	read1_dataout <= x"0000";
	read2_dataout <= x"0000";

	-- for debug show wave
	d_write_enable <= write.enable;
	d_read1_enable <= read1.enable;
	d_read2_enable <= read2.enable;
	d_write_addr <= write.addr;
	d_read1_addr <= read1.addr;
	d_read2_addr <= read2.addr;
	d_write_data <= write.data;

end arch ; -- arch
