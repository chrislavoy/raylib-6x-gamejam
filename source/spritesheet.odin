package game

import rl "vendor:raylib"

Spritesheet_Reference :: struct {
	name: string,
	rec:  rl.Rectangle,
}

get_spritesheet_recs :: proc() -> [5]Spritesheet_Reference {
	return [5]Spritesheet_Reference {
		{"Unclaimed", {0, 0, 144, 144}},
		{"Empty", {144, 0, 144, 144}},
		{"Wheat", {288, 0, 144, 144}},
		{"Cows", {0, 144, 144, 144}},
		{"Chickens", {144, 144, 144, 144}},
	}
}

