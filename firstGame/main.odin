package main

import rl "vendor:raylib"

Animation_Name :: enum {
	Idle,
	Run,
}

Animation :: struct {
	texture:       rl.Texture2D,
	num_frames:    int,
	frame_timer:   f32,
	current_frame: int,
	frame_length:  f32,
	name:          Animation_Name,
}

update_animation :: proc(anim: ^Animation) {
	anim.frame_timer += rl.GetFrameTime()
	if anim.frame_timer > anim.frame_length {
		anim.current_frame += 1
		anim.frame_timer = 0

		if anim.current_frame == anim.num_frames {
			anim.current_frame = 0
		}
	}
}

draw_animation :: proc(anim: Animation, pos: rl.Vector2, flip: bool) {
	anim_width := f32(anim.texture.width)
	anim_height := f32(anim.texture.height)

	source := rl.Rectangle {
		x      = f32(anim.current_frame) * anim_width / f32(anim.num_frames),
		y      = 0,
		width  = anim_width / f32(anim.num_frames),
		height = anim_height,
	}

	if flip {
		source.width = -source.width
	}

	dest := rl.Rectangle {
		x      = pos.x,
		y      = pos.y,
		width  = anim_width / f32(anim.num_frames),
		height = anim_height,
	}

	rl.DrawTexturePro(anim.texture, source, dest, {dest.width / 2, dest.height}, 0, rl.WHITE)
}

PixelWindowHeight :: 180

main :: proc() {
	rl.InitWindow(1280, 720, "My First Game")
	//rl.SetWindowState({.WINDOW_RESIZABLE})
	rl.SetTargetFPS(500)

	player_pos: rl.Vector2
	player_vel: rl.Vector2
	player_grounded: bool
	player_run := Animation {
		texture      = rl.LoadTexture("cat_run.png"),
		num_frames   = 4,
		frame_length = 0.1,
		name         = .Run,
	}

	player_flip: bool

	player_idle := Animation {
		texture      = rl.LoadTexture("cat_idle.png"),
		num_frames   = 2,
		frame_length = 0.5,
		name         = .Idle,
	}

	current_anim := player_idle

	platforms := []rl.Rectangle{{-20, 20, 96, 16}, {-30, -20, 96, 16}}

	platform_texture := rl.LoadTexture("platform.png")


	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({110, 184, 168, 255})

		if rl.IsKeyDown(.A) {
			player_vel.x = -100
			player_flip = true
			if current_anim.name != .Run {
				current_anim = player_run
			}
		} else if rl.IsKeyDown(.D) {
			player_vel.x = 100
			player_flip = false
			if current_anim.name != .Run {
				current_anim = player_run
			}
		} else {
			player_vel.x = 0
			if current_anim.name != .Idle {
				current_anim = player_idle
			}
		}

		player_vel.y += 1000 * rl.GetFrameTime()

		if player_grounded && rl.IsKeyPressed(.SPACE) {
			player_vel.y = -300
		}

		player_pos += player_vel * rl.GetFrameTime()

		player_feet_collider := rl.Rectangle{player_pos.x - 4, player_pos.y - 4, 8, 4}

		player_grounded = false

		for platform in platforms {
			if rl.CheckCollisionRecs(player_feet_collider, platform) && player_vel.y > 0 {
				player_vel.y = 0
				player_pos.y = platform.y
				player_grounded = true
			}
		}


		update_animation(&current_anim)

		screen_height := f32(rl.GetScreenHeight())

		camera := rl.Camera2D {
			zoom   = screen_height / PixelWindowHeight,
			offset = {f32(rl.GetScreenWidth() / 2), screen_height / 2},
			target = player_pos,
		}

		rl.BeginMode2D(camera)
		draw_animation(current_anim, player_pos, player_flip)
		for platform in platforms {
			rl.DrawTextureV(platform_texture, {platform.x, platform.y}, rl.WHITE)
		}
    // Debug
		//rl.DrawRectangleRec(player_feet_collider, {0, 255, 0, 100})
		rl.EndMode2D()

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
