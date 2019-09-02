# Copyright (c) 2017 Cory Perry
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

HEADERS := $(wildcard rtl/*.vh)
VFLAGS :=
OUT := out

MODULE_TESTS := $(notdir $(basename $(wildcard tb/*_tb.v)))
PROG_TESTS := $(notdir $(basename $(notdir $(wildcard progs/*_prog.s))))
VERILOG ?= $(shell which iverilog)
SYNTH ?= $(shell which yosys)

SIM_MODULE_TESTS := $(MODULE_TESTS)
SIM_PROG_TESTS := $(PROG_TESTS)
ifneq (SYNTH,)
	SYNTH_MODULE_TESTS := $(subst _tb,_synth_tb,$(MODULE_TESTS))
	SYNTH_PROG_TESTS := $(subst _tb,_synth_tb,$(PROG_TESTS))
endif

include module_parameters.mk

all:	build
.PRECIOUS:	$(OUT)/%_synth.v

$(OUT):
	-@mkdir -p $@

rtl/%.v:	$(HEADERS)
$(OUT)/%_synth.v:	rtl/%.v module_parameters.mk
	$(SYNTH) -o $@ $< -q -l $(OUT)/$*_synth.log \
		-p "read_liberty -lib synth/stdcells.lib" \
		-p "synth -top $*" \
		-p "flatten" \
		-p "check -assert" \
		-p "dfflibmap -liberty synth/stdcells.lib" \
		-p "abc -constr synth/stdcells.constr -dff -liberty synth/stdcells.lib -markgroups -D $(DELAY)" \
		-p "stat -width"
$(OUT)/%_synth_tb:	tb/%_tb.v $(OUT)/%_synth.v
	$(VERILOG) -o $@ $^ synth/stdcells.v $(VFLAGS)
$(OUT)/%_tb:	tb/%_tb.v rtl/%.v
	$(VERILOG) -o $@ $^ $(VFLAGS)

%_tb.build:	$(OUT)
	@$(MAKE) $(OUT)/$*_tb
%_tb.run:	%_tb.build
	cd $(OUT); ./$*_tb
%_tb.test:
	@printf '%-20s ' $*
	@if $(MAKE) $*_tb.run | grep -q '*** PASSED ***'; then echo PASSED; else echo FAILED; exit 1; fi
%_tb.waves:	%_tb.build
	cd $(OUT); ./$*_tb +WAVES=$*.vcd

prog_runner:	progs/prog_runner.v
	iverilog -o $@ $^

%_prog.bin:
	# TODO: add command to assemble a riscv program
%_prog.build:	%_prog prog_runner
%_prog.run:	%_prog.build
	cd $(OUT); ./prog_runner +testname=$*_prog.bin
%_prog.waves:	%_prog.build
	cd $(OUT); ./prog_runner +testname=$*_prog +WAVES=$*_prog.vcd
%_prog.test:
	@printf '%-20s ' $*
	@if $(MAKE) $*_tb.run | grep -q '*** PASSED ***'; then echo PASSED; else echo FAILED; exit 1; fi

build:	$(OUT)
	@$(MAKE) $(addsuffix .build,$(SIM_MODULE_TESTS) $(SIM_PROG_TESTS))
synth_build:	$(OUT)
	@$(MAKE) $(addsuffix .build,$(SYNTH_MODULE_TESTS) $(SYNTH_PROG_TESTS))
test:
	@if [ ! -z "$(SIM_MODULE_TESTS)" ]; then $(MAKE) $(addsuffix .test,$(SIM_MODULE_TESTS)); fi
	@if [ ! -z "$(SIM_PROG_TESTS)" ]; then $(MAKE) $(addsuffix .test,$(SIM_PROG_TESTS)); fi
synth_test:
	@if [ ! -z "$(SYNTH_MODULE_TESTS)" ]; then $(MAKE) $(addsuffix .test,$(SYNTH_MODULE_TESTS)); fi
	@if [ ! -z "$(SYNTH_PROG_TESTS)" ]; then $(MAKE) $(addsuffix .test,$(SYNTH_PROG_TESTS)); fi
clean:
	$(RM) -r $(OUT)
