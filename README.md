# RS-232
Protocol RS-232 _ description&amp;simulation (vhdl)
for now not parametrable, made it for a special baud rate 115200bit/s and a oscillator with a frequency clock of 25MHz
data of 8 bits, 1 bit of start, 2 bits of stop, no parity
2 files:
  - async_txd.vhd => .vhd file, ready for implementation
  - tb_async_txd.vhd => test_bench, clk at the final frequency

use ModelSim 10.4 for the simulation and QuartusII for the writing and implementation (use an ACEX1K for this project)
