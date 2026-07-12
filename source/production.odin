package game

import "core:strings"
import rl "vendor:raylib"

Production :: struct {
	id:            int,
	show:          bool,
	rec:           rl.Rectangle,
	button:        Dropdown_Button,
	tile_id:       int,
	ind_to_buy:    ^Industry,
	purchase_text: cstring,
	sb:            strings.Builder,
}

init_production :: proc(
	dropdown: ^Production,
	id: int,
	rec: rl.Rectangle,
	button: Dropdown_Button,
) {
	dropdown.rec = rec
	dropdown.button = button
	dropdown.id = id
	dropdown.sb = strings.builder_make()
}

update_production :: proc(production: ^Production, fs: ^Frame_State) {
	if !production.show {
		return
	}

	if rl.CheckCollisionPointRec(fs.input_pos, production.rec) {
		fs.mouse_over_production = true
		fs.production = production

		if rl.CheckCollisionPointRec(fs.input_pos, production.button.rec) {
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

draw_purchase_production :: proc() {
	rl.DrawRectangleRec(game.purchase_dropdown.rec, rl.LIGHTGRAY)
	rl.DrawText(
		game.purchase_dropdown.purchase_text,
		cast(i32)game.purchase_dropdown.rec.x,
		cast(i32)game.purchase_dropdown.rec.y + 40,
		20,
		rl.BLACK,
	)
	rl.DrawTexturePro(
		game.spritesheet,
		game.purchase_dropdown.button.img_src_rec,
		game.purchase_dropdown.button.rec,
		{0, 0},
		0,
		rl.WHITE,
	)
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

show_purchase_production :: proc(tile_id: int, ind: ^Industry) {
	game.dropdown_open = true
	game.purchase_dropdown.tile_id = tile_id

	strings.builder_reset(&game.purchase_dropdown.sb)

	if ind.type == .MillForSale {
		game.purchase_dropdown.ind_to_buy = &game.ind_arr[Industry_Type.Mill]

		strings.write_string(
			&game.purchase_dropdown.sb,
			"       Purchase\n        the Mill\n       for $",
		)
		strings.write_int(&game.purchase_dropdown.sb, cast(int)ind.cost)
		strings.write_string(&game.purchase_dropdown.sb, "?")
		game.purchase_dropdown.purchase_text = strings.to_cstring(
			&game.purchase_dropdown.sb,
		)
	} else if ind.type == .BakeryForSale {
		game.purchase_dropdown.ind_to_buy = &game.ind_arr[Industry_Type.Bakery]
		strings.write_string(
			&game.purchase_dropdown.sb,
			"       Purchase\n      the Bakery\n       for $",
		)
		strings.write_int(&game.purchase_dropdown.sb, cast(int)ind.cost)
		strings.write_string(&game.purchase_dropdown.sb, "?")
		game.purchase_dropdown.purchase_text = strings.to_cstring(
			&game.purchase_dropdown.sb,
		)
	} else {
		game.purchase_dropdown.ind_to_buy = &game.ind_arr[Industry_Type.Empty]
		strings.write_string(
			&game.purchase_dropdown.sb,
			"      Purchase\n       this plot\n       for $",
		)
		strings.write_int(
			&game.purchase_dropdown.sb,
			cast(int)game.ind_arr[Industry_Type.ForSale].cost,
		)
		strings.write_string(&game.purchase_dropdown.sb, "?")
		game.purchase_dropdown.purchase_text = strings.to_cstring(
			&game.purchase_dropdown.sb,
		)

	}

	game.purchase_dropdown.show = true

	game.purchase_dropdown.button.rec.x =
		game.purchase_dropdown.rec.x +
		(game.purchase_dropdown.rec.width / 2) -
		(game.purchase_dropdown.button.rec.width / 2)
	game.purchase_dropdown.button.rec.y =
		game.purchase_dropdown.rec.y +
		game.purchase_dropdown.rec.height -
		game.purchase_dropdown.button.rec.height -
		5

}
