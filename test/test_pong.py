from textwrap import dedent

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from .dotmatrix import assert_screen, scanlines, printscreen
from .paddle import Paddle

DEBOUNCEWIDTH = 2


async def reset(dut):
    print("Resetting...")
    dut.reset = 1
    await ClockCycles(dut.clk32mhz, 3)
    dut.reset = 0


@cocotb.test()
async def test_start(dut):
    clock = Clock(dut.clk32mhz, 31, units="ns")
    cocotb.fork(clock.start())

    lpaddle = Paddle(dut.player1_a, dut.player1_b)
    rpaddle = Paddle(dut.player2_a, dut.player2_b)
    dut.start = 0
    dut.difficulty = 1
    await reset(dut)

    print("Run 10 ticks before pressing start...")
    await ClockCycles(dut.clk32mhz, 10)
    assert dut.x == 16
    assert dut.y == 16
    assert dut.score_p1 == 0
    assert dut.score_p2 == 0

    print("Move paddles...")
    for _ in range(20):
        lpaddle.down()
        rpaddle.up()
        await ClockCycles(dut.clk32mhz, 2**DEBOUNCEWIDTH * 4)   # debounce with of 2 on 10MHz clock

    print("Capturing the contents of the next screen refresh...")
    screen = await scanlines(dut)
    assert_screen(dedent("""\
        0000000000000000
        1000000000000000
        1000000000000000
        1000000000000000
        1000000000000000
        0000000000000000
        0000000000000000
        0000000000000000
        0000000010000000
        0000000000000000
        0000000000000000
        0000000000000001
        0000000000000001
        0000000000000001
        0000000000000001
        0000000000000000
    """), screen)


@cocotb.test()
async def test_ball_movement(dut):
    clock = Clock(dut.clk32mhz, 31, units="ns")
    cocotb.fork(clock.start())

    dut.difficulty = 0xF
    printscreen(await scanlines(dut))
    print("Pressing start...")
    dut.start = 1
    await ClockCycles(dut.clk32mhz, 4)
    dut.start = 0

    dut.difficulty = 0xF
    cycles = int(2**16 / (127 * 15)) * 3 + 4
    print("Waiting %d clock cycles for the ball to move 1 pixel..." % cycles)
    await ClockCycles(dut.clk32mhz, cycles)
    dut.difficulty = 0     # prevent further ball movement while we capture the screen
    print(f"x={dut.x.value.integer} y={dut.y.value.integer}")

    # Since the direction is pseudo random based on the LFSR generator, anticipate all directions:
    assert (dut.x.value.integer, dut.y.value.integer) in ((16, 17), (16, 15), (15, 16), (17, 16),
                                                          (15, 15), (17, 17), (15, 17), (17, 15))
