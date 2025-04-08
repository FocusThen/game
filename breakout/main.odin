package main


import "core:fmt"
import rl "vendor:raylib"

SCREEN_SIZE :: 320

// PADDLE
PADDLE_WIDTH :: 50
PADDLE_HEIGHT :: 6
PADDLE_POS_Y :: 260
PADDLE_SPEED :: 200
paddle_pos_x: f32


restart :: proc() {
	paddle_pos_x = SCREEN_SIZE / 2 - PADDLE_WIDTH / 2
}

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(320, 320, "Breakout!")
	rl.SetTargetFPS(500)

	restart()

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		paddle_move_velocity: f32

		if rl.IsKeyDown(.A) {
			paddle_move_velocity -= PADDLE_SPEED
		}
		if rl.IsKeyDown(.D) {
			paddle_move_velocity += PADDLE_SPEED
		}


		paddle_pos_x += paddle_move_velocity * dt
		paddle_pos_x = clamp(paddle_pos_x, 0, SCREEN_SIZE - PADDLE_WIDTH)


		rl.BeginDrawing()
		rl.ClearBackground({150, 190, 220, 255})

		camera := rl.Camera2D {
        zoom = f32(rl.GetScreenHeight() / SCREEN_SIZE),
		}

		rl.BeginMode2D(camera)

		paddle_rect := rl.Rectangle{paddle_pos_x, PADDLE_POS_Y, PADDLE_WIDTH, PADDLE_HEIGHT}


		rl.DrawRectangleRec(paddle_rect, {50, 150, 90, 255})

		// debug screen
		screen_rect := rl.Rectangle{0, 0, SCREEN_SIZE, SCREEN_SIZE}
		rl.DrawRectangleRec(screen_rect, {255, 150, 90, 100})

		rl.EndMode2D()
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
