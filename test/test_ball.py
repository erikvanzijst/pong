import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


async def reset(dut):
    dut.reset = 1
    await ClockCycles(dut.clk, 3)
    dut.reset = 0


@cocotb.test()
async def test_start(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    dut.speed = 0x0
    dut.lpaddle = 0b00000000000011111111000000000000
    dut.rpaddle = 0b00000000000011111111000000000000
    dut.entropy = 0
    dut.ball_reset = 0
    await reset(dut)

    assert dut.theta == 0
    assert dut.hor == 0x100000 and dut.x == 0x10
    assert dut.vert == 0x100000 and dut.y == 0x10


@cocotb.test()
async def test_ball_reset(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    dut.speed = 0x0
    dut.ball_reset = 1
    await ClockCycles(dut.clk, 2)
    dut.ball_reset = 0
    await ClockCycles(dut.clk, 2)

    assert dut.theta == 0
    assert dut.hor == 0x100000 and dut.x == 0x10
    assert dut.vert == 0x100000 and dut.y == 0x10
    await ClockCycles(dut.clk, 2)


@cocotb.test()
async def test_paddle_bounce(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    async def step(speed: int) -> None:
        dut.speed = speed
        await ClockCycles(dut.clk, 1)
        dut.speed = 0
        await ClockCycles(dut.clk, 1)

    dut.lpaddle = 0xffffffff
    dut.rpaddle = 0xffffffff
    dut.entropy = 0

    await reset(dut)

    dut.speed = 0
    await ClockCycles(dut.clk, 2)
    assert dut.hor == 0x100000 and dut.x == 0x10
    assert dut.vert == 0x100000 and dut.y == 0x10
    assert dut.moving_left
    assert dut.moving_right == 0

    # Move left and right at speed 1:
    await step(1)
    assert dut.hor == 0x10007F and dut.x == 0x10
    assert dut.vert == 0x100000 and dut.y == 0x10

    # Position the ball at the far left right before the paddle:
    dut.speed = 0
    dut.theta = 0
    dut.hor = 0x1EFFFF
    await ClockCycles(dut.clk, 1)
    assert dut.x == 30

    # After col 30 we should hit the left paddle and reverse direction:
    await step(1)

    assert(dut.x == 30)
    assert(dut.theta == 32)
    await ClockCycles(dut.clk, 2)


@cocotb.test()
async def test_movement(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    async def clear() -> None:
        dut.speed = 1
        await reset(dut)

    async def step(speed: int, theta: int) -> None:
        dut.speed = speed
        dut.theta = theta
        await ClockCycles(dut.clk, 1)
        dut.speed = 0
        await ClockCycles(dut.clk, 1)

    dut.lpaddle = 0xffffffff
    dut.rpaddle = 0xffffffff
    dut.entropy = 0
    dut.speed = 0

    await reset(dut)
    assert dut.theta == 0
    assert dut.hor == 0x100000 and dut.x == 0x10
    assert dut.vert == 0x100000 and dut.y == 0x10

    # Move left and right at speed 1:
    await step(1, 0)
    assert dut.hor == 0x10007F and dut.x == 0x10
    assert dut.vert == 0x100000 and dut.y == 0x10

    # turn around 180 degrees:
    await step(1, 32)
    assert dut.hor == 0xFFFFF and dut.x == 0xF
    assert dut.vert == 0xFFFFF and dut.y == 0xF

    # Move up at speed 1:
    dut.speed = 0
    await reset(dut)
    await step(1, 48)
    assert dut.hor == 0x100000 and dut.x == 0x10
    assert dut.vert == 0xFFF80 and dut.y == 15

    # turn around 180 degrees and move down:
    await step(1, 16)
    assert dut.hor == 0xFFFFF and dut.x == 15
    assert dut.vert == 0xFFFFF and dut.y == 15
    await reset(dut)

    # Move at 45 degrees:
    await step(1, 40)
    assert dut.hor == 0x0FFFA6 and dut.x == 15
    assert dut.vert == 0x0FFFA6 and dut.y == 15
    await reset(dut)

    # Move at max forward speed (15)
    await step(15, 0)
    assert(dut.hor == 0x100771 and dut.x == 16)
    assert(dut.vert == 0x100000 and dut.y == 16)
