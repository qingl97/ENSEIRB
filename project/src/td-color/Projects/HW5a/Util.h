#ifndef UTIL_H_
#define UTIL_H_

#include "trax.hpp"
#include "Vector.h"
#include "Point.h"
#include "TriangleKai.h"
#include "Box.h"

/**
 * Final Project - Metropolis Light Transport
 * CS 6965
 *
 * Kai Hatch
 * 00478514
 *
 * This file holds convenience functions for loading certain objects out
 * of TRaX memory.
 */

const float EPSILON = 0.001;

/**
 * Returns a Vector created writh values read starting from the given address
 */
inline Vector loadVectorFromMemory(const int addr) {
	float x = loadf(addr, 0);
	float y = loadf(addr, 1);
	float z = loadf(addr, 2);
	return Vector(x, y, z);
}

/**
 * Returns a Point created with values read starting from the given address.
 */
inline Point loadPointFromMemory(const int addr) {
	float x = loadf(addr, 0);
	float y = loadf(addr, 1);
	float z = loadf(addr, 2);
	return Point(x, y, z);
}

/**
 * Returns a TriangleKai created with values read starting from the given address.
 */
inline TriangleKai loadTriFromMemory(const int addr) {
	Point p1(loadf(addr, 0),
			 loadf(addr, 1),
			 loadf(addr, 2));
	Point p2(loadf(addr, 3),
			 loadf(addr, 4),
			 loadf(addr, 5));
	Point p3(loadf(addr, 6),
			 loadf(addr, 7),
			 loadf(addr, 8));
	return TriangleKai(p1, p2, p3, addr);
}

/**
 * Returns a bounding box with values read starting from the given address
 */
inline Box loadBoxFromMemory(const int nodeAddr) {
	// cMin
	float cMinX = loadf(nodeAddr, 0);
	float cMinY = loadf(nodeAddr, 1);
	float cMinZ = loadf(nodeAddr, 2);

	// cMax
	float cMaxX = loadf(nodeAddr, 3);
	float cMaxY = loadf(nodeAddr, 4);
	float cMaxZ = loadf(nodeAddr, 5);

	// Make Box
	Vector cMin(cMinX, cMinY, cMinZ);
	Vector cMax(cMaxX, cMaxY, cMaxZ);
	return Box(cMin, cMax);
}

#endif /* UTIL_H_ */
