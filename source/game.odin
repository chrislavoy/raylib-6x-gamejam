package game

import "core:strings"
import rl "vendor:raylib"

STARTING_MONEY :: 10
IND_ARR_COUNT :: 12
BUTTON_ARR_COUNT :: 5
MILL_TILE_ID :: 4
BAKERY_TILE_ID :: 6

PLOT_COST_INCREASE :: 5

WHEAT_VALUE :: 2
FLOUR_VALUE :: 4
EGGS_VALUE :: 2
CAKE_VALUE :: 15
MILK_VALUE :: 5

Game :: struct {
	wheat_count:         u32,
	milk_count:          u32,
	egg_count:           u32,
	flour_count:         u32,
	cake_count:          u32,
	spritesheet:         rl.Texture,
	tile_arr:            [TILE_ARR_COUNT]Tile,
	ind_arr:             [IND_ARR_COUNT]Industry,
	dropdown:            Dropdown,
	money:               u32,
	button_arr:          [BUTTON_ARR_COUNT]Button,
	mill_dropdown:       Production,
	bakery_dropdown:     Production,
	purchase_dropdown:   Production,
	dropdown_open:       bool,
	collect_sound:       rl.Sound,
	place_wheat_sound:   rl.Sound,
	place_chicken_sound: rl.Sound,
	place_cow_sound:     rl.Sound,
	place_empty_sound:   rl.Sound,
	sell_sound:          rl.Sound,
	button_click:        rl.Sound,
	cake_sound:          rl.Sound,
	flour_sound:         rl.Sound,
	wheat_img_src_rec:   rl.Rectangle,
	flour_img_src_rec:   rl.Rectangle,
	eggs_img_src_rec:    rl.Rectangle,
	milk_img_src_rec:    rl.Rectangle,
	cake_img_src_rec:    rl.Rectangle,
	music:               rl.Music,
	run:                 bool,
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
	input_pos:                    rl.Vector2,
}

game: Game

update :: proc() {
	rl.UpdateMusicStream(game.music)
	fs: Frame_State

	if rl.GetTouchPointCount() > 0 {
		fs.input_pos = rl.GetTouchPosition(0)
	} else {
		fs.input_pos = rl.GetMousePosition()
	}

	update_buttons(&fs)
	update_tiles(&game.tile_arr, &fs)
	update_dropdown(&game.dropdown, &fs)
	update_production(&game.mill_dropdown, &fs)
	update_production(&game.bakery_dropdown, &fs)
	update_production(&game.purchase_dropdown, &fs)

	// Handle Input
	handle_input(&fs)
}

