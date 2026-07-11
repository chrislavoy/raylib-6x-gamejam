package game

import rl "vendor:raylib"

Dropdown_Button :: struct {
	rec:        rl.Rectangle,
	state:      Button_State,
	tint:       rl.Color,
	text_color: rl.Color,
	type:       Industry_Type,
	text:       cstring,
}

Dropdown :: struct {
	rec:     rl.Rectangle,
	buttons: [4]Dropdown_Button,
	show:    bool,
	tile_id: int,
}

init_dropdown :: proc(
	dropdown: ^Dropdown,
	rec: rl.Rectangle,
	buttons: [4]Dropdown_Button,
) {
	dropdown.show = false
	dropdown.rec = rec
	dropdown.buttons = buttons
}

update_dropdown :: proc(dropdown: ^Dropdown, mouse_pos: rl.Vector2) {
	if game.dropdown.show {

		if game.dropdown_just_opened {
			game.dropdown_just_opened = false
		} else {
			for &button in game.dropdown.buttons {
				if rl.CheckCollisionPointRec(mouse_pos, button.rec) &&
				   button.state != .Disabled {
					if rl.IsMouseButtonPressed(.LEFT) {
						change_industry(game.dropdown.tile_id, button.type)
						hide_dropdown()
					}
				}
			}

			if rl.IsMouseButtonPressed(.LEFT) {
				if !rl.CheckCollisionPointRec(mouse_pos, game.dropdown.rec) {
					hide_dropdown()
				}
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
		}
	}
}
