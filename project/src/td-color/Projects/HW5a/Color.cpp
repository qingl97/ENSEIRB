#include "Color.h"

/**
 * Creates a Color with the default color black.
 */

Color::Color()
	: r(0.0f), g(0.0f), b(0.0f) {
}

/**
 * Creates a Color with the specified value.
 */

Color::Color(const float f)
	: r(f), g(f), b(f) {
}

/**
 * Creates a Color with the specified values.
 */

Color::Color(const float red, const float green, const float blue)
	: r(red), g(green), b(blue) {
}
