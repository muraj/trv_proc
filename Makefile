MODULE_TESTS := $(basename $(wildcard *_tb.v))
PROG_TESTS := $(basename $(notdir $(wildcard progs/*_prog.s)))
ifdef ENABLE_SYNTH
SYNTH_MODULE_TESTS := $(subst _tb,_synth_tb,$(MODULE_TESTS))
SYNTH_PROG_TESTS := $(subst _tb,_synth_tb,$(PROG_TESTS))
endif
HEADERS := $(wildcard *.vh)
IVERILOG_FLAGS :=
OUT := out

all:	build
.PRECIOUS:	$(OUT)/%_synth.v

$(OUT):
	-@mkdir -p $@

%.v:	$(HEADERS)
$(OUT)/%_synth.v:	synth.ys %.v
	yosys -o $@ $*.v synth.ys
$(OUT)/%_synth_tb:	%_tb.v $(OUT)/%_synth.v
	iverilog -o $@ $^ $(VFLAGS)
$(OUT)/%_tb:	%_tb.v %.v
	iverilog -o $@ $^ $(VFLAGS)

%_tb.build:	$(OUT)
	@$(MAKE) $(OUT)/$*_tb
%_tb.run:	%_tb.build
	cd $(OUT); ./$*_tb
%_tb.test:
	@printf '%-20s ' $*
	@if $(MAKE) $*_tb.run | grep -q '*** PASSED ***'; then echo PASSED; else echo FAILED; exit 1; fi
%_tb.waves:	%_tb.build
	cd $(OUT); $*_tb +WAVES

prog_runner:	progs/prog_runner.v
	iverilog -o $@ $^

%_prog.bin:
	# TODO: add command to assemble a riscv program
%_prog.build:	%_prog prog_runner
%_prog.run:	%_prog.build
	cd $(OUT); ./prog_runner +testname=$*_prog.bin
%_prog.waves:	%_prog.build
	cd $(OUT); ./prog_runner +testname=$*_prog +WAVES
%_prog.test:
	@printf '%-20s ' $*
	@if $(MAKE) $*_tb.run | grep -q '*** PASSED ***'; then echo PASSED; else echo FAILED; exit 1; fi

build:	$(OUT)
	@$(MAKE) $(addsuffix .build,$(MODULE_TESTS) $(SYNTH_MODULE_TESTS) $(PROG_TESTS))
test:
	@if [ ! -z "$(MODULE_TESTS)" ]; then $(MAKE) $(addsuffix .test,$(MODULE_TESTS)); fi
	@if [ ! -z "$(SYNTH_MODULE_TESTS)" ]; then $(MAKE) $(addsuffix .test,$(SYNTH_MODULE_TESTS)); fi
	@if [ ! -z "$(PROG_TESTS)" ]; then $(MAKE) $(addsuffix .test,$(PROG_TESTS)); fi
	@if [ ! -z "$(SYNTH_PROG_TESTS)" ]; then $(MAKE) $(addsuffix .test,$(SYNTH_PROG_TESTS)); fi
clean:
	$(RM) -r $(OUT)
