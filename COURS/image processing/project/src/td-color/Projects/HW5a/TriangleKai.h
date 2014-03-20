#ifndef TRIANGLEKAI_H_
#define TRIANGLEKAI_H_

#include "Vector.h"
#include "Ray.h"
#include "Point.h"
#include "Color.h"
#include "HitRecord.h"

/*
 * HW3
 * CS 6965 - Parallel Hardware Ray Tracing
 *
 * Kai Hatch
 * 00478514
 * September 23, 2011
 *
 * Represents a Triangle
 *
 */

class TriangleKai {
	public:
		Point v0;			// Vertex 0
		Point v1;			// Vertex 1
		Point v2;			// Vertex 2
		Vector normal;		// Triangle normal
		int startAddr;		// Starting address in TRaX memory

	public:
		/* Constructors */
		TriangleKai(const Point& p1, const Point& p2, const Point& p3, const int addr);

		/* Functions */
		void intersect(const Ray& ray, HitRecord& hitRec) const;

	/* Private functions */
	private:
		Color getMaterialColor() const;
};

#endif
