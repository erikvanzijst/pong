from textwrap import dedent

import cocotb
from cocotb.clock import Clock
from cocotb.result import TestFailure
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles

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


async def scanlines(dut):
    """Collects the next full screen of 16 horizontal scanlines.

    This waits for the screen refresh circuit to reach the end of the currently
    drawing screen, return to the top left of the screen and then captures the
    16 scanlines.

    The screen contents are returned as a list of 16 integers.
    """
    lines = [0] * 16

    await FallingEdge(dut.RSDI) # wait for start of a new screen...

    for row in range(16):
        await RisingEdge(dut.RCLK)  # wait for the first row to be ready...
        for col in range(16):
            lines[row + (-1 if (row & 1) else 1)] |= dut.CSDI.value << col
            if col < 15:
                await RisingEdge(dut.CCLK)

    return lines


def printscreen(scanlines) -> None:
    for scanline in scanlines:
        print(bin(scanline)[2:].rjust(16, '0'))


def assert_screen(expected: str, scanlines) -> None:
    for i, line in enumerate(expected.splitlines()):
        if line != bin(scanlines[i])[2:].rjust(16, '0'):
            error = "Screen mismatch\n"
            for i_, line_ in enumerate(expected.splitlines()):
                error += (line_ + "        " + bin(scanlines[i_])[2:].rjust(16, '0') + "\n")
            error += "    Expected                 Actual\n"
            raise TestFailure(error)


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
    

class Paddle(object):
    CYCLE = [1, 1, 0, 0]

    def __init__(self, a, b):
        self.a = a
        self.b = b
        self.a_phase = 2
        self.b_phase = 3
        self.a <= self.CYCLE[self.a_phase]
        self.b <= self.CYCLE[self.b_phase]

    def _turn(self, direction: int) -> None:
        self.a_phase = (self.a_phase + direction) % 4
        self.b_phase = (self.b_phase + direction) % 4
        self.a <= self.CYCLE[self.a_phase]
        self.b <= self.CYCLE[self.b_phase]

    def up(self):
        self._turn(-1)

    def down(self):
        self._turn(1)
