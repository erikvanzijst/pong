
all: $(PROJ).rpt $(PROJ).bin

%.blif: %.v $(ADD_SRC) $(ADD_DEPS)
	yosys -ql $*.log -p 'synth_ice40 -top top -blif $@' $< $(ADD_SRC)

%.json: %.v $(ADD_SRC) $(ADD_DEPS)
	yosys -ql $*.log -p 'synth_ice40 -top top -json $@' $< $(ADD_SRC)

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
	iverilog -o sim_build/sim.vvp -Ptop.SCREENTIMERWIDTH=6 -Ptop.BALLSPEED=32 -s top -s dump pong.v clkdiv.v screen.v ball.v math.v test/dump_pong.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_pong vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp

mathsim:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/mathsim.vvp -s sin -s dump math.v test/dump_math.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_math vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/mathsim.vvp

ballsim:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/ballsim.vvp -Pball.THETA_WIDTH=6 -s ball -s dump  clkdiv.v ball.v math.v test/dump_ball.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_ball vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/ballsim.vvp

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
	verible-verilog-lint *v --rules_config verible.rules

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin $(PROJ).json $(PROJ).log $(PROJ).vcd $(ADD_CLEAN)

.SECONDARY:
.PHONY: all prog clean
