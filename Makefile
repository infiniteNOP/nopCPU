compiler-test=iverilog
test: 
	$(compiler-test) alu.v control_unit.v cpu_tb.v cpu.v regfile.v bidirecp.v -o cpu-test

clean:
	rm -rf cpu-test
