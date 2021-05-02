import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

async def reset(dut):
    dut.reset <= 1

    await ClockCycles(dut.clk, 3)
    dut.reset <= 0

@cocotb.test()
async def test_pong(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    await reset(dut)
    # assert dut.debounced == 0

    await ClockCycles(dut.clk, 2500)
