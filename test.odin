package bragi

import "core:testing"
import "core:log"

@(test)
test_max :: proc(t: ^testing.T) {
	points:= [?]Vec3 {
		{10,0, 0},
		{3,40, 0},
		{2,-30, 0},
	}
	d:= Vec3{-1,0,0}
	max_point:= find_max_in_direction(points[:],d)
	testing.expect(t,max_point == {2,-30, 0}) }

@(test)
test_support :: proc(t: ^testing.T) {
	p1:= [?]Vec3 {
		{4,11, 5},
		{11,5, 3},
		{9, 9, 4},
		{-2, 30, 1}
	}
	p2:= [?]Vec3 {
		{-4,13, 0},
		{4,7, 2},
		{8,10, 5},
		{9,-4, 7},
	}
	d:= Vec3{-1,0, 0}
	sup := support(p1[:],p2[:],d)
	log.info(sup)

	testing.expect(t,sup == {-11,34, -6})
}

@(test)
test_gjk :: proc(t: ^testing.T) {
	s1:= [8]Vec3 {
		{10,10,10},
		{20,10,10},
		{20,20,10},
		{10,20,10},
		{10,10,20},
		{20,10,20},
		{20,20,20},
		{10,20,20},
	}
	s2:= [8]Vec3 {
		{15,10,15},
		{25,10,15},
		{25,20,15},
		{15,20,15},
		{15,10,25},
		{25,10,25},
		{25,20,25},
		{15,20,25},
	}

	testing.expect(t,gjk(s1[:],s2[:]))
}

@(test)
test_gjk_2d :: proc(t: ^testing.T) {
	s1:= [8]Vec3 {
		{10,10,0},
		{20,10,0},
		{20,20,0},
		{10,20,0},
		{10,10,0},
		{20,10,0},
		{20,20,0},
		{10,20,0},
	}
	s2:= [8]Vec3 {
		{15,10,0},
		{25,10,0},
		{25,20,0},
		{15,20,0},
		{15,10,0},
		{25,10,0},
		{25,20,0},
		{15,20,0},
	}

	testing.expect(t,gjk(s1[:],s2[:]))
}
