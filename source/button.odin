package game

import rl "vendor:raylib"

Button_State :: enum {
	Normal,
	Hovered,
	Clicked,
	Disabled,
}

Button_ID :: enum int {
	Sell_Wheat,
	Sell_Eggs,
	Sell_Milk,
	Sell_Flour,
	Sell_Cake,
}

Button :: struct {
	id:          Button_ID,
	rec:         rl.Rectangle,
	src:         rl.Rectangle,
	click_src:   rl.Rectangle,
	click_reset: f32,
	state:       Button_State,
	tint:        rl.Color,
}

init_sell_buttons :: proc() {
	click_reset: f32 = 0.1
	positions := get_ui_button_initial_positions()

	game.button_arr[Button_ID.Sell_Wheat] = {
		id          = .Sell_Wheat,
		rec         = positions[Button_ID.Sell_Wheat],
		src         = get_sprite_rec_by_name("SellWheat"),
		click_src   = get_sprite_rec_by_name("SellWheat_Clicked"),
		click_reset = click_reset,
		tint        = rl.WHITE,
		state       = .Normal,
	}

	game.button_arr[Button_ID.Sell_Eggs] = {
		id          = .Sell_Eggs,
		rec         = positions[Button_ID.Sell_Eggs],
		src         = get_sprite_rec_by_name("SellEggs"),
		click_src   = get_sprite_rec_by_name("SellEggs_Clicked"),
		click_reset = click_reset,
		tint        = rl.WHITE,
		state       = .Normal,
	}

	game.button_arr[Button_ID.Sell_Milk] = {
		id          = .Sell_Milk,
		rec         = positions[Button_ID.Sell_Milk],
		src         = get_sprite_rec_by_name("SellMilk"),
		click_src   = get_sprite_rec_by_name("SellMilk_Clicked"),
		click_reset = click_reset,
		tint        = rl.WHITE,
		state       = .Normal,
	}

	game.button_arr[Button_ID.Sell_Flour] = {
		id          = .Sell_Flour,
		rec         = positions[Button_ID.Sell_Flour],
		src         = get_sprite_rec_by_name("SellFlour"),
		click_src   = get_sprite_rec_by_name("SellFlour_Clicked"),
		click_reset = click_reset,
		tint        = rl.WHITE,
		state       = .Normal,
	}

	game.button_arr[Button_ID.Sell_Cake] = {
		id          = .Sell_Cake,
		rec         = positions[Button_ID.Sell_Cake],
		src         = get_sprite_rec_by_name("SellCake"),
		click_src   = get_sprite_rec_by_name("SellCake_Clicked"),
		click_reset = click_reset,
		tint        = rl.WHITE,
		state       = .Normal,
	}
}

update_buttons :: proc(fs: ^Frame_State) {
	for &button in game.button_arr {
		if button.state == .Clicked {
			button.click_reset -= rl.GetFrameTime()

			if button.click_reset <= 0 {
				button.state = .Normal
				button.click_reset = 0.1
			}
		}

		if rl.CheckCollisionPointRec(fs.input_pos, button.rec) {
			fs.mouse_over_button = true
			fs.button = &button
		}
	}
}

draw_buttons :: proc() {
	for button in game.button_arr {
		if button.state == .Clicked {
			rl.DrawTexturePro(
				game.spritesheet,
				button.click_src,
				button.rec,
				{0, 0},
				0,
				button.tint,
			)
		} else {
			rl.DrawTexturePro(
				game.spritesheet,
				button.src,
				button.rec,
				{0, 0},
				0,
				button.tint,
			)
		}
	}
}
