#ifndef RAY_H_
#define RAY_H_

#include "Point.h"
#include "Vector.h"

/*
 * HW1
 * CS 6965 - Parallel Hardware Ray Tracing
 *
 * Kai Hatch
 * 00478514
 * September 3, 2011
 *
 * A Ray consists of a Point and a Vector.  Variables are public for
 * performance.
 *
 */

class Ray {
	public:
		Point origin;
		Vector direction;

	public:
		/* Constructors */
		Ray();
		Ray(const Point& p);
		Ray(const Point& p, const Vector& v);
};

#endif
