#include <complex.h>

static float complex add_scaled(float complex left, float complex right, float scale)
{
	return left + right * scale;
}

static float complex call_indirect(
	float complex (*operation)(float complex, float complex, float),
	float complex left,
	float complex right)
{
	return operation(left, right, 2.0f);
}

int main(void)
{
	float complex left = { 2.0f, 3.0f };
	float complex right = 4.0f - I;
	float complex sum = left + right;
	float complex product = left * right;
	float complex quotient = product / right;
	float complex negated = -left;
	float complex called = add_scaled(left, right, 2.0f);
	float complex indirect = call_indirect(add_scaled, left, right);
	float complex exponential = cexpf(I);
	float complex square_root = csqrtf((float complex){ -4.0f, 0.0f });
	if (crealf(sum) != 6.0f || cimagf(sum) != 2.0f) return 1;
	if (crealf(quotient) != 2.0f || cimagf(quotient) != 3.0f) return 2;
	if (crealf(called) != 10.0f || cimagf(called) != 1.0f) return 3;
	if (crealf(indirect) != 10.0f || cimagf(indirect) != 1.0f) return 4;
	if (crealf(exponential) < 0.5f || cimagf(exponential) < 0.8f) return 5;
	if (crealf(square_root) != 0.0f || cimagf(square_root) != 2.0f) return 6;
	if (negated != ((float complex){ -2.0f, -3.0f })) return 7;
	return 0;
}