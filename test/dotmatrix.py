from typing import List
from cocotb.result import TestFailure
from cocotb.triggers import FallingEdge, RisingEdge


async def scanlines(dut) -> List[int]:
    """Collects the next full screen of 16 horizontal scanlines.

    This waits for the screen refresh circuit to reach the end of the currently
    drawing screen, return to the top left of the screen and then captures the
    16 scanlines.

    The screen contents are returned as a list of 16 integers.
    """
    lines = [0] * 16

    await FallingEdge(dut.RSDI)     # wait for start of a new screen...

    for row in range(16):
        for col in range(16):
            await RisingEdge(dut.CCLK)
            lines[row + (-1 if (row & 1) else 1)] |= dut.CSDI.value << col

    return lines


def printscreen(scanlines: List[int]) -> None:
    for scanline in scanlines:
        print(bin(scanline)[2:].rjust(16, '0'))


def assert_screen(expected: str, scanlines: List[int]) -> None:
    for i, line in enumerate(expected.splitlines()):
        if line != bin(scanlines[i])[2:].rjust(16, '0'):
            error = "Screen mismatch\n"
            for i_, line_ in enumerate(expected.splitlines()):
                error += (line_ + "        " + bin(scanlines[i_])[2:].rjust(16, '0') + "\n")
            error += "    Expected                 Actual\n"
            raise TestFailure(error)
