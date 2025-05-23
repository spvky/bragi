package bragi

import "core:testing"
import "core:log"

// @(test)
// test_max :: proc(t: ^testing.T) {
// 	points:= [?]Vec2 {
// 		{-10,0},
// 		{-3,40},
// 		{0,-30},
// 	}
// 	d:= [2]f32{-1,0}
// 	max_point:= find_max_in_direction(points[:],d)
// 	testing.expect(t,max_point.x == -10)
// }

// @(test)
// test_support :: proc(t: ^testing.T) {
// 	p1:= [?]Vec2 {
// 		{-10,0},
// 		{-3,40},
// 		{0,-30},
// 	}
// 	p2:= [?]Vec2 {
// 		{20,17},
// 		{12,11},
// 		{0,-30},
// 	}
// 	d:= [2]f32{-1,0}
// 	sup := support(p1[:],p2[:],d)

// 	testing.expect(t,sup == {-30,-17})
// }

@(test)
test_gjk :: proc(t: ^testing.T) {
	a:= [4]Vec2 {
		{10,10},
		{20,20},
		{20,10},
		{10,20}
	}

	b:= [4]Vec2 {
		{5,10},
		{15,20},
		{15,10},
		{5,20}
	}

	testing.expect(t,gjk(a[:],b[:]))
}

@(test)
dot_test :: proc(t: ^testing.T) {
	log.infof("Dot of zero")
}

