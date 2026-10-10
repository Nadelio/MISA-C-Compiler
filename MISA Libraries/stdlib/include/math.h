#ifndef _MATH_H
#define _MATH_H

#define HUGE_VAL  (1.0 / 0.0)
#define HUGE_VALF (1.0f / 0.0f)
#define INFINITY  HUGE_VALF

double sqrt(double value);
float sqrtf(float value);
double exp(double value);
float expf(float value);
double log(double value);
float logf(float value);
double sin(double value);
float sinf(float value);
double cos(double value);
float cosf(float value);
double tan(double value);
float tanf(float value);
double asin(double value);
float asinf(float value);
double acos(double value);
float acosf(float value);
double atan(double value);
float atanf(float value);
double atan2(double y, double x);
float atan2f(float y, float x);
double pow(double base, double exponent);
float powf(float base, float exponent);
double fabs(double value);
float fabsf(float value);
double hypot(double x, double y);
float hypotf(float x, float y);

#endif
