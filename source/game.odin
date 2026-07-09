package game

import rl "vendor:raylib"

Industry_Type :: enum {
	Unclaimed,
	Empty,
	Wheat,
	Cow,
	Chicken,
}

Count :: struct {
	wheat_count: int,
	milk_count:  int,
	egg_count:   int,
}

count: Count

Industry :: struct {
	type:        Industry_Type,
	src:         rl.Rectangle,
	growth_rate: f32,
	max_growth:  f32,
	growth:      f32,
	produced:    int,
}

Tile :: struct {
	rec:      rl.Rectangle,
	industry: Industry,
	hovered: bool,
}

SPRITE_COUNT :: 5

Spritesheet_Reference :: struct {
	name: string,
	rec:  rl.Rectangle,
}

spritesheet: rl.Texture

tile_arr: [27]Tile

ind_arr := [5]Industry {
	{.Unclaimed, {0, 0, 144, 144}, 0, 0, 0, 0},
	{.Empty, {144, 0, 144, 144}, 0, 0, 0, 0},
	{.Wheat, {288, 0, 144, 144}, 1, 5, 0, 1},
	{.Cow, {0, 144, 144, 144}, 1, 10, 0, 1},
	{.Chicken, {144, 144, 144, 144}, 1, 10, 0, 3},
}

init_tile_arr :: proc(tile_arr: ^[27]Tile) {
	pos_arr := [27]rl.Vector2 {
		{0, 15},
		{144, 15},
		{288, 15},
		{432, 15},
		{576, 15}, // Row 1
		{72, 124},
		{216, 124},
		{360, 124},
		{504, 124}, // Row 2
		{0, 233},
		{144, 233},
		{288, 233},
		{432, 233},
		{576, 233}, // Row 3
		{72, 342},
		{216, 342},
		{360, 342},
		{504, 342}, // Row 4
		{0, 451},
		{144, 451},
		{288, 451},
		{432, 451},
		{576, 451}, // Row 5
		{72, 560},
		{216, 560},
		{360, 560},
		{504, 560}, // Row 6
	}

	for i := 0; i < 27; i += 1 {
		tile_arr[i].rec = {pos_arr[i].x, pos_arr[i].y, 144, 144}

		if i < 14 {
			tile_arr[i].industry = ind_arr[0]
		} else if i >= 14 && i < 18 {
			tile_arr[i].industry = ind_arr[2]
		} else if i >= 18 && i < 22 {
			tile_arr[i].industry = ind_arr[3]
		} else {
			tile_arr[i].industry = ind_arr[4]
		}
	}
}

get_spritesheet_recs :: proc() -> [SPRITE_COUNT]Spritesheet_Reference {
	return [SPRITE_COUNT]Spritesheet_Reference {
		{"Unclaimed", {0, 0, 144, 144}},
		{"Empty", {144, 0, 144, 144}},
		{"Wheat", {288, 0, 144, 144}},
		{"Cows", {0, 144, 144, 144}},
		{"Chickens", {144, 144, 144, 144}},
	}
}

get_initial_tile_positions :: proc() -> [27]rl.Rectangle {
	return [27]rl.Rectangle {
		{0, 15, 144, 144},
		{144, 15, 144, 144},
		{288, 15, 144, 144},
		{432, 15, 144, 144},
		{576, 15, 144, 144}, // Row 1
		{72, 124, 144, 144},
		{216, 124, 144, 144},
		{360, 124, 144, 144},
		{504, 124, 144, 144}, // Row 2
		{0, 233, 144, 144},
		{144, 233, 144, 144},
		{288, 233, 144, 144},
		{432, 233, 144, 144},
		{576, 233, 144, 144}, // Row 3
		{72, 342, 144, 144},
		{216, 342, 144, 144},
		{360, 342, 144, 144},
		{504, 342, 144, 144}, // Row 4
		{0, 451, 144, 144},
		{144, 451, 144, 144},
		{288, 451, 144, 144},
		{432, 451, 144, 144},
		{576, 451, 144, 144}, // Row 5
		{72, 560, 144, 144},
		{216, 560, 144, 144},
		{360, 560, 144, 144},
		{504, 560, 144, 144}, // Row 6
	}
}

update :: proc() {
	
	mousepoint := rl.GetMousePosition()

	for &tile in tile_arr {
		tile.hovered = rl.CheckCollisionPointRec(mousepoint, tile.rec)

			if tile.industry.type != .Unclaimed && tile.industry.type != .Empty {
				tile.industry.growth += tile.industry.growth_rate * rl.GetFrameTime()

				if tile.industry.growth >= tile.industry.max_growth {
					tile.industry.growth = 0

					#partial switch tile.industry.type {
					case .Wheat:
						count.wheat_count += tile.industry.produced
					case .Cow:
						count.milk_count += tile.industry.produced
					case .Chicken:
						count.egg_count += tile.industry.produced
					}
				}
			}	
	}
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.Color({70, 130, 50, 255}))

	for tile in tile_arr {
		
		if tile.hovered {
			rl.DrawTexturePro(
			spritesheet,
			tile.industry.src,
			tile.rec,
			{0, 0},
			0,
			rl.RED,
		)
		} else {
			rl.DrawTexturePro(
			spritesheet,
			tile.industry.src,
			tile.rec,
			{0, 0},
			0,
			rl.WHITE,
		)
		}
	}
	rl.DrawText(rl.TextFormat("Wheat: %d", count.wheat_count), 10, 10, 20, rl.BLACK)
	rl.DrawText(rl.TextFormat("Milk: %d", count.milk_count), 10, 40, 20, rl.BLACK)
	rl.DrawText(rl.TextFormat("Eggs: %d", count.egg_count), 10, 70, 20, rl.BLACK)
	rl.EndDrawing()
}

@(export)
game_update :: proc() {
	update()
	draw()
}

@(export)
game_init :: proc() {
	//rl.InitAudioDevice(); // Initialize Audio Device
	// Button_Sound = rl.LoadSound(); // Button Sound
	// Button_Texture = rl.LoadTexture(); // Button Texture
	
	init_tile_arr(&tile_arr)
	spritesheet = rl.LoadTexture("assets\\farm_spritesheet.png")
}

@(export)
game_init_window :: proc() {
	rl.InitWindow(720, 720, "test")

}

@(export)
game_should_run :: proc() -> bool {
	return !rl.WindowShouldClose()
}

@(export)
game_shutdown :: proc() {
	defer rl.UnloadTexture(spritesheet)
}

@(export)
game_shutdown_window :: proc() {
	rl.CloseWindow()
}

@(export)
game_force_reload :: proc() -> bool {
	return rl.IsKeyPressed(.F5)
}

@(export)
game_force_restart :: proc() -> bool {
	return rl.IsKeyPressed(.F6)
}

game_parent_window_size_changed :: proc(w, h: int) {
	rl.SetWindowSize(i32(w), i32(h))
}
