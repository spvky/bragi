package bragi

import "base:intrinsics"
import "core:log"
import "core:math"
import l "core:math/linalg"
import "core:math/rand"

Vec2 :: [2]f32
Vec3 :: [3]f32

Simplex :: struct {
	a:     Vec3,
	b:     Vec3,
	c:     Vec3,
	d:     Vec3,
	count: int,
}

// Converts a simplex into a polytope A:(temp_allocator)
polytope_from_simplex :: proc(s: Simplex) -> (p: Polytope, ok: bool) {
	switch s.count {
	case 3:
		p.points = make([dynamic]Vec3, 0, 8, allocator = context.temp_allocator)
		append_elems(&p.points, s.a, s.b, s.c)
	case 4:
		p.points = make([dynamic]Vec3, 0, 8, allocator = context.temp_allocator)
		append_elems(&p.points, s.a, s.b, s.c, s.d)
	case:
		return
	}
}

Polytope :: struct {
	points: [dynamic]Vec3,
}

Collision :: struct {}

PointList :: []Vec3

Sphere :: struct {
	translation: Vec3,
	radius:      f32,
}

Capsule :: struct {
	translation: Vec3,
	radius:      f32,
	height:      f32,
}

extend :: proc(val: Vec2, z: f32) -> Vec3 {
	return Vec3{val.x, val.y, z}
}

simplex_update :: proc(s: ^Simplex) {
	s.d = s.c
	s.c = s.b
	s.b = s.a
	s.count += 1
}

calculate_aabb :: proc(p: PointList) {
	// TODO: Find the fastest way to create and store AABB
}

crossed_origin :: proc(p: Vec3, d: Vec3) -> bool {
	return l.dot(p, d) < 0
}

same_direction :: proc(a, b: Vec3) -> bool {
	return l.dot(a, b) > 0
}

find_max_in_direction_polygon :: proc(p1: []Vec3, d: Vec3) -> Vec3 {
	max_dot := l.dot(p1[0], d)
	max_index: int

	for p, i in p1 {
		dot := l.dot(p, d)
		if dot > max_dot {
			max_dot = dot
			max_index = i
		}
	}
	return p1[max_index]
}

find_max_in_direction_sphere :: proc(s: Sphere, d: Vec3) -> Vec3 {
	return s.translation + (s.radius * d) / l.length(d)
}

find_max_in_direction_capsule :: proc(c: Capsule, d: Vec3) -> Vec3 {
	// norm_d := l.normalize(d)
	// start, end := c.translation - {0,c.height/2,0}, c.translation + {0,c.height/2,0}
	// line := end - start
	// dot := l.dot(Vec3{0,1,0}, norm_d)
	// center := line * dot
	// return center + ((c.radius * d) / l.length(d))
	norm_d := l.normalize(d)
	half_height := c.height / 2
	top, bottom := c.translation + {0, half_height, 0}, c.translation - {0, half_height, 0}
	top_dot, bot_dot := l.dot(top, norm_d), l.dot(bottom, norm_d)
	if top_dot > bot_dot {
		return top + (c.radius * norm_d)
	} else {
		return bottom + (c.radius * norm_d)
	}
}

find_max_in_direction :: proc {
	find_max_in_direction_capsule,
	find_max_in_direction_polygon,
	find_max_in_direction_sphere,
}

support :: proc(s1: $T, s2: $V, d: Vec3) -> Vec3 where T == Capsule || T == Sphere || T == []Vec3,
	V == Capsule || V == Sphere || V == []Vec3 {
	a := find_max_in_direction(s1, d)
	b := find_max_in_direction(s2, -d)
	return a - b
}

avg :: proc {
	avg_sphere,
	avg_points,
	avg_capsule,
}

avg_sphere :: proc(s: Sphere) -> Vec3 {
	return s.translation
}

avg_capsule :: proc(c: Capsule) -> Vec3 {
	return c.translation
}

avg_points :: proc(p1: []Vec3) -> Vec3 {
	a: Vec3
	for p in p1 {
		a += p
	}
	return a / f32(len(p1))
}
