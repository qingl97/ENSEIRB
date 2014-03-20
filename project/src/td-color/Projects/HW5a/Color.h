#ifndef COLOR_H_
#define COLOR_H_

/*
 * HW1
 * CS 6965 - Parallel Hardware Ray Tracing
 *
 * Kai Hatch
 * September 2, 2011
 *
 * A Color is a triple of floats, ranged [0.0, 1.0]. Fields are public for
 * performance.
 *
 */

class Color {

	// Variables
	public:
		float r;	// Red
		float g;	// Green
		float b;	// Blue

	// Functions
	public:
		/* Constructors */
		Color();									// Default color is black
		Color(const float f);
		Color(const float red, const float green, const float blue);

		/* Scalar */
		Color& operator+=(const float f);			// C += k
		Color& operator*=(const float f);			// C *= k
		Color& operator/=(const float f);			// C /= k
		Color operator*(const float f) const;		// C = C * k
		Color operator/(const float f) const;		// C = C / k

		/* Color */
		Color operator+(const Color& c) const;		// C = C + C
		Color operator-(const Color& c) const;		// C = C - C
		Color operator*(const Color& c) const;		// C = C * C
		Color operator/(const Color& c) const;		// C = C / C
		Color& operator+=(const Color& c);			// C += C
		Color& operator*=(const Color& c);			// C *= C

		float getLuminance() const;
		Color& normalize();
		void clear();
		bool isBlack() const;
};

/* INLINE FUNCTIONS *///////////////////////////////////////////////////////////
/* Scalar add */
inline Color& Color::operator+=(const float f) {
	r += f;
	g += f;
	b += f;
	return (*this);
}

/* Scalar multiply */
inline Color& Color::operator*=(const float f) {
	r *= f;
	g *= f;
	b *= f;
	return (*this);
}

/* Scalar mulitply */
inline Color Color::operator*(const float f) const {
	return Color(r*f, g*f, b*f);
}

/* Scalar divide */
inline Color& Color::operator/=(const float f) {
	r /= f;
	g /= f;
	b /= f;
	return (*this);
}

/* Scalar divide */
inline Color Color::operator/(const float f) const {
	return Color(r/f, g/f, b/f);
}

/* Color add */
inline Color Color::operator+(const Color& c) const {
	return Color(r+c.r, g+c.g, b+c.b);
}

/* Color subtract */
inline Color Color::operator-(const Color& c) const {
	return Color(r-c.r, g-c.g, b-c.b);
}

/* Color multiply */
inline Color Color::operator*(const Color& c) const {
	return Color(r*c.r, g*c.g, b*c.b);
}

/* Color divide */
inline Color Color::operator/(const Color& c) const {
	return Color(r/c.r, g/c.g, b/c.b);
}

/* Color addEquals */
inline Color& Color::operator+=(const Color& c) {
	r += c.r;
	g += c.g;
	b += c.b;
	return (*this);
}

/* Color multiplyEquals */
inline Color& Color::operator*=(const Color& c) {
	r *= c.r;
	g *= c.g;
	b *= c.b;
	return (*this);
}

/* Normalize colors in-range */
inline Color& Color::normalize() {
	float max = 1.0f;
	if (r > max) {max = r;}
	if (g > max) {max = g;}
	if (b > max) {max = b;}
	if (max > 1.0f) {
		r /= max;
		g /= max;
		b /= max;
	}
	return (*this);
}

/* Resets color to black */
inline void Color::clear() {
	r = 0.0f;
	g = 0.0f;
	b = 0.0f;
}

/* Returns true if this Color is black */
inline bool Color::isBlack() const {
	if (r == 0.0f && g == 0.0f && b == 0.0f) {
		return true;
	}

	return false;
}

/* Luminance */
inline float Color::getLuminance() const {
	// Rec. 601 luma
	float lumR = 0.299f * r;
	float lumG = 0.587f * g;
	float lumB = 0.114f * b;
	return (lumR + lumG + lumB);
}

#endif
