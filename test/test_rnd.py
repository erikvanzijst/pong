import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_rnd(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())
    await ClockCycles(dut.clk, 1)
    dut.reset <= 1
    await ClockCycles(dut.clk, 1)
    dut.reset <= 0
    await ClockCycles(dut.clk, 1)
    assert dut.q == 0x1f

    expected = [0x1f, 0x1b, 0x19, 0x18, 0x0c, 0x06, 0x03, 0x15,
                0x1e, 0x0f, 0x13, 0x1d, 0x1a, 0x0d, 0x12, 0x09,
                0x10, 0x08, 0x04, 0x02, 0x01, 0x14, 0x0a, 0x05,
                0x16, 0x0b, 0x11, 0x1c, 0x0e, 0x07, 0x17, 0x1f,
                0x1b, 0x19]

    for i in expected:
        assert dut.q == i
        await ClockCycles(dut.clk, 1)
