import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


def twos_comp(val, bits):
    """compute the 2's complement of int `val`."""
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val                         # return positive value as is


@cocotb.test()
async def test_trig(dut):
    clock = Clock(dut.CLK, 83, units="ns")
    cocotb.fork(clock.start())

    sin_expected = [
        0, 12, 24, 36, 48, 59, 70, 80, 89, 98, 105, 112, 117, 121, 124, 126,
        127, 126, 124, 121, 117, 112, 105, 98, 89, 80, 70, 59, 48, 36, 24, 12,
        -1, -13, -25, -37, -49, -60, -71, -81, -90, -99, -106, -113, -118, -122, -125, -127,
        -128, -127, -125, -122, -118, -113, -106, -99, -90, -81, -71, -60, -49, -37, -25, -13]
    cos_expected = [
        127, 126, 124, 121, 117, 112, 105, 98, 89, 80, 70, 59, 48, 36, 24, 12,
        -1, -13, -25, -37, -49, -60, -71, -81, -90, -99, -106, -113, -118, -122, -125, -127,
        -128, -127, -125, -122, -118, -113, -106, -99, -90, -81, -71, -60, -49, -37, -25, -13,
        0, 12, 24, 36, 48, 59, 70, 80, 89, 98, 105, 112, 117, 121, 124, 126]

    for i, (sin_val, cos_val) in enumerate(zip(sin_expected, cos_expected)):
        dut.theta_i = i
        await ClockCycles(dut.CLK, 1)
        assert twos_comp(int(dut.sin_o), 8) == sin_val, "sin_o result not equal to expected value: %d" % sin_val
        assert twos_comp(int(dut.cos_o), 8) == cos_val, "cos_o result not equal to expected value: %d" % cos_val
