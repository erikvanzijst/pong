#!/usr/bin/env python3

from math import radians, sin, cos

step = radians(360) / 64

with open('sine.lut', 'w') as f_sin:
    with open('cosine.lut', 'w') as f_cos:
        for i in range(64):
            angle = i * step

            f_sin.write(bin(int(sin(angle)*127) & 0b11111111)[2:].rjust(8, '0'))
            f_sin.write('\n')

            f_cos.write(bin(int(cos(angle)*127) & 0b11111111)[2:].rjust(8, '0'))
            f_cos.write('\n')
