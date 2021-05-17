#!/usr/bin/env python3
#
# Generates a quarter sine lookup rom.

from math import radians, sin

step = radians(360) / 32

with open('sine.lut', 'w') as f_sin:
    for i in range(8+1):
        angle = i * step

        f_sin.write(bin(int(sin(angle)*127) & 0b11111111)[2:].rjust(8, '0'))
        f_sin.write('\n')
