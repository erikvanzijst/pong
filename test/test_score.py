import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, ReadWrite


@cocotb.test()
async def test_score(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    dut.score_p1 = 0
    dut.score_p2 = 0

    dut.reset <= 1
    await ClockCycles(dut.clk, 1)
    dut.reset <= 0
    await ClockCycles(dut.clk, 1)

    assert dut.score_o.value.integer == 0
    assert dut.cath1.value ^ dut.cath2.value, "Exactly one cathode must be active"

    # Set scores to distinct values and assert they alternate correctly:
    dut.score_p1 = 3
    dut.score_p2 = 7
    await ClockCycles(dut.clk, 1)

    await RisingEdge(dut.cath1)
    await ReadWrite()   # wait for combinatorial output to settle
    assert dut.score_o.value.integer == 3

    await RisingEdge(dut.cath2)
    await ReadWrite()
    assert dut.score_o.value.integer == 7
    await ClockCycles(dut.clk, 1)


@cocotb.test()
async def test_blinking(dut):
    clock = Clock(dut.clk, 83, units="ns")
    cocotb.fork(clock.start())

    dut.score_p1 = 3
    dut.score_p2 = 7

    # Blink interval is 1024 ticks, so assert that we're not off for 2048 ticks:
    for _ in range(2048):
        await ClockCycles(dut.clk, 1)
        assert dut.cath1.value ^ dut.cath2.value, "Exactly one cathode must be active"

    # Trigger blinking:
    dut.score_p2 = 9
    on_off_diff = 0
    for _ in range(2048):
        await ClockCycles(dut.clk, 1)
        on_off_diff += 1 if (dut.cath1.value ^ dut.cath2.value) else -1

    assert abs(on_off_diff) < 2, "Over 2048 ticks we should have an equal number of off vs on"
