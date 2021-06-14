from textwrap import dedent

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from .dotmatrix import assert_screen, scanlines, printscreen
from .paddle import Paddle


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

    print("Capturing the contents of the next screen refresh...")
    screen = await scanlines(dut)
    printscreen(screen)
    assert_screen(dedent("""\
        0000000000000000
        0000000000000000
        0000000000000000
        0000000000000000
        0000000000000000
        0000000000000000
        1000000000000001
        1000000000000001
        1000000010000001
        1000000000000001
        0000000000000000
        0000000000000000
        0000000000000000
        0000000000000000
        0000000000000000
        0000000000000000
    """), screen)


# @cocotb.test()
async def test_pong(dut):
    clock = Clock(dut.clk32mhz, 83, units="ns")
    cocotb.fork(clock.start())

    await reset(dut)
    # assert dut.debounced == 0

    await ClockCycles(dut.clk32mhz, 2500)
