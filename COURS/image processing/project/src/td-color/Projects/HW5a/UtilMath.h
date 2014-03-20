#ifndef UTILMATH_H_
#define UTILMATH_H_

#include "trax.hpp"

/**
 * Final Project - Metropolis Light Transport
 * CS 6965
 *
 * Kai Hatch
 * 00478514
 *
 * This class holds all math related constants and functions.  Cos, sin, and
 * exp approximation functions were needed because TRaX does not have any.
 *
 * All approximation functions use Taylor Series expansions.  The number of
 * terms included had to be limited due to the size of long and float, because
 * of accuracy used with factorial.
 */

const float PI 							= 3.141592f;
const float INV_PI 						= 1.f / PI;
const int 	SIN_TAYLOR_SERIES_TERMS		= 7;
const int   COS_TAYLOR_SERIES_TERMS 	= 8;
const int 	EXP_TAYLOR_SERIES_TERMS		= 8;

/**
 * Return a uniform float
 */
inline float randFloat() {
	return trax_rand();
}


/**
 * Return sin(x).  Based on Taylor Series for sine.
 */
inline float sinApprox(const float x) {
	float mappedX = x - PI;
	float result = mappedX;
	float xNum = mappedX;
	int sign = 1;

	for (int i = 1; i <= SIN_TAYLOR_SERIES_TERMS; i++) {
		sign *= -1;
		xNum *= mappedX*mappedX;

		long xDen = 1;
		int factorial = 2*i + 1;
		for (int j = 1; j <= factorial; j++) {
			xDen *= j;
		}

		float step = xNum/xDen;
		result += (sign * step);
	}

	result *= -1;
	return result;
}

/**
 * Return cos(x).  Based on Taylor Series for cosine.
 */
inline float cosApprox(const float x) {
	float mappedX = x - PI;

	float result = 1.f;
	float xNum = 1.f;
	int sign = 1;

	for (int i = 1; i <= COS_TAYLOR_SERIES_TERMS; i++) {
		sign *= -1;
		xNum *= mappedX*mappedX;

		long xDen = 1;
		int factorial = 2*i;
		for (int j = 1; j <= factorial; j++) {
			xDen *= j;
		}

		float step = xNum/xDen;
		result += (sign * step);
	}

	result *= -1;
	return result;
}

/**
 * Return e^x.  Based on Taylor Series for exponential.
 */
inline float expApprox(const float x) {
	float result = 1.f;
	float xNum = 1.f;

	for (int i = 1; i <= EXP_TAYLOR_SERIES_TERMS; i++) {
		xNum *= x;

		long xDen = 1;
		int factorial = i;
		for (int j = 1; j <= factorial; j++) {
			xDen *= j;
		}

		float step = xNum/xDen;
		result += step;
	}

	return result;
}

/**
 * Returns the sqrt(x).  Based on TRaX implementation.
 */
inline float sqrtApprox(const float x) {
	return sqrt(x);
}

#endif /* UTILMATH_H_ */
