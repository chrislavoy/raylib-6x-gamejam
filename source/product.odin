package game

import "core:math"
import rl "vendor:raylib"

Product_Type :: enum {
	None,
	Wheat,
	Eggs,
	Milk,
	Flour,
	Cake,
}

Product :: struct {
	type:      Product_Type,
	src_rec:   rl.Rectangle,
	dst_rec:   rl.Rectangle,
	origin:    rl.Vector2,
	start_pos: rl.Vector2,
	tgt_pos:   rl.Vector2,
	speed:     f32,
	show:      bool,
	time:      f32,
	tgt_time:  f32,
}

init_product :: proc(
	product: ^Product,
	tile_industry_type: Industry_Type,
	tile_pos: rl.Vector2,
	target_pos: rl.Vector2,
) {
	product.start_pos = tile_pos + {72, 72}
	product.tgt_pos = target_pos + {72, 72}
	product.speed = 200
	product.show = false
	product.time = 0
	product.tgt_time = 1

	product.dst_rec = {product.start_pos.x, product.start_pos.y, 0, 0}

	change_product_type(product, tile_industry_type)
}

change_product_type :: proc(product: ^Product, type: Industry_Type) {
	product.type = .None

	#partial switch type {
	case .Wheat:
		product.src_rec = get_sprite_rec_by_name("Wheat_Icon")
		product.type = .Wheat
	case .Chicken:
		product.src_rec = get_sprite_rec_by_name("Eggs_Icon")
		product.type = .Eggs
	case .Cow:
		product.src_rec = get_sprite_rec_by_name("Milk_Icon")
		product.type = .Milk
	case .Mill:
		product.src_rec = get_sprite_rec_by_name("Flour_Icon")
		product.type = .Flour
	case .Bakery:
		product.src_rec = get_sprite_rec_by_name("Cake_Icon")
		product.type = .Cake
	}

	product.dst_rec.width = product.src_rec.width
	product.dst_rec.height = product.src_rec.height

	product.origin = {
		math.round(product.src_rec.width / 2),
		math.round(product.src_rec.height / 2),
	}
}

update_product :: proc(product: ^Product) {
	if product.show {
		product.time += rl.GetFrameTime()

		new_x := rl.EaseExpoInOut(
			product.time,
			product.start_pos.x,
			product.tgt_pos.x - product.start_pos.x,
			product.tgt_time,
		)

		new_y := rl.EaseExpoInOut(
			product.time,
			product.start_pos.y,
			product.tgt_pos.y - product.start_pos.y,
			product.tgt_time,
		)

		product.dst_rec.x = new_x
		product.dst_rec.y = new_y

		if product.time >= product.tgt_time {
			end_product_animation(product)
		}
	}
}

draw_product :: proc(product: ^Product) {
	if product.show {
		rl.DrawTexturePro(
			game.spritesheet,
			product.src_rec,
			product.dst_rec,
			product.origin,
			0,
			rl.WHITE,
		)
	}
}

start_product_animation :: proc(product: ^Product) {
	product.dst_rec.x = product.start_pos.x
	product.dst_rec.y = product.start_pos.y
	product.time = 0
	product.show = true
}

end_product_animation :: proc(product: ^Product) {
	product.show = false
	rl.PlaySound(game.collect_sound)
}

// C1 :: 1.70158
// C3 :: C1 + 1
//
// ease_in_back :: proc(pos: rl.Vector2) -> rl.Vector2 {
// 	return {
// 		C3 * pos.x * pos.x * pos.x - C1 * pos.x * pos.x,
// 		C3 * pos.y * pos.y * pos.y - C1 * pos.y * pos.y,
// 	}
// }
