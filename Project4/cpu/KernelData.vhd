library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

package Data is 
	type TKernelData is array (0 to 1072-1) of u8; -- 1072 Byte = 536 Word
	constant kernelData: TKernelData :=
(
	x"00",x"00",x"00",x"00",x"00",x"08",x"61",x"10",x"00",x"08",x"00",x"08",x"00",x"08",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"10",x"4E",x"00",x"DE",x"21",x"DE",x"42",x"DE",x"84",x"DE",x"A5",x"DE",
	x"00",x"91",x"01",x"63",x"FF",x"68",x"0C",x"E9",x"00",x"92",x"01",x"63",x"FF",x"63",x"00",x"D3",x"FF",x"63",x"00",x"D7",x"0F",x"6B",x"40",x"EF",x"03",x"4F",x"00",x"08",x"AC",x"10",x"00",x"08",
	x"BF",x"6E",x"C0",x"36",x"60",x"DE",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"10",x"4E",x"00",x"68",x"2A",x"E8",x"02",x"61",x"00",x"08",x"87",x"9E",x"20",x"68",x"2A",x"E8",x"02",x"61",x"00",x"08",
	x"88",x"9E",x"10",x"68",x"2A",x"E8",x"02",x"61",x"00",x"08",x"89",x"9E",x"00",x"08",x"A6",x"9E",x"A2",x"EC",x"0B",x"61",x"00",x"08",x"86",x"DE",x"40",x"EF",x"03",x"4F",x"00",x"08",x"8B",x"10",
	x"00",x"08",x"BF",x"6E",x"C0",x"36",x"20",x"DE",x"00",x"08",x"00",x"08",x"0F",x"6B",x"40",x"EF",x"03",x"4F",x"00",x"08",x"80",x"10",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"60",x"DE",x"00",x"08",
	x"C0",x"42",x"00",x"F3",x"80",x"68",x"00",x"30",x"0D",x"EB",x"BF",x"6F",x"E0",x"37",x"10",x"4F",x"00",x"9F",x"21",x"9F",x"42",x"9F",x"84",x"9F",x"A5",x"9F",x"00",x"97",x"01",x"63",x"01",x"63",
	x"00",x"08",x"01",x"F3",x"00",x"EE",x"FF",x"93",x"00",x"08",x"07",x"68",x"01",x"F0",x"BF",x"68",x"00",x"30",x"10",x"48",x"00",x"64",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"10",x"4E",x"00",x"68",
	x"00",x"DE",x"01",x"DE",x"02",x"DE",x"03",x"DE",x"04",x"DE",x"05",x"DE",x"06",x"DE",x"01",x"48",x"07",x"DE",x"01",x"48",x"08",x"DE",x"01",x"48",x"09",x"DE",x"40",x"EF",x"03",x"4F",x"00",x"08",
	x"4A",x"10",x"BF",x"6E",x"C0",x"36",x"4F",x"68",x"00",x"DE",x"00",x"08",x"40",x"EF",x"03",x"4F",x"00",x"08",x"41",x"10",x"BF",x"6E",x"C0",x"36",x"4B",x"68",x"00",x"DE",x"00",x"08",x"40",x"EF",
	x"03",x"4F",x"00",x"08",x"38",x"10",x"BF",x"6E",x"C0",x"36",x"0A",x"68",x"00",x"DE",x"00",x"08",x"40",x"EF",x"03",x"4F",x"00",x"08",x"2F",x"10",x"BF",x"6E",x"C0",x"36",x"0D",x"68",x"00",x"DE",
	x"00",x"08",x"40",x"EF",x"03",x"4F",x"00",x"08",x"31",x"10",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"20",x"9E",x"FF",x"6E",x"CC",x"E9",x"00",x"08",x"52",x"68",x"2A",x"E8",x"32",x"60",x"00",x"08",
	x"44",x"68",x"2A",x"E8",x"4D",x"60",x"00",x"08",x"41",x"68",x"2A",x"E8",x"0E",x"60",x"00",x"08",x"55",x"68",x"2A",x"E8",x"07",x"60",x"00",x"08",x"47",x"68",x"2A",x"E8",x"09",x"60",x"00",x"08",
	x"E0",x"17",x"00",x"08",x"00",x"08",x"C0",x"10",x"00",x"08",x"00",x"08",x"82",x"10",x"00",x"08",x"00",x"08",x"03",x"11",x"00",x"08",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"01",x"4E",x"00",x"9E",
	x"01",x"6E",x"CC",x"E8",x"F8",x"20",x"00",x"08",x"00",x"EF",x"00",x"08",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"01",x"4E",x"00",x"9E",x"02",x"6E",x"CC",x"E8",x"F8",x"20",x"00",x"08",x"00",x"EF",
	x"00",x"08",x"06",x"69",x"06",x"6A",x"BF",x"68",x"00",x"30",x"10",x"48",x"2F",x"E2",x"61",x"E0",x"60",x"98",x"40",x"EF",x"03",x"4F",x"00",x"08",x"DE",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",
	x"60",x"DE",x"63",x"33",x"40",x"EF",x"03",x"4F",x"00",x"08",x"D5",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"60",x"DE",x"FF",x"49",x"00",x"08",x"E6",x"29",x"00",x"08",x"A2",x"17",x"00",x"08",
	x"40",x"EF",x"03",x"4F",x"00",x"08",x"D2",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"A0",x"9E",x"FF",x"6E",x"CC",x"ED",x"00",x"08",x"40",x"EF",x"03",x"4F",x"00",x"08",x"C7",x"17",x"00",x"08",
	x"BF",x"6E",x"C0",x"36",x"20",x"9E",x"FF",x"6E",x"CC",x"E9",x"00",x"08",x"20",x"31",x"AD",x"E9",x"40",x"EF",x"03",x"4F",x"00",x"08",x"BA",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"A0",x"9E",
	x"FF",x"6E",x"CC",x"ED",x"00",x"08",x"40",x"EF",x"03",x"4F",x"00",x"08",x"AF",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"40",x"9E",x"FF",x"6E",x"CC",x"EA",x"00",x"08",x"40",x"32",x"AD",x"EA",
	x"60",x"99",x"40",x"EF",x"03",x"4F",x"00",x"08",x"96",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"60",x"DE",x"63",x"33",x"40",x"EF",x"03",x"4F",x"00",x"08",x"8D",x"17",x"00",x"08",x"BF",x"6E",
	x"C0",x"36",x"60",x"DE",x"01",x"49",x"FF",x"4A",x"00",x"08",x"EA",x"2A",x"00",x"08",x"59",x"17",x"00",x"08",x"40",x"EF",x"03",x"4F",x"00",x"08",x"89",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",
	x"A0",x"9E",x"FF",x"6E",x"CC",x"ED",x"00",x"08",x"40",x"EF",x"03",x"4F",x"00",x"08",x"7E",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"20",x"9E",x"FF",x"6E",x"CC",x"E9",x"00",x"08",x"20",x"31",
	x"AD",x"E9",x"00",x"68",x"2A",x"E8",x"1D",x"60",x"00",x"08",x"40",x"EF",x"03",x"4F",x"00",x"08",x"6D",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"A0",x"9E",x"FF",x"6E",x"CC",x"ED",x"00",x"08",
	x"40",x"EF",x"03",x"4F",x"00",x"08",x"62",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"40",x"9E",x"FF",x"6E",x"CC",x"EA",x"00",x"08",x"40",x"32",x"AD",x"EA",x"40",x"D9",x"00",x"08",x"C9",x"17",
	x"00",x"08",x"00",x"08",x"1E",x"17",x"00",x"08",x"40",x"EF",x"03",x"4F",x"00",x"08",x"4E",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"A0",x"9E",x"FF",x"6E",x"CC",x"ED",x"00",x"08",x"40",x"EF",
	x"03",x"4F",x"00",x"08",x"43",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"20",x"9E",x"FF",x"6E",x"CC",x"E9",x"00",x"08",x"20",x"31",x"AD",x"E9",x"40",x"EF",x"03",x"4F",x"00",x"08",x"36",x"17",
	x"00",x"08",x"BF",x"6E",x"C0",x"36",x"A0",x"9E",x"FF",x"6E",x"CC",x"ED",x"00",x"08",x"40",x"EF",x"03",x"4F",x"00",x"08",x"2B",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"40",x"9E",x"FF",x"6E",
	x"CC",x"EA",x"00",x"08",x"40",x"32",x"AD",x"EA",x"60",x"99",x"40",x"EF",x"03",x"4F",x"00",x"08",x"12",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"60",x"DE",x"63",x"33",x"40",x"EF",x"03",x"4F",
	x"00",x"08",x"09",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"60",x"DE",x"01",x"49",x"FF",x"4A",x"00",x"08",x"EA",x"2A",x"00",x"08",x"D5",x"16",x"00",x"08",x"40",x"EF",x"03",x"4F",x"00",x"08",
	x"05",x"17",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"A0",x"9E",x"FF",x"6E",x"CC",x"ED",x"00",x"08",x"40",x"EF",x"03",x"4F",x"00",x"08",x"FA",x"16",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"40",x"9E",
	x"FF",x"6E",x"CC",x"EA",x"00",x"08",x"40",x"32",x"AD",x"EA",x"C0",x"42",x"BF",x"6F",x"E0",x"37",x"10",x"4F",x"A5",x"9F",x"FF",x"63",x"00",x"D5",x"00",x"F5",x"80",x"69",x"20",x"31",x"2D",x"ED",
	x"00",x"9F",x"21",x"9F",x"42",x"9F",x"63",x"9F",x"84",x"9F",x"40",x"EF",x"04",x"4F",x"01",x"F5",x"00",x"EE",x"00",x"95",x"00",x"08",x"00",x"08",x"01",x"63",x"BF",x"6F",x"E0",x"37",x"10",x"4F",
	x"00",x"DF",x"21",x"DF",x"42",x"DF",x"63",x"DF",x"84",x"DF",x"A5",x"DF",x"00",x"F0",x"7F",x"69",x"20",x"31",x"FF",x"6A",x"4D",x"E9",x"2C",x"E8",x"01",x"F0",x"07",x"69",x"40",x"EF",x"03",x"4F",
	x"00",x"08",x"B9",x"16",x"00",x"08",x"BF",x"6E",x"C0",x"36",x"20",x"DE",x"8A",x"16",x"00",x"08"
);
end package;