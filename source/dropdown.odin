package game

import "core:strings"
import rl "vendor:raylib"

Dropdown_Button :: struct {
	rec:         rl.Rectangle,
	state:       Button_State,
	tint:        rl.Color,
	text_color:  rl.Color,
	type:        Industry_Type,
	text:        cstring,
	img_src_rec: rl.Rectangle,
	img_dst_rec: rl.Rectangle,
}

Dropdown :: struct {
	rec:     rl.Rectangle,
	buttons: [4]Dropdown_Button,
	show:    bool,
	tile_id: int,
	sb:      strings.Builder,
}

init_dropdown :: proc(
	dropdown: ^Dropdown,
	rec: rl.Rectangle,
	buttons: [4]Dropdown_Button,
) {
	dropdown.show = false
	dropdown.rec = rec
	dropdown.buttons = buttons
	dropdown.sb = strings.builder_make()
}

update_dropdown :: proc(dropdown: ^Dropdown, fs: ^Frame_State) {
	if game.dropdown.show {
		if rl.CheckCollisionPointRec(fs.input_pos, game.dropdown.rec) {
			fs.mouse_over_dropdown = true
			fs.dropdown = dropdown
		}
		for &button in game.dropdown.buttons {
			if rl.CheckCollisionPointRec(fs.input_pos, button.rec) &&
			   button.state != .Disabled {
				fs.mouse_over_dropdown_button = true
				fs.dropdown_button = &button
			}
		}
	}
}

draw_dropdown :: proc(dropdown: ^Dropdown) {
	if dropdown.show {
		rl.DrawRectangleRec(dropdown.rec, rl.RAYWHITE)

		for button in dropdown.buttons {
			rl.DrawRectangleRec(button.rec, button.tint)
			rl.DrawText(
				button.text,
				cast(i32)button.rec.x,
				cast(i32)button.rec.y,
				20,
				button.text_color,
			)
			rl.DrawTexturePro(
				game.spritesheet,
				button.img_src_rec,
				button.img_dst_rec,
				{0, 0},
				0,
				rl.WHITE,
			)
		}
	}
}

show_dropdown :: proc(point: rl.Vector2, tile_id: int) {
	game.dropdown_open = true
	game.dropdown.show = true
	game.dropdown.tile_id = tile_id
	game.dropdown.rec.x = point.x
	game.dropdown.rec.y = point.y
	tile_ind := game.tile_arr[tile_id].industry.type
	sell_value := game.tile_arr[tile_id].industry.sell_value
	strings.builder_reset(&game.dropdown.sb)
	strings.write_string(&game.dropdown.sb, "Sell ")
	strings.write_int(&game.dropdown.sb, cast(int)sell_value)
	sell_cstring := strings.to_cstring(&game.dropdown.sb)

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

		if game.money < game.ind_arr[game.dropdown.buttons[i].type].cost ||
		   game.dropdown.buttons[i].type == tile_ind {
			game.dropdown.buttons[i].state = .Disabled
			game.dropdown.buttons[i].text_color = rl.GRAY
		} else {
			game.dropdown.buttons[i].state = .Normal
			game.dropdown.buttons[i].text_color = rl.BLACK
		}

		if game.dropdown.buttons[i].type == .Empty {
			game.dropdown.buttons[i].text = sell_cstring
		}
	}
}

hide_dropdowns :: proc() {
	game.dropdown.show = false
	game.mill_dropdown.show = false
	game.bakery_dropdown.show = false
	game.dropdown_open = false
}
