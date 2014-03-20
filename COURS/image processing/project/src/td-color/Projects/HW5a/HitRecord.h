#ifndef HITRECORD_H_
#define HITRECORD_H_

#include "Ray.h"
#include "Vector.h"
#include "Point.h"
#include "Color.h"

/**
 * HW5
 * CS 6965 - Parallel Hardware Ray Tracing
 *
 * Kai Hatch
 * 00478514
 * October 24, 2011
 *
 * Holds relevant data to a ray-object interesections.
 *
 */

class HitRecord {
	public:
		bool didHit;
		float tMin;
		Ray ray;
		Vector normal;
		Point hitPoint;
		Color material;

		HitRecord();
};


#endif
