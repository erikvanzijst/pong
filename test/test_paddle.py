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

    dut.encoder_value <= 0
    await reset(dut)

    await ClockCycles(dut.clk, 2)
    assert(dut.paddle_o == 0b00000000000011111111000000000000)


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

    dut.encoder_value <= 0
    await reset(dut)

    assert(dut.paddle_o == 0b00000000000011111111000000000000)
    await up(dut, clock)
    assert(dut.paddle_o == 0b00000000000001111111100000000000)
    await ClockCycles(dut.clk, 2)

    await up(dut, clock)
    assert(dut.paddle_o == 0b00000000000000111111110000000000)
    await ClockCycles(dut.clk, 2)

    # Move the other way
    await down(dut, clock)
    assert(dut.paddle_o == 0b00000000000001111111100000000000)
    await ClockCycles(dut.clk, 2)

    await down(dut, clock)
    assert(dut.paddle_o == 0b00000000000011111111000000000000)
    await ClockCycles(dut.clk, 2)

    await down(dut, clock)
    assert(dut.paddle_o == 0b00000000000111111110000000000000)
    await ClockCycles(dut.clk, 2)


@cocotb.test()
async def test_paddle_stop_at_wall(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    # move all the way to the side (plus one extra step that should be blocked):
    for i in range(13):
        await up(dut, clock)
    assert(dut.paddle_o == 0b00000000000000000000000011111111)

    # move one step back:
    await down(dut, clock)
    assert(dut.paddle_o == 0b00000000000000000000000111111110)

    # move all the way to the other side:
    for i in range(30):
        await down(dut, clock)
    assert(dut.paddle_o == 0b11111111000000000000000000000000)
