package game

import rl "vendor:raylib"

STARTING_MONEY :: 10
IND_ARR_COUNT :: 10
BUTTON_ARR_COUNT :: 5
MILL_TILE_ID :: 4
BAKERY_TILE_ID :: 6

Button_ID :: enum int {
	Sell_Wheat,
	Sell_Eggs,
	Sell_Milk,
	Sell_Flour,
	Sell_Cake,
}

Production :: struct {
	show:    bool,
	rec:     rl.Rectangle,
	buttons: [2]Dropdown_Button,
}

update_production :: proc(
	production: ^Production,
	mousepoint : rl.Vector2,
) {
	if !production.show {
		return
	}

	if rl.IsMouseButtonPressed(.LEFT) {
		if !rl.CheckCollisionPointRec(
			mousepoint,
			production.rec,
		) {
			production.show = false
		}
	}
}

draw_production :: proc(
	production: ^Production,
) {
	if !production.show {
		return
	}
	rl.DrawRectangleRec(
		production.rec,
		rl.LIGHTGRAY,
	)
	for _ in production.buttons {

	}
}

init_production :: proc(
	dropdown: ^Production,
	rec: rl.Rectangle,
	buttons: [2]Dropdown_Button,
) {
	dropdown.rec = rec
	dropdown.buttons = buttons
}

