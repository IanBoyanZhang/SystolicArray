#!/usr/bin/env python3

src_list = [
        'add_normalizer.v',
        'control.v',
        'mac_unit.v',
        'PE2.v',
        'delay2.v',
        'mul2x2.v',
        'mul4x4.v',
        'mul8x8.v',
        'mul16x16.v',
        'alignment.v',
        'systolic.v',
        'cla_nbit.v',
        'int_fp_add.v',
        'int_fp_mul.v',
        'mul_normalizer.v'
]

concat_filepath = 'mat_mul_generated.v'

with open(concat_filepath, 'w') as outfile:
    for fname in src_list:
        with open(fname) as infile:
            for line in infile:
                # Skip `include lines
                if (line.strip()).startswith("`include") is False:
                    outfile.write(line)
