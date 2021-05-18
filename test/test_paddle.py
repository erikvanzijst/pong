import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


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
    dut.encoder_value <= 0
    await reset(dut)

    await ClockCycles(dut.clk, 2)
    assert(dut.paddle_o == 0b0000001111000000)

    dut.width <= 1
    await ClockCycles(dut.clk, 2)
    assert(dut.paddle_o == 0b0000000111000000)

    dut.width <= 0
    await ClockCycles(dut.clk, 2)
    assert(dut.paddle_o == 0b0000001111000000)


async def up(dut, clk: Clock):
    dut.encoder_value <= dut.encoder_value.value + 1
    await ClockCycles(dut.clk, 2)


async def down(dut, clk: Clock):
    dut.encoder_value <= dut.encoder_value.value - 1
    await ClockCycles(dut.clk, 2)


@cocotb.test()
async def test_paddle_move(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    dut.width <= 0
    dut.encoder_value <= 0
    await reset(dut)

    await up(dut, clock)
    assert(dut.paddle_o == 0b0000000111100000)
    await ClockCycles(dut.clk, 2)

    await up(dut, clock)
    assert(dut.paddle_o == 0b0000000011110000)
    await ClockCycles(dut.clk, 2)

    # Move the other way
    await down(dut, clock)
    assert(dut.paddle_o == 0b0000000111100000)
    await ClockCycles(dut.clk, 2)

    await down(dut, clock)
    assert(dut.paddle_o == 0b0000001111000000)
    await ClockCycles(dut.clk, 2)

    await down(dut, clock)
    assert(dut.paddle_o == 0b0000011110000000)
    await ClockCycles(dut.clk, 2)


@cocotb.test()
async def test_paddle_shrink(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    dut.width <= 0
    dut.encoder_value <= 0
    await reset(dut)

    await up(dut, clock)
    assert(dut.paddle_o == 0b0000000111100000)

    dut.width <= 1
    await ClockCycles(dut.clk, 2)
    assert(dut.paddle_o == 0b0000000011100000)
    await ClockCycles(dut.clk, 2)

    # move all the way to the side:
    for i in range(5):
        await up(dut, clock)
    assert(dut.paddle_o == 0b0000000000000111)

    # now grow again:
    dut.width <= 0
    await ClockCycles(dut.clk, 2)
    assert(dut.paddle_o == 0b0000000000001111)


@cocotb.test()
async def test_paddle_stop_at_wall(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    dut.width <= 0

    await ClockCycles(dut.clk, 2)
    # where the previous test left the paddle:
    assert(dut.paddle_o == 0b0000000000001111)

    # move one step back:
    await down(dut, clock)
    assert(dut.paddle_o == 0b0000000000011110)


    # move all the way to the side:
    for i in range(4):
        await up(dut, clock)
    assert(dut.paddle_o == 0b0000000000001111)