handle_input :: proc(fs: ^Frame_State) {
	if (rl.GetTouchPointCount() > 0 && rl.IsGestureDetected(.TAP)) ||
	   (rl.GetTouchPointCount() == 0 && rl.IsMouseButtonPressed(.LEFT)) {
		if game.dropdown_open {
			if fs.mouse_over_production {
				if fs.mouse_over_production_button {
					if fs.production.id == 2 {
						change_industry(
							fs.production.tile_id,
							fs.production.ind_to_buy,
						)
					} else {
						toggle_industry(fs.production_button.type)
					}
				}
			} else if fs.mouse_over_dropdown {
				if fs.mouse_over_dropdown_button {
					change_industry(
						game.dropdown.tile_id,
						fs.dropdown_button.type,
					)
					hide_dropdowns()
				}
			} else {
				hide_dropdowns()
			}

			return
		}

		if fs.mouse_over_tile {
			switch fs.tile.industry.type {
			case .Mill:
				show_mill_production(fs.input_pos)
			case .Bakery:
				show_bakery_production(fs.input_pos)
			case .MillForSale:
				show_purchase_production(fs.tile.id, &fs.tile.industry)
			case .BakeryForSale:
				show_purchase_production(fs.tile.id, &fs.tile.industry)
			case .ForSale:
				show_purchase_production(fs.tile.id, &fs.tile.industry)
			case .Unclaimed,
			     .Empty,
			     .Wheat,
			     .Cow,
			     .Chicken,
			     .Farmhouse,
			     .Storehouse:
				show_dropdown(fs.input_pos, fs.tile.id)
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

			fs.button.state = .Clicked

			switch Button_ID(fs.button.id) {

			case .Sell_Wheat:
				amount := min(game.wheat_count, sell_amount)

				if sell_all {
					amount = game.wheat_count
				}

				if amount > 0 {
					game.wheat_count -= amount
					game.money += amount * 2
					rl.PlaySound(game.sell_sound)
				}
			case .Sell_Eggs:
				amount := min(game.egg_count, sell_amount)

				if sell_all {
					amount = game.egg_count
				}

				if amount > 0 {
					game.egg_count -= amount
					game.money += amount * 2
					rl.PlaySound(game.sell_sound)
				}
			case .Sell_Milk:
				amount := min(game.milk_count, sell_amount)

				if sell_all {
					amount = game.milk_count
				}

				if amount > 0 {
					game.milk_count -= amount
					game.money += amount * 5
					rl.PlaySound(game.sell_sound)
				}
			case .Sell_Flour:
				amount := min(game.flour_count, sell_amount)

				if sell_all {
					amount = game.flour_count
				}

				if amount > 0 {
					game.flour_count -= amount
					game.money += amount * 4
					rl.PlaySound(game.sell_sound)
				}
			case .Sell_Cake:
				amount := min(game.cake_count, sell_amount)

				if sell_all {
					amount = game.cake_count
				}

				if amount > 0 {
					game.cake_count -= amount
					game.money += amount * 15
					rl.PlaySound(game.sell_sound)
				}
			}
		}
	}
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.Color({70, 130, 50, 255}))
	rl.DrawRectangle(0, 0, 720, 115, rl.BROWN)

	draw_buttons()

	draw_tiles(&game.tile_arr)

	draw_dropdown(&game.dropdown)

	if game.mill_dropdown.show {
		draw_mill_production()
	}

	if game.bakery_dropdown.show {
		draw_bakery_production()
	}

	if game.purchase_dropdown.show {
		draw_purchase_production()
	}

	rl.DrawText(
		rl.TextFormat("Wheat: %d", game.wheat_count),
		10,
		5,
		20,
		rl.RAYWHITE,
	)
	rl.DrawText(
		rl.TextFormat("Eggs: %d", game.egg_count),
		10,
		40,
		20,
		rl.RAYWHITE,
	)
	rl.DrawText(
		rl.TextFormat("Milk: %d", game.milk_count),
		10,
		75,
		20,
		rl.RAYWHITE,
	)
	rl.DrawText(
		rl.TextFormat("Flour: %d", game.flour_count),
		175,
		5,
		20,
		rl.RAYWHITE,
	)
	rl.DrawText(
		rl.TextFormat("Cake: %d", game.cake_count),
		175,
		40,
		20,
		rl.RAYWHITE,
	)
	rl.DrawText(rl.TextFormat("Market Value"), 390, 5, 20, rl.RAYWHITE)
	rl.DrawText(
		rl.TextFormat(
			"Wheat: %d Flour: %d\nEggs: %d Cake: %d\nMilk: %d\n",
			WHEAT_VALUE,
			FLOUR_VALUE,
			EGGS_VALUE,
			CAKE_VALUE,
			MILK_VALUE,
		),
		390,
		30,
		20,
		rl.RAYWHITE,
	)

	rl.DrawText(
		rl.TextFormat("Money: $%d", game.money),
		575,
		5,
		20,
		rl.RAYWHITE,
	)
	rl.EndDrawing()
}

