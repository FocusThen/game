package main

import "core:fmt"
import rl "vendor:raylib"

Vec2i :: [2]int

WINDOW_SIZE :: 1000
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH * CELL_SIZE
MAX_SNAKE_LENGHT :: GRID_WIDTH * GRID_WIDTH

TICK_RATE :: 0.13
tick_timer: f32 = TICK_RATE

snake: [MAX_SNAKE_LENGHT]Vec2i
snake_length: int
snake_head_position: Vec2i
move_direction: Vec2i
game_over: bool

restart :: proc() {
	start_head_pos := Vec2i{GRID_WIDTH / 2, GRID_WIDTH / 2}
	snake[0] = start_head_pos
	snake[1] = start_head_pos - {0, 1}
	snake[2] = start_head_pos - {0, 2}
	snake_length = 3
	move_direction = {0, 1}
	game_over = false
}

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Sneak Game")
	rl.SetTargetFPS(500)

	restart()

	for !rl.WindowShouldClose() {
		if rl.IsKeyPressed(.W) {
			move_direction = {0, -1}
		}
		if rl.IsKeyPressed(.S) {
			move_direction = {0, 1}
		}
		if rl.IsKeyPressed(.A) {
			move_direction = {-1, 0}
		}
		if rl.IsKeyPressed(.D) {
			move_direction = {1, 0}
		}

		if game_over {
			if rl.IsKeyPressed(.ENTER) {
				restart()
			}
		} else {
			tick_timer -= rl.GetFrameTime()
		}

		if tick_timer <= 0 {
			next_part_pos := snake[0]
			snake[0] += move_direction
			head_pos := snake[0]

			// check is snake hit wall
			if head_pos.x < 0 ||
			   head_pos.y < 0 ||
			   head_pos.x >= GRID_WIDTH ||
			   head_pos.y >= GRID_WIDTH {
				game_over = true
			}

			for i in 1 ..< snake_length {
				cur_pos := snake[i]
				snake[i] = next_part_pos
				next_part_pos = cur_pos
			}


			tick_timer = TICK_RATE + tick_timer
		}

		rl.BeginDrawing()
		rl.ClearBackground({76, 53, 83, 255})

		camera := rl.Camera2D {
			zoom = f32(WINDOW_SIZE) / CANVAS_SIZE,
		}

		rl.BeginMode2D(camera)

		for i in 0 ..< snake_length {
			body_rect := rl.Rectangle {
				f32(snake[i].x) * CELL_SIZE,
				f32(snake[i].y) * CELL_SIZE,
				CELL_SIZE,
				CELL_SIZE,
			}

			rl.DrawRectangleRec(body_rect, rl.WHITE)
		}


    // game over

    if game_over{
      rl.DrawText("Game Over!", 4, 4, 25, rl.RED)
      rl.DrawText("Press Enter to Play Again!", 4, 30, 15, rl.BLACK)
    }


		rl.EndMode2D()
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
