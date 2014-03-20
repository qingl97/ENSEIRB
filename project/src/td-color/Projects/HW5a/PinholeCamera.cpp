#include "PinholeCamera.h"
#include "Util.h"

/**
 * Creates a PinholeCamera from the camera stored in Trax global memory
 */

PinholeCamera::PinholeCamera(const int addr) {
	eye = loadPointFromMemory(addr);
	up = loadVectorFromMemory(addr + 9);
	u = loadVectorFromMemory(addr + 15);
	v = loadVectorFromMemory(addr + 18);
	w = loadVectorFromMemory(addr + 12);
}
