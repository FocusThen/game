package main

import "core:fmt"
import rl "vendor:raylib"

GRID_WIDTH :: 20
CELL_SIZE :: 16
Vec2i :: [2]int

snake_head_position: Vec2i

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(1280, 720, "Sneak Game")
	rl.SetTargetFPS(500)

	snake_head_position = {GRID_WIDTH / 2, GRID_WIDTH / 2}

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({76, 53, 83, 255})

		head_rect := rl.Rectangle {
			f32(snake_head_position.x) * CELL_SIZE,
			f32(snake_head_position.y) * CELL_SIZE,
			CELL_SIZE,
			CELL_SIZE,
		}

		rl.DrawRectangleRec(head_rect, rl.WHITE)


		rl.EndDrawing()
	}

	rl.CloseWindow()
}
