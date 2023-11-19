// Copyright(C) 2021-2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module main

import gg
import gx
import math
import rand
import sokol.sapp
import voronoi as v

const (
	win_width  = 600
	win_height = 600
	colors_len = (20 * 3) // 20 different colors
)

struct App {
mut:
	gg     &gg.Context
	points []v.Point
	bounds v.Rect
	colors []u8
	width  int
	height int
}

fn main() {
	mut a := &App{
		gg: 0
	}
	a.gg = gg.new_context(
		bg_color: gx.black
		width: win_width
		height: win_height
		use_ortho: true
		create_window: true
		window_title: 'Voronoi'
		frame_fn: frame
		event_fn: event
		user_data: a
		init_fn: init
	)
	a.gg.run()
}

@[inline]
fn init(mut a App) {
	a.width = sapp.width()
	a.height = sapp.height()

	a.colors = []u8{len: colors_len}
	for i in 0 .. colors_len {
		a.colors[i] = u8(rand.int_in_range(0, 255) or { 0 })
	}
	for _ in 0 .. rand.int_in_range(1, 10) or { 1 } {
		a.points << v.Point{
			x: rand.int_in_range(0, a.width) or { 0 }
			y: rand.int_in_range(0, a.height) or { 0 }
		}
	}
	a.bounds = v.Rect{
		min: v.Point{
			x: 0.0
			y: 0.0
		}
		max: v.Point{
			x: f32(a.width)
			y: f32(a.height)
		}
	}
}

@[inline]
fn frame(a &App) {
	a.gg.begin()
	a.draw()
	a.gg.end()
}

@[inline]
fn event(e &gg.Event, ptr voidptr) {
	mut a := unsafe { &App(ptr) }
	mut resized := false
	if sapp.width() != a.width {
		a.width = sapp.width()
		resized = true
	}
	if sapp.height() != a.height {
		a.height = sapp.height()
		resized = true
	}
	if resized {
		a.bounds = v.Rect{
			min: v.Point{
				x: 0.0
				y: 0.0
			}
			max: v.Point{
				x: f32(a.width)
				y: f32(a.height)
			}
		}
	}
	match e.typ {
		.key_up {
			if e.key_code == .c {
				a.points.clear()
			}
		}
		.mouse_down {
			a.points << v.Point{
				x: e.mouse_x
				y: e.mouse_y
			}
		}
		.mouse_up {}
		else {}
	}
}

// oscillate will "wave" or "ping-pong" between min and max value
fn oscillate(value int, min int, max int) int {
	range := max - min
	return min + int(math.abs(((value + range) % (range * 2)) - range))
}

// normalize or cycle input value in range start <-> end
// I.e it normalizes a number to an arbitrary range by assuming the range wraps around when going below min or above max
fn normalize(value int, start int, end int) int {
	width := end - start
	offset_value := value - start // value relative to 0
	return int(offset_value - (math.floor(offset_value / width) * width)) + start
	// ... + start to reset back to start of original range
}

// clamp returns a number whose value is limited to the given range.
fn clamp(x int, a int, b int) int {
	return int(math.min(math.max(x, a), b))
}

@[direct_array_access; inline]
fn (a &App) draw() {
	mut dia := v.Diagram{}
	dia.generate(a.points, a.bounds)
	sites := dia.sites()
	mut ci := 0
	mut j := 0
	for i := 0; i < dia.numsites; i++ {
		ci = clamp(normalize(i, 0, colors_len - 3), 0, colors_len - 3)
		unsafe {
			site := sites[i]
			mut e := site.edges
			j = 0
			for !isnil(e) {
				// ci = normalize(i+j, 0, colors_len-3)
				a.gg.draw_triangle_filled(site.p.x, site.p.y, e.pos[0].x, e.pos[0].y,
					e.pos[1].x, e.pos[1].y, gx.rgb(a.colors[ci], a.colors[ci + 1], a.colors[ci + 2]))
				e = e.next
				j++
			}
		}
	}
	mut edge := dia.edges()
	for !isnil(edge) {
		a.gg.draw_line(edge.pos[0].x, edge.pos[0].y, edge.pos[1].x, edge.pos[1].y, gx.rgb(0,
			0, 0))
		edge = C.jcv_diagram_get_next_edge(edge)
	}
	for p in a.points {
		a.gg.draw_circle_filled(p.x, p.y, 3, gx.rgb(0, 0, 0))
	}
	dia.free()
}
