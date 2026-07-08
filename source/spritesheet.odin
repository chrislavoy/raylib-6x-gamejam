package game

import rl "vendor:raylib"

SPRITE_COUNT :: 5

Spritesheet_Reference :: struct {
	name: string,
	rec:  rl.Rectangle,
}

get_spritesheet_recs :: proc() -> [SPRITE_COUNT]Spritesheet_Reference {
	return [SPRITE_COUNT]Spritesheet_Reference {
		{"Unclaimed", {0, 0, 144, 144}},
		{"Empty", {144, 0, 144, 144}},
		{"Wheat", {288, 0, 144, 144}},
		{"Cows", {0, 144, 144, 144}},
		{"Chickens", {144, 144, 144, 144}},
	}
}

get_initial_tile_positions :: proc() -> [27]rl.Rectangle {
	return [27]rl.Rectangle {
		{0, 15, 144, 144},
		{144, 15, 144, 144},
		{288, 15, 144, 144},
		{432, 15, 144, 144},
		{576, 15, 144, 144}, // Row 1
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

