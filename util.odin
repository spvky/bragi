package bragi

import l "core:math/linalg"
import "core:log"

Vec2 :: [2]f32
find_max_in_direction :: proc(p1: []Vec2, d: Vec2) -> Vec2 {
	max_dot: f32
	max_index: int

	for p,i in p1 {
		dot := l.dot(p,d)
		if dot > max_dot {
			max_dot = dot
			max_index = i
		}
	}
	return p1[max_index]
}

support :: proc(p1,p2: []Vec2, d: Vec2) -> Vec2 {
	a:= find_max_in_direction(p1,d)
	b:= find_max_in_direction(p2,-d)
	return a - b
}

perependicular :: proc(a: Vec2) -> Vec2 {
	return {a.y, -a.x}
}

vtp :: proc(a,b,c: Vec2) -> Vec2 {
	// d,e,f: [3]f32
	// d = {a.x,a.y,0}
	// e = {b.x,b.y,0}
	// f = {c.x,c.y,0}
	// result := l.vector_triple_product(d,e,f)
	// return {result.x,result.y}
	return (l.dot(a,c) * b) - (l.dot(a,b) * c)
}

avg :: proc(p1: []Vec2) -> Vec2 {
	a: Vec2
	for p in p1 {
		a += p
	}
	return a
}
