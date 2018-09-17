library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_async_rxd_gene is
end tb_async_rxd_gene;

architecture test of tb_async_rxd_gene is
constant T : time := 40 ns;

signal clk, RxD		: std_logic;
signal RxD_data		: std_logic_vector(7 downto 0);
signal data_ready	: std_logic;

begin

DUT : entity work.async_rxd_gene
	generic map (
		BaudRate => 9600,
		Horloge	=> 25000000,
		Sample	=> 16)
	port map(
		clk => clk,
		RxD => RxD,
		RxD_data => RxD_data,
		data_ready => data_ready);

 process
 begin
	clk <= '0';
	wait for T/2;
	clk <= '1';
	wait for T/2;
end process;

RxD <= 	'1',
	'0' after 104 us, --start (time = 1/BaudRate)
	'0' after 208 us,
	'0' after 312 us,
	'0' after 416 us,
	'1' after 520 us,
	'0' after 624 us,
	'0' after 728 us,
	'1' after 832 us,
	'0' after 936 us,
	'1' after 1040 us;-- stop
	

end test;