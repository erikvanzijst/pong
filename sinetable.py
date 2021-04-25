#!/usr/bin/env python3

from math import radians, sin

step = radians(360) / 64

with open('sine.lut', 'w') as f:
    for i in range(64):
        angle = i * step
        result = int(sin(angle)*127)
        f.write(bin(result & 0b11111111)[2:].rjust(8, '0'))
        f.write('\n')
