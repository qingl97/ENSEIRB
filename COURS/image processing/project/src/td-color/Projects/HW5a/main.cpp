#include "trax.hpp"
#include "Util.h"
#include "HitRecord.h"
#include "Color.h"
#include "TriangleKai.h"
#include "Box.h"
#include "PinholeCamera.h"
#include "PointLight.h"

//#include <ctime>
#include <iostream>
using std::cout;


/* Holds all scene/program data that all functions need.  This is here because
 * the main program is global.
 */
struct MainInfo {
	// Image
	int width, height;
	float invWidth, invHeight;
	int samplesPerPixel;
	int maxDepth;

	// Camera
	float pixelSize;
	PinholeCamera* camera;

	// Light
	PointLight* light;

	// Shading
	float Kd;
	Color* bkgdColor;

	// Trax
	int startBVH;
	int startFB;
};

/**
 * Intersects the given triangles in TRaX memory starting at address "startTris"
 * and populates the HitRecord with intersection information, if any.
 */
void intersectTris(const int numTris, const int startTris, const Ray& ray,
				   HitRecord& rayHitRec) {

	// All triangles
	for (int i = 0; i < numTris; i++) {
		HitRecord tempRec;
		TriangleKai tri = loadTriFromMemory(startTris + (i*11));
		tri.intersect(ray, tempRec);

		// Triangle hit
		if ((tempRec.didHit == true) && (tempRec.tMin < rayHitRec.tMin)) {
			rayHitRec = tempRec;
		}
	}
}

/**
 * Returns relavant shadow ray-object intersection, if any, from triangles
 * in TRaX's memory.
 */
void shadowHit(const int numTris, const int startTris, const Ray& ray,
			   HitRecord& rayHitRec, const MainInfo& info) {

	const PointLight* light = info.light;

	// Light to hit point distance
	float dist = light->position.distance(ray.origin);

	// All triangles
	for (int i = 0; i < numTris; i++) {
		HitRecord tempRec;
		TriangleKai tri = loadTriFromMemory(startTris + (i*11));
		tri.intersect(ray, tempRec);

		// Triangle hit
		if ((tempRec.didHit == true) && (tempRec.tMin < dist)) {
			rayHitRec = tempRec;
			return;
		}
	}
}

/**
 * Iterative search though the scene BVH.  If "shadowBVH" is true, then the ray
 * searching the BVH is a shadow ray.  Relavant ray-object intersection is
 * stored in the HitRecord reference.
 */
void searchBVH(const Ray& ray, HitRecord& rayHitRec, const bool shadowBVH,
			   const MainInfo& info) {

	const int& startBVH = info.startBVH;

	int stack[32];
	int currentNodeID = 0;
	int stackPointer = -1;

	while (true) {
		int nodeAddr = startBVH + (currentNodeID * 8);
		Box boundBox(loadBoxFromMemory(nodeAddr));
		HitRecord boxHitRec;
		boundBox.intersect(ray, boxHitRec);

		// Intersected bounding box
		if (boxHitRec.didHit == true) {

			// Node info
			int numChildren = loadi(nodeAddr, 6);
			int leftChildID = loadi(nodeAddr, 7);
			int rightChildID = leftChildID + 1;

			// Interior node
			if (numChildren < 0) {
				stack[++stackPointer] = rightChildID;
				currentNodeID = leftChildID;
				continue;
			}

			// Child node (PRIMARY)
			if (shadowBVH == false)	{
				intersectTris(numChildren, leftChildID, ray, rayHitRec);
			}

			// Child node (SHADOW)
			else {
				shadowHit(numChildren, leftChildID, ray, rayHitRec, info);
			}
		}

		// Stack empty
		if (stackPointer == -1) {
			return;
		}

		// Next node
		currentNodeID = stack[stackPointer--];
	}
}

/**
 * Calculates direct illumination from the given HitRecord.
 */
Color directShade(const HitRecord& record, const MainInfo& info) {
	const PointLight* light = info.light;
	const float& Kd = info.Kd;

	Ray ray = record.ray;
	Vector normal = record.normal;
	Point hitPoint = record.hitPoint;
	Color Cd = record.material;
	Color Ld;

	// Direction to light
	Vector wi = light->getDirection(hitPoint);
	wi.normalize();

	// Reverse back-side lighting
	float cosTheta = normal.dot(ray.direction);
	if (cosTheta > 0) {
		normal = normal * -1;
	}

	// NdotL
	float nDotWi = normal.dot(wi);

	// Facing camera
	if (nDotWi > 0.f) {
		HitRecord shadowHitRec;
		Ray shadowRay(hitPoint, wi);
		searchBVH(shadowRay, shadowHitRec, true, info);

		// Diffuse shading
		if (shadowHitRec.didHit == false) {
			Color f = (Cd * Kd);
			Color Li = light->color;
			Ld += f * Li * nDotWi;
		}
	}

	return Ld;
}

/**
 * Calculates the given pixel color value of a MLTSample, and its camera path.
 */
