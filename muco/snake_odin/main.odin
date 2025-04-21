package main

import "core:fmt"
import "core:math"
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
food_pos: Vec2i


// food
place_food :: proc() {
	occupied: [GRID_WIDTH][GRID_WIDTH]bool

	for i in 0 ..< snake_length {
		occupied[snake[i].x][snake[i].y] = true
	}

	free_cells := make([dynamic]Vec2i, context.temp_allocator)

	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_WIDTH {
			if !occupied[x][y] {
				append(&free_cells, Vec2i{x, y})
			}
		}
	}

	if len(free_cells) > 0 {
		random_cell_index := rl.GetRandomValue(0, i32(len(free_cells) - 1))
		food_pos = free_cells[random_cell_index]
	}

	// other ways to control over memory
	//delete(free_cells)
}

restart :: proc() {
	start_head_pos := Vec2i{GRID_WIDTH / 2, GRID_WIDTH / 2}
	snake[0] = start_head_pos
	snake[1] = start_head_pos - {0, 1}
	snake[2] = start_head_pos - {0, 2}
	snake_length = 3
	move_direction = {0, 1}
	game_over = false
	place_food()
}


main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Sneak Game")
	rl.SetTargetFPS(500)
  rl.InitAudioDevice()

	restart()

	food_sprite := rl.LoadTexture("food.png")
	head_sprite := rl.LoadTexture("head.png")
	body_sprite := rl.LoadTexture("body.png")
	tail_sprite := rl.LoadTexture("tail.png")

  eat_sound := rl.LoadSound("eat.wav")
  crash_sound := rl.LoadSound("crash.wav")

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
        rl.PlaySound(crash_sound)
			}

			for i in 1 ..< snake_length {
				cur_pos := snake[i]
				// check eating your self
				if (cur_pos == head_pos) {
					game_over = true
          rl.PlaySound(crash_sound)
				}

				snake[i] = next_part_pos
				next_part_pos = cur_pos
			}

			// food
			if head_pos == food_pos {
				snake_length += 1
				snake[snake_length - 1] = next_part_pos
				place_food()
        rl.PlaySound(eat_sound)
			}


			tick_timer = TICK_RATE + tick_timer
		}

		rl.BeginDrawing()
		rl.ClearBackground({76, 53, 83, 255})

		camera := rl.Camera2D {
			zoom = f32(WINDOW_SIZE) / CANVAS_SIZE,
		}

		rl.BeginMode2D(camera)

		// food
		// RECT
		//food_rect := rl.Rectangle {
		//	f32(food_pos.x) * CELL_SIZE,
		//	f32(food_pos.y) * CELL_SIZE,
		//	CELL_SIZE,
		//	CELL_SIZE,
		//}
		//rl.DrawRectangleRec(food_rect, rl.RED)

		// Texture
		rl.DrawTextureV(food_sprite, {f32(food_pos.x), f32(food_pos.y)} * CELL_SIZE, rl.WHITE)

		for i in 0 ..< snake_length {
			// texture
			part_sprite := body_sprite
			dir: Vec2i

			if i == 0 {
				part_sprite = head_sprite
				dir = snake[i] - snake[i + 1]
			} else if i == snake_length - 1 {
				part_sprite = tail_sprite
				dir = snake[i - 1] - snake[i]
			} else {
				dir = snake[i - 1] - snake[i]
			}

			rot := math.atan2(f32(dir.y), f32(dir.x)) * math.DEG_PER_RAD

			source := rl.Rectangle{0, 0, f32(part_sprite.width), f32(part_sprite.height)}

			dest := rl.Rectangle {
				f32(snake[i].x) * CELL_SIZE + 0.5 * CELL_SIZE,
				f32(snake[i].y) * CELL_SIZE + 0.5 * CELL_SIZE,
				CELL_SIZE,
				CELL_SIZE,
			}


			rl.DrawTexturePro(
				part_sprite,
				source,
				dest,
				{CELL_SIZE, CELL_SIZE} * 0.5,
				rot,
				rl.WHITE,
			)
			//


			// RECT
			//body_rect := rl.Rectangle {
			//	f32(snake[i].x) * CELL_SIZE,
			//	f32(snake[i].y) * CELL_SIZE,
			//	CELL_SIZE,
			//	CELL_SIZE,
			//}
			//
			//rl.DrawRectangleRec(body_rect, rl.WHITE)
		}


		// game over

		if game_over {
			rl.DrawText("Game Over!", 4, 4, 25, rl.RED)
			rl.DrawText("Press Enter to Play Again!", 4, 30, 15, rl.BLACK)
		}

		score := snake_length - 3
		score_str := fmt.ctprintf("Score: %v", score)
		rl.DrawText(score_str, 4, CANVAS_SIZE - 14, 10, rl.GRAY)

		rl.EndMode2D()
		rl.EndDrawing()

		free_all(context.temp_allocator)
	}

	rl.UnloadTexture(head_sprite)
	rl.UnloadTexture(body_sprite)
	rl.UnloadTexture(tail_sprite)
	rl.UnloadTexture(food_sprite)

  rl.UnloadSound(eat_sound)
  rl.UnloadSound(crash_sound)

  rl.CloseAudioDevice()
	rl.CloseWindow()
}
