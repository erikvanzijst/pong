import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random


async def reset(dut):
    dut.reset <= 1

    await ClockCycles(dut.clk, 2)
    dut.reset <= 0
    await ClockCycles(dut.clk, 2)


@cocotb.test()
async def test_paddle(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    dut.width <= 0
    dut.up <= 0
    dut.down <= 0
    await reset(dut)

    await ClockCycles(dut.clk, 2)
    assert(dut.paddle_o == 0b0011111111111100)

    dut.width <= 1
    await ClockCycles(dut.clk, 2)
    assert(dut.paddle_o == 0b0000111111110000)

    dut.width <= 2
    await ClockCycles(dut.clk, 2)
    assert(dut.paddle_o == 0b0000001111000000)

    dut.width <= 3
    await ClockCycles(dut.clk, 2)
    assert(dut.paddle_o == 0b0000000110000000)


async def up(dut, clk: Clock):
    dut.up <= 1
    await ClockCycles(dut.clk, 1)
    dut.up <= 0
    await ClockCycles(dut.clk, 1)


async def down(dut, clk: Clock):
    dut.down <= 1
    await ClockCycles(dut.clk, 1)
    dut.down <= 0
    await ClockCycles(dut.clk, 1)


@cocotb.test()
async def test_paddle_move(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    dut.width <= 0
    dut.up <= 0
    dut.down <= 0
    await reset(dut)

    await up(dut, clock)
    assert(dut.paddle_o == 0b0001111111111110)
    await ClockCycles(dut.clk, 2)

    await up(dut, clock)
    assert(dut.paddle_o == 0b0000111111111111)
    await ClockCycles(dut.clk, 2)

    # Move the other way
    await down(dut, clock)
    assert(dut.paddle_o == 0b0001111111111110)
    await ClockCycles(dut.clk, 2)

    await down(dut, clock)
    assert(dut.paddle_o == 0b0011111111111100)
    await ClockCycles(dut.clk, 2)

    await down(dut, clock)
    assert(dut.paddle_o == 0b0111111111111000)
    await ClockCycles(dut.clk, 2)


@cocotb.test()
async def test_paddle_shrink(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    dut.width <= 0
    dut.up <= 0
    dut.down <= 0
    await reset(dut)

    await up(dut, clock)
    assert(dut.paddle_o == 0b0001111111111110)

    dut.width <= 1
    await ClockCycles(dut.clk, 2)
    assert(dut.paddle_o == 0b0000011111111000)
    await ClockCycles(dut.clk, 2)

    dut.width <= 2
    await ClockCycles(dut.clk, 2)
    assert(dut.paddle_o == 0b0000000111100000)
    await ClockCycles(dut.clk, 2)

    # move all the way to the side:
    for i in range(5):
        await up(dut, clock)
    assert(dut.paddle_o == 0b0000000000001111)

    # now grow again:
    dut.width <= 0
    await ClockCycles(dut.clk, 2)
    assert(dut.paddle_o == 0b0000000011111111)


@cocotb.test()
async def test_paddle_stop_at_wall(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    dut.width <= 1
    dut.up <= 0
    dut.down <= 0
    await reset(dut)

    assert(dut.paddle_o == 0b0000111111110000)

    # move all the way to the side:
    for i in range(4):
        await up(dut, clock)
    assert(dut.paddle_o == 0b0000000011111111)

    # Should not move any further:
    await up(dut, clock)
    assert(dut.paddle_o == 0b0000000011111111)

    # Grow paddle and move back:
    dut.width <= 0
    await ClockCycles(dut.clk, 2)
    assert(dut.paddle_o == 0b0000001111111111)
    await down(dut, clock)
    assert(dut.paddle_o == 0b0000011111111111)