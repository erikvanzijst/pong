PROJ = pong
ADD_SRC = src/clkdiv.v src/screen.v src/ball.v src/trig.v src/paddle.v src/debounce.v src/rot_encoder.v src/game.v src/score.v src/rnd.v src/vga.v src/vgasync.v src/fpga.v src/tone.v

PIN_DEF = icebreaker.pcf
DEVICE = up5k

# Target freq for the iCEBreaker
FREQ = 12

include main.mk
