// Copyright(C) 2019-2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
//
// C wrapper for https://github.com/JCash/voronoi
module voronoi

#flag -I @VMODROOT/c
#flag -D JC_VORONOI_IMPLEMENTATION
#include "jc_voronoi_clip.h"
#include "jc_voronoi.h"

@[typedef]
struct C.jcv_diagram {
mut:
	numsites int
	min      C.jcv_point
	max      C.jcv_point
}

@[typedef]
struct C.jcv_point {
	x f32
	y f32
}

@[typedef]
struct C.jcv_rect {
	min C.jcv_point
	max C.jcv_point
}

@[typedef]
struct C.jcv_site {
	p     C.jcv_point
	index int
	edges &C.jcv_graphedge
}

@[typedef]
struct C.jcv_edge {
	next &C.jcv_edge
	// sites [2]&C.jcv_site
	pos [2]C.jcv_point
	a   f32
	b   f32
	c   f32
}

@[typedef]
struct C.jcv_clipper {
}

@[typedef]
struct C.jcv_graphedge {
	next     &C.jcv_graphedge
	edge     &C.jcv_edge
	neighbor &C.jcv_site
	pos      [2]C.jcv_point
	angle    f32 // jcv_real
}

fn C.jcv_diagram_free(diagram &C.jcv_diagram)

fn C.jcv_diagram_get_sites(diagram &C.jcv_diagram) &C.jcv_site

fn C.jcv_diagram_get_edges(diagram &C.jcv_diagram) &C.jcv_edge

fn C.jcv_diagram_get_next_edge(edge &C.jcv_edge) &C.jcv_edge

fn C.jcv_diagram_generate(num_points int, points &C.jcv_point, rect &C.jcv_rect, clipper &C.jcv_clipper, diagram &C.jcv_diagram)
