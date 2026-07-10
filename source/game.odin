package game

import rl "vendor:raylib"

Industry_Type :: enum {
	Unclaimed,
	Empty,
	Wheat,
	Cow,
	Chicken,
}

Industry :: struct {
	type:        Industry_Type,
	src:         rl.Rectangle,
	growth_rate: f32,
	max_growth:  f32,
	growth:      f32,
	produced:    u32,
	cost:        u32,
}

Tile :: struct {
	id:       int,
	rec:      rl.Rectangle,
	industry: Industry,
	hovered:  bool,
	collider: [8]rl.Vector2,
	tint:     rl.Color,
}

Game :: struct {
	wheat_count: u32,
	milk_count:  u32,
	egg_count:   u32,
	wheat_button: Button,
	milk_button: Button,
	egg_button: Button,
	spritesheet: rl.Texture,
	tile_arr:    [22]Tile,
	ind_arr:     [5]Industry,
	dropdown:    Dropwdown,
	money:       u32,
	dropdown_just_opened: bool,
}

Button_State :: enum {
	Normal,
	Hovered,
	Clicked,
	Disabled,
}

Button :: struct {
	rec:   rl.Rectangle,
	state: Button_State,
	tint:  rl.Color,
}

Dropdown_Button :: struct {
	rec:        rl.Rectangle,
	state:      Button_State,
	tint:       rl.Color,
	text_color: rl.Color,
	// interact: proc(i: int, ind_type: Industry_Type),
	type:       Industry_Type,
	text:       cstring,
}

Dropwdown :: struct {
	rec:     rl.Rectangle,
	buttons: [5]Dropdown_Button,
	show:    bool,
	tile_id: int,
}

game: Game

init_tile_arr :: proc(tile_arr: ^[22]Tile) {
	pos_arr := get_initial_tile_positions()

	collider_points: [8]rl.Vector2 = {
		{0, 35},
		{70, 0},
		{73, 0},
		{143, 35},
		{143, 108},
		{73, 143},
		{70, 143},
		{0, 108},
	}

	for i := 0; i < len(tile_arr); i += 1 {
		tile_arr[i].id = i
		tile_arr[i].rec = pos_arr[i]
		tile_arr[i].tint = rl.WHITE

		for j := 0; j < len(collider_points); j += 1 {
			tile_arr[i].collider[j] =
				{pos_arr[i].x, pos_arr[i].y} + collider_points[j]
		}

		if i < 9 {
			tile_arr[i].industry = game.ind_arr[0]
		} else {
			tile_arr[i].industry = game.ind_arr[1]
		}
		// } else if i >= 14 && i < 18 {
		// 	tile_arr[i].industry = game.ind_arr[2]
		// } else if i >= 18 && i < 22 {
		// 	tile_arr[i].industry = game.ind_arr[3]
		// } else {
		// 	tile_arr[i].industry = game.ind_arr[4]
		// }
	}
}

