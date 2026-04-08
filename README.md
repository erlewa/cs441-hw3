### CS 441 Homework 3

All programs work.

Problem 5 Timings:

CPU:           | GPU:
               |
real:  3.810s  | real: 1.560s
user:  3.787s  | user: 1.412s
sys:   0.023s  | sys:  0.141s

3.810 / 1.560 = 2.44

Overall the GPU accelerated version executed approximatley 2.44 times faster than the CPU version.
The GPU version did have more sys time than the CPU version likely due to the overhead associated with CUDA.
