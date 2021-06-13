import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


async def reset(dut):
    dut.lpaddle = 0b00000000000011111111000000000000
    dut.rpaddle = 0b00000000000011111111000000000000
    dut.start = 0
    dut.reset <= 1

    await ClockCycles(dut.game_clk, 2)
    dut.reset <= 0
    await ClockCycles(dut.game_clk, 2)


@cocotb.test()
async def test_reset(dut):
    clock = Clock(dut.game_clk, 83, units="ns")
    cocotb.fork(clock.start())

    dut.difficulty = 1  # should not take effect until start is pressed
    dut.entropy = 0

    await reset(dut)
    await ClockCycles(dut.game_clk, 2)

    assert not dut.out_left.value
    assert not dut.out_right.value
    assert dut.score_p1 == 0
    assert dut.score_p2 == 0
    assert dut.speed == 0


@cocotb.test()
async def test_start(dut):
    clock = Clock(dut.game_clk, 83, units="ns")
    cocotb.fork(clock.start())

    dut.difficulty = 0xF
    dut.entropy = 0
    assert dut.speed == 0

    dut.start = 1
    await ClockCycles(dut.game_clk, 2)
    dut.start = 0
    await ClockCycles(dut.game_clk, 2)

    await ClockCycles(dut.game_clk, 1)
    assert dut.freeze == 0
    assert dut.speed == 0xF


@cocotb.test()
async def test_move_ball(dut):
    clock = Clock(dut.game_clk, 83, units="ns")
    cocotb.fork(clock.start())

    dut.difficulty = 0xF
    dut.entropy = 0

    cycles = int(2**16 / (127 * 15)) + 2
    # It takes `cycles` ticks to move one pixel on the VGA screen
    print("Waiting %d ticks for the ball to move 1 pixel..." % cycles)
    await ClockCycles(dut.game_clk, cycles)
    assert dut.x == 17
    assert dut.y == 16

    assert not dut.out_left.value
    assert not dut.out_right.value
    assert dut.score_p1 == 0
    assert dut.score_p2 == 0
