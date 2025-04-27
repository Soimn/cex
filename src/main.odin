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

	num_octaves :: i32(3)
	keymap_letters := [num_octaves*12]cstring{
		"Q", "2", "W", "3", "E", "R", "5", "T", "6", "Y", "7", "U",
		"I", "9", "O", "0", "P", "Z", "S", "X", "D", "C", "F", "V",
		"B", "H", "N", "J", "M", ",", "L", ".", nil, nil, nil, nil,
	}
	octave_width :: i32(WIDTH/num_octaves)
	key_width    :: i32(octave_width/7)
	key_height   :: key_width*4
	shadow_width :: key_width/16
	font_size    :: i32(32)

	HEIGHT :: key_height

	rl.InitWindow(WIDTH, HEIGHT, "CEX")
	rl.SetTargetFPS(60)

	Key :: struct
	{
		letter: cstring,
		text_width: i32,
		x: i32,
		w: i32,
		h: i32,
		is_elevated: bool,
	}

	keys: [num_octaves*12]Key;
	for i in 0..<num_octaves
	{
		for j, jj in ([7]i32{0, 2, 4, 5, 7, 9, 11})
		{
			k := i*12 + j

			keys[k] = Key{
				letter          = keymap_letters[k],
				text_width      = rl.MeasureText(keymap_letters[k], font_size),
				x               = i*octave_width + i32(jj)*key_width,
				w               = (jj == 6 ? octave_width - 6*key_width : key_width),
				h               = key_height,
				is_elevated     = false,
			}
		}

		for j, jj in ([6]i32{1, 3, -1, 6, 8, 10})
		{
			if j < 0 do continue

			k := i*12 + j

			keys[k] = Key{
				letter          = keymap_letters[k],
				text_width      = rl.MeasureText(keymap_letters[k], font_size),
				x               = i*octave_width + i32(jj)*key_width + (3*key_width)/4,
				w               = key_width/2,
				h               = (7*key_height)/12,
				is_elevated     = true,
			}
		}
	}

	for !rl.WindowShouldClose()
	{
		highlighted_keys := u64(1 + 64)

		rl.BeginDrawing()
		{
			rl.ClearBackground(Color_Background)

			for is_elevated in ([2]bool{false, true})
			{
				for key, i in keys
				{
					if key.is_elevated != is_elevated do continue

					shadow_color := Color_PanelHi
					color        := Color_Panel
					if (highlighted_keys & (1 << uint(i))) != 0
					{
						shadow_color = Color_BlueLo
						color        = Color_BlueHi
					}

					if key.is_elevated do shadow_color, color = color, shadow_color

					rl.DrawRectangle(key.x, 0, key.w, key.h, shadow_color)
					rl.DrawRectangle(key.x, 0, key.w - shadow_width, key.h - shadow_width, color)
					rl.DrawText(key.letter, key.x + (key.w - shadow_width)/2 - key.text_width/2, shadow_width + (is_elevated ? 0 : font_size), font_size, shadow_color)
				}
			}
		}
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
