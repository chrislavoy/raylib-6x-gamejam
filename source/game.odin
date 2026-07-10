package game

import rl "vendor:raylib"

STARTING_MONEY :: 10
IND_ARR_COUNT :: 10

Game :: struct {
	wheat_count:          u32,
	milk_count:           u32,
	egg_count:            u32,
	wheat_button:         Button,
	milk_button:          Button,
	egg_button:           Button,
	spritesheet:          rl.Texture,
	tile_arr:             [TILE_ARR_COUNT]Tile,
	ind_arr:              [IND_ARR_COUNT]Industry,
	dropdown:             Dropwdown,
	money:                u32,
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
	src:   rl.Rectangle,
	state: Button_State,
	tint:  rl.Color,
}

game: Game

update :: proc() {
	mousepoint := rl.GetMousePosition()

	if rl.IsMouseButtonPressed(.LEFT) {
		if rl.CheckCollisionPointRec(mousepoint, game.wheat_button.rec) &&
		   game.wheat_count > 0 {
			game.wheat_count -= 1
			game.money += 2
		}
		if rl.CheckCollisionPointRec(mousepoint, game.milk_button.rec) &&
		   game.milk_count > 0 {
			game.milk_count -= 1
			game.money += 3
		}
		if rl.CheckCollisionPointRec(mousepoint, game.egg_button.rec) &&
		   game.egg_count > 0 {
			game.egg_count -= 1
			game.money += 1
		}
	}

	update_tiles(&game.tile_arr, mousepoint)

	update_dropdown(&game.dropdown, mousepoint)
}


draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.Color({70, 130, 50, 255}))
	rl.DrawRectangle(0, 0, 720, 115, rl.BROWN)
	// rl.DrawRectangleRec(game.wheat_button.rec, rl.DARKBROWN)
	rl.DrawTexturePro(
		game.spritesheet,
		game.wheat_button.src,
		game.wheat_button.rec,
		{0, 0},
		0,
		game.wheat_button.tint,
	)
	//rl.DrawText("Sell Wheat", 160, 5, 20, rl.BLACK)
	// rl.DrawRectangleRec(game.egg_button.rec, rl.DARKBROWN)
	rl.DrawTexturePro(
		game.spritesheet,
		game.egg_button.src,
		game.egg_button.rec,
		{0, 0},
		0,
		game.egg_button.tint,
	)
	//rl.DrawText("Sell Eggs", 160, 35, 20, rl.BLACK)
	// rl.DrawRectangleRec(game.milk_button.rec, rl.DARKBROWN)
	rl.DrawTexturePro(
		game.spritesheet,
		game.milk_button.src,
		game.milk_button.rec,
		{0, 0},
		0,
		game.milk_button.tint,
	)
	//rl.DrawText("Sell Milk", 160, 65, 20, rl.BLACK)

	draw_tiles(&game.tile_arr)

	draw_dropdown(&game.dropdown)

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
	game.wheat_button.src = get_sprite_rec_by_name("SellWheat")
	game.wheat_button.tint = rl.WHITE
	game.egg_button.rec = {150, 40, 32, 32}
	game.egg_button.src = get_sprite_rec_by_name("SellEggs")
	game.egg_button.tint = rl.WHITE
	game.milk_button.rec = {150, 75, 32, 32}
	game.milk_button.src = get_sprite_rec_by_name("SellMilk")
	game.milk_button.tint = rl.WHITE

	for i := 0; i < len(game.tile_arr); i += 1 {
		game.tile_arr[i].id = i
		game.tile_arr[i].selectable = true
		game.tile_arr[0].selectable = false
		game.tile_arr[1].selectable = false
		game.tile_arr[2].selectable = false
		game.tile_arr[3].selectable = false
		game.tile_arr[5].selectable = false
		game.tile_arr[7].selectable = false
		game.tile_arr[8].selectable = false
	}

	game.ind_arr = [IND_ARR_COUNT]Industry {
		{.Unclaimed, get_sprite_rec_by_name("Unclaimed"), 0, 0, 0, 0, 0},
		{.Empty, get_sprite_rec_by_name("Empty"), 0, 0, 0, 0, 0},
		{.Wheat, get_sprite_rec_by_name("Wheat"), 1, 20, 0, 1, 5},
		{.Cow, get_sprite_rec_by_name("Cows"), 1, 40, 0, 1, 15},
		{.Chicken, get_sprite_rec_by_name("Chickens"), 1, 30, 0, 3, 10},
		{.Farmhouse, get_sprite_rec_by_name("Farmhouse"), 0, 0, 0, 0, 0},
		{.Mill, get_sprite_rec_by_name("Mill"), 1, 45, 0, 1, 100},
		{.Bakery, get_sprite_rec_by_name("Bakery"), 1, 60, 0, 1, 500},
		{.Storehouse, get_sprite_rec_by_name("Storehouse"), 0, 0, 0, 0, 250},
		{.ForSale, get_sprite_rec_by_name("ForSale"), 0, 0, 0, 0, 50},
	}

	game.money = STARTING_MONEY

	dropdown_btns: [4]Dropdown_Button = {
		{{0, 0, 0, 0}, .Normal, rl.LIGHTGRAY, rl.BLACK, .Wheat, "Wheat 5"},
		{
			{0, 0, 0, 0},
			.Normal,
			rl.LIGHTGRAY,
			rl.BLACK,
			.Chicken,
			"Chicken 10",
		},
		{{0, 0, 0, 0}, .Normal, rl.LIGHTGRAY, rl.BLACK, .Cow, "Cow 15"},
		{{0, 0, 0, 0}, .Normal, rl.LIGHTGRAY, rl.BLACK, .Empty, "Empty"},
	}
	init_dropdown(&game.dropdown, {0, 0, 150, 205}, dropdown_btns)

	init_tiles(&game.tile_arr)
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

change_industry :: proc(i: int, ind_type: Industry_Type) {
	game.money -= game.ind_arr[ind_type].cost

	change_tile_industry(&game.tile_arr[i], game.ind_arr[ind_type])
}
