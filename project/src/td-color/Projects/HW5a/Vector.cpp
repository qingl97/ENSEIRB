#include "Vector.h"

/**
 * Default constructor
 */
 
Vector::Vector()
	: x(0.0f), y(0.0f), z(0.0f) {
}

/**
 * Creates a Vector with the given X, Y, and Z-coords for its direction.
 */
 
Vector::Vector(const float newX, const float newY, const float newZ)
	: x(newX), y(newY), z(newZ) {
}
