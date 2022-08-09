#include "conversion.h"
#include <stdlib.h>

// TODO: negative number
float print_fp16(float fp32)
{
  uint16_t x = convert_float_to_half_branch_uint16(fp32);
    
  printf("%f\n", fp32);
  printf("%#010x\n", x);
}

int main()
{
    print_fp16(0.45f);
    return 0;
}
