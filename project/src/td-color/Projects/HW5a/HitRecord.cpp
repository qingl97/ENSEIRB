#include "HitRecord.h"

/**
 * Constructs a HitRecord with all default values, except tMin gets a large
 * float.
 */
HitRecord::HitRecord()
	: didHit(false),
	  tMin(999999.9f),
	  ray(),
	  normal(),
	  hitPoint(),
	  material() {
}
