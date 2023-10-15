#include <immintrin.h>
#include <stdio.h>
#include <stdlib.h>

// Beware: LLVM incompatible intrinsics in use.

extern void sum_f32_array_asm(
    _Inout_updates_all_(size) float* const restrict z,
    _In_reads_(size) const float* restrict const x,
    _In_reads_(size) const float* restrict const y,
    _In_ const size_t size
); // implemented in the Ch01_01.asm file. (AVX512)

static void inline __stdcall sum_f32_array(
    _Inout_updates_all_(size) float* const restrict z,
    _In_reads_(size) const float* restrict const x,
    _In_reads_(size) const float* restrict const y,
    _In_ size_t const size
) {
    for (size_t i = 0; i < size; ++i) z[i] = x[i] + y[i];
    return;
}

static void inline sum_f32_array_avx(
    _Inout_updates_all_(size) float* const restrict z,
    _In_reads_(size) const float* restrict const x,
    _In_reads_(size) const float* restrict const y,
    _In_ size_t const size
) {
    const size_t nfloats_xmm = 4; // 4 32 bit floats in a 128 bits wide xmm register.
    const size_t nremainders = size % nfloats_xmm;
    __m128       xmm_x, xmm_y, xmm_z;
    size_t       i = 0;

    for (; i < size - nremainders; i += nfloats_xmm) {
        xmm_x = _mm_loadu_ps(x + i);
        xmm_y = _mm_loadu_ps(y + i);
        xmm_z = _mm_add_ps(xmm_x, xmm_y);
        _mm_storeu_ps(z + i, xmm_z);
    }

    for (; i < size; ++i) z[i] = x[i] + y[i];
    return;
}

static void inline __stdcall sum_f32_array_avx2(
    _Inout_updates_all_(size) float* const restrict z,
    _In_reads_(size) const float* restrict const x,
    _In_reads_(size) const float* restrict const y,
    _In_ size_t const size
) {
    const size_t nfloats_ymm = 8; // ymm registers are 256 bits wide, can store 8 packed floats (32 * 8)
    const size_t nremainders = size % nfloats_ymm;

    size_t       i           = 0;
    __m256       ymm_x, ymm_y, ymm_z;

    for (; i < size - nremainders; i += nfloats_ymm) {
        // z[i:i+7] = x[i:i+7] + y[i:i+7]
        ymm_x = _mm256_loadu_ps(x + i);
        ymm_y = _mm256_loadu_ps(y + i);
        ymm_z = _mm256_add_ps(ymm_x, ymm_y);
        _mm256_storeu_ps(z + i, ymm_z);
    }

    for (; i < size; ++i) z[i] = x[i] + y[i];
    return;
}

static void inline __stdcall sum_f32_array_avx512(
    _Inout_updates_all_(size) float* const restrict z,
    _In_reads_(size) const float* restrict const x,
    _In_reads_(size) const float* restrict const y,
    _In_ size_t const size
) {
    const size_t nfloats_ymm = 16; // zmm registers are 512 bits wide, can store 16 packed floats (32 * 16)
    const size_t nremainders = size % nfloats_ymm;

    size_t       i           = 0;
    __m512       zmm_x, zmm_y, zmm_z;

    for (; i < size - nremainders; i += nfloats_ymm) {
        // z[i:i+15] = x[i:i+15] + y[i:i+15]
        zmm_x = _mm512_loadu_ps(x + i);
        zmm_y = _mm512_loadu_ps(y + i);
        zmm_z = _mm512_add_ps(zmm_x, zmm_y);
        _mm512_storeu_ps(z + i, zmm_z);
    }

    for (; i < size; ++i) z[i] = x[i] + y[i];
    return;
}

int main(void) {
    float static x[1000], y[1000], z[1000] = { 0.0f }, zavx[1000] = { 0.0f }, zavx2[1000] = { 0.0f }, zavx512[1000] = { 0.0f },
                                   zasm[1000] = { 0.0f };
    for (size_t i = 0; i < 1000; ++i) {
        x[i] = (float) rand() / (rand() % 500);
        y[i] = (float) rand() / (rand() % 500);
    }

    sum_f32_array(z, x, y, 1000);
    sum_f32_array_avx(zavx, x, y, 1000);
    sum_f32_array_avx2(zavx2, x, y, 1000);
    sum_f32_array_avx512(zavx512, x, y, 1000);
    sum_f32_array_asm(zasm, x, y, 1000);

    for (size_t i = 0; i < 1000; ++i)
        printf_s("regular: %10.4f, avx %10.4f, avx2: %10.4f, avx512: %10.4f, .asm %10.4f\n", z[i], zavx[i], zavx2[i], zavx512[i], zasm[i]);

    return EXIT_SUCCESS;
}