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
	id:     int,
	show:   bool,
	rec:    rl.Rectangle,
	button: Dropdown_Button,
}

update_production :: proc(
	production: ^Production,
	mousepoint: rl.Vector2,
	fs: ^Frame_State,
) {
	if !production.show {
		return
	}

	if rl.CheckCollisionPointRec(mousepoint, production.rec) {
		fs.mouse_over_production = true
		fs.production = production

		if rl.CheckCollisionPointRec(mousepoint, production.button.rec) {
			fs.mouse_over_production_button = true
			fs.production_button = &production.button
		}
	}
}

draw_bakery_production :: proc() {
	rl.DrawRectangleRec(game.bakery_dropdown.rec, rl.LIGHTGRAY)
	line_end_pos: rl.Vector2 = {
		game.bakery_dropdown.rec.x + game.bakery_dropdown.rec.width - 19 - 5,
		game.bakery_dropdown.rec.y + (150 / 2) + 3,
	}

	rl.DrawLineV(
		{
			game.bakery_dropdown.rec.x + 5 + 13,
			game.bakery_dropdown.rec.y + 5 + 21,
		},
		line_end_pos,
		rl.BLACK,
	)
	rl.DrawLineV(
		{
			game.bakery_dropdown.rec.x + 7 + 11,
			game.bakery_dropdown.rec.y + 10 + 42 + 26,
		},
		line_end_pos,
		rl.BLACK,
	)
	rl.DrawLineV(
		{
			game.bakery_dropdown.rec.x + 4 + 17,
			game.bakery_dropdown.rec.y + 15 + 99 + 16,
		},
		line_end_pos,
		rl.BLACK,
	)

	rl.DrawTexturePro(
		game.spritesheet,
		game.flour_img_src_rec,
		{
			game.bakery_dropdown.rec.x + 5,
			game.bakery_dropdown.rec.y + 5,
			26,
			42,
		},
		{0, 0},
		0,
		rl.WHITE,
	)
	rl.DrawTexturePro(
		game.spritesheet,
		game.milk_img_src_rec,
		{
			game.bakery_dropdown.rec.x + 7,
			game.bakery_dropdown.rec.y + 10 + 42,
			22,
			52,
		},
		{0, 0},
		0,
		rl.WHITE,
	)
	rl.DrawTexturePro(
		game.spritesheet,
		game.eggs_img_src_rec,
		{
			game.bakery_dropdown.rec.x + 4,
			game.bakery_dropdown.rec.y + 15 + 99,
			34,
			32,
		},
		{0, 0},
		0,
		rl.WHITE,
	)
	rl.DrawTexturePro(
		game.spritesheet,
		game.cake_img_src_rec,
		{
			game.bakery_dropdown.rec.x +
			game.bakery_dropdown.rec.width -
			38 -
			5,
			game.bakery_dropdown.rec.y + (150 / 2) - 18,
			38,
			36,
		},
		{0, 0},
		0,
		rl.WHITE,
	)
	rl.DrawTexturePro(
		game.spritesheet,
		game.bakery_dropdown.button.img_src_rec,
		game.bakery_dropdown.button.rec,
		{0, 0},
		0,
		rl.WHITE,
	)
}

draw_mill_production :: proc() {
	rl.DrawRectangleRec(game.mill_dropdown.rec, rl.LIGHTGRAY)
	rl.DrawLineV(
		{game.mill_dropdown.rec.x + 17, game.mill_dropdown.rec.y + 24},
		{
			game.mill_dropdown.rec.x + game.mill_dropdown.rec.width - 26,
			game.mill_dropdown.rec.y + 24,
		},
		rl.DARKGRAY,
	)
	rl.DrawTexturePro(
		game.spritesheet,
		game.wheat_img_src_rec,
		{game.mill_dropdown.rec.x + 5, game.mill_dropdown.rec.y + 5, 34, 44},
		{0, 0},
		0,
		rl.WHITE,
	)
	rl.DrawTexturePro(
		game.spritesheet,
		game.flour_img_src_rec,
		{
			game.mill_dropdown.rec.x + game.mill_dropdown.rec.width - 26 - 5,
			game.mill_dropdown.rec.y + 5,
			26,
			42,
		},
		{0, 0},
		0,
		rl.WHITE,
	)
	rl.DrawTexturePro(
		game.spritesheet,
		game.mill_dropdown.button.img_src_rec,
		game.mill_dropdown.button.rec,
		{0, 0},
		0,
		rl.WHITE,
	)
}