@(export)
game_update :: proc() {
	update()
	draw()

	free_all(context.temp_allocator)
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
	game.run = true
	game.spritesheet = rl.LoadTexture("assets/farm_spritesheet.png")
	game.collect_sound = rl.LoadSound("assets/collect.wav")
	game.place_wheat_sound = rl.LoadSound("assets/wheat.wav")
	game.place_chicken_sound = rl.LoadSound("assets/chicken.wav")
	game.place_cow_sound = rl.LoadSound("assets/cow.wav")
	game.place_empty_sound = rl.LoadSound("assets/empty_plot.wav")
	game.sell_sound = rl.LoadSound("assets/sell.wav")
	game.button_click = rl.LoadSound("assets/button_chunk.wav")
	game.music = rl.LoadMusicStream("assets/music.mp3")
	game.cake_sound = rl.LoadSound("assets/cake.wav")
	game.flour_sound = rl.LoadSound("assets/flour.wav")

	game.wheat_img_src_rec = get_sprite_rec_by_name("Wheat_Icon")
	game.flour_img_src_rec = get_sprite_rec_by_name("Flour_Icon")
	game.eggs_img_src_rec = get_sprite_rec_by_name("Eggs_Icon")
	game.milk_img_src_rec = get_sprite_rec_by_name("Milk_Icon")
	game.cake_img_src_rec = get_sprite_rec_by_name("Cake_Icon")

	game.mill_dropdown.show = false
	game.bakery_dropdown.show = false
	game.purchase_dropdown.show = false

	init_sell_buttons()

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
		{.Unclaimed, get_sprite_rec_by_name("Unclaimed"), 0, 0, 0, 0, 0, 0},
		{.Empty, get_sprite_rec_by_name("Empty"), 0, 0, 0, 0, 0, 0},
		{.Wheat, get_sprite_rec_by_name("Wheat"), 1, 10, 0, 1, 5, 5},
		{.Cow, get_sprite_rec_by_name("Cows"), 1, 18, 0, 1, 15, 5},
		{.Chicken, get_sprite_rec_by_name("Chickens"), 1, 15, 0, 3, 10, 5},
		{.Farmhouse, get_sprite_rec_by_name("Farmhouse"), 0, 0, 0, 0, 0, 0},
		{.Mill, get_sprite_rec_by_name("Mill"), 1, 13, 0, 1, 0, 0},
		{.Bakery, get_sprite_rec_by_name("Bakery"), 1, 60, 0, 1, 0, 0},
		{
			.Storehouse,
			get_sprite_rec_by_name("Storehouse"),
			0,
			0,
			0,
			0,
			250,
			0,
		},
		{.ForSale, get_sprite_rec_by_name("ForSale"), 0, 0, 0, 0, 15, 0},
		{.MillForSale, get_sprite_rec_by_name("Mill"), 1, 20, 0, 1, 30, 0},
		{
			.BakeryForSale,
			get_sprite_rec_by_name("Bakery"),
			1,
			60,
			0,
			1,
			300,
			0,
		},
	}

	game.money = STARTING_MONEY

	dropdown_btns: [4]Dropdown_Button = {
		{
			{0, 0, 0, 0},
			.Normal,
			rl.LIGHTGRAY,
			rl.BLACK,
			.Wheat,
			"Wheat 5",
			game.wheat_img_src_rec,
			{
				0,
				0,
				game.wheat_img_src_rec.width,
				game.wheat_img_src_rec.height,
			},
		},
		{
			{0, 0, 0, 0},
			.Normal,
			rl.LIGHTGRAY,
			rl.BLACK,
			.Chicken,
			"Chicken 10",
			game.eggs_img_src_rec,
			{0, 0, game.eggs_img_src_rec.width, game.eggs_img_src_rec.height},
		},
		{
			{0, 0, 0, 0},
			.Normal,
			rl.LIGHTGRAY,
			rl.BLACK,
			.Cow,
			"Cow 15",
			game.milk_img_src_rec,
			{0, 0, game.milk_img_src_rec.width, game.milk_img_src_rec.height},
		},
		{
			{0, 0, 0, 0},
			.Normal,
			rl.LIGHTGRAY,
			rl.BLACK,
			.Empty,
			"Sell",
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

	purchase_dropdown_button: Dropdown_Button = {
		{0, 0, 64, 64},
		.Normal,
		rl.LIGHTGRAY,
		rl.BLACK,
		.ForSale,
		"Purchase",
		get_sprite_rec_by_name("Buy"),
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

	init_production(
		&game.purchase_dropdown,
		2,
		{(720 / 2) - 100, (720 / 2) - 100, 200, 200},
		purchase_dropdown_button,
	)

	init_tiles(&game.tile_arr)

	rl.PlayMusicStream(game.music)
}

@(export)
game_init_window :: proc() {
	rl.InitWindow(720, 720, "High Yield")
	rl.InitAudioDevice() // Initialize Audio Device
}

@(export)
game_should_run :: proc() -> bool {
	// if ignore_frame_count < 5 {
	// 	return true
	// } else {
	// 	return rl.WindowShouldClose()
	// }
	when ODIN_OS != .JS {
		// Never run this proc in browser. It contains a 16 ms sleep on web!
		if rl.WindowShouldClose() {
			return false
		}
	}

	return game.run
}

@(export)
game_shutdown :: proc() {
	rl.UnloadTexture(game.spritesheet)
	rl.UnloadSound(game.collect_sound)
	rl.UnloadSound(game.place_wheat_sound)
	rl.UnloadSound(game.place_chicken_sound)
	rl.UnloadSound(game.place_cow_sound)
	rl.UnloadSound(game.place_empty_sound)
	rl.UnloadSound(game.sell_sound)
	rl.UnloadSound(game.button_click)
	rl.UnloadMusicStream(game.music)
	rl.UnloadSound(game.cake_sound)
	rl.UnloadSound(game.flour_sound)
	strings.builder_destroy(&game.dropdown.sb)
	strings.builder_destroy(&game.purchase_dropdown.sb)
	strings.builder_destroy(&game.mill_dropdown.sb)
	strings.builder_destroy(&game.bakery_dropdown.sb)

	// free(game)
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

change_industry :: proc(i: int, ind_type: Industry_Type) {
	can_change := true
	prev_ind := game.tile_arr[i].industry.type

	#partial switch ind_type {
	case .Wheat:
		rl.PlaySound(game.place_wheat_sound)
		game.money -= game.ind_arr[ind_type].cost
	case .Chicken:
		rl.PlaySound(game.place_chicken_sound)
		game.money -= game.ind_arr[ind_type].cost
	case .Cow:
		rl.PlaySound(game.place_cow_sound)
		game.money -= game.ind_arr[ind_type].cost
	case .Empty:
		if prev_ind == .ForSale {
			if game.money >= game.ind_arr[prev_ind].cost {
				game.money -= game.ind_arr[prev_ind].cost
				rl.PlaySound(game.sell_sound)
				game.ind_arr[prev_ind].cost += PLOT_COST_INCREASE
				hide_dropdowns()
			} else {
				can_change = false
			}
		} else {
			rl.PlaySound(game.place_empty_sound)
			game.money += game.ind_arr[prev_ind].sell_value
		}
	case .Mill:
		if game.money >= game.ind_arr[prev_ind].cost {
			game.money -= game.ind_arr[prev_ind].cost
			rl.PlaySound(game.flour_sound)
			hide_dropdowns()
		} else {
			can_change = false
		}
	case .Bakery:
		if game.money >= game.ind_arr[prev_ind].cost {
			game.money -= game.ind_arr[prev_ind].cost
			rl.PlaySound(game.cake_sound)
			hide_dropdowns()
		} else {
			can_change = false
		}
	}

	if can_change {
		change_tile_industry(&game.tile_arr[i], game.ind_arr[ind_type])
	}
}
