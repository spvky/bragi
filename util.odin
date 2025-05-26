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

PointList :: []Vec3

Sphere :: struct {
	translation: Vec3,
	radius: f32
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

find_max_in_direction_sphere :: proc(s: Sphere, d: Vec3) -> Vec3 {
	return s.translation + (s.radius * d) / l.length(d)
}

support :: proc {
	poly_poly_support,
	poly_sphere_support,
	sphere_sphere_support,
}

poly_poly_support :: proc(p1,p2: []Vec3, d: Vec3) -> Vec3 {
	a:= find_max_in_direction(p1,d)
	b:= find_max_in_direction(p2,-d)
	return a - b
}

poly_sphere_support :: proc(p: []Vec3, s: Sphere, d: Vec3) -> Vec3 {
	a:= find_max_in_direction(p,d)
	b:= find_max_in_direction_sphere(s,-d)
	return a - b
}

sphere_sphere_support :: proc(s1,s2: Sphere, d: Vec3) -> Vec3 {
	a:= find_max_in_direction_sphere(s1, d)
	b:= find_max_in_direction_sphere(s2, -d)
	return a - b
}

avg :: proc {
	avg_sphere,
	avg_points,
}

avg_sphere :: proc(s: Sphere) -> Vec3 {
	return s.translation
}

avg_points :: proc(p1: []Vec3) -> Vec3 {
	a: Vec3
	for p in p1 {
		a += p
	}
	return a / f32(len(p1))
}
