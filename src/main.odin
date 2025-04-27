package cex

import rl "vendor:raylib"
import "core:fmt"

Color_Background :: rl.Color{199, 194, 170, 255}
Color_Panel      :: rl.Color{210, 204, 180, 255}
Color_PanelHi    :: rl.Color{ 72,  69,  60, 255}
Color_BlueLo     :: rl.Color{ 34,  68,  67, 255}
Color_BlueHi     :: rl.Color{185, 205, 187, 255}

HEIGHT :: 1080

main :: proc()
{
	WIDTH :: 1920

	num_octaves :: 3
	keymap := [?]rune{
		'Q', '2', 'W', '3', 'E', 'R', '5', 'T', '6', 'Y', '7', 'U',
		'I', '9', 'O', '0', 'P', 'Z', 'S', 'X', 'D', 'C', 'F', 'V',
		'B', 'H', 'N', 'J', 'M', ',', 'L', '.',
	}
	octave_width :: i32(WIDTH/num_octaves)
	key_width    :: i32(octave_width/7)
	key_height   :: key_width*4
	shadow_width :: key_width/16
	font_size    :: i32(32)

	HEIGHT :: key_height

	rl.InitWindow(WIDTH, HEIGHT, "CEX")
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose()
	{
		highlighted_keys := i64(1 + 2)

		rl.BeginDrawing()
		{
			rl.ClearBackground(Color_Background)


			for i in 0..<i32(num_octaves)
			{
				for j in 0..<i32(7)
				{
					skiplist := [7]i32{0, 3, 4, 5, 7, 9, 11}
					key_i := i*12 + skiplist[j]

					shadow_color := Color_PanelHi
					color        := Color_Panel
					if (highlighted_keys & (1 << u32(key_i))) != 0
					{
						shadow_color = Color_BlueLo
						color        = Color_BlueHi
					}

					w := i32(j == 6 ? octave_width - 6*key_width : key_width)

					x := i*octave_width + j*key_width

					rl.DrawRectangle(x, 0, w, key_height, shadow_color)
					rl.DrawRectangle(x, 0, w - shadow_width, key_height - shadow_width, color)


					if key_i < len(keymap)
					{
						c := keymap[key_i]
						s := fmt.ctprint(c)
						tw := rl.MeasureText(s, font_size)
						rl.DrawText(s, x + (w - tw)/2, shadow_width + font_size, font_size, Color_PanelHi)
					}
				}

				for j in 0..<i32(6)
				{
					if j == 2 do continue

					skiplist := [6]i32{1, 3, 0, 6, 8, 10}
					key_i := i*12 + skiplist[j]

					color        := Color_PanelHi
					if (highlighted_keys & (1 << u32(key_i))) != 0
					{
						color = Color_BlueLo
					}

					w := key_width/2
					h := (7*key_height)/12

					x := i*octave_width + j*key_width + (3*key_width)/4 - shadow_width/2

					rl.DrawRectangle(x, 0, w, h, color)

					if key_i < len(keymap)
					{
						c := keymap[key_i]
						s := fmt.ctprint(c)
						tw := rl.MeasureText(s, font_size)
						rl.DrawText(s, x + (w - tw)/2, shadow_width, font_size, Color_Panel)
					}
				}
			}
		}
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
