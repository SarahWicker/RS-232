library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity async_rxd_gene is
generic (
	BaudRate	: integer :=115200;
	Horloge		: integer :=25000000;
	Sample		: integer :=16);
	
port(
	clk, RxD	: in std_logic;
	RxD_data	: out std_logic_vector(7 downto 0);
	data_ready	: out std_logic);
end async_rxd_gene;

architecture Behavioral of async_rxd_gene is
type Etat is (attente, middle_position, decalage, pause, fin);
signal present, futur: Etat;

signal reg_cpt13	: integer := Horloge/(BaudRate*Sample);
signal reg_cpt7		: integer := Sample/2;
signal reg_cpt15	: integer := Sample;
signal cpt_bits		: std_logic_vector(3 downto 0):= "0000";
signal oversampling	: std_logic;
signal fin_cpt7		: std_logic;
signal fin_cpt15	: std_logic;
signal all_received	: std_logic;
signal start_cpt7	: std_logic := '0';
signal start_compteur	: std_logic := '0';
signal count		: std_logic :='0';
signal cmd		: std_logic :='0';
signal ready		: std_logic :='0';
signal reg_data		: std_logic_vector( 7 downto 0) := "00000000";

begin
--------- compteur modulo 14 : oversampling ----------
process(clk)
begin
	if rising_edge(clk) then
		if (oversampling = '1') then reg_cpt13 <= Horloge/(BaudRate*Sample);
		else reg_cpt13 <= reg_cpt13 -1;
		end if;
	end if;
end process;
oversampling <= '1' when reg_cpt13=0  else '0';
--------- compteur modulo 7 and 15 : middle data ----------
process(clk)
begin
	if rising_edge(clk) then
		if (start_cpt7 ='0') then reg_cpt7 <= Sample/2;
		elsif (fin_cpt7 = '1') then reg_cpt7 <= Sample/2;
			elsif oversampling ='1' then reg_cpt7 <= reg_cpt7-1;
				else reg_cpt7 <= reg_cpt7;
		end if;
	end if;
end process;
fin_cpt7 <= '1' when reg_cpt7=0  else '0';
process(clk)
begin
	if rising_edge(clk) then
		if (start_compteur ='0') then reg_cpt15 <=Sample;
		elsif (fin_cpt15 = '1') then reg_cpt15 <= Sample;
			elsif oversampling ='1' then reg_cpt15 <= reg_cpt15-1;
				else reg_cpt15 <= reg_cpt15;
		end if;
	end if;
end process;
fin_cpt15 <= '1' when reg_cpt15=0 else '0';
--------- compteur modulo 8 : data ----------
process(clk)
begin
	if rising_edge(clk) then
		if all_received='1' then cpt_bits <= (others=> '0');
		elsif	count = '1' then cpt_bits <= std_logic_vector(unsigned(cpt_bits)+1);
			else cpt_bits <= cpt_bits;
		end if;
	end if;
end process;
all_received <= '1' when unsigned(cpt_bits)="1000"  else '0';

--------- registre a decallage ----------
process(clk)
begin
	if rising_edge(clk) then
		if cmd='0' then reg_data <= reg_data; -- chargement
		else reg_data <= RxD & reg_data(7 downto 1);
		end if;
	end if;
end process;


--------- controle machine d'etat ---------
process (clk)
begin
	if rising_edge(clk) then
		present <= futur;
	end if;
end process;

process(RxD, fin_cpt7, fin_cpt15, all_received, present)
begin
	case present is
		when attente 	=>	if RxD='0' then futur <= middle_position;
					else futur <= attente;
					end if;
					----- "output"-----
					cmd<= '0';
					count<='0';
					start_cpt7 <='0';
					start_compteur <='0';
					ready<='0';
								
		when middle_position=>	if (fin_cpt7 ='1') then futur <= pause;
					else futur <= middle_position;
					end if;
					---------------------
					cmd<= '0';
					count<='0';
					start_cpt7 <='1';
					start_compteur <='0';
					ready<='0';
								
		when pause 	=>	if (fin_cpt15 ='1' and all_received ='0') then futur <= decalage;
					elsif all_received ='1' then futur <= fin;
					else futur <= pause;
					end if;
					----------------
					cmd<= '0';
					count<='0';
					start_cpt7 <='0';
					start_compteur <='1';
					ready<='0';
								
		when decalage 	=>	futur <= pause;
					--------------
					cmd<= '1';
					count<='1';
					start_cpt7 <='0';
					start_compteur <='1';
					ready<='0';
						
		when fin 	=>	if (RxD ='1') then futur <= attente;
					else futur <= fin;
					end if;
					-------------
					cmd<= '0';
					count<='0';
					start_cpt7 <='0';
					start_compteur <='0';
					ready<='1';
	end case;
end process;						

------ output -----
RxD_data <= reg_data;
data_ready <= ready;
end Behavioral;