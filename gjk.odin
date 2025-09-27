package bragi

import sa "core:container/small_array"
import "core:log"
import l "core:math/linalg"

collision :: proc(
	s1: $T,
	s2: $V,
) -> bool where (T == PointList || T == Sphere || T == Capsule) &&
	(V == PointList || V == Sphere || V == Capsule) {
	simplex: Simplex
	d := avg(s1) - avg(s2)
	simplex.a = support(s1, s2, d)
	simplex.count = 1
	if crossed_origin(simplex.a, d) {
		return false
	}
	d = -simplex.a

	for {
		simplex_update(&simplex)
		simplex.a = support(s1, s2, d)
		if crossed_origin(simplex.a, d) {
			return false
		}

		switch simplex.count {
		case 2:
			d = line_case(&simplex)
		case 3:
			d = triangle_case(&simplex)
		case 4:
			collide: bool
			collide, d = tetrahedron_case(&simplex)
			if collide {
				return true
			}
		}
	}
	return false
}

collision_pro :: proc(
	s1: $T,
	s2: $V,
) -> bool where (T == PointList || T == Sphere || T == Capsule) &&
	(V == PointList || V == Sphere || V == Capsule) {
	simplex: Simplex
	d := avg(s1) - avg(s2)
	simplex.a = support(s1, s2, d)
	simplex.count = 1
	if crossed_origin(simplex.a, d) {
		return false
	}
	d = -simplex.a

	for {
		simplex_update(&simplex)
		simplex.a = support(s1, s2, d)
		if crossed_origin(simplex.a, d) {
			return false
		}

		switch simplex.count {
		case 2:
			d = line_case(&simplex)
		case 3:
			d = triangle_case(&simplex)
		case 4:
			collide: bool
			collide, d = tetrahedron_case(&simplex)
			if collide {
				return true
			}
		}
	}
	return false
}

epa :: proc(
	s: Simplex,
	s1: $T,
	s2: $V,
) -> Collision where (T == PointList || T == Sphere || T == Capsule) &&
	(V == PointList || V == Sphere || V == Capsule) {
	if p, ok = polytope_from_simplex(s); ok {
		min_index: int
		min_distance: f32 = 10000000
		min_noraml: Vec3

		for min_distance == 10000000 {
			i
			for i < len(p.points) {
				j = (i + 1) % len(p.points)
				v_i := p.points[i]
				v_j := p.points[j]
				i_j := j - i
				normal := -i_j
				i += 1
			}

		}
	}
}
epa_full :: proc(
	s: Simplex,
	s1: $T,
	s2: $V,
) -> Collision where (T == PointList || T == Sphere || T == Capsule) &&
	(V == PointList || V == Sphere || V == Capsule) {

	MAX_ITERATIONS :: 64
	MAX_FACES :: 64
	MAX_LOOS_EDGES :: 32
	TOLERANCE :: 0.0001

	if p, ok = polytope_from_simplex(s); ok {
		faces: [64][4]Vec3
		faces[0][0] = simplex.a
		faces[0][1] = simplex.b
		faces[0][2] = simplex.c
		faces[0][3] = l.normalize(l.cross(simplex.b - simplex.a, simplex.c - simplex.a)) // abc normal
		faces[1][0] = simplex.a
		faces[1][1] = simplex.c
		faces[1][2] = simplex.d
		faces[1][3] = l.normalize(l.cross(simplex.c - simplex.a, simplex.d - simplex.a)) // acd normal
		faces[2][0] = simplex.a
		faces[2][1] = simplex.d
		faces[2][2] = simplex.b
		faces[2][3] = l.normalize(l.cross(simplex.d - simplex.a, simplex.b - simplex.a)) // adb normal
		faces[3][0] = simplex.b
		faces[3][1] = simplex.d
		faces[3][2] = simplex.c
		faces[3][3] = l.normalize(l.cross(simplex.d - simplex.b, simplex.c - simplex.b)) // bdc normal

		num_faces := 4
		closest_face: int

		for i in 0 ..< MAX_ITERATIONS {
			min_dist := l.dot(faces[0][0], faces[0][3])
			closest_face = 0
			for j in 1 .. num_faces {
				dist := l.dot(faces[i][0], faces[i][3])
				if dist < min_dist {
					min_dist = dist
					closest_face = j
				}
			}
		}


	}
}

line_case :: proc(s: ^Simplex) -> Vec3 {
	ab := s.b - s.a
	ao := -s.a

	if same_direction(ab, ao) {
		return l.vector_triple_product(ab, ao, ab)
	} else {
		s.count = 1
		return ao
	}
}

triangle_case :: proc(s: ^Simplex) -> Vec3 {
	abc := l.cross(s.b - s.a, s.c - s.a)
	ac := s.c - s.a
	ao := -s.a

	if same_direction(l.cross(abc, ac), ao) {
		if same_direction(ac, ao) {
			// origin is closest to ac
			s.b = s.c
			s.count = 2
			return l.vector_triple_product(ac, ao, ac)
		} else {
			ab := s.b - s.a
			if same_direction(ab, ao) {
				// origin is closest to ab
				s.count = 2
				return l.vector_triple_product(ab, ao, ab)
			} else {
				// origin is closest to a
				s.count = 1
				return ao
			}
		}
	} else {
		ab := s.b - s.a
		if same_direction(l.cross(ab, abc), ao) {
			if same_direction(ab, ao) {
				// origin is closest to ab
				s.count = 2
				return l.vector_triple_product(ab, ao, ab)
			} else {
				// origin is closest to a
				s.count = 1
				return ao
			}
		} else {
			if same_direction(abc, ao) {
				// origin is closest to abc
				return abc
			} else {
				// origin is closest to acb
				// swap b and c
				temp_b := s.b
				temp_c := s.c
				s.b = temp_c
				s.c = temp_b
				return -abc
			}
		}
	}
}

tetrahedron_case :: proc(s: ^Simplex) -> (bool, Vec3) {
	abc := l.cross(s.b - s.a, s.c - s.a)
	ao := -s.a

	if same_direction(abc, ao) {
		// the origin is nearest to the triangle abc
		s.count = 3
		return false, triangle_case(s)
	}

	adb := l.cross(s.d - s.a, s.b - s.a)

	if same_direction(adb, ao) {
		s.c = s.b
		s.b = s.d
		s.count = 3
		return false, triangle_case(s)
	}

	bdc := l.cross(s.d - s.b, s.c - s.b)
	bo := -s.b

	if same_direction(bdc, bo) {
		s.a = s.b
		s.b = s.d
		s.count = 3
		return false, triangle_case(s)
	}

	return true, {0, 0, 0}
}
