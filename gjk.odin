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
		simplex[index] = a
		log.infof("Adding support %v  on index %v", a, index)
		log.infof("Current Simplex: %v", simplex)
		if l.dot(a,d) <= 0 {
			log.infof("New point %v did not pass origin with direction %v, exiting", a, d)
			return false
		}
		ao = -a
		log.infof("AO = %v", ao)

		if index < 2 {
			b = simplex[0]
			ab = b - a
			d = vtp(ab,ao,ab)
			log.infof("Setting direction to  triple(ab,ao,ab): %v", d)
			if l.length2(d) == 0 {
				d = perependicular(ab)
				log.infof("Invalid direction, setting to %v", d)
			}

			continue
		}
		log.infof("Three points in simplex, checking origin")

		b = simplex[1]
		c = simplex[0]
		ab = b - a
		log.infof("AB = %v", ab)
		ac = c - a
		log.infof("AC = %v", ac)
		acperp = vtp(ac, ab, ab)
		log.infof("ACperp = %v", acperp)

		if l.dot(acperp, ao) >= 0 {
			d = acperp
			log.infof("ACperp points towards origin, setting direction to %v",d)
		} else {
			abperp = vtp(ac,ab,ab)
			if l.dot(abperp,ao) < 0 {return true}
			simplex[0] = simplex[1]
			d = abperp
			log.infof("ABperp invalid, setting direction to %v and shuffling",d)
		}

		simplex[1] = simplex[2]
		index -= 1
	}
	return false
}

