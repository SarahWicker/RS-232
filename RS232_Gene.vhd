library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RS232_Gene is
generic (	Horloge	: positive := 25000000;
			BaudRate: positive := 115200;
			Sample	: positive := 16);
port( 
	clk, TxD_start, RxD		: in std_logic;
	TxD_Data				: in std_logic_vector(7 downto 0);
	TxD, TxD_Busy,data_ready: out std_logic;
	RxD_data				: out std_logic_vector(7 downto 0));
end RS232_Gene;

architecture Behavioral of RS232_Gene is

component async_txd_gene
	generic (	
		Horloge	: positive := 25000000;
		BaudRate: positive := 115200);
	port(	
		clk,TxD_start : in std_logic;
		TxD_data : in std_logic_vector(7 downto 0);
		TxD,TxD_busy : out std_logic);
end component;

component async_rxd_gene
	generic (
		BaudRate	: positive :=115200;
		Horloge		: positive :=25000000;
		Sample		: positive :=16);
	port(
		clk, RxD	: in std_logic;
		RxD_data	: out std_logic_vector(7 downto 0);
		data_ready	: out std_logic);
end component;

begin 

transmitter : async_txd_gene
	generic map (Horloge,BaudRate)
	port map(clk,TxD_start,TxD_data,TxD,TxD_busy);
receiver : async_rxd_gene
	generic map (BaudRate, Horloge, Sample)
	port map(clk,RxD,RxD_data,data_ready);
	

end Behavioral;