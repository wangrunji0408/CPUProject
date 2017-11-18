library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 点阵字体读取接口
-- 字符编码：ASCII
entity FontReader is
	port (
		clk: in std_logic;
		id: in natural range 0 to 127;	-- 字符编码
		x, y: in natural range 0 to 15;	-- 坐标
		b: out std_logic				-- 输出字符在坐标下的bit
	);
end entity;

architecture arch of FontReader is
	COMPONENT FontROM
		PORT (
		clka : IN STD_LOGIC;
		addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
		douta : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
		);
	END COMPONENT;
	signal addr: std_logic_vector(14 downto 0);
	signal data: std_logic_vector(0 downto 0);
begin
	rom: FontROM port map (clk, addr, data);
	addr <= std_logic_vector(to_unsigned(id, 7)) 
				& std_logic_vector(to_unsigned(x, 4))
				& std_logic_vector(to_unsigned(y, 4));
	b <= data(0);
end arch ; -- arch