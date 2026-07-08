package game

import rl "vendor:raylib"

//Enum
Plot_Type :: enum {
	Empty = 0,
	Wheat = 1,
	Cow = 2,
	Chicken =3,
} 

Product_Type :: enum {
	Empty = 0,
	Wheat = 1,
	Cow = 2,
	Chicken = 3,
}

Industry_Type :: enum {
  Unclaimed,
  Empty,
  Wheat,
  Cow,
  Chicken,
}

Tile :: struct {
  rec: rl.Rectangle,
  industry: Industry,
}

Industry :: struct {
  type: Industry_Type,
  src: rl.Rectangle,
}

//Structs
Farm_Plot :: struct {
	x: f32,
	y: f32,
	radius: f32,
	Plot_Type: Plot_Type, 
	Product_Type: Product_Type,
	Growth_Speed: f32,
}

	//Buys products from farmhouse
Buy_Crop_Button :: struct {

}

	//Collects from plot
Collect_From_Plot :: struct {

}

	//Select product in warehouse
Select_Product :: struct {

}

	//Sells products from warehouse
Sell_Crop_Button :: struct {

}

SPRITE_COUNT :: 5

Spritesheet_Reference :: struct {
	name: string,
	rec:  rl.Rectangle,
}

ind_arr := [5]Industry {
  {.Unclaimed, {0, 0, 144, 144}},
  {.Empty, {144, 0, 144, 144}},
  {.Wheat, {288, 0, 144, 144}},
  {.Cow, {0, 144, 144, 144}},
  {.Chicken, {144, 144, 144, 144}},
}

init_tile_arr :: proc(tile_arr: ^[27]Tile) {
  pos_arr := [27]rl.Vector2{
    {0, 15}, {144, 15}, {288, 15}, {432, 15}, {576, 15}, // Row 1
    {72, 124}, {216, 124}, {360, 124}, {504, 124}, // Row 2
    {0, 233}, {144, 233}, {288, 233}, {432, 233}, {576, 233}, // Row 3
    {72, 342}, {216, 342}, {360, 342}, {504, 342}, // Row 4
    {0, 451}, {144, 451}, {288, 451}, {432, 451}, {576, 451}, // Row 5
    {72, 560}, {216, 560}, {360, 560}, {504, 560}, // Row 6
  }

  for i := 0; i < 27; i += 1 {
    tile_arr[i].rec = {pos_arr[i].x, pos_arr[i].y, 144, 144}

    if i < 14 {
      tile_arr[i].industry = ind_arr[0]
    } else {
      tile_arr[i].industry = ind_arr[1]
    }
  }
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

 update :: proc() {
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	rl.EndDrawing()
}

@(export)
game_update :: proc() {
	update()
	draw()
}

@(export)
game_init :: proc() {
	
}

@(export)
game_init_window :: proc() {
	rl.InitWindow(720, 720, "test")

  spritesheet := rl.LoadTexture("assets\\farm_spritesheet.png")
  defer rl.UnloadTexture(spritesheet)

  tile_arr: [27]Tile
  
  init_tile_arr(&tile_arr)

  for !rl.WindowShouldClose() {
    rl.BeginDrawing()
    rl.ClearBackground(rl.Color({70, 130, 50, 255}))

    for tile in tile_arr {
      rl.DrawTexturePro(spritesheet, tile.industry.src, tile.rec, {0, 0}, 0, rl.WHITE)
    }

    rl.EndDrawing()
  } 
}

 @(export)
 game_should_run :: proc() -> bool {
 		return !rl.WindowShouldClose()
}

 @(export)
 game_shutdown :: proc() {
 }

@(export)
game_shutdown_window :: proc() {
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

