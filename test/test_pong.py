import cocotb
import random
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles

from test.encoder import Encoder

async def reset(dut):
    dut.reset <= 1

    await ClockCycles(dut.clk, 3)
    dut.reset <= 0

@cocotb.test()
async def test_encoder(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())
    clocks_per_phase = 5
    encoder = Encoder(dut.clk, dut.player1_a, dut.player1_b, clocks_per_phase = clocks_per_phase, noise_cycles = 0)

    await reset(dut)

    # count up
    for i in range(clocks_per_phase * 2 *  7):
        await encoder.update(1)

    # count down
    for i in range(clocks_per_phase * 2 * 7):
        await encoder.update(-1)


@cocotb.test()
async def test_pong(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    await reset(dut)
    # assert dut.debounced == 0

    await ClockCycles(dut.clk, 2500)
