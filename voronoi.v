// Copyright(C) 2019-2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module voronoi

pub struct Point {
pub:
	x f32
	y f32
}

fn (p Point) as_c() C.jcv_point {
	pp := C.jcv_point{
		x: p.x
		y: p.y
	}
	return pp
}

pub struct Rect {
pub:
	min Point
	max Point
}

fn (r Rect) as_c() C.jcv_rect {
	rr := C.jcv_rect{
		min: r.min.as_c()
		max: r.max.as_c()
	}
	return rr
}

/*
pub struct Site {
    pub mut:
    p               Point
    index           int
    edges           &GraphEdge
}


pub struct Edge {
    pub mut:
    next                &Edge
    sites               &Site
    pos                 []Point
    a                   f32
    b                   f32
    c                   f32
}


pub struct GraphEdge {
    pub mut:
        next            &GraphEdge
        edge            &Edge
        neighbor        &Site
        pos             []Point
        angle           f32
}

pub struct CDiagram {
    internal            &C.jcv_context_internal
    edges               &C.jcv_edge
    sites               &C.jcv_site
    numsites            int
    min                 C.jcv_point
    max                 C.jcv_point
}
*/
pub struct Diagram {
pub mut:
	numsites int
mut:
	dgm      C.jcv_diagram
}

pub fn (mut d Diagram) generate(points []Point, bounds Rect) {
	// d.dgm = &C.jcv_diagram{!}
	// d.dgm = &dgm
	// println( points.data )
	// C.memset(&d.dgm, 0, sizeof(C.jcv_diagram))
	bnds := bounds.as_c()
	// eprintln('Generating...')
	C.jcv_diagram_generate(points.len, points.data, &bnds, C.NULL, &d.dgm)
	d.numsites = d.dgm.numsites
	// println('Reached here 2')
	// println( d.dgm.numsites )
	// println( dgm.numsites )
	// cdgm := CDiagram(dgm)
	// println( cdgm.numsites )
	// C.jcv_diagram_free( &dgm )
}

pub fn (mut d Diagram) free() {
	C.jcv_diagram_free(&d.dgm)
}

pub fn (d Diagram) edges() &C.jcv_edge {
	return C.jcv_diagram_get_edges(&d.dgm)
	/*
	// If all you need are the edges
        const jcv_edge* edge = jcv_diagram_get_edges( diagram );
        while( edge )
        {
            draw_line(edge->pos[0], edge->pos[1]);
            edge = jcv_diagram_get_next_edge(edge);
        }
	*/
	// edge
	/*
	mut edge := C.jcv_diagram_get_edges( &d.dgm )
    for !isnil(edge) {
        p := (edge.pos)[0]
        //eprintln('$p.x')
        edge = C.jcv_diagram_get_next_edge( edge )
    }
	*/
	// eprintln('---')
	// println(edge.pos[0])
	// println(edge.pos[0].x)
	// for e in edges {
	// println(e.pos[0].x)
	// }
	// return edges
}

pub fn (d Diagram) sites() &C.jcv_site {
	return C.jcv_diagram_get_sites(&d.dgm)
}