get_initial_tile_positions :: proc() -> [22]rl.Rectangle {
	return [22]rl.Rectangle {
		// {0, 15, 144, 144},
		// {144, 15, 144, 144},
		// {288, 15, 144, 144},
		// {432, 15, 144, 144},
		// {576, 15, 144, 144}, // Row 1
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

	if rl.IsMouseButtonPressed(.LEFT) {
		if rl.CheckCollisionPointRec(mousepoint, game.wheat_button.rec) && game.wheat_count > 0 {
			game.wheat_count -= 1
			game.money += 2
		}
		if rl.CheckCollisionPointRec(mousepoint, game.milk_button.rec) && game.milk_count > 0 {
			game.milk_count -= 1
			game.money += 3
		}
		if rl.CheckCollisionPointRec(mousepoint, game.egg_button.rec) && game.egg_count > 0 {
			game.egg_count -= 1
			game.money += 1
		}
	}

	for &tile in game.tile_arr {
		if !game.dropdown.show {
			if rl.CheckCollisionPointPoly(
				mousepoint,
				raw_data(&tile.collider),
				8,
			) {
				tile.hovered = true
				tile.tint = rl.RED

				if rl.IsMouseButtonPressed(.LEFT) {
					show_dropdown(mousepoint, tile.id)
				}

			} else {
				tile.hovered = false
				tile.tint = rl.WHITE
			}
		}

		if tile.industry.type != .Unclaimed && tile.industry.type != .Empty {
			tile.industry.growth +=
				tile.industry.growth_rate * rl.GetFrameTime()

			if tile.industry.growth >= tile.industry.max_growth {
				tile.industry.growth = 0

				#partial switch tile.industry.type {
				case .Wheat:
					game.wheat_count += tile.industry.produced
				case .Cow:
					game.milk_count += tile.industry.produced
				case .Chicken:
					game.egg_count += tile.industry.produced
				}
			}
		}
	}

	if game.dropdown.show {

		if game.dropdown_just_opened {
			game.dropdown_just_opened = false
		} else {
		for &button in game.dropdown.buttons {
			if rl.CheckCollisionPointRec(mousepoint, button.rec) &&
			   button.state != .Disabled {
				if rl.IsMouseButtonPressed(.LEFT) {
					change_tile_industry(game.dropdown.tile_id, button.type)
					hide_dropdown()
				}
			}
		}

		if rl.IsMouseButtonPressed(.LEFT) {
			if !rl.CheckCollisionPointRec(mousepoint, game.dropdown.rec) {
				hide_dropdown()
				}
			}
		}
	}
}


draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.Color({70, 130, 50, 255}))
	rl.DrawRectangle(0, 0, 720, 115, rl.BROWN)
	rl.DrawRectangleRec(game.wheat_button.rec, rl.DARKBROWN)
	//rl.DrawText("Sell Wheat", 160, 5, 20, rl.BLACK)
	rl.DrawRectangleRec(game.egg_button.rec, rl.DARKBROWN)
	//rl.DrawText("Sell Eggs", 160, 35, 20, rl.BLACK)
	rl.DrawRectangleRec(game.milk_button.rec, rl.DARKBROWN)
	//rl.DrawText("Sell Milk", 160, 65, 20, rl.BLACK)

	for tile in game.tile_arr {
		rl.DrawTexturePro(
			game.spritesheet,
			tile.industry.src,
			tile.rec,
			{0, 0},
			0,
			tile.tint,
		)
	}

	if game.dropdown.show {
		rl.DrawRectangleRec(game.dropdown.rec, rl.RAYWHITE)

		for button in game.dropdown.buttons {
			rl.DrawRectangleRec(button.rec, button.tint)
			rl.DrawText(
				button.text,
				cast(i32)button.rec.x,
				cast(i32)button.rec.y,
				20,
				button.text_color,
			)
		}
	}

	rl.DrawText(
		rl.TextFormat("Wheat: %d", game.wheat_count),
		10,
		5,
		20,
		rl.BLACK,
	)
	rl.DrawText(
		rl.TextFormat("Eggs: %d", game.egg_count),
		10,
		40,
		20,
		rl.BLACK,
	)
	rl.DrawText(
		rl.TextFormat("Milk: %d", game.milk_count),
		10,
		75,
		20,
		rl.BLACK,
	)

	rl.DrawText(rl.TextFormat("Money: %d", game.money), 600, 10, 20, rl.BLACK)
	rl.EndDrawing()
}

@(export)
game_update :: proc() {
	update()
	draw()
}

