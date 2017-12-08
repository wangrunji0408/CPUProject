library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity Hard_term is
	port(
		rst, clk : in std_logic;
		
		-- 从shell到hard_term
		ci_read: out std_logic;
		ci_canread: in std_logic;
		ci_data: in u8; -- ISE 无法转换 integer/unsigned => character ...
		
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
		bo_data: out u8
	);
end Hard_term;

architecture arch of Hard_term is
begin

end arch ; -- arch