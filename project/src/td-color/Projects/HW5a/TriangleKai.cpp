#include "TriangleKai.h"
#include "Util.h"
#include "trax.hpp"

/**
 * Creates a TriangleKai with the specified Points.
 */

TriangleKai::TriangleKai(const Point& p1, const Point& p2, const Point& p3,
						 const int addr)

	: v0(p1), v1(p2), v2(p3), startAddr(addr) {

	normal = (v1 - v0).cross(v2 - v0);
	normal.normalize();
}

/**
 * Returns true if the given ray hits this TriangleKai.  The normal at the hitpoint, 
 * the hitpoint coords itself, and the ray parameter values are updated in the parameters.
 */

void TriangleKai::intersect(const Ray& ray, HitRecord& hitRec) const {
	// Book's
	float a = v0.x - v1.x;
	float b = v0.x - v2.x;
	float c = ray.direction.x;
	float d = v0.x - ray.origin.x;
	float e = v0.y - v1.y;
	float f = v0.y - v2.y; 
	float g = ray.direction.y;
	float h = v0.y - ray.origin.y;
	float i = v0.z - v1.z;
	float j = v0.z - v2.z;
	float k = ray.direction.z;
	float l = v0.z - ray.origin.z;

	float m = f * k - g * j;
	float n = h * k - g * l;
	float p = f * l - h * j;
	float q = g * i - e * k;
	float s = e * j - f * i;

	float inv_denom  = 1.f / (a * m + b * q + c * s);

	float e1 = d * m - b * n - c * p;
	float beta = e1 * inv_denom;

	if (beta < 0.0)
	 	return;

	float r = e * l - h * i;
	float e2 = a * n + d * q + c * r;
	float gamma = e2 * inv_denom;

	if (gamma < 0.0 )
	 	return;

	if (beta + gamma > 1.f)
		return;

	float e3 = a * p - b * r + d * s;
	float t = e3 * inv_denom;

	if (t < EPSILON)
		return;

	hitRec.didHit = true;
	hitRec.tMin = t;
	hitRec.ray = ray;
	hitRec.normal = normal;
	hitRec.hitPoint = ray.origin + (ray.direction * t);
	hitRec.material = getMaterialColor();
}

/**
 * Returns the material color for this triangle
 */

Color TriangleKai::getMaterialColor() const {
	int matID 		= loadi(startAddr, 10);
	int matStart	= loadi(0, 9);
	int matAddr 	= matStart + (matID * 25);
	float r 		= loadf(matAddr, 4);
	float g 		= loadf(matAddr, 5);
	float b			= loadf(matAddr, 6);

	return Color(r, g, b);
}
