library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestFakeRam is
end TestFakeRam;

architecture arch of TestFakeRam is	
	component FakeRam is
		port (
			addr: in u18;
			data: inout u16;
			read, write, enable: in std_logic
		) ;
	end component;

	signal addr: u18;
	signal data: u16;
	signal read, write, enable: std_logic;

	procedure writeData (
		signal addr: out u18; 
		signal data: out u16; 
		signal write: out std_logic;
		addr0: integer;
		data0: u16) is
	begin
		addr <= to_unsigned(addr0, 18);
		data <= data0;
		wait for 2 ns;
		write <= '0'; wait for 2 ns; 
		write <= '1'; wait for 2 ns; 
	end procedure;

	procedure readData (			-- will not set read back to 1
		signal addr: out u18; 
		signal data: out u16; 
		signal read: out std_logic;
		addr0: integer) is
	begin
		data <= (others => 'Z');
		read <= '0'; wait for 2 ns;
		addr <= to_unsigned(addr0, 18);
		wait for 2 ns;		
	end procedure;

begin
	fakeram0: FakeRam port map (addr, data, read, write, enable);
	process
	begin
		-- init
		addr <= to_unsigned(0, 18);
		data <= to_u16(0);
		read <= '1';
		write <= '1';
		enable <= '1';
		wait for 10 ns;

		writeData(addr, data, write, 2, x"ABCD");
		writeData(addr, data, write, 0, x"1111");
		readData(addr, data, read, 2);
		assert(data = x"ABCD") 
			report "Failed to read. data = " & toString(data) severity error;
		readData(addr, data, read, 0);
		assert(data = x"1111") 
			report "Failed to read. data = " & toString(data) severity error;
		read <= '1'; wait for 10 ns;
		writeData(addr, data, write, 2, x"2222");
		readData(addr, data, read, 2);
		assert(data = x"2222") 
			report "Failed to read. data = " & toString(data) severity error;

		enable <= '0'; wait for 10 ns;
		data <= x"1234"; wait for 10 ns;
		assert(data = x"1234") 
		report "Disable but still work" severity error;

		

		assert(false) report "FakeRam: Test Success." severity note;
		wait;
	end process ;
end arch ; -- arch
