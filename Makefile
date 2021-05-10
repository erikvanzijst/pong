PROJ = pong
ADD_SRC = src/clkdiv.v src/screen.v src/ball.v src/math.v src/paddle.v src/debounce.v src/rot_encoder.v src/game.v src/score.v

PIN_DEF = icebreaker.pcf
DEVICE = up5k

include main.mk