@(export)
game_init :: proc() {
	// Button_Sound = rl.LoadSound() // Button Sound
	// Button_Texture = rl.LoadTexture() // Button Texture
	game.wheat_button.rec = {150, 5, 32, 32}
	game.wheat_button.tint = rl.BROWN
	game.egg_button.rec = {150, 40, 32, 32}
	game.egg_button.tint = rl.BROWN
	game.milk_button.rec = {150, 75, 32, 32}
	game.milk_button.tint = rl.BROWN

	game.ind_arr = [5]Industry {
		{.Unclaimed, {0, 0, 144, 144}, 0, 0, 0, 0, 0},
		{.Empty, {144, 0, 144, 144}, 0, 0, 0, 0, 0},
		{.Wheat, {288, 0, 144, 144}, 1, 20, 0, 1, 5},
		{.Cow, {0, 144, 144, 144}, 1, 40, 0, 1, 15},
		{.Chicken, {144, 144, 144, 144}, 1, 30, 0, 3, 10},
	}

	game.money = 5
	game.dropdown.show = false
	game.dropdown.rec = {0, 0, 150, 255}
	game.dropdown.buttons = {
		{{0, 0, 0, 0}, .Normal, rl.LIGHTGRAY, rl.BLACK, .Wheat, "Wheat 5"},
		{{0, 0, 0, 0}, .Normal, rl.LIGHTGRAY, rl.BLACK, .Chicken, "Chicken 10"},
		{{0, 0, 0, 0}, .Normal, rl.LIGHTGRAY, rl.BLACK, .Cow, "Cow 15"},
		{{0, 0, 0, 0}, .Normal, rl.LIGHTGRAY, rl.BLACK, .Empty, "Empty"},
		{
			{0, 0, 0, 0},
			.Normal,
			rl.LIGHTGRAY,
			rl.BLACK,
			.Unclaimed,
			"Unclaimed",
		},
	}

	init_tile_arr(&game.tile_arr)
	game.spritesheet = rl.LoadTexture("assets\\farm_spritesheet.png")
}

@(export)
game_init_window :: proc() {
	rl.InitWindow(720, 720, "Farm Game")
	rl.InitAudioDevice() // Initialize Audio Device
}

@(export)
game_should_run :: proc() -> bool {
	return !rl.WindowShouldClose()
}

@(export)
game_shutdown :: proc() {
	defer rl.UnloadTexture(game.spritesheet)
}

@(export)
game_shutdown_window :: proc() {
	rl.CloseAudioDevice()
	rl.CloseWindow()
}

@(export)
// for i := 0; i < len(game.dropdown.buttons); i += 1 {
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

text_color: rl.Color
change_tile_industry :: proc(i: int, ind_type: Industry_Type) {
	game.money -= game.ind_arr[ind_type].cost
	game.tile_arr[i].industry = game.ind_arr[ind_type]
}

show_dropdown :: proc(point: rl.Vector2, tile_id: int) {
	game.dropdown.show = true
	game.dropdown_just_opened = true
	game.dropdown.tile_id = tile_id
	game.dropdown.rec.x = point.x
	game.dropdown.rec.y = point.y

	if game.dropdown.rec.x + game.dropdown.rec.width > 720 {
		game.dropdown.rec.x = 720 - game.dropdown.rec.width
	}

	if game.dropdown.rec.y + game.dropdown.rec.height > 720 {
		game.dropdown.rec.y = 720 - game.dropdown.rec.height
	}

	for i := 0; i < len(game.dropdown.buttons); i += 1 {
		game.dropdown.buttons[i].rec = {
			game.dropdown.rec.x + 5,
			game.dropdown.rec.y + (50 * cast(f32)i) + 5,
			game.dropdown.rec.width - 10,
			45,
		}
		if game.money >= game.ind_arr[game.dropdown.buttons[i].type].cost {
			game.dropdown.buttons[i].state = .Normal
			game.dropdown.buttons[i].text_color = rl.BLACK
		} else {
			game.dropdown.buttons[i].state = .Disabled
			game.dropdown.buttons[i].text_color = rl.GRAY
		}
	}
}

hide_dropdown :: proc() {
	game.dropdown.show = false
}
