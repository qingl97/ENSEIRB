#include "Point.h"

/**
 * Creates a Point with default location (0,0,0).
 */

Point::Point()
	: x(0.0f), y(0.0f), z(0.0f) {
}

/**
 * Creates a Point with the given X, Y, and Z-coords.
 */

Point::Point(const float newX, const float newY, const float newZ)
	: x(newX), y(newY), z(newZ) {
}
