VLIB ?= vlib
VLOG ?= vlog
VSIM ?= vsim

RTL := $(wildcard ../rtl/*.sv)
TB := $(wildcard ../tb/*.sv)
TESTS := uart_tx_tb uart_rx_tb uart_loopback_tb

.PHONY: all compile test clean

all: test

work:
	$(VLIB) work

compile: | work
	$(VLOG) -sv $(RTL) $(TB)

test: compile
	@set -e; for test in $(TESTS); do \
		$(VSIM) -c $$test -l $$test.log -do "run -all; quit -f"; \
		grep -q '^# Errors: 0,' $$test.log; \
	done

clean:
	$(RM) -r work modelsim.ini transcript *.log *.wlf *.ucdb
