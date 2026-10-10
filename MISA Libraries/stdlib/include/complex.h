#ifndef _COMPLEX_H
#define _COMPLEX_H

#include <math.h>

#define complex _Complex
#define _Complex_I ((float _Complex){ 0.0f, 1.0f })
#define I _Complex_I

static inline double creal(double complex value)
{
	return ((double *)&value)[0];
}

static inline double cimag(double complex value)
{
	return ((double *)&value)[1];
}

static inline float crealf(float complex value)
{
	return ((float *)&value)[0];
}

static inline float cimagf(float complex value)
{
	return ((float *)&value)[1];
}

static inline double complex conj(double complex value)
{
	return (double complex){ creal(value), -cimag(value) };
}

static inline float complex conjf(float complex value)
{
	return (float complex){ crealf(value), -cimagf(value) };
}

static inline double cabs(double complex value)
{
	return hypot(creal(value), cimag(value));
}

static inline float cabsf(float complex value)
{
	return hypotf(crealf(value), cimagf(value));
}

static inline double carg(double complex value)
{
	return atan2(cimag(value), creal(value));
}

static inline float cargf(float complex value)
{
	return atan2f(cimagf(value), crealf(value));
}

static inline double complex cexp(double complex value)
{
	double magnitude = exp(creal(value));
	return (double complex){
		magnitude * cos(cimag(value)),
		magnitude * sin(cimag(value))
	};
}

static inline float complex cexpf(float complex value)
{
	float magnitude = expf(crealf(value));
	return (float complex){
		magnitude * cosf(cimagf(value)),
		magnitude * sinf(cimagf(value))
	};
}

static inline double complex clog(double complex value)
{
	return (double complex){ log(cabs(value)), carg(value) };
}

static inline float complex clogf(float complex value)
{
	return (float complex){ logf(cabsf(value)), cargf(value) };
}

static inline double complex csqrt(double complex value)
{
	double x = creal(value);
	double y = cimag(value);
	double magnitude = cabs(value);
	double real_part = sqrt((magnitude + x) / 2.0);
	double imag_part = sqrt((magnitude - x) / 2.0);
	if (y < 0.0) imag_part = -imag_part;
	return (double complex){ real_part, imag_part };
}

static inline float complex csqrtf(float complex value)
{
	float x = crealf(value);
	float y = cimagf(value);
	float magnitude = cabsf(value);
	float real_part = sqrtf((magnitude + x) / 2.0f);
	float imag_part = sqrtf((magnitude - x) / 2.0f);
	if (y < 0.0f) imag_part = -imag_part;
	return (float complex){ real_part, imag_part };
}

static inline double complex cpow(double complex base, double complex exponent)
{
	return cexp(exponent * clog(base));
}

static inline float complex cpowf(float complex base, float complex exponent)
{
	return cexpf(exponent * clogf(base));
}

static inline double complex csin(double complex value)
{
	double x = creal(value);
	double y = cimag(value);
	double ey = exp(y);
	double emy = exp(-y);
	double cosh_y = (ey + emy) / 2.0;
	double sinh_y = (ey - emy) / 2.0;
	return (double complex){ sin(x) * cosh_y, cos(x) * sinh_y };
}

static inline float complex csinf(float complex value)
{
	float x = crealf(value);
	float y = cimagf(value);
	float ey = expf(y);
	float emy = expf(-y);
	float cosh_y = (ey + emy) / 2.0f;
	float sinh_y = (ey - emy) / 2.0f;
	return (float complex){ sinf(x) * cosh_y, cosf(x) * sinh_y };
}

static inline double complex ccos(double complex value)
{
	double x = creal(value);
	double y = cimag(value);
	double ey = exp(y);
	double emy = exp(-y);
	double cosh_y = (ey + emy) / 2.0;
	double sinh_y = (ey - emy) / 2.0;
	return (double complex){ cos(x) * cosh_y, -sin(x) * sinh_y };
}

static inline float complex ccosf(float complex value)
{
	float x = crealf(value);
	float y = cimagf(value);
	float ey = expf(y);
	float emy = expf(-y);
	float cosh_y = (ey + emy) / 2.0f;
	float sinh_y = (ey - emy) / 2.0f;
	return (float complex){ cosf(x) * cosh_y, -sinf(x) * sinh_y };
}

static inline double complex ctan(double complex value)
{
	return csin(value) / ccos(value);
}

static inline float complex ctanf(float complex value)
{
	return csinf(value) / ccosf(value);
}

static inline double complex casin(double complex value)
{
	double complex iz = (double complex){ -cimag(value), creal(value) };
	double complex root = csqrt(1.0 - value * value);
	double complex logarithm = clog(iz + root);
	return (double complex){ cimag(logarithm), -creal(logarithm) };
}

static inline float complex casinf(float complex value)
{
	float complex iz = (float complex){ -cimagf(value), crealf(value) };
	float complex root = csqrtf(1.0f - value * value);
	float complex logarithm = clogf(iz + root);
	return (float complex){ cimagf(logarithm), -crealf(logarithm) };
}

static inline double complex cacos(double complex value)
{
	return 1.5707963267948966 - casin(value);
}

static inline float complex cacosf(float complex value)
{
	return 1.5707963267948966f - casinf(value);
}

static inline double complex catan(double complex value)
{
	double complex iz = (double complex){ -cimag(value), creal(value) };
	double complex difference = clog(1.0 - iz) - clog(1.0 + iz);
	return (double complex){ -cimag(difference) / 2.0, creal(difference) / 2.0 };
}

static inline float complex catanf(float complex value)
{
	float complex iz = (float complex){ -cimagf(value), crealf(value) };
	float complex difference = clogf(1.0f - iz) - clogf(1.0f + iz);
	return (float complex){ -cimagf(difference) / 2.0f, crealf(difference) / 2.0f };
}

static inline double complex csinh(double complex value)
{
	return (cexp(value) - cexp(-value)) / 2.0;
}

static inline float complex csinhf(float complex value)
{
	return (cexpf(value) - cexpf(-value)) / 2.0f;
}

static inline double complex ccosh(double complex value)
{
	return (cexp(value) + cexp(-value)) / 2.0;
}

static inline float complex ccoshf(float complex value)
{
	return (cexpf(value) + cexpf(-value)) / 2.0f;
}

static inline double complex ctanh(double complex value)
{
	return csinh(value) / ccosh(value);
}

static inline float complex ctanhf(float complex value)
{
	return csinhf(value) / ccoshf(value);
}

static inline double complex casinh(double complex value)
{
	return clog(value + csqrt(value * value + 1.0));
}

static inline float complex casinhf(float complex value)
{
	return clogf(value + csqrtf(value * value + 1.0f));
}

static inline double complex cacosh(double complex value)
{
	return clog(value + csqrt(value + 1.0) * csqrt(value - 1.0));
}

static inline float complex cacoshf(float complex value)
{
	return clogf(value + csqrtf(value + 1.0f) * csqrtf(value - 1.0f));
}

static inline double complex catanh(double complex value)
{
	return (clog(1.0 + value) - clog(1.0 - value)) / 2.0;
}

static inline float complex catanhf(float complex value)
{
	return (clogf(1.0f + value) - clogf(1.0f - value)) / 2.0f;
}

static inline double complex cproj(double complex value)
{
	return value;
}

static inline float complex cprojf(float complex value)
{
	return value;
}

#endif
