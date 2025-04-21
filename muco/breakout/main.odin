package main


import "core:fmt"
import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

SCREEN_SIZE :: 320
WINDOW_SIZE :: 720

// PADDLE
PADDLE_WIDTH :: 50
PADDLE_HEIGHT :: 6
PADDLE_POS_Y :: 260
PADDLE_SPEED :: 200
paddle_pos_x: f32

// BALL
BALL_SPEED :: 260
BALL_RADIUS :: 4
BALL_START_Y :: 160
ball_pos: rl.Vector2
ball_dir: rl.Vector2

// game
started: bool

restart :: proc() {
	paddle_pos_x = SCREEN_SIZE / 2 - PADDLE_WIDTH / 2
	ball_pos = {SCREEN_SIZE / 2, BALL_START_Y}
	started = false
}

reflect :: proc(dir, normal: rl.Vector2) -> rl.Vector2 {
	new_direction := linalg.reflect(dir, linalg.normalize(normal))
	return linalg.normalize(new_direction)
}

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Breakout!")
	rl.SetTargetFPS(500)

	restart()

	camera: rl.Camera2D


	for !rl.WindowShouldClose() {
		dt: f32
		screen_width := rl.GetScreenWidth()
		screen_height := rl.GetScreenHeight()


		if !started {
			ball_pos = {
				SCREEN_SIZE / 2 + f32(math.cos(rl.GetTime()) * SCREEN_SIZE / 2.5),
				BALL_START_Y,
			}

			if rl.IsKeyPressed(.SPACE) {
				paddle_middle := rl.Vector2{paddle_pos_x + PADDLE_WIDTH / 2, PADDLE_POS_Y}
				ball_to_paddle := paddle_middle - ball_pos
				ball_dir = linalg.normalize0(ball_to_paddle)
				started = true
			}
		} else {
			dt = rl.GetFrameTime()
		}

		previous_ball_pos := ball_pos
		ball_pos += ball_dir * BALL_SPEED * dt
		paddle_move_velocity: f32

		// right wall
		if ball_pos.x + BALL_RADIUS > SCREEN_SIZE {
			ball_pos.x = SCREEN_SIZE - BALL_RADIUS
			ball_dir = reflect(ball_dir, {-1, 0})
		}
		// left wall
		if ball_pos.x - BALL_RADIUS < 0 {
			ball_pos.x = BALL_RADIUS
			ball_dir = reflect(ball_dir, {1, 0})
		}
		// top wall
		if ball_pos.y - BALL_RADIUS < 0 {
			ball_pos.y = BALL_RADIUS
			ball_dir = reflect(ball_dir, {0, 1})
		}
		// bottom wall
		if ball_pos.y > SCREEN_SIZE + BALL_RADIUS * 6 {
			restart()
		}


		if rl.IsKeyDown(.A) {
			paddle_move_velocity -= PADDLE_SPEED
		}
		if rl.IsKeyDown(.D) {
			paddle_move_velocity += PADDLE_SPEED
		}

		paddle_pos_x += paddle_move_velocity * dt
		paddle_pos_x = clamp(paddle_pos_x, 0, SCREEN_SIZE - PADDLE_WIDTH)

		zoom_x := f32(screen_width) / 320.0
		zoom_y := f32(screen_height) / 320.0
		zoom := math.min(zoom_x, zoom_y)

		camera.offset = rl.Vector2{f32(screen_width) / 2.0, f32(screen_height) / 2.0}
		camera.target = rl.Vector2{160.0, 160.0}
		camera.zoom = zoom
		camera.rotation = 0.0

		paddle_rect := rl.Rectangle{paddle_pos_x, PADDLE_POS_Y, PADDLE_WIDTH, PADDLE_HEIGHT}

		if rl.CheckCollisionCircleRec(ball_pos, BALL_RADIUS, paddle_rect) {
			collision_normal: rl.Vector2
			if previous_ball_pos.y < paddle_rect.y + paddle_rect.height {
				collision_normal += {0, -1}
				ball_pos.y = paddle_rect.y - BALL_RADIUS
			}

			if previous_ball_pos.y > paddle_rect.y + paddle_rect.height {
				collision_normal += {0, 1}
				ball_pos.y = paddle_rect.y + paddle_rect.height + BALL_RADIUS
			}

			if previous_ball_pos.x < paddle_rect.x {
				collision_normal += {-1, 0}
			}
			if previous_ball_pos.x > paddle_rect.x + paddle_rect.width {
				collision_normal += {1, 0}
			}

			if collision_normal != 0 {
				ball_dir = reflect(ball_dir, collision_normal)
			}
		}

		rl.BeginDrawing()
		rl.ClearBackground({150, 190, 220, 255})
		rl.BeginMode2D(camera)

		rl.DrawRectangleRec(paddle_rect, {50, 150, 90, 255})
		rl.DrawCircleV(ball_pos, BALL_RADIUS, {200, 90, 20, 255})

		rl.EndMode2D()
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
