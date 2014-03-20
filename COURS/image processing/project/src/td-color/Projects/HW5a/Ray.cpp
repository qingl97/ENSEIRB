#include "Ray.h"

/**
 * Default constructor, using the default Point and Vector values.
 */
 
Ray::Ray()
	: origin(), direction() {
}

/**
 * Creates a Ray with the given Point and the default vector
 */

Ray::Ray(const Point& p)
	: origin(p), direction() {
}

/**
 * Creates a Ray with the given Point and Vector.
 */
 
Ray::Ray(const Point& p, const Vector& v)
	: origin(p), direction(v) {
}
