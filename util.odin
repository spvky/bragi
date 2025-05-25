package bragi

import l "core:math/linalg"
import "core:log"
import "core:math/rand"

Vec3 :: [3]f32

Simplex :: struct {
	a: Vec3,
	b: Vec3,
	c: Vec3,
	d: Vec3,
	count: int
}

simplex_update :: proc(s: ^Simplex) {
	s.d = s.c
	s.c = s.b
	s.b = s.a
	s.count += 1
}

crossed_origin :: proc(p: Vec3, d: Vec3) -> bool {
	return l.dot(p,d) < 0
}

same_direction :: proc(a,b: Vec3) -> bool {
	return l.dot(a,b) > 0
}

find_max_in_direction :: proc(p1: []Vec3, d: Vec3) -> Vec3 {
	max_dot:= l.dot(p1[0],d)
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

support :: proc(p1,p2: []Vec3, d: Vec3) -> Vec3 {
	a:= find_max_in_direction(p1,d)
	b:= find_max_in_direction(p2,-d)
	return a - b
}


avg :: proc(p1: []Vec3) -> Vec3 {
	a: Vec3
	for p in p1 {
		a += p
	}
	return a / f32(len(p1))
}
