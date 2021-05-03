PROJ = pong
ADD_SRC = src/clkdiv.v src/screen.v src/ball.v src/math.v src/paddle.v

PIN_DEF = icebreaker.pcf
DEVICE = up5k

include main.mk
