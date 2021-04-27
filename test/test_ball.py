import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
from typing import Callable, NoReturn
import random


"""compute the 2's complement of int `val`."""
def twos_comp(val, bits):
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val                         # return positive value as is


async def reset(dut):
    dut.reset <= 1

    await ClockCycles(dut.clk, 3)
    dut.reset <= 0


@cocotb.test()
async def test_ball(dut):

    async def clear() -> None:
        dut.speed = 1
        await reset(dut)

    async def step(speed: int, theta: int) -> None:
        dut.speed = speed
        dut.theta = theta
        await ClockCycles(dut.clk, 1)
        dut.speed = 0
        await ClockCycles(dut.clk, 1)

    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    await reset(dut)

    dut.speed = 0
    await ClockCycles(dut.clk, 2)
    assert(dut.horizontal == 0x100000 and dut.x == 8)
    assert(dut.vertical == 0x100000 and dut.y == 8)

    # Move left and right at speed 1:
    await step(1, 0)
    assert(dut.horizontal == 0x10007F and dut.x == 8)
    assert(dut.vertical == 0x100000 and dut.y == 8)

    # turn around 180 degrees:
    await step(1, 32)
    assert(dut.horizontal == 0x100000 and dut.x == 8)
    assert(dut.vertical == 0x100000 and dut.y == 8)
    await clear()


    # Move down and up at speed 1:
    await step(1, 16)
    assert(dut.horizontal == 0x100000 and dut.x == 8)
    assert(dut.vertical == 0x10007F and dut.y == 8)

    # turn around 180 degrees and move up:
    await step(1, 48)
    assert(dut.horizontal == 0x100000 and dut.x == 8)
    assert(dut.vertical == 0x100000 and dut.y == 8)
    await clear()


    # Move at 45 degrees:
    await step(1, 40)
    assert(dut.horizontal == 0x0FFFA7 and dut.x == 7)
    assert(dut.vertical == 0x0FFFA7 and dut.y == 7)
    await step(1, 8)
    assert(dut.horizontal == 0x100000 and dut.x == 8)
    assert(dut.vertical == 0x100000 and dut.y == 8)
    await clear()


    # Move at max forward speed (15)
    await step(15, 0)
    assert(dut.horizontal == 0x100771 and dut.x == 8)
    assert(dut.vertical == 0x100000 and dut.y == 8)
    await clear()


    # # At horizontal 11FFFF we should roll from col 8 to col 9:
    # dut.speed = 0
    # dut.theta = 0
    # dut.horizontal = 0x11FFFF
    # await ClockCycles(dut.clk, 1)
    # assert(dut.x == 8)
    # await step(1, 0)
    # assert(dut.x == 9)

    # # After col 15 we should wrap to col 0:
    # dut.speed = 0
    # dut.theta = 0
    # dut.horizontal = 0x1FFFFF
    # await ClockCycles(dut.clk, 1)
    # assert(dut.x == 15)
    # await step(1, 0)
    # assert(dut.x == 0)


    # Bounce off left edge:
    dut.speed = 0
    dut.theta = 0
    dut.horizontal = 0x1FFFFF
    await ClockCycles(dut.clk, 1)
    assert(dut.x == 15)
    await step(1, 2)
    assert(dut.x == 15)
    assert(dut.theta == 30)

    await step(1, dut.theta.value.integer)
    assert(dut.theta == 30)
    assert(dut.x == 15)