init_production :: proc(
	dropdown: ^Production,
	id: int,
	rec: rl.Rectangle,
	button: Dropdown_Button,
) {
	dropdown.rec = rec
	dropdown.button = button
}

Game :: struct {
	wheat_count:       u32,
	milk_count:        u32,
	egg_count:         u32,
	flour_count:       u32,
	cake_count:        u32,
	spritesheet:       rl.Texture,
	tile_arr:          [TILE_ARR_COUNT]Tile,
	ind_arr:           [IND_ARR_COUNT]Industry,
	dropdown:          Dropdown,
	money:             u32,
	button_arr:        [BUTTON_ARR_COUNT]Button,
	mill_dropdown:     Production,
	bakery_dropdown:   Production,
	dropdown_open:     bool,
	collect_sound:     rl.Sound,
	wheat_img_src_rec: rl.Rectangle,
	flour_img_src_rec: rl.Rectangle,
	eggs_img_src_rec:  rl.Rectangle,
	milk_img_src_rec:  rl.Rectangle,
	cake_img_src_rec:  rl.Rectangle,
}

Button_State :: enum {
	Normal,
	Hovered,
	Clicked,
	Disabled,
}

Button :: struct {
	id:    Button_ID,
	rec:   rl.Rectangle,
	src:   rl.Rectangle,
	state: Button_State,
	tint:  rl.Color,
}

Frame_State :: struct {
	mouse_over_tile:              bool,
	tile:                         ^Tile,
	mouse_over_button:            bool,
	button:                       ^Button,
	mouse_over_dropdown:          bool,
	dropdown:                     ^Dropdown,
	mouse_over_dropdown_button:   bool,
	dropdown_button:              ^Dropdown_Button,
	mouse_over_production:        bool,
	production:                   ^Production,
	mouse_over_production_button: bool,
	production_button:            ^Dropdown_Button,
}

game: Game

