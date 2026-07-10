package game

import rl "vendor:raylib"

TILE_ARR_COUNT :: 22

Industry_Type :: enum {
	Unclaimed,
	Empty,
	Wheat,
	Cow,
	Chicken,
	Farmhouse,
	Mill,
	Bakery,
	Storehouse,
	ForSale,
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
	id:                int,
	rec:               rl.Rectangle,
	industry:          Industry,
	hovered:           bool,
	collider:          [8]rl.Vector2,
	tint:              rl.Color,
	selectable:        bool,
	show_progress_bar: bool,
	progress_bar:      Progress_Bar,
}

get_initial_tile_positions :: proc() -> [TILE_ARR_COUNT]rl.Rectangle {
	return [TILE_ARR_COUNT]rl.Rectangle {
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


init_tiles :: proc(tile_arr: ^[TILE_ARR_COUNT]Tile) {
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
			change_tile_industry(
				&tile_arr[i],
				game.ind_arr[Industry_Type.Unclaimed],
			)
		} else {
			change_tile_industry(
				&tile_arr[i],
				game.ind_arr[Industry_Type.Empty],
			)
		}

		init_progress_bar(
			&tile_arr[i].progress_bar,
			tile_arr[i].rec,
			tile_arr[i].industry.max_growth,
		)
		// } else if i >= 14 && i < 18 {
		// 	tile_arr[i].industry = game.ind_arr[2]
		// } else if i >= 18 && i < 22 {
		// 	tile_arr[i].industry = game.ind_arr[3]
		// } else {
		// 	tile_arr[i].industry = game.ind_arr[4]
		// }
	}

	change_tile_industry(&tile_arr[1], game.ind_arr[Industry_Type.Storehouse])
	change_tile_industry(&tile_arr[4], game.ind_arr[Industry_Type.Mill])
	change_tile_industry(&tile_arr[5], game.ind_arr[Industry_Type.Farmhouse])
	change_tile_industry(&tile_arr[6], game.ind_arr[Industry_Type.Bakery])
}

update_tiles :: proc(tiles: ^[TILE_ARR_COUNT]Tile, mouse_pos: rl.Vector2) {
	for &tile in tiles {
		if !tile.selectable {
			continue
		}
		if !game.dropdown.show {
			if rl.CheckCollisionPointPoly(
				mouse_pos,
				raw_data(&tile.collider),
				8,
			) {
				tile.hovered = true
				//tile.tint = rl.RED

				if rl.IsMouseButtonPressed(.LEFT) {
					show_dropdown(mouse_pos, tile.id)
				}

			} else {
				tile.hovered = false
				//tile.tint = rl.WHITE
			}
		}

		if tile.industry.type != .Empty {
			tile.industry.growth +=
				tile.industry.growth_rate * rl.GetFrameTime()

			update_progress_bar(&tile.progress_bar, tile.industry.growth)

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
}

draw_tiles :: proc(tiles: ^[TILE_ARR_COUNT]Tile) {
	for &tile in tiles {
		rl.DrawTexturePro(
			game.spritesheet,
			tile.industry.src,
			tile.rec,
			{0, 0},
			0,
			rl.WHITE,
		)

		if tile.show_progress_bar {
			draw_progress_bar(&tile.progress_bar)
		}

		if tile.hovered {
			for i := 0; i < 8; i += 1 {
				next := (i + 1) % 8
				rl.DrawLineEx(
					tile.collider[i],
					tile.collider[next],
					3,
					rl.WHITE,
				)
			}
		}
	}
}

change_tile_industry :: proc(tile: ^Tile, industry: Industry) {
	// game.tile_arr[i].industry = game.ind_arr[ind_type]
	tile.industry = industry

	if industry.type == .Wheat ||
	   industry.type == .Chicken ||
	   industry.type == .Cow {
		tile.show_progress_bar = true
	} else {
		tile.show_progress_bar = false
	}

	init_progress_bar(&tile.progress_bar, tile.rec, industry.max_growth)
}

