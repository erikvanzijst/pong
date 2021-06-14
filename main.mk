TEST_RESULTS = build/test-results

all: test_trig test_paddle test_debounce test_encoder test_rnd test_ball test_game test_pong

%.blif: src/%.v $(ADD_SRC) $(ADD_DEPS)
	yosys -ql $*.log -p 'synth_ice40 -top fpga -blif $@' $< $(ADD_SRC)

%.json: src/%.v $(ADD_SRC) $(ADD_DEPS)
	yosys -ql $*.log -DSYNTH -p 'synth_ice40 -top fpga -json $@' $< $(ADD_SRC)

ifeq ($(USE_ARACHNEPNR),)
%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --$(DEVICE) --freq $(FREQ) --json $(filter-out $<,$^) --pcf $< --asc $@
else
%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d $(subst up,,$(subst hx,,$(subst lp,,$(DEVICE)))) -o $@ -p $^
endif

test_pong:
	rm -rf sim_build/
	mkdir -p sim_build/ ${TEST_RESULTS}
	iverilog -o sim_build/sim.vvp -Ppong.SCREENTIMERWIDTH=5 -Ppong.GAMECLK=2 -Ppong.DEBOUNCEWIDTH=2 -s pong -s dump src/paddle.v src/pong.v src/clkdiv.v src/screen.v src/ball.v src/trig.v src/debounce.v src/rot_encoder.v src/vga.v src/vgasync.v src/score.v src/rnd.v src/game.v test/dump_pong.v
	PYTHONOPTIMIZE=${NOASSERT} COCOTB_RESULTS_FILE=${TEST_RESULTS}/results_pong.xml MODULE=test.test_pong vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure ${TEST_RESULTS}/results_pong.xml > /dev/null

test_trig:
	rm -rf sim_build/
	mkdir -p sim_build/ ${TEST_RESULTS}
	iverilog -o sim_build/trigsim.vvp -s trig -s dump src/trig.v test/dump_trig.v
	PYTHONOPTIMIZE=${NOASSERT} COCOTB_RESULTS_FILE=${TEST_RESULTS}/results_trig.xml MODULE=test.test_trig vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/trigsim.vvp
	! grep failure ${TEST_RESULTS}/results_trig.xml > /dev/null

test_rnd:
	rm -rf sim_build/
	mkdir -p sim_build/ ${TEST_RESULTS}
	iverilog -o sim_build/rndsim.vvp -s rnd -s dump src/rnd.v test/dump_rnd.v
	PYTHONOPTIMIZE=${NOASSERT} COCOTB_RESULTS_FILE=${TEST_RESULTS}/results_rnd.xml MODULE=test.test_rnd vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/rndsim.vvp
	! grep failure ${TEST_RESULTS}/results_rnd.xml > /dev/null

test_game:
	rm -rf sim_build/
	mkdir -p sim_build/ ${TEST_RESULTS}
	iverilog -o sim_build/gamesim.vvp -s game -s dump src/game.v src/ball.v src/trig.v test/dump_game.v
	PYTHONOPTIMIZE=${NOASSERT} COCOTB_RESULTS_FILE=${TEST_RESULTS}/results_game.xml MODULE=test.test_game vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/gamesim.vvp
	! grep failure ${TEST_RESULTS}/results_game.xml > /dev/null

test_ball:
	rm -rf sim_build/
	mkdir -p sim_build/ ${TEST_RESULTS}
	iverilog -o sim_build/ballsim.vvp -Pball.THETA_WIDTH=6 -s ball -s dump src/clkdiv.v src/ball.v src/trig.v test/dump_ball.v
	PYTHONOPTIMIZE=${NOASSERT} COCOTB_RESULTS_FILE=${TEST_RESULTS}/results_ball.xml MODULE=test.test_ball vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/ballsim.vvp
	! grep failure ${TEST_RESULTS}/results_ball.xml > /dev/null

test_paddle:
	rm -rf sim_build/
	mkdir -p sim_build/ ${TEST_RESULTS}
	iverilog -o sim_build/paddlesim.vvp -s paddle -s dump src/paddle.v test/dump_paddle.v
	PYTHONOPTIMIZE=${NOASSERT} COCOTB_RESULTS_FILE=${TEST_RESULTS}/results_paddle.xml MODULE=test.test_paddle vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/paddlesim.vvp
	! grep failure ${TEST_RESULTS}/results_paddle.xml > /dev/null

test_debounce:
	rm -rf sim_build/
	mkdir -p sim_build/ ${TEST_RESULTS}
	iverilog -o sim_build/debouncesim.vvp -s debounce -s dump -g2012 src/debounce.v test/dump_debounce.v
	PYTHONOPTIMIZE=${NOASSERT} COCOTB_RESULTS_FILE=${TEST_RESULTS}/results_debounce.xml MODULE=test.test_debounce vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/debouncesim.vvp
	! grep failure ${TEST_RESULTS}/results_debounce.xml > /dev/null

test_encoder:
	rm -rf sim_build/
	mkdir -p sim_build/ ${TEST_RESULTS}
	iverilog -o sim_build/rot_encoder_sim.vvp -s rot_encoder -s dump -g2012 test/dump_rot_encoder.v src/rot_encoder.v
	PYTHONOPTIMIZE=${NOASSERT} COCOTB_RESULTS_FILE=${TEST_RESULTS}/results_encoder.xml MODULE=test.test_rot_encoder vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/rot_encoder_sim.vvp
	! grep failure ${TEST_RESULTS}/results_encoder.xml > /dev/null

# Gate level simulation requires hardening the Pong project with Openlane and then copy the `pong.lvs.powered.v` file
# from the Openlane results/lvs/ dir into the Pong dir.
test_gatelevel:
	rm -rf sim_build/
	mkdir -p sim_build/ ${TEST_RESULTS}
	cat test/gl_header.v gds/pong.lvs.powered.v > sim_build/pong.lvs.powered.v
	iverilog -o sim_build/gl_sim.vvp -s pong -s dump -g2012 sim_build/pong.lvs.powered.v test/dump_pong.v -I $(PDK_ROOT)/sky130A
	PYTHONOPTIMIZE=${NOASSERT} COCOTB_RESULTS_FILE=${TEST_RESULTS}/results_gatelevel.xml MODULE=test.test_gatelevel vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/gl_sim.vvp
	! grep failure ${TEST_RESULTS}/results_gatelevel.xml > /dev/null

wave: sim
	gtkwave $(PROJ).vcd $(PROJ).gtkw

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

%_tb: %_tb.v %.v
	iverilog -o $@ $^

%_tb.vcd: %_tb
	vvp -N $< +vcd=$@

%_syn.v: %.blif
	yosys -p 'read_blif -wideports $^; write_verilog $@'

%_syntb: %_tb.v %_syn.v
	iverilog -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

%_syntb.vcd: %_syntb
	vvp -N $< +vcd=$@

show_synth_%: %.v
	yosys -p "read_verilog $<; proc; opt; show -colors 2 -width -signed"

prog: $(PROJ).bin
	iceprog $<

lint:
	verible-verilog-lint --rules=-explicit-parameter-storage-type src/*.v

clean:
	rm -rf $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin $(PROJ).json $(PROJ).log *.vcd $(ADD_CLEAN) build/

.SECONDARY:
.PHONY: all prog clean