Color PathL(const float x, const float y, const MainInfo& info) {
	const int& maxDepth = info.maxDepth;
	const Color& bkgdColor = *(info.bkgdColor);
	const PinholeCamera* camera = info.camera;

	// Camera ray
	Vector dir = (camera->w + (camera->u*x) + (camera->v*y));
	dir.normalize();
	Ray ray(camera->eye, dir);

	// Calculate path value
	int depth = 0;
	Color attenuation(1.f);
	Color L;
	while (depth != maxDepth) {
		HitRecord r;
		searchBVH(ray, r, false, info);

		// Ray-object intersection
		if (r.didHit) {
			L += directShade(r, info) * attenuation;
			attenuation *= r.material;

			// Suffern cosine hemisphere sampling //////////////////////////////
			const Vector& normal = r.normal;
			Vector w = r.normal;
			Vector v = Vector(0.0034f, 1.f, 0.0071f).cross(w);
			v.normalize();
			Vector u = v.cross(w);

			float randX = randFloat();
			float randY = randFloat();

			float cosPhi = cosApprox(2.0f * PI * randX);
			float sinPhi = sinApprox(2.0f * PI * randX);
			float cosTheta = sqrtApprox(1.f - randY);
			float sinTheta = sqrtApprox(1.f - cosTheta*cosTheta);
			float pu = sinTheta * cosPhi;
			float pv = sinTheta * sinPhi;
			float pw = cosTheta;

			Vector wi = u*pu + v*pv + w*pw;
			wi.normalize();
			ray = Ray(r.hitPoint, wi);
			////////////////////////////////////////////////////////////////////
		}

		// Ray left scene
		else {
			L += bkgdColor * attenuation;
			break;
		}

		// Increment depth
		depth++;
	}

	// Return total color
	return L;
}

/**
 * Main rendering loop
 */
void render(MainInfo& info) {
	// MainInfo declarations to save typing space
	const int& width = info.width;
	const int& height = info.height;
	const float& pixelSize = info.pixelSize;
	const int& samplesPerPixel = info.samplesPerPixel;
	const int& maxDepth = info.maxDepth;
	const int& startFB = info.startFB;

	const int numPixels = width*height;
	const int n = (int) sqrt((float) samplesPerPixel);

	// Main render loop
	int addrFB = startFB;
	for (int i = atomicinc(0); i < numPixels; i = atomicinc(0)) {
		Color L;
		cout << "Done: " << ((float) (i+1) / (float) numPixels) * 100 << "%\n";

		int imageX = i % width;
		int imageY = i / width;

		/*// Regular sampling (no sampling is 1 reg)
		for (int p = 0; p < n; p++) {
			for (int q = 0; q < n; q++) {
				float worldX = pixelSize * (imageX - 0.5f * width + (q + 0.5f) / n) / width;
				float worldY = pixelSize * (imageY - 0.5f * height + (p + 0.5f) / n) / height;
				L += PathL(worldX, worldY, info);
			}
		}*/

		// Jittered sampling
		for (int p = 0; p < n; p++) {
			for (int q = 0; q < n; q++) {
				float worldX = pixelSize * (imageX - 0.5f * width + (q + randFloat()) / n) / width;
				float worldY = pixelSize * (imageY - 0.5f * height + (p + randFloat()) / n) / height;
				L += PathL(worldX, worldY, info);
			}
		}

		/*// Random sampling
		for (int p = 0; p < samplesPerPixel; p++) {
			float worldX = pixelSize * (imageX - 0.5f * width + randFloat()) / width;
			float worldY = pixelSize * (imageY - 0.5f * height + randFloat()) / height;
			L += PathL(worldX, worldY, info);
		}*/

		L /= samplesPerPixel;
		L.normalize();

		storef(L.r, addrFB, 0);
		storef(L.g, addrFB, 1);
		storef(L.b, addrFB, 2);
		addrFB += 3;
	}
}

/**
 * Main function
 */
int main() {
	// Init TRaX
	trax_setup();

	/* Rendering Selections ***************************************************/
	MainInfo info;

	// Image info
	info.width 									= GetXRes();
	info.height 								= GetYRes();
	info.invWidth								= GetInvXRes();
	info.invHeight								= GetInvYRes();
	info.samplesPerPixel 						= 20;
	info.maxDepth 								= 1;

	// Camera
	PinholeCamera camera(GetCamera());
	info.pixelSize 								= 2.0f;
	info.camera									= &camera;

	// Light
	PointLight light(GetLight());
	info.light 									= &light;

	// Shading
	Color bkgdColor(0.561f, 0.729f, 0.988f);
	info.Kd 									= 0.7f;
	info.bkgdColor 								= &bkgdColor;

	// Trax
	info.startBVH 								= GetBVH();
	info.startFB 								= GetFrameBuffer();
	/**************************************************************************/

	// Render and cleanup
	//clock_t start = clock();
	render(info);
	//clock_t end = clock() - start;
	//cout << ((float) end / (float) CLOCKS_PER_SEC);

	trax_cleanup();

	return 0;
}
