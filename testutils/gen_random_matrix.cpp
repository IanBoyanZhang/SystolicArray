#include "conversion.h"
#include <stdlib.h>
#include <time.h>

//srand(time(NULL));

// air for the chamber
float generate_random_float(float upper_bound)
{
  return (float)rand()/(float)(RAND_MAX/upper_bound);
}

// TODO: negative number
float generate_random_fp16_matrix(uint16_t* pMat, size_t mat_size, float upper_bound)
{
  // int a_mat[3 * 3]
  for (size_t i = 0; i < mat_size; i++)
  {
    float fp32 = generate_random_float(upper_bound);
    uint16_t x = convert_float_to_half_branch_uint16(fp32);
    
    printf("%f\n", fp32);
    printf("%#010x\n", x);

    *(pMat + i) = x;
  } 
}

int main()
{
    srand (time(NULL));
    uint16_t a_mat[9];
    generate_random_fp16_matrix(a_mat, 9, 3.f);

    return 0;
}
