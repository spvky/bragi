package bragi

import l "core:math/linalg"
import sa "core:container/small_array"
import "core:log"

gjk :: proc(p1,p2: []Vec2) -> bool {
	index: int
	a,b,c,d,ao,ab,ac,abperp,acperp: Vec2
	simplex: [3]Vec2

	
	d = avg(p1) - avg(p2)
	log.infof("Initial direction: %v",d)
	if d.x == 0 && d.y == 0 {d.x = 1}
	
	a = support(p1,p2,d)

	log.infof("Adding initial support point of of %v", a)
	simplex[0] = a
	
	if l.dot(a,d) <= 0 {
	log.infof("Did not pass origin with initial support: %v and initial direction: %v, exiting",a,d)
		return false
	}
	d = -a
	log.infof("Flipping direction to %v",d)

	for {
		index += 1
		log.infof("Starting loop with index of %v", index)
		a = support(p1,p2,d)
		log.infof("Adding support %v  on index %v", a, index)
		simplex[0] = a
		simplex[index] = a
		if l.dot(a,d) <= 0 {
			log.infof("New point %v did not pass origin with direction %v, exiting", a, d)
			return false
		}
		ao = -a

		if index < 2 {
			b = simplex[0]
			ab = b - a
			d = vtp(ab,ao,ab)
			if l.length2(d) == 0 {d = perependicular(ab)}

			continue
		}

		b = simplex[1]
		c = simplex[0]
		ab = b - a
		ac = c - a

		acperp = vtp(ac, ab, ab)

		if l.dot(acperp, ao) >= 0 {
			d = acperp
		} else {
			abperp = vtp(ac,ab,ab)
			if l.dot(abperp,ao) < 0 {return true}
			simplex[0] = simplex[1]
			d = abperp
		}

		simplex[1] = simplex[2]
		index -= 1
	}
	return false
}

