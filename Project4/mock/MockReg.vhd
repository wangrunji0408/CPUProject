library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity MockReg is
	port (
		read1, read2: in RegPort;	-- read.data is null, unable to read.
		read1_dataout, read2_dataout: out u16;
		reg: in RegData
	) ;
end MockReg;

architecture arch of MockReg is	
begin

	read1_dataout <= reg(to_integer(read1.addr)) when read1.enable = '1' else x"0000";
	read2_dataout <= reg(to_integer(read2.addr)) when read2.enable = '1' else x"0000";

end arch ; -- arch
