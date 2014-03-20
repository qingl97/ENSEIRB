#ifndef POINT_H_
#define POINT_H_

#include "Vector.h"
#include "UtilMath.h"

/*
 * HW1
 * CS 6965 - Parallel Hardware Ray Tracing
 *
 * Kai Hatch
 * 00478514
 * September 3, 2011
 *
 * A Point is a triple of floats.
 *
 */

class Point {
	public:
		float x;	// X-coord
		float y;	// Y-coord
		float z;	// Z-coord

	public:
		/* Constructors */
		Point();
		Point(const float newX, const float newY, const float newZ);

		/* Operators */
		Point operator+(const Vector& v) const;	// P = P + V
		Point operator-(const Vector& v) const;	// P = P - V
		Vector operator-(const Point& p) const;	// V = P - P
		
		/* Functions */
		float distance(const Point& p) const;
};

/* Inlined functions*///////////////////////////////////////////////////////////
/* P = P + V */
inline Point Point::operator+(const Vector& v) const {
	return Point(x+v.x, y+v.y, z+v.z);
}

/* P = P - V */
inline Point Point::operator-(const Vector& v) const {
	return Point(x-v.x, y-v.y, z-v.z);
}

/* V = P - P */
inline Vector Point::operator-(const Point& p) const {
	return Vector(x-p.x, y-p.y, z-p.z);
}

/* Distance */
inline float Point::distance(const Point& p) const {
	const float x1 = (x - p.x);
	const float y1 = (y - p.y);
	const float z1 = (z - p.z);
	return sqrtApprox(x1*x1 + y1*y1 + z1*z1);
}

#endif
