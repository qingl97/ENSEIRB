#ifndef POINTLIGHT_H_
#define POINTLIGHT_H_

#include "Point.h"
#include "Color.h"
#include "Vector.h"

/**
 * HW2
 * CS 6965 - Parallel Hardware Ray Tracing
 *
 * Kai Hatch
 * 00478514
 * September 16, 2011
 *
 * Represents a point light source.
 *
 */
 
class PointLight {
	public:
		Point position;
		Color color;
	
	public:
		/* Constructors */
		PointLight(const int addr);

		/* Functions */
		Vector getDirection(const Point& p) const;
};
 
#endif
