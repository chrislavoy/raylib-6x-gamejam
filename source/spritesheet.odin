package game

import rl "vendor:raylib"

Spritesheet_Reference :: struct {
	name: string,
	rec:  rl.Rectangle,
}

sprite_ref := [35]Spritesheet_Reference {
	{"Unclaimed", {0, 0, 144, 144}},
	{"ForSale", {144, 0, 144, 144}},
	{"Empty", {288, 0, 144, 144}},
	{"Wheat", {432, 0, 144, 144}},
	{"Cows", {0, 144, 144, 144}},
	{"Chickens", {144, 144, 144, 144}},
	{"Farmhouse", {288, 144, 144, 144}},
	{"Mill", {432, 144, 144, 144}},
	{"Storehouse", {0, 288, 144, 144}},
	{"Bakery", {144, 288, 144, 144}},
	{"SellWheat", {288, 288, 32, 32}},
	{"SellWheat_Clicked", {320, 288, 32, 32}},
	{"BuyWheat", {352, 288, 32, 32}},
	{"BuyWheat_Clicked", {384, 288, 32, 32}},
	{"SellMilk", {416, 288, 32, 32}},
	{"SellMilk_Clicked", {448, 288, 32, 32}},
	{"BuyMilk", {480, 288, 32, 32}},
	{"BuyMilk_Clicked", {512, 288, 32, 32}},
	{"SellEggs", {544, 288, 32, 32}},
	{"SellEggs_Clicked", {288, 320, 32, 32}},
	{"BuyEggs", {320, 320, 32, 32}},
	{"BuyEggs_Clicked", {352, 320, 32, 32}},
	{"SellFlour", {384, 320, 32, 32}},
	{"SellFlour_Clicked", {416, 320, 32, 32}},
	{"BuyFlour", {448, 320, 32, 32}},
	{"BuyFlour_Clicked", {480, 320, 32, 32}},
	{"SellCake", {512, 320, 32, 32}},
	{"SellCake_Clicked", {544, 320, 32, 32}},
	{"BuyCake", {288, 352, 32, 32}},
	{"BuyCake_Clicked", {320, 352, 32, 32}},
	{"Wheat_Icon", {352, 352, 17, 22}},
	{"Cake_Icon", {369, 352, 19, 18}},
	{"Milk_Icon", {388, 352, 11, 26}},
	{"Flour_Icon", {399, 352, 13, 21}},
	{"Eggs_Icon", {412, 352, 17, 16}},
}

get_spritesheet_recs :: proc() -> [35]Spritesheet_Reference {
	return sprite_ref
}

get_sprite_rec_by_name :: proc(name: string) -> rl.Rectangle {
	for ref in sprite_ref {
		if ref.name == name {
			return ref.rec
		}
	}

	return {0, 0, 0, 0}
}
