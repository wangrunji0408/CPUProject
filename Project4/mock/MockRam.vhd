library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;
use work.Data.all;
use std.textio.all;

entity MockRam is
	generic (
		ID: natural := 0;
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

	process( rst, enable, read, write, addr )
		variable inner_addr: integer;

		type binfile is file of character;
		file filein: binfile;
		variable fstatus: FILE_OPEN_STATUS; 
		variable char: character;
	begin
		if rst = '0' then
			if KERNEL then
				copy_to_ram : for i in 0 to 536-1 loop
					ram(i)(7 downto 0) <= kernelData(i*2);
					ram(i)(15 downto 8) <= kernelData(i*2+1);
				end loop ; -- copy_to_ram
			elsif FILE_PATH'length > 0 then
				report "Ready to open file: " & FILE_PATH;			
				file_open(fstatus, filein, FILE_PATH, READ_MODE);			
				if fstatus /= open_ok then
					report "Failed to open file: " & FILE_PATH severity error;
				end if;
				for i in 0 to SIZE-1 loop
					exit when endfile(filein);
					read(filein, char); -- nvc fatal: unimplemented
					ram(i)(7 downto 0) <= to_unsigned(character'pos(char), 8);
					read(filein, char);
					ram(i)(15 downto 8) <= to_unsigned(character'pos(char), 8);
				end loop ;
				file_close(filein);
				report "Load to RAM from " & FILE_PATH;
			else
				ram <= (others => x"0000");
			end if;
		else
			inner_addr := to_integer(addr) - OFFSET;
			assert not(enable = '0' and inner_addr < 0)
				report "Address out of range: " & toStr16(addr(15 downto 0)) severity error;
			data <= (others => 'Z');
			if enable = '0' and falling_edge(write) then
				report "WriteRAM" & natural'image(ID) & "[" & toStr16(addr(15 downto 0)) & "]=" & toStr16(data);
				ram(inner_addr) <= data after 8 ns;
			end if;
			if enable = '0' and falling_edge(read) then
				data <= (others => 'X');
			end if;
			if enable = '0' and read = '0' then
				if not (ID = 2 and addr(15 downto 14) = "00") then -- not report fetch inst
				report "Read RAM" & natural'image(ID) & "[" & toStr16(addr(15 downto 0)) & "]=" & toStr16(ram(inner_addr));
				end if;
				data <= data, 
						ram(inner_addr) after 10 ns;
			end if;
		end if;
	end process ;
end arch ; -- arch
