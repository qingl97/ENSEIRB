#ifndef PINHOLECAMERA_H_
#define PINHOLECAMERA_H_

#include "Point.h"
#include "Vector.h"
#include "Ray.h"

/*
 * HW2
 * CS 6965 - Parallel Hardware Ray Tracing
 *
 * Kai Hatch
 * 00478514
 * September 16, 2011
 *
 * Represents a Pinhole camera.
 *
 */

class PinholeCamera {
	public:
		Point eye;
		Vector up;
		Vector u, v, w;

	public:
		/* Constructors */
		PinholeCamera(const int addr);
};

#endif
