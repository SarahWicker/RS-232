library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_async_txd is
end tb_async_txd;

architecture test of tb_async_txd is 
constant T : time := 40ns;

signal clk, TxD_start	: std_logic;
signal TxD_Data			: std_logic_vector(7 downto 0);
signal TxD, TxD_Busy		: std_logic;


begin

DUT : entity work.async_txd 
	port map(
		clk => clk,
		TxD_start => TxD_start,
		TxD_Data => TxD_Data,
		TxD => TxD,
		TxD_Busy => TxD_Busy );

 process
 begin
	clk <= '0';
	wait for T/2;
	clk <= '1';
	wait for T/2;
end process;


TxD_Data <= "10110001", "01001110" after 40 us;
TxD_Start <= '1','0' after 60 ns, '1' after 60 us;

end test;
