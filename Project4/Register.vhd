library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 寄存器堆
entity Register is
	port (
		clk, rst: in std_logic;
		write_enable: in std_logic;
		write_addr: in RegAddr;
		write_data: in u16;
		read1_enable, read2_enable: in std_logic;
		read1_addr, read2_addr: in RegAddr;
		read1_data, read2_data: out u16
	) ;
end Register;

architecture arch of Register is	
begin
	-- 1. $0=0
	-- 2. 读使能无效时，输出0
	-- 3. 时钟上升沿时，若写使能生效，将数据写入
end arch ; -- arch
