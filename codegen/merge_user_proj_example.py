#!/usr/bin/env python3

from shutil import copyfile
import os, errno

copyfile('./user_proj_example.v', './user_proj_example_cp.v')

src_list = [
        'mat_mul_generated.v',
        'user_proj_example_cp.v'
]

# TODO: From cmd arguments which can be used by the makefile
concat_filepath = 'user_proj_example.v'

with open(concat_filepath, 'w') as outfile:
    for fname in src_list:
        with open(fname) as infile:
            for line in infile:
                outfile.write(line)

try:
    os.remove('./user_proj_example_cp.v')
except OSError as e:
    if e.errno != errno.ENOENT:
        raise
