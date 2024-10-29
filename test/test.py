import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles


'''
@cocotb.test()
async def test_mult(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())
    max_count = 100
    dut._log.info("check all the mults")
    #await ClockCycles(dut.clk, max_count)
'''

@cocotb.test()
async def test_txformer(dut):
    clock = Clock(dut.clk, 2, units="us")
    dut.rst_n.value = 1;
    dut.ena.value = 1;
    dut.ui_in.value = 0b10000000
    cocotb.start_soon(clock.start())
    tex = open("../src/tex/transforms.tex", "r")
    dut._log.info("start")
    dut._log.info("check that our expected transforms are seen")
    total_txforms = 44
    res_dict = {}
    # hacky
    for x in range(total_txforms):
        lhs, rhs = tex.readline().split(",")
        lhs = lhs[7:]
        rhs = rhs[0:-4]
        lhs = lhs.strip()
        rhs = rhs.strip()
        lhsl = len(lhs)
        rhsl = len(rhs)
        ind = max(lhsl, rhsl)
        rhs = rhs.ljust(ind)
        lhs = lhs.ljust(ind)
        res_dict[x] = [lhs, rhs]
    tex.close()
    for txform_to_test in range(total_txforms):
        #dut._log.info("testing txform " + str(txform_to_test))
        await Timer(2.5, units="us")
        dut.ui_in.value = 0b10000000 + txform_to_test;
        dut.rst_n.value = 0;
        await Timer(2.5, units="us")
        dut.rst_n.value = 1;
        await Timer(3, units="us")
        dut.ui_in.value = 0b11000000 + txform_to_test;
        max_count = 7 + len(res_dict[txform_to_test][0]) + 20
        #dut._log.info(len(res_dict[txform_to_test][0]))
        for char in range(len(res_dict[txform_to_test][0])):
            #dut.clk.value = 0;
            await Timer(1, units="us")
            #dut.clk.value = 1;
            await Timer(1, units="us")
            # use the chr(ord("c")) function to get ascii->char
            #dut._log.info("seeing lhs: '" + chr(dut.uio_out.value) + "'")
            #dut._log.info("seeing rhs: '" + chr(dut.uo_out.value) + "'")
            #dut._log.info("expecting lhs: '" + (res_dict[txform_to_test][0][char]) + "'")
            # targeted_lhs = (res_dict[0][0][char]) + "'")
            #dut._log.info("expecting rhs: '" + (res_dict[txform_to_test][1][char]) + "'")
            assert chr(dut.uio_out.value) == res_dict[txform_to_test][0][char], "failed to match lhs!"
            assert chr(dut.uo_out.value) == res_dict[txform_to_test][1][char], "failed to match rhs!"
        await Timer(3, units="us")
        dut.ui_in.value = 0b10000000
        dut.rst_n.value = 0
        await ClockCycles(dut.clk, max_count)
