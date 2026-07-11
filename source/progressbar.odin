package game

import rl "vendor:raylib"

Progress_Bar :: struct {
	outer_rec: rl.Rectangle,
	inner_rec: rl.Rectangle,
	val:       f32,
	max:       f32,
	outer_col: rl.Color,
	inner_col: rl.Color,
}

init_progress_bar :: proc(bar: ^Progress_Bar, rec: rl.Rectangle, max: f32) {
	bar.outer_rec = {rec.x + 46, rec.y + 96, 50, 10}
	bar.inner_rec = {
		bar.outer_rec.x,
		bar.outer_rec.y,
		0,
		bar.outer_rec.height,
	} // inner bar is at the "beginning" of the progress bar
	bar.val = 0 // explicitly setting for completeness
	bar.max = max
	bar.outer_col = {199, 207, 204, 255}
	bar.inner_col = {117, 167, 67, 255}
}

update_progress_bar :: proc(bar: ^Progress_Bar, val: f32) {
	bar.val = val

	if bar.val > bar.max {
		bar.val = bar.max
	}

	bar.inner_rec.width = (val / bar.max) * bar.outer_rec.width
}

draw_progress_bar :: proc(bar: ^Progress_Bar) {
	rl.DrawRectangleRec(
		{
			bar.outer_rec.x - 2,
			bar.outer_rec.y - 2,
			bar.outer_rec.width + 4,
			bar.outer_rec.height + 4,
		},
		rl.BLACK,
	)
	rl.DrawRectangleRec(bar.outer_rec, bar.outer_col)
	rl.DrawRectangleRec(bar.inner_rec, bar.inner_col)
}
