# RS-232
Protocol RS-232 _ description&amp;simulation (vhdl)
for now not parametrable, made it for a special baud rate 115200bit/s and a oscillator with a frequency clock of 25MHz
async_txd:
principle : data load on Txd_Data, when press TxD_Start data is process into the format start&data&stop_bits, then each bit is sent at the baudrate defined before. When done get back to waiting state, until TxD_Start is "pressed" again.
important : data of 8 bits, 1 bit of start, 2 bits of stop, no parity
2 files:
  - async_txd.vhd => .vhd file, ready for implementation
  - tb_async_txd.vhd => test_bench, clk at the final frequency 
  
asynx_rxd:
principle : received flow of data and from it get the final 8 bits data. always actif, the process start when received the start bit (0),  placing in the middle of each received bits. Collect all the bits until get the 8th and store them into a register(at the same time). When done wait for the stop bit and get back to waiting state.
2 files:
  - async_rxd.vhd
  - tb_async_rxd

use ModelSim 10.4 for the simulation and QuartusII for the writing and implementation (use an ACEX1K for this project)
