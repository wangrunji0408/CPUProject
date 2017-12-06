library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;
use work.Show.all;

-- 渲染模块
entity Renderer is
	port (
		rst, clk: in std_logic;
		vga_x, vga_y: in natural;
		color: out TColor;
		pixel_mode: in std_logic;	-- 是否全屏显示显存内容
		-- 对PixelReader接口
		pixel_x, pixel_y: out natural;
		pixel_data: in u16;
		-- Debug信息输入
		debug: in CPUDebug;
		io: in IODebug;
		buf0, buf1: in DataBufInfo;
		shell: in ShellBufInfo
	) ;
end Renderer;

architecture arch of Renderer is	
	
	signal font_color, back_color: TColor;
	signal grid_x, grid_y: natural; -- 80 * 30
	signal char_ascii: natural range 0 to 255;
	signal char: character;
	signal char_x, char_y: natural;
	signal font_data: std_logic;

begin
	rom: entity work.FontReader port map (clk, char_ascii, char_x, char_y, font_data);
	-- Read ROM
	grid_x <= vga_x / 8;  grid_y <= vga_y / 16;
	pixel_x <= vga_x / 8;  pixel_y <= vga_y / 8;

	-- Output
	process( vga_x, vga_y, pixel_data, font_data )
		constant reg_zone_x: natural := 40;
		constant reg_zone_y: natural := 1;
		variable reg_id: natural;
		variable reg_data_str: string(1 to 4);
		constant io_zone_x: natural := 50;
		constant io_zone_y: natural := 0;
		variable entity_str: string(1 to 2);
		variable step_str: string(1 to 4);
		variable inst_name: string(1 to 8);
		variable x0, y0, pos: natural;
		variable buf: DataBufInfo;

		function inZone (x: natural; x0: natural; x1: natural; y: natural; y0: natural; y1: natural) return boolean is
		begin
			return x >= x0 and x < x1 and y >= y0 and y < y1;
		end function;

	begin
		-- 默认设置
		font_color <= o"777";
		back_color <= o"000";
		char_ascii <= character'pos(char);
		char <= ' ';
		char_x <= vga_x mod 8;  char_y <= vga_y mod 16;

		if inZone(grid_x, 0, 2, grid_y, 0, 1) then
			entity_str := "IF";
			char <= entity_str(grid_x + 1);
		elsif inZone(grid_x, 3, 14, grid_y, 0, 1) then --len=11
			-- lastPC & Branch
			char <= show_IF_Data(debug.if_in)(grid_x - 3);
		elsif inZone(grid_x, 0, 2, grid_y, 1, 2) then
			entity_str := "ID";
			char <= entity_str(grid_x + 1);
		elsif inZone(grid_x, 3, 24, grid_y, 1, 2) then --len=21
			-- PC & 16位指令 
			char <= show_IF_ID_Data(debug.id_in)(grid_x - 3);
		elsif inZone(grid_x, 25, 31, grid_y, 1, 2) then --len=6
			-- 识别的指令 
			inst_name := showInst(debug.instType);
			char <= inst_name(grid_x - 25 + 1);
		elsif inZone(grid_x, 0, 2, grid_y, 2, 3) then
			entity_str := "EX";
			char <= entity_str(grid_x + 1);
		elsif inZone(grid_x, 3, 18, grid_y, 2, 3) then --len=15
			-- EX的输入 
			char <= show_ID_EX_Data(debug.ex_in)(grid_x - 3);
		elsif inZone(grid_x, 0, 2, grid_y, 3, 4) then
			entity_str := "ME";
			char <= entity_str(grid_x + 1);
		elsif inZone(grid_x, 3, 23, grid_y, 3, 4) then --len=20
			-- MEM的输入 
			char <= show_EX_MEM_Data(debug.mem_in)(grid_x - 3);
		elsif inZone(grid_x, 0, 2, grid_y, 4, 5) then
			entity_str := "RB";
			char <= entity_str(grid_x + 1);
		elsif inZone(grid_x, 3, 10, grid_y, 4, 5) then --len=7
			-- RB的输入 
			char <= show_RegPort(debug.mem_out)(grid_x - 3 + 1);
		elsif inZone(grid_x, reg_zone_x, reg_zone_x+6, grid_y, reg_zone_y, reg_zone_y+16) then
			-- 寄存器 
			reg_id := grid_y - reg_zone_y;			
			if grid_x = reg_zone_x then
				char <= toHex(to_u4(reg_id));
			elsif grid_x >= reg_zone_x + 2 then
				reg_data_str := toStr16(debug.regs(grid_y - reg_zone_y));			
				char <= reg_data_str(grid_x - reg_zone_x - 1);				
			end if;
		elsif inZone(grid_x, io_zone_x, io_zone_x+17, grid_y, io_zone_y, io_zone_y+17) then
			-- IO
			if grid_y = io_zone_y then	
				char <= show_IOEvent_Title(grid_x - io_zone_x +1);
			elsif grid_x >= reg_zone_x + 2 then
				char <= show_IOEvent(io(grid_y-1))(grid_x - io_zone_x);				
			end if;
		elsif inZone(grid_x, 0, 2, grid_y, 5, 6) then
			-- 序号
			step_str := toStr16(to_u16(debug.step));
			char <= step_str(grid_x + 3);
		elsif inZone(grid_x, 3, 19, grid_y, 5, 6) then --len=15
			-- Mode & BreakPointPC
			char <= show_Mode(debug.mode, debug.breakPointPC)(grid_x - 3);
		end if;

		x0 := 0; y0 := 24; buf := buf0;
		if inZone(grid_x, x0, x0+32, grid_y, y0, y0+2) then
			pos := (grid_y-y0)*32 + grid_x-x0;
			char_ascii <= to_integer(buf.data(pos));
			if buf.readPos <= buf.writePos then
				if pos < buf.readPos then
					font_color <= o"700";
				elsif pos < buf.writePos then
					font_color <= o"070";
				else
					font_color <= o"700";
				end if;
			else
				if pos < buf.writePos then
					font_color <= o"070";
				elsif pos < buf.readPos then
					font_color <= o"700";
				else
					font_color <= o"070";
				end if;
			end if;
		elsif inZone(grid_x, x0, x0+32, grid_y, y0+2, y0+6) then
			pos := (grid_y-y0-2)*16 + (grid_x-x0)/2;		
			if grid_x mod 2 = 0 then
				char <= toHex(buf.data(pos)(7 downto 4));
			else
				char <= toHex(buf.data(pos)(3 downto 0));
			end if;
			if to_u4(grid_x)(1) = '1' then
				font_color <= o"666";
			else
				font_color <= o"555";
			end if;
		end if;

		x0 := 36; y0 := 24; buf := buf1;
		if inZone(grid_x, x0, x0+32, grid_y, y0, y0+2) then
			pos := (grid_y-y0)*32 + grid_x-x0;
			char_ascii <= to_integer(buf.data(pos));
			if buf.readPos <= buf.writePos then
				if pos < buf.readPos then
					font_color <= o"700";
				elsif pos < buf.writePos then
					font_color <= o"070";
				else
					font_color <= o"700";
				end if;
			else
				if pos < buf.writePos then
					font_color <= o"070";
				elsif pos < buf.readPos then
					font_color <= o"700";
				else
					font_color <= o"070";
				end if;
			end if;
		elsif inZone(grid_x, x0, x0+32, grid_y, y0+2, y0+6) then
			pos := (grid_y-y0-2)*16 + (grid_x-x0)/2;		
			if grid_x mod 2 = 0 then
				char <= toHex(buf.data(pos)(7 downto 4));
			else
				char <= toHex(buf.data(pos)(3 downto 0));
			end if;
			if to_u4(grid_x)(1) = '1' then
				font_color <= o"666";
			else
				font_color <= o"555";
			end if;
		end if;

		x0 := 0; y0 := 8;
		if inZone(grid_x, x0, x0+16, grid_y, y0, y0+16) then
			-- Shell
			char_ascii <= to_integer(shell.data(grid_y - y0)(grid_x - x0));
			if grid_y - y0 = shell.y and grid_x - x0 = shell.x then
				back_color <= o"777";
				font_color <= o"000";
			end if;
		end if;

		if font_data = '1' then		
			color <= font_color;
		else
			color <= back_color;
		end if;

		if pixel_mode = '1' then
			if pixel_data(15) = '1' then
				-- 字符
				char_ascii <= to_integer(pixel_data(7 downto 0));
				if pixel_data(14) = '0' then	
					char_y <= vga_y mod 8;		-- 上半部分字符
				else
					char_y <= 8 + vga_y mod 8;	-- 下半部分字符
				end if;
				if font_data = '1' then 
					color <= std_logic_vector(pixel_data(13 downto 12)) & "0" 
							& std_logic_vector(pixel_data(11 downto 10)) & "0"
							& std_logic_vector(pixel_data(9 downto 8)) & "0";
				else
					color <= o"000";
				end if;
			else
				-- 颜色
				color <= TColor(pixel_data(8 downto 0));
			end if;
		end if;

	end process ;
end arch ; -- arch