Game :: struct {
	wheat_count:          u32,
	milk_count:           u32,
	egg_count:            u32,
	flour_count:          u32,
	cake_count:           u32,
	spritesheet:          rl.Texture,
	tile_arr:             [TILE_ARR_COUNT]Tile,
	ind_arr:              [IND_ARR_COUNT]Industry,
	dropdown:             Dropdown,
	money:                u32,
	dropdown_just_opened: bool,
	button_arr:           [BUTTON_ARR_COUNT]Button,
	mill_dropdown:        Production,
	bakery_dropdown:      Production,
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

		sell_amount: u32 = 1
		sell_all := false
		if rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.RIGHT_CONTROL) {
			sell_all = true
		} else if rl.IsKeyDown(.LEFT_SHIFT) || rl.IsKeyDown(.RIGHT_SHIFT) {
			sell_amount = 10
		}

		for i in 0 ..< BUTTON_ARR_COUNT {

			if !rl.CheckCollisionPointRec(mousepoint, game.button_arr[i].rec) {
				continue
			}

			switch Button_ID(i) {

			case .Sell_Wheat:
				amount := min(game.wheat_count, sell_amount)

				if sell_all {
					amount = game.wheat_count
				}

				if amount > 0 {
					game.wheat_count -= amount
					game.money += amount * 2
				}
			case .Sell_Eggs:
				amount := min(game.egg_count, sell_amount)

				if sell_all {
					amount = game.egg_count
				}

				if amount > 0 {
					game.egg_count -= amount
					game.money += amount * 1
				}
			case .Sell_Milk:
				amount := min(game.milk_count, sell_amount)

				if sell_all {
					amount = game.milk_count
				}

				if amount > 0 {
					game.milk_count -= amount
					game.money += amount * 3
				}
			case .Sell_Flour:
				amount := min(game.flour_count, sell_amount)

				if sell_all {
					amount = game.flour_count
				}

				if amount > 0 {
					game.flour_count -= amount
					game.money += amount * 4
				}
			case .Sell_Cake:
				amount := min(game.cake_count, sell_amount)

				if sell_all {
					amount = game.cake_count
				}

				if amount > 0 {
					game.cake_count -= amount
					game.money += amount * 35
				}
			}
		}
	}

	if rl.IsMouseButtonPressed(.LEFT) {
		if rl.CheckCollisionPointRec(
			mousepoint,
			game.tile_arr[MILL_TILE_ID].rec,
		) {
			show_mill_production(mousepoint)
		}

		if rl.CheckCollisionPointRec(
			mousepoint,
			game.tile_arr[BAKERY_TILE_ID].rec,
		) {
			show_bakery_production(mousepoint)
		}

	}
	update_tiles(&game.tile_arr, mousepoint)

	update_dropdown(&game.dropdown, mousepoint)
	update_production(&game.mill_dropdown, mousepoint)
	update_production(&game.bakery_dropdown, mousepoint)
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.Color({70, 130, 50, 255}))
	rl.DrawRectangle(0, 0, 720, 115, rl.BROWN)

	for button in game.button_arr {
		rl.DrawTexturePro(
			game.spritesheet,
			button.src,
			button.rec,
			{0, 0},
			0,
			button.tint,
		)
	}

	draw_tiles(&game.tile_arr)

	draw_dropdown(&game.dropdown)
	draw_production(&game.mill_dropdown)
	draw_production(&game.bakery_dropdown)

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
	rl.DrawText(
		rl.TextFormat("Flour: %d", game.flour_count),
		175,
		5,
		20,
		rl.BLACK,
	)
	rl.DrawText(
		rl.TextFormat("Cake: %d", game.cake_count),
		175,
		40,
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

get_ui_button_initial_positions :: proc() -> [BUTTON_ARR_COUNT]rl.Rectangle {
	return [BUTTON_ARR_COUNT]rl.Rectangle {
		{125, 5, 32, 32}, //Wheat
		{125, 40, 32, 32}, //Eggs
		{125, 75, 32, 32}, //Milk
		{275, 5, 32, 32}, //Flour
		{275, 40, 32, 32}, //Cake
	}
}
@(export)
game_init :: proc() {
	// Button_Sound = rl.LoadSound() // Button Sound
	// Button_Texture = rl.LoadTexture() // Button Texture

	mill_dropdown_buttons: [2]Dropdown_Button = {
		{{0, 0, 0, 0}, .Normal, rl.LIGHTGRAY, rl.BLACK, .Empty, "Mill Flour"},
		{
			{0, 0, 0, 0},
			.Normal,
			rl.LIGHTGRAY,
			rl.BLACK,
			.Empty,
			"Mill 10 Flour",
		},
	}

	bakery_dropdown_buttons: [2]Dropdown_Button = {
		{{0, 0, 0, 0}, .Normal, rl.LIGHTGRAY, rl.BLACK, .Empty, "Bake Cake"},
		{
			{0, 0, 0, 0},
			.Normal,
			rl.LIGHTGRAY,
			rl.BLACK,
			.Empty,
			"Bake 10 Cakes",
		},
	}
	positions := get_ui_button_initial_positions()

	game.button_arr[Button_ID.Sell_Wheat] = {
		rec  = positions[Button_ID.Sell_Wheat],
		src  = get_sprite_rec_by_name("SellWheat"),
		tint = rl.WHITE,
	}

	game.button_arr[Button_ID.Sell_Eggs] = {
		rec  = positions[Button_ID.Sell_Eggs],
		src  = get_sprite_rec_by_name("SellEggs"),
		tint = rl.WHITE,
	}

	game.button_arr[Button_ID.Sell_Milk] = {
		rec  = positions[Button_ID.Sell_Milk],
		src  = get_sprite_rec_by_name("SellMilk"),
		tint = rl.WHITE,
	}

	game.button_arr[Button_ID.Sell_Flour] = {
		rec  = positions[Button_ID.Sell_Flour],
		src  = get_sprite_rec_by_name("SellFlour"),
		tint = rl.WHITE,
	}

	game.button_arr[Button_ID.Sell_Cake] = {
		rec  = positions[Button_ID.Sell_Cake],
		src  = get_sprite_rec_by_name("SellCake"),
		tint = rl.WHITE,
	}

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

	init_production(
		&game.mill_dropdown,
		{0, 0, 150, 105},
		mill_dropdown_buttons,
	)
	init_production(
		&game.bakery_dropdown,
		{0, 0, 150, 105},
		bakery_dropdown_buttons,
	)

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

show_mill_production :: proc(point: rl.Vector2) {
	game.mill_dropdown.show = true
	game.mill_dropdown.rec.x = point.x
	game.mill_dropdown.rec.y = point.y
}

show_bakery_production :: proc(point: rl.Vector2) {
	game.bakery_dropdown.show = true
	game.bakery_dropdown.rec.x = point.x
	game.bakery_dropdown.rec.y = point.y
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
