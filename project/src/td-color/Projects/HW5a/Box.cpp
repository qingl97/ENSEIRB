#include "Box.h"
#include "Util.h"

/**
 * Creates a Box with the given "min" and "max" vectors.
 */

Box::Box(const Vector& min, const Vector& max)
	: x0(min.x), y0(min.y), z0(min.z), x1(max.x), y1(max.y), z1(max.z) {
}

/**
 * Returns if the Box is intersected by the given ray.  It updates the
 * HitRecord of the interesection, if any.
 */

void Box::intersect(const Ray& ray, HitRecord& hitRec) const {
	const float originX = ray.origin.x;
	const float originY = ray.origin.y;
	const float originZ = ray.origin.z;
	const float dirX = ray.direction.x;
	const float dirY = ray.direction.y;
	const float dirZ = ray.direction.z;

	float txMin, tyMin, tzMin;
	float txMax, tyMax, tzMax;
	float t0, t1;

	// X-coord
	const float a = 1.0f / dirX;
	if (a >= 0.0f) {
		txMin = (x0 - originX) * a;
		txMax = (x1 - originX) * a;
	}
	else {
		txMin = (x1 - originX) * a;
		txMax = (x0 - originX) * a;
	}

	// Y-coord
	const float b = 1.0f / dirY;
	if (b >= 0.0f) {
		tyMin = (y0 - originY) * b;
		tyMax = (y1 - originY) * b;
	}
	else {
		tyMin = (y1 - originY) * b;
		tyMax = (y0 - originY) * b;
	}

	// Z-coord
	const float c = 1.0f / dirZ;
	if (c >= 0.0f) {
		tzMin = (z0 - originZ) * c;
		tzMax = (z1 - originZ) * c;
	}
	else {
		tzMin = (z1 - originZ) * c;
		tzMax = (z0 - originZ) * c;
	}

	// Largest entering T-value
	t0 = txMin > tyMin ? txMin : tyMin;
	if (tzMin > t0)
		t0 = tzMin;

	// Smallest exiting T-value
	t1 = txMax < tyMax ? txMax : tyMax;
	if (tzMax < t1)
		t1 = tzMax;

	// Hit
	hitRec.didHit = (t0 < t1 && t1 > EPSILON);
}
