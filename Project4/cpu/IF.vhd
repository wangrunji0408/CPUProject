library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 取指模块
entity InstFetch is
	port (
		rst, clk: in std_logic;
		pc: in u16;
		inst: out Inst;
		
		------ RAM2接口 ------
		ram2: out RamPort;
		ram2_datain: in u16
	) ;
end InstFetch;

architecture arch of InstFetch is	
begin

	ram2.addr <= "00" & pc;
	inst <= ram2_datain;

	process( rst, clk )
	begin
		if rst = '0' then
			ram2.read <= '1'; ram2.write <= '1'; ram2.enable <= '1';
			ram2.data <= (others => 'Z');
		elsif rising_edge(clk) then
			ram2.read <= '0'; ram2.enable <= '0'; -- enable RAM2 read
		end if;
	end process ;

end arch ; -- arch
