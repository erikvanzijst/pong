
all: $(PROJ).rpt $(PROJ).bin

%.blif: src/%.v $(ADD_SRC) $(ADD_DEPS)
	yosys -ql $*.log -p 'synth_ice40 -top pong -blif $@' $< $(ADD_SRC)

%.json: src/%.v $(ADD_SRC) $(ADD_DEPS)
	yosys -ql $*.log -p 'synth_ice40 -top pong -json $@' $< $(ADD_SRC)

ifeq ($(USE_ARACHNEPNR),)
%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --$(DEVICE) --json $(filter-out $<,$^) --pcf $< --asc $@
else
%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d $(subst up,,$(subst hx,,$(subst lp,,$(DEVICE)))) -o $@ -p $^
endif

sim:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -Ppong.SCREENTIMERWIDTH=6 -Ppong.BALLSPEED=32 -s pong -s dump src/paddle.v src/pong.v src/clkdiv.v src/screen.v src/ball.v src/math.v test/dump_pong.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_pong vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp

mathsim:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/mathsim.vvp -s sin -s dump src/math.v test/dump_math.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_math vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/mathsim.vvp

ballsim:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/ballsim.vvp -Pball.THETA_WIDTH=6 -s ball -s dump  src/clkdiv.v src/ball.v src/math.v test/dump_ball.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_ball vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/ballsim.vvp

paddlesim:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/paddlesim.vvp -s paddle -s dump src/paddle.v test/dump_paddle.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_paddle vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/paddlesim.vvp

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
	verible-verilog-lint src/*.v --rules_config verible.rules

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin $(PROJ).json $(PROJ).log *.vcd $(ADD_CLEAN)

.SECONDARY:
.PHONY: all prog clean
