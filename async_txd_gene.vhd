library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity async_txd_gene is
generic (	Horloge	: positive := 25000000;
		BaudRate: positive := 115200);
port( 
	clk, TxD_start	: in std_logic;
	TxD_Data	: in std_logic_vector(7 downto 0);
	TxD, TxD_Busy	: out std_logic);
end async_txd_gene;

architecture Behavioral of async_txd_gene is
type Etat is (attente, chargement, memorisation, decalage);
signal present, futur: Etat;

signal fin_cpt217	: std_logic;
signal fin_cpt10	: std_logic;
signal start_counting	: std_logic;
signal busy		: std_logic;
signal cmd		: std_logic_vector(1 downto 0);
signal reg_cpt217	: integer := Horloge/BaudRate;
signal reg_cpt10	: std_logic_vector(3 downto 0):= "0000";
signal reg_data		: std_logic_vector(10 downto 0);

begin
--------- compteur modulo 218 ----------
process(clk)
begin
	if rising_edge(clk) then
		if (fin_cpt217 = '1') then reg_cpt217<= Horloge/BaudRate;
		else reg_cpt217 <= reg_cpt217-1;
		end if;
	end if;
end process;
fin_cpt217 <= '1' when reg_cpt217= 0 else '0';
--------- compteur modulo 11 ----------
process(clk)
begin
	if rising_edge(clk) then
		if (start_counting ='0') then reg_cpt10 <= (others =>'0');
		elsif (fin_cpt10 = '1') then reg_cpt10 <= (others =>'0');
			elsif (fin_cpt217 ='1') then reg_cpt10 <= std_logic_vector(unsigned(reg_cpt10)+1);
				else reg_cpt10 <= reg_cpt10;
		end if;
	end if;
end process;
fin_cpt10 <= '1' when unsigned(reg_cpt10)="1011"  else '0';

--------- registre a decallage ----------
process(clk)
begin
	if rising_edge(clk) then
		case cmd is
			when "00" => reg_data <= "11"& TxD_data &'0'; -- chargement
			when "01" => reg_data <= '1'&reg_data(10 downto 1);
			when "10" => reg_data <= reg_data;
			when others => reg_data <= (others =>'1');
		end case;
	end if;
end process;

--------- controle machine d'etat ---------
process (clk)
begin
	if rising_edge(clk) then
		present <= futur;
	end if;
end process;

process(TxD_start, fin_cpt217, fin_cpt10, present)
begin
	case present is
		when attente => if TxD_start = '1' then
							futur <= chargement;
						end if;
						busy <= '0';
						start_counting <= '0';
						cmd <= "11";
		when chargement => futur <= memorisation;
						busy <= '1';
						start_counting <='1';
						cmd <="00";
		when memorisation => if (fin_cpt217 ='1') then
					futur <= decalage;
						end if ;
						busy <= '1';
						start_counting <= '1';
						cmd <= "10";
		when decalage => if (fin_cpt10 ='1') then
					futur <= attente;
				 else futur <= memorisation;
				 end if;
				 busy <= '1';
				 start_counting <= '1';
				 cmd <= "01";
	end case;
end process;						

------ output -----
TxD <= reg_data(0);
TxD_Busy <= busy;
end Behavioral;