update :: proc() {
	fs: Frame_State

	mousepoint := rl.GetMousePosition()

	for i in 0 ..< BUTTON_ARR_COUNT {
		if rl.CheckCollisionPointRec(mousepoint, game.button_arr[i].rec) {
			fs.mouse_over_button = true
			fs.button = &game.button_arr[i]
		}
	}

	update_tiles(&game.tile_arr, mousepoint, &fs)

	update_dropdown(&game.dropdown, mousepoint, &fs)
	update_production(&game.mill_dropdown, mousepoint, &fs)
	update_production(&game.bakery_dropdown, mousepoint, &fs)

	// Handle Input
	if rl.IsMouseButtonPressed(.LEFT) {
		if game.dropdown_open {
			if fs.mouse_over_production {
				if fs.mouse_over_production_button {
					toggle_industry(fs.production_button.type)
				}
			} else if fs.mouse_over_dropdown {
				if fs.mouse_over_dropdown_button {
					change_industry(
						game.dropdown.tile_id,
						fs.dropdown_button.type,
					)
					hide_dropdown()
				}
			} else {
				hide_dropdown()
				game.dropdown.show = false
				game.mill_dropdown.show = false
				game.bakery_dropdown.show = false
				game.dropdown_open = false
			}

			return
		}

		if fs.mouse_over_tile {
			switch fs.tile.industry.type {
			case .Mill:
				show_mill_production(mousepoint)
			case .Bakery:
				show_bakery_production(mousepoint)
			case .Unclaimed,
			     .Empty,
			     .Wheat,
			     .Cow,
			     .Chicken,
			     .Farmhouse,
			     .Storehouse,
			     .ForSale:
				show_dropdown(mousepoint, fs.tile.id)
			}
		}

		if fs.mouse_over_button {
			sell_amount: u32 = 1
			sell_all := false
			if rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.RIGHT_CONTROL) {
				sell_all = true
			} else if rl.IsKeyDown(.LEFT_SHIFT) || rl.IsKeyDown(.RIGHT_SHIFT) {
				sell_amount = 10
			}

			switch Button_ID(fs.button.id) {

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

	if game.mill_dropdown.show {
		draw_mill_production()
	}

	if game.bakery_dropdown.show {
		draw_bakery_production()
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
	game.collect_sound = rl.LoadSound("assets\\collect.wav")

	game.wheat_img_src_rec = get_sprite_rec_by_name("Wheat_Icon")
	game.flour_img_src_rec = get_sprite_rec_by_name("Flour_Icon")
	game.eggs_img_src_rec = get_sprite_rec_by_name("Eggs_Icon")
	game.milk_img_src_rec = get_sprite_rec_by_name("Milk_Icon")
	game.cake_img_src_rec = get_sprite_rec_by_name("Cake_Icon")

	game.bakery_dropdown.show = false
	game.mill_dropdown.show = false

	// img_arr: [10]rl.Rectangle = {
	// 	get_sprite_rec_by_name("WheatImg"),
	// 	get_sprite_rec_by_name("WheatImg_Clicked"),
	// 	get_sprite_rec_by_name("MilkImg"),
	// 	get_sprite_rec_by_name("MilkImg_Clicked"),
	// 	get_sprite_rec_by_name("EggsImg"),
	// 	get_sprite_rec_by_name("EggsImg_Clicked"),
	// 	get_sprite_rec_by_name("FlourImg"),
	// 	get_sprite_rec_by_name("FlourImg_Clicked"),
	// 	get_sprite_rec_by_name("CakeImg"),
	// 	get_sprite_rec_by_name("CakeImg_Clicked"),
	// }

	positions := get_ui_button_initial_positions()

	game.button_arr[Button_ID.Sell_Wheat] = {
		id   = .Sell_Wheat,
		rec  = positions[Button_ID.Sell_Wheat],
		src  = get_sprite_rec_by_name("SellWheat"),
		tint = rl.WHITE,
	}

	game.button_arr[Button_ID.Sell_Eggs] = {
		id   = .Sell_Eggs,
		rec  = positions[Button_ID.Sell_Eggs],
		src  = get_sprite_rec_by_name("SellEggs"),
		tint = rl.WHITE,
	}

	game.button_arr[Button_ID.Sell_Milk] = {
		id   = .Sell_Milk,
		rec  = positions[Button_ID.Sell_Milk],
		src  = get_sprite_rec_by_name("SellMilk"),
		tint = rl.WHITE,
	}

	game.button_arr[Button_ID.Sell_Flour] = {
		id   = .Sell_Flour,
		rec  = positions[Button_ID.Sell_Flour],
		src  = get_sprite_rec_by_name("SellFlour"),
		tint = rl.WHITE,
	}

	game.button_arr[Button_ID.Sell_Cake] = {
		id   = .Sell_Cake,
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

	wheat_icon_rec := get_sprite_rec_by_name("Wheat_Icon")
	eggs_icon_rec := get_sprite_rec_by_name("Eggs_Icon")
	milk_icon_rec := get_sprite_rec_by_name("Milk_Icon")

	dropdown_btns: [4]Dropdown_Button = {
		{
			{0, 0, 0, 0},
			.Normal,
			rl.LIGHTGRAY,
			rl.BLACK,
			.Wheat,
			"Wheat 5",
			wheat_icon_rec,
			{0, 0, wheat_icon_rec.width, wheat_icon_rec.height},
		},
		{
			{0, 0, 0, 0},
			.Normal,
			rl.LIGHTGRAY,
			rl.BLACK,
			.Chicken,
			"Chicken 10",
			eggs_icon_rec,
			{0, 0, eggs_icon_rec.width, eggs_icon_rec.height},
		},
		{
			{0, 0, 0, 0},
			.Normal,
			rl.LIGHTGRAY,
			rl.BLACK,
			.Cow,
			"Cow 15",
			milk_icon_rec,
			{0, 0, milk_icon_rec.width, milk_icon_rec.height},
		},
		{
			{0, 0, 0, 0},
			.Normal,
			rl.LIGHTGRAY,
			rl.BLACK,
			.Empty,
			"Empty",
			{0, 0, 0, 0},
			{0, 0, 0, 0},
		},
	}

	mill_dropdown_button: Dropdown_Button = {
		{0, 0, 64, 64},
		.Normal,
		rl.LIGHTGRAY,
		rl.BLACK,
		.Mill,
		"Mill Flour",
		get_sprite_rec_by_name("FlourImg"),
		{0, 0, 32, 32},
	}

	bakery_dropdown_button: Dropdown_Button = {
		{0, 0, 64, 64},
		.Normal,
		rl.LIGHTGRAY,
		rl.BLACK,
		.Bakery,
		"Bake Cake",
		get_sprite_rec_by_name("CakeImg"),
		{0, 0, 32, 32},
	}

	init_dropdown(&game.dropdown, {0, 0, 150, 205}, dropdown_btns)

	init_production(
		&game.mill_dropdown,
		0,
		{0, 0, 150, 125},
		mill_dropdown_button,
	)

	init_production(
		&game.bakery_dropdown,
		1,
		{0, 0, 150, 220},
		bakery_dropdown_button,
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
	rl.UnloadTexture(game.spritesheet)
	rl.UnloadSound(game.collect_sound)
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
	game.dropdown_open = true
	game.mill_dropdown.show = true
	game.mill_dropdown.rec.x = point.x
	game.mill_dropdown.rec.y = point.y
	game.mill_dropdown.button.rec.x =
		point.x +
		(game.mill_dropdown.rec.width / 2) -
		(game.mill_dropdown.button.rec.width / 2)
	game.mill_dropdown.button.rec.y =
		point.y +
		game.mill_dropdown.rec.height -
		game.mill_dropdown.button.rec.height -
		5
}

show_bakery_production :: proc(point: rl.Vector2) {
	game.dropdown_open = true
	game.bakery_dropdown.show = true
	game.bakery_dropdown.rec.x = point.x
	game.bakery_dropdown.rec.y = point.y
	game.bakery_dropdown.button.rec.x =
		point.x +
		(game.bakery_dropdown.rec.width / 2) -
		(game.bakery_dropdown.button.rec.width / 2)
	game.bakery_dropdown.button.rec.y =
		point.y +
		game.bakery_dropdown.rec.height -
		game.bakery_dropdown.button.rec.height -
		5
}

show_dropdown :: proc(point: rl.Vector2, tile_id: int) {
	game.dropdown_open = true
	game.dropdown.show = true
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
		game.dropdown.buttons[i].img_dst_rec.x =
			game.dropdown.buttons[i].rec.x +
			game.dropdown.buttons[i].rec.width -
			game.dropdown.buttons[i].img_src_rec.width -
			5
		game.dropdown.buttons[i].img_dst_rec.y =
			game.dropdown.buttons[i].rec.y +
			(game.dropdown.buttons[i].rec.height / 2) -
			(game.dropdown.buttons[i].img_src_rec.height / 2)
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
	game.dropdown_open = false
}

change_industry :: proc(i: int, ind_type: Industry_Type) {
	game.money -= game.ind_arr[ind_type].cost

	change_tile_industry(&game.tile_arr[i], game.ind_arr[ind_type])
}

toggle_industry :: proc(type: Industry_Type) {
	#partial switch type {
	case .Mill:
		game.tile_arr[4].show_progress_bar =
		!game.tile_arr[4].show_progress_bar
		if game.tile_arr[4].show_progress_bar {
			start_production(&game.tile_arr[4])
		} else {
			stop_production(&game.tile_arr[4])
		}
	case .Bakery:
		game.tile_arr[6].show_progress_bar =
		!game.tile_arr[6].show_progress_bar
		if game.tile_arr[6].show_progress_bar {
			start_production(&game.tile_arr[6])
		} else {
			stop_production(&game.tile_arr[6])
		}
	}
}
