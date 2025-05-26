package bragi

import "core:math"
import rl "vendor:raylib"


Transform :: struct {
	using translation: Vec3,
	rotation: f32,
}

Triangle :: struct {
	using transform: Transform,
	points: [3]Vec3,
	colliding: bool
}

draw_circle :: proc(s: Sphere) {
	rl.DrawCircleV({s.translation.x,s.translation.y}, s.radius, rl.BLUE)
}

draw_triangle :: proc(t: Triangle) {
	points:= transformed_points(t)

	v2: [3][2]f32

	for p,i in points {
		v2[i] = {p.x,p.y}
	}

	color:= t.colliding ? rl.RED : rl.BLUE

	rl.DrawTriangle(v2[2],v2[1],v2[0], color)
}

main :: proc() {
	a: Triangle = {
		translation = {200,200,0},
		points = {
			{-30,-10,0},
			{30,-10,0},
			{0,30,0},
		}
	}

	b: Triangle = {
		translation = {400,200,0},
		points = {
			{-30,-10,0},
			{30,-10,0},
			{0,30,0},
		}
	}

	c: Sphere = {
		translation = {600, 200, 0},
		radius = 30
	}

	rl.InitWindow(800, 400, "mafs")

	for !rl.WindowShouldClose() {
		if rl.IsKeyDown(.D) {
			a.x += 0.005
		}
		if rl.IsKeyDown(.A) {
			a.x -= 0.005
		}
		if rl.IsKeyDown(.S) {
			a.y += 0.005
		}
		if rl.IsKeyDown(.W) {
			a.y -= 0.005
		}

		if rl.IsKeyDown(.E) {
			a.rotation += 0.01
		}

		a_points := transformed_points(a)
		b_points := transformed_points(b)

		a.colliding = gjk(a_points[:], b_points[:]) || gjk(a_points[:],c)
		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)
		draw_triangle(a)
		draw_triangle(b)
		draw_circle(c)
		rl.EndDrawing()
	}
}


transformed_points :: proc(t: Triangle) -> [3]Vec3 {
	points: [3]Vec3

	for p,i in t.points {
		current_point:= interpolate_point(t.transform, p)
		points[i] = current_point
	}
	return points
}


rotate :: proc(vector: Vec3, angle: f32) -> Vec3 {
	new_x:= vector.x * math.cos(angle) - vector.y * math.sin(angle)
	new_y:= vector.x * math.sin(angle) + vector.y * math.cos(angle)
	return {new_x,new_y, 0}
}


interpolate_point :: proc(transform: Transform, point: Vec3) -> Vec3 {
	x_axis := rotate({1,0, 0}, transform.rotation)
	y_axis := rotate({0,1, 0}, transform.rotation)
	return transform.translation + (x_axis * point.x) + (y_axis * point.y)
}

