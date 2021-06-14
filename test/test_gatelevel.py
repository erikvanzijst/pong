from textwrap import dedent

import cocotb
from cocotb.clock import Clock
from cocotb.result import TestFailure
from cocotb.triggers import RisingEdge, ClockCycles

from .paddle import Paddle
from .dotmatrix import scanlines, assert_screen, printscreen

clocks_per_phase = 1
DEBOUNCEWIDTH = 2


async def wait_for_value(clk, signal, val, max_ticks):
    for i in range(max_ticks):
        await RisingEdge(clk)
        if signal == val:
            return signal
    raise TestFailure(f"{signal} did not reach value {val} within {max_ticks} clock ticks")


async def reset(dut):
    dut.start <= 0
    dut.player1_a <= 0
    dut.player1_b <= 0
    dut.player2_a <= 0
    dut.player2_b <= 0
    dut.difficulty <= 0
    dut.reset <= 1

    await ClockCycles(dut.clk32mhz, 4)
    dut.reset <= 0
    await ClockCycles(dut.clk32mhz, 10)


@cocotb.test()
async def test_start(dut):
    clock = Clock(dut.clk32mhz, 31, units="ns")
    cocotb.fork(clock.start())
    print("Test has started the clock")

    dut.VGND <= 0
    dut.VPWR <= 1

    await reset(dut)
    print("Reset completed")
    dut.difficulty <= 0

    print("Let r rip!")
    await ClockCycles(dut.clk32mhz, 400)

    print("Capturing the contents of the next screen refresh...")
    screen = await scanlines(dut)
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

    lpaddle = Paddle(dut.player1_a, dut.player1_b)
    rpaddle = Paddle(dut.player2_a, dut.player2_b)

    print("Move paddles...")
    for _ in range(20):
        lpaddle.down()
        rpaddle.up()
        await ClockCycles(dut.clk32mhz, 2**DEBOUNCEWIDTH * 4)   # debounce with of 2 on 10MHz clock

    print("Capturing the contents of the next screen to assert new paddle locations...")
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

    print("Move the paddles as far as they go and assert they don't run off-screen...")
    for _ in range(10):
        lpaddle.down()
        rpaddle.up()
        await ClockCycles(dut.clk32mhz, 2**DEBOUNCEWIDTH * 4)   # debounce with of 2 on 10MHz clock
    screen = await scanlines(dut)
    assert_screen(dedent("""\
        1000000000000000
        1000000000000000
        1000000000000000
        1000000000000000
        0000000000000000
        0000000000000000
        0000000000000000
        0000000000000000
        0000000010000000
        0000000000000000
        0000000000000000
        0000000000000000
        0000000000000001
        0000000000000001
        0000000000000001
        0000000000000001
    """), screen)
    printscreen(screen)

    dut.difficulty <= 0xF
    print("Pressing start...")
    dut.start <= 1
    await ClockCycles(dut.clk32mhz, 4)
    dut.start <= 0
    cycles = int((2**17 / (127 * 15)) * 4)
    # cycles = 60000
    print("Waiting %d clock cycles for the ball to move 1 pixel..." % cycles)
    await ClockCycles(dut.clk32mhz, cycles)
    printscreen(await scanlines(dut))
