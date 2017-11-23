library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;
use work.Data.all;
use std.textio.all;

entity MockRam is
	generic (
		SIZE: natural := 1024;
		OFFSET: natural := 0;
		FILE_PATH: string := "";
		KERNEL: boolean := false
	);
	port (
		rst: in std_logic;
		addr: in u18;
		data: inout u16;
		read, write, enable: in std_logic
	) ;
end MockRam;

architecture arch of MockRam is	
	type TRam is array (0 to SIZE-1) of u16;
	signal ram: TRam;
begin
	-- readfile : process
	-- 	file filein: text;
	-- 	variable fstatus: FILE_OPEN_STATUS; 
	-- 	variable buf: line; 
	-- 	variable byte: bit_vector(7 downto 0);
	-- begin
	-- 	if FILE_PATH'length > 0 then
	-- 		report "Ready to open file: " & FILE_PATH;			
	-- 		file_open(fstatus, filein, FILE_PATH, READ_MODE);			
	-- 		if fstatus /= open_ok then
	-- 			report "Failed to open file: " & FILE_PATH severity error;
	-- 		end if;
	-- 		readline(filein, buf);
	-- 		for i in 0 to SIZE-1 loop
	-- 			exit when endfile(filein);
	-- 			read(buf, byte); -- nvc fatal: unimplemented
	-- 			ram(i)(7 downto 0) <= unsigned(to_stdlogicvector(byte));
	-- 			read(buf, byte);
	-- 			ram(i)(15 downto 8) <= unsigned(to_stdlogicvector(byte));
	-- 			report integer'image(i) & ": " & toStr16(ram(i));
	-- 		end loop ;
	-- 		file_close(filein);
	-- 		report "Load to RAM from " & FILE_PATH;
	-- 	end if;
	-- 	wait;
	-- end process ; -- readfile

	process( rst, enable, read, write, addr )
		variable inner_addr: integer;
	begin
		if rst = '0' then
			if KERNEL then
				copy_to_ram : for i in 0 to 536-1 loop
					ram(i)(7 downto 0) <= kernelData(i*2);
					ram(i)(15 downto 8) <= kernelData(i*2+1);
				end loop ; -- copy_to_ram
			else
				ram <= (others => x"0000");
			end if;
		else
			inner_addr := to_integer(addr) - OFFSET;
			assert inner_addr >= 0 report "Address out of range: " & toStr16(addr(15 downto 0)) severity error;
			data <= (others => 'Z');
			if enable = '0' and falling_edge(write) then
				ram(inner_addr) <= data after 8 ns;
			end if;
			if enable = '0' and falling_edge(read) then
				data <= (others => 'X');
			end if;
			if enable = '0' and read = '0' then
				data <= data, 
						ram(inner_addr) after 10 ns;
			end if;
		end if;
	end process ;
end arch ; -- arch
