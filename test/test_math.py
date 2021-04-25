import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random


"""compute the 2's complement of int `val`."""
def twos_comp(val, bits):
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val                         # return positive value as is


@cocotb.test()
async def test_sin(dut):
    clock = Clock(dut.CLK, 83, units="ns")
    cocotb.fork(clock.start())

    dut.theta_i = 0
    await ClockCycles(dut.CLK, 2)
    assert(dut.sin_o == 0)

    dut.theta_i = 16
    await ClockCycles(dut.CLK, 1)
    assert(dut.sin_o == 127)

    dut.theta_i = 32
    await ClockCycles(dut.CLK, 1)
    assert(dut.sin_o == 0)

    dut.theta_i = 50
    await ClockCycles(dut.CLK, 1)
    assert(twos_comp(int(dut.sin_o), 8) == -124)
