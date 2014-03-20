#include "PointLight.h"
#include "Util.h"

/**
 * Creates a PointLight from the given Trax address.  Default color is white.
 */

PointLight::PointLight(const int addr) {
	position = loadPointFromMemory(addr);
	color = Color(1.0f, 1.0f, 1.0f);
}	

/**
 * Returns the vector from this PointLight to the given Point
 */
 
Vector PointLight::getDirection(const Point& p) const{
	return (position - p);
}
