#ifndef BOX_H_
#define BOX_H_

#include "Vector.h"
#include "Ray.h"
#include "Point.h"
#include "HitRecord.h"

/*
 * HW3
 * CS 6965 - Parallel Hardware Ray Tracing
 *
 * Kai Hatch
 * 00478514
 * September 21, 2011
 *
 * Represents a Box
 *
 */

class Box {
	public:
		float x0, y0, z0;			// First corner coords
		float x1, y1, z1;			// Second corner coords

	public:
		/* Constructors */
		Box(const Vector& min, const Vector& max);

		/* Functions */
		void intersect(const Ray& ray, HitRecord& hitRec) const;
};

#endif
