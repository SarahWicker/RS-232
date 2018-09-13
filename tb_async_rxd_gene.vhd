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

DUT : entity work.async_rxd
	generic map (
		BaudRate => 115200,
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
	'0' after 8700 ns, --start
	'0' after 17400 ns,
	'0' after 26100 ns,
	'0' after 34800 ns,
	'1' after 43500 ns,
	'0' after 52200 ns,
	'0' after 60900 ns,
	'1' after 69600 ns,
	'0' after 78300 ns,
	'1' after 87000 ns;-- stop
	

end test;