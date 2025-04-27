package cex

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

Color_Background :: rl.Color{199, 194, 170, 255}
Color_Panel      :: rl.Color{210, 204, 180, 255}
Color_PanelHi    :: rl.Color{ 72,  69,  60, 255}
Color_BlueLo     :: rl.Color{ 34,  68, 107, 255}
Color_BlueHi     :: rl.Color{185, 205, 227, 255}
Color_RedLo      :: rl.Color{127,  28,   4, 255}
Color_RedHi      :: rl.Color{247, 165, 155, 255}

WIDTH :: 1920

NUM_OCTAVES  :: i32(3)
OCTAVE_WIDTH :: i32(WIDTH/NUM_OCTAVES)
KEY_WIDTH    :: i32(OCTAVE_WIDTH/7)
KEY_HEIGHT   :: KEY_WIDTH*4
SHADOW_WIDTH :: KEY_WIDTH/16
FONT_SIZE    :: i32(32)

HEIGHT :: KEY_HEIGHT

SAMPLE_RATE :: 44100

Tone :: struct
{
	freq: f32,
	t: f32,
	ts: f32,
}

ToneCur := 0
Tones   := [8]Tone{}

AudioCallback :: proc($idx: int) -> (proc "c" (data: rawptr, frames: u32))
{
	return proc "c" (data: rawptr, frames: u32)
	{
		tone := &Tones[idx]

		for i in 0..<frames
		{
			a := f32(0.3*32767.0)

			f := a*(1.0*math.sin(1*2.0*rl.PI*tone.t))
			f += a*(0.5*math.sin(2*2.0*rl.PI*tone.t))
			f += a*(0.25*math.sin(3*2.0*rl.PI*tone.t))
			f += a*(0.125*math.sin(4*2.0*rl.PI*tone.t))
			f += a*(0.0625*math.sin(5*2.0*rl.PI*tone.t))
			f += a*(0.03125*math.sin(6*2.0*rl.PI*tone.t))

			tone.t  += tone.freq/f32(SAMPLE_RATE)
			tone.ts += 2/f32(SAMPLE_RATE)

			if tone.t > 1 do tone.t -= 1

			f *= math.exp(-tone.ts*tone.ts)

			(([^]i16)(data))[i] = i16(f)
		}
	}
}

main :: proc()
{

	rl.InitWindow(WIDTH, HEIGHT, "CEX")
	rl.SetTargetFPS(60)
	
	rl.InitAudioDevice()

	streams := [8]rl.AudioStream{}
	streams[0] = rl.LoadAudioStream(SAMPLE_RATE, 16, 1)
	rl.SetAudioStreamCallback(streams[0], AudioCallback(0))
	streams[1] = rl.LoadAudioStream(SAMPLE_RATE, 16, 1)
	rl.SetAudioStreamCallback(streams[1], AudioCallback(1))
	streams[2] = rl.LoadAudioStream(SAMPLE_RATE, 16, 1)
	rl.SetAudioStreamCallback(streams[2], AudioCallback(2))
	streams[3] = rl.LoadAudioStream(SAMPLE_RATE, 16, 1)
	rl.SetAudioStreamCallback(streams[3], AudioCallback(3))
	streams[4] = rl.LoadAudioStream(SAMPLE_RATE, 16, 1)
	rl.SetAudioStreamCallback(streams[4], AudioCallback(4))
	streams[5] = rl.LoadAudioStream(SAMPLE_RATE, 16, 1)
	rl.SetAudioStreamCallback(streams[5], AudioCallback(5))
	streams[6] = rl.LoadAudioStream(SAMPLE_RATE, 16, 1)
	rl.SetAudioStreamCallback(streams[6], AudioCallback(6))
	streams[7] = rl.LoadAudioStream(SAMPLE_RATE, 16, 1)
	rl.SetAudioStreamCallback(streams[7], AudioCallback(7))

	for i in 0..<8 do rl.PlayAudioStream(streams[i])

	keymap_letters := [NUM_OCTAVES*12]cstring{
		"Q", "2", "W", "3", "E", "R", "5", "T", "6", "Y", "7", "U",
		"I", "9", "O", "0", "P", "Z", "S", "X", "D", "C", "F", "V",
		"B", "H", "N", "J", "M", ",", "L", ".", nil, nil, nil, nil,
	}

	Key :: struct
	{
		letter: cstring,
		text_width: i32,
		x: i32,
		w: i32,
		h: i32,
		is_elevated: bool,
	}

	keys: [NUM_OCTAVES*12]Key;
	for i in 0..<NUM_OCTAVES
	{
		for j, jj in ([7]i32{0, 2, 4, 5, 7, 9, 11})
		{
			k := i*12 + j

			keys[k] = Key{
				letter          = keymap_letters[k],
				text_width      = rl.MeasureText(keymap_letters[k], FONT_SIZE),
				x               = i*OCTAVE_WIDTH + i32(jj)*KEY_WIDTH,
				w               = (jj == 6 ? OCTAVE_WIDTH - 6*KEY_WIDTH : KEY_WIDTH),
				h               = KEY_HEIGHT,
				is_elevated     = false,
			}
		}

		for j, jj in ([6]i32{1, 3, -1, 6, 8, 10})
		{
			if j < 0 do continue

			k := i*12 + j

			keys[k] = Key{
				letter          = keymap_letters[k],
				text_width      = rl.MeasureText(keymap_letters[k], FONT_SIZE),
				x               = i*OCTAVE_WIDTH + i32(jj)*KEY_WIDTH + (3*KEY_WIDTH)/4,
				w               = KEY_WIDTH/2,
				h               = (7*KEY_HEIGHT)/12,
				is_elevated     = true,
			}
		}
	}

	KeyUnderMouse :: proc(keys: []Key) -> i32
	{
		result := i32(-1)

		x := rl.GetMouseX()
		y := rl.GetMouseY()

		if y >= 0 && y <= KEY_HEIGHT
		{
			for key, i in keys
			{
				if key.x > x do break

				if x >= key.x && x <= key.x + key.w
				{
					result = i32(i)
					if key.is_elevated do break
				}
			}
		}

		return result
	}

	for !rl.WindowShouldClose()
	{
		highlighted_keys := u64(0)

		key_under_mouse := KeyUnderMouse(keys[:]);

		if key_under_mouse != -1 && rl.IsMouseButtonDown(rl.MouseButton.LEFT)
		{
			highlighted_keys |= 1 << uint(key_under_mouse)
		}

		for letter, i in keymap_letters
		{
			if letter == nil do continue

			keyb_key := rl.KeyboardKey((([^]u8)(letter))[0])

			if rl.IsKeyDown(keyb_key)
			{
				highlighted_keys |= 1 << uint(i)
			}

			if rl.IsKeyPressed(keyb_key)
			{
				ToneCur = (ToneCur + 1) % len(Tones)
				Tones[ToneCur] = Tone{
					freq = 261.63*math.pow(2, f32(i)/12),
				}
			}
		}

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
					rl.DrawRectangle(key.x, 0, key.w - SHADOW_WIDTH, key.h - SHADOW_WIDTH, color)
					rl.DrawText(key.letter, key.x + (key.w - SHADOW_WIDTH)/2 - key.text_width/2, SHADOW_WIDTH + (is_elevated ? 0 : FONT_SIZE), FONT_SIZE, shadow_color)
				}
			}
		}
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
