--------------------------------------
-- Biblioteca
--------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

--------------------------------------
-- Entidade
--------------------------------------
entity tb is
end entity;

--------------------------------------
-- Arquitetura
--------------------------------------
architecture tb of tb is

  type test_record is record
    t      : integer;
    mode   : std_logic_vector(2 downto 0);
    padrao : std_logic_vector(7 downto 0);
  end record;

  type padroes is array(natural range <>) of test_record;
  constant padrao_de_teste : padroes := (
    (t =>   5, mode => "001", padrao => x"AC"),   
    (t =>  20, mode => "010", padrao => x"F0"),
    (t =>  35, mode => "011", padrao => x"6F"),
    (t =>  50, mode => "100", padrao => x"FF"), -- ATIVA A COMPARAÇÃO
    (t =>  70, mode => "101", padrao => x"FF"), --reset
    (t =>  90, mode => "101", padrao => x"FF"), --reset
    (t => 120, mode => "101", padrao => x"FF"), --reset
    (t => 200, mode => "101", padrao => x"FF"), --reset
    (t => 250, mode => "101", padrao => x"FF"), --reset
    (t => 300, mode => "101", padrao => x"FF")  --reset
  );

  -- LFSR: ----------------------------------------------- x^19+x^18+x^17+x^14+1
  constant GP : integer := 19 ;
  constant polinomio : std_logic_vector(GP-1 downto 0) := "1110010000000000000";
  constant seed : std_logic_vector(GP-1 downto 0)      := "1101101110110111011";
  signal lfsr, w_mask: std_logic_vector(GP-1 downto 0);
  ----------------------------------------------------------------------------

  signal reset : std_logic ;
  signal clock : std_logic := '0'; 
  signal din, dout, prog, alarme : std_logic := '0';
   
  signal mode : std_logic_vector(2 downto 0) := "000";
  signal pattern : std_logic_vector(1 downto 0);

  signal conta_tempo : integer := 0;
  signal programa : integer;
  signal tb_padrao : std_logic_vector(7 downto 0);
begin

  reset <= '1', '0' after 2 ns;
  clock <= not clock after 5 ns;

  DUT: entity work.tp3  
       port map(clock=>clock, reset=>reset,  din=>din, prog=>prog, mode=>mode, 
                dout=>dout, alarme=>alarme, pattern=>pattern );

  -- lfsr -------------------------------------- gera DIN de forma pseudo-aleatoria 
  g_mask : for k in GP-1 downto 0 generate
    w_mask(k) <= polinomio(k) and lfsr(0);
  end generate;

  process (clock, reset) begin
    if reset = '1' then
      lfsr <= seed;
    elsif rising_edge(clock) then
      lfsr <=  ('0' & lfsr(GP-1 downto 1))  xor w_mask ;
    end if;
  end process;

  din <= lfsr(0);
  -- end lfsr -----------------------------------------------------------------------

  -- injeta a programação dos padrões e comandos start/restart
  process(clock, reset)
  begin
    if reset = '1' then
      conta_tempo <= 0;
    elsif rising_edge(clock) then
      conta_tempo <= conta_tempo + 1;

      for i in 0 to padrao_de_teste'high loop    
        if padrao_de_teste(i).t = conta_tempo then
          mode <= padrao_de_teste(i).mode;
          tb_padrao <= padrao_de_teste(i).padrao;
          programa <= 1;
        end if;
      end loop;

      if programa > 0 then
        mode <= "000";  -- o mode só sobe 1 ciclo
        prog <= tb_padrao(0);
        tb_padrao <=  '0' & tb_padrao(7 downto 1);
        if programa < 8 then
          programa <= programa + 1;
        else
          programa <= 0;
        end if;
      end if;
    end if;
  end process;

end architecture; 