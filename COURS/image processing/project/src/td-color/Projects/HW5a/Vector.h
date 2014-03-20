#ifndef VECTOR_H_
#define VECTOR_H_

#include "UtilMath.h"

/*
 * HW1
 * CS 6965 - Parallel Hardware Ray Tracing
 *
 * Kai Hatch
 * 00478514
 * September 3, 2011
 *
 * A Vector is a triple of floats. Fields are public for performance.
 *
 */

class Vector {
	public:
		float x;	// X-coord
		float y;	// Y-coord
		float z;	// Z-coord

	public:
		/* Constructors */
		Vector();
		Vector(const float newX, const float newY, const float newZ);

		/* Operators */
		Vector operator-() const;					// -V
		Vector operator*(const float f) const;		// V = V * s
		Vector operator/(const float f) const;		// V = V / s
		Vector operator+(const Vector& v) const;	// V = V + V
		Vector operator-(const Vector& v) const;	// V = V - V

		/* Functions */
		float dot(const Vector& v) const;			// Dot product
		Vector cross(const Vector& v) const;		// Cross product
		float length() const;						// Vector length
		void normalize();							// Normalize
};

/* INLINE FUNCTIONS *///////////////////////////////////////////////////////////
/* Unary minus */
inline Vector Vector::operator-() const {
	return Vector(-x, -y, -z);
}

/* Scalar multiplication */
inline Vector Vector::operator*(const float f) const {
	return Vector(x*f, y*f, z*f);
}

/* Scalar division */
inline Vector Vector::operator/(const float f) const {
	return Vector(x/f, y/f, z/f);
}

/* Vector addition */
inline Vector Vector::operator+(const Vector& v) const {
	return Vector(x+v.x, y+v.y, z+v.z);
}

/* Vector subtraction */
inline Vector Vector::operator-(const Vector& v) const {
	return Vector(x-v.x, y-v.y, z-v.z);
}

/* Dot product */
inline float Vector::dot(const Vector& v) const {
	return (x*v.x + y*v.y + z*v.z);
}

/* Cross product */
inline Vector Vector::cross(const Vector& v) const {
	return Vector(y*v.z - z*v.y, z*v.x - x*v.z, x*v.y - y*v.x);
}

/* Vector length */
inline float Vector::length() const {
	return sqrtApprox(x*x + y*y + z*z);
}

/* Normalize */
inline void Vector::normalize() {
	float length = sqrtApprox(x*x + y*y + z*z);
	x /= length;
	y /= length;
	z /= length;
}

#endif
