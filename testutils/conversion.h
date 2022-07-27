#include <stdio.h>
#include <inttypes.h>

// https://gamedev.stackexchange.com/questions/17326/conversion-of-a-number-from-single-precision-floating-point-representation-to-a

/* This method is faster than the OpenEXR implementation (very often
 * used, eg. in Ogre), with the additional benefit of rounding, inspired
 * by James Tursa’s half-precision code. */
static inline uint16_t float_to_half_branch(uint32_t x)
{
    uint16_t bits = (x >> 16) & 0x8000; /* Get the sign */
    uint16_t m = (x >> 12) & 0x07ff; /* Keep one extra bit for rounding */
    unsigned int e = (x >> 23) & 0xff; /* Using int is faster here */

    /* If zero, or denormal, or exponent underflows too much for a denormal
     * half, return signed zero. */
    if (e < 103)
        return bits;

    /* If NaN, return NaN. If Inf or exponent overflow, return Inf. */
    if (e > 142)
    {
        bits |= 0x7c00u;
        /* If exponent was 0xff and one mantissa bit was set, it means NaN,
         * not Inf, so make sure we set one mantissa bit too. */
        bits |= e == 255 && (x & 0x007fffffu);
        return bits;
    }

    /* If exponent underflows but not too much, return a denormal */
    if (e < 113)
    {
        m |= 0x0800u;
        /* Extra rounding may overflow and set mantissa to 0 and exponent
         * to 1, which is OK. */
        bits |= (m >> (114 - e)) + ((m >> (113 - e)) & 1);
        return bits;
    }

    bits |= ((e - 112) << 10) | (m >> 1);
    /* Extra rounding. An overflow will set mantissa to 0 and increment
     * the exponent, which is OK. */
    bits += m & 1;
    return bits;
}

// https://stackoverflow.com/questions/44609743/obtaining-bit-representation-of-a-float-in-c
uint32_t show_ieee754(float f)
{
  union {
    float f;
    uint32_t u;
  } fu = { .f = f };

  //int i = sizeof f * CHAR_BIT;
  return fu.u;
}

static inline uint16_t convert_float_to_half_branch_uint16(float fp_32)
{
  uint32_t w = show_ieee754(fp_32);
  uint16_t b = float_to_half_branch(w);
  return b;
}
