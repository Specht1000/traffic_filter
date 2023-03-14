--------------------------------------
-- Biblioteca
--------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

--------------------------------------
-- Entidade
--------------------------------------
entity tp3 is
  port( prog, din, reset, clock: in std_logic;
	mode: in std_logic_vector(2 downto 0);
	dout: out std_logic;
	alarme: out std_logic;
	pattern: out std_logic_vector(1 downto 0)
    );
end entity;

--------------------------------------
-- Arquitetura
--------------------------------------
architecture tp3 of tp3 is
  type state is ( ESPERA, PADRAO1, PADRAO2, PADRAO3, START, RESTART, GRAVA1, GRAVA2, GRAVA3 );
  signal EA, PE: state;
  signal reg_prog: std_logic_vector(7 downto 0);
  signal reg_din: std_logic_vector(7 downto 0);
  signal reg_p1: std_logic_vector(7 downto 0);
  signal reg_p2: std_logic_vector(7 downto 0);
  signal reg_p3: std_logic_vector(7 downto 0);
  signal comp_p1, comp_p2, comp_p3: std_logic;
  signal valid_p1, valid_p2, valid_p3: std_logic;
  signal match_p1, match_p2, match_p3: std_logic;
  signal match, match_en, match_verif: std_logic;
  signal cont: std_logic_vector(2 downto 0);
  signal pattern_int: std_logic_vector(1 downto 0);
  signal alarme_int: std_logic;

begin

  ------------------------------------
  -- MAQUINA DE ESTADOS (FSM)
  ------------------------------------
  process(clock, reset)
  begin
    if reset = '1' then
		EA <= ESPERA;
	elsif rising_edge(clock) then
		EA <= PE;
  end if;
  end process;

  process(EA, mode, cont)
  begin
    case EA is
		when ESPERA =>
		  if mode = "000" then
			PE <= ESPERA;
		  elsif mode = "001" then
			PE <= GRAVA1;
		  elsif mode = "010" then
			PE <= GRAVA2;
		  elsif mode = "011" then
			PE <= GRAVA3;
		  elsif mode = "100" then
			PE <= START;
		  elsif mode = "101" then
			PE <= RESTART;
		end if;
		when GRAVA1 =>
	      if cont = "111" then
		    PE <= ESPERA;
		  else
		    PE <= PADRAO1;
		  end if;
		when PADRAO1 =>
	      if cont = "111" then
		    PE <= ESPERA;
		  else
		    PE <= EA;
		  end if;
		when GRAVA2 =>
	      if cont = "111" then
		    PE <= ESPERA;
		  else
		    PE <= PADRAO2;
		  end if;
		when PADRAO2 =>
		   if cont = "111" then
		    PE <= ESPERA;
		   else
		    PE <= EA;
		  end if;
		when GRAVA3 =>
	      if cont = "111" then
		    PE <= ESPERA;
		  else
		    PE <= PADRAO3;
		  end if;
		when PADRAO3 =>
		   if cont = "111" then
		    PE <= ESPERA;
		   else
			PE <= EA;
		  end if;
		when START =>
		   PE <= ESPERA;
		when RESTART =>
		   PE <= ESPERA;
    end case;
  end process;

  ------------------------------------
  -- REGISTRADORES DE DESLOCAMENTO
  -- QUE RECEBE O FLUXO DE ENTRADA
  -- E OS DADOS DE PROGRAMAÇÃO
  ------------------------------------
  process(clock, reset)
  begin
	if reset = '1' then
	reg_prog <= (others => '0');
	reg_din <= (others => '0');
	elsif rising_edge(clock) then
	reg_prog(7) <= prog;
	reg_prog(6) <= reg_prog(7);
	reg_prog(5) <= reg_prog(6);
	reg_prog(4) <= reg_prog(5);
	reg_prog(3) <= reg_prog(4);
	reg_prog(2) <= reg_prog(3);
	reg_prog(1) <= reg_prog(2);
	reg_prog(0) <= reg_prog(1);
	reg_din(7) <= din;
	reg_din(6) <= reg_din(7);
	reg_din(5) <= reg_din(6);
	reg_din(4) <= reg_din(5);
	reg_din(3) <= reg_din(4);
	reg_din(2) <= reg_din(3);
	reg_din(1) <= reg_din(2);
	reg_din(0) <= reg_din(1);
	end if;

  end process;

  ------------------------------------
  -- CONTADOR
  ------------------------------------
  process(clock, reset)
  begin
     if reset = '1' then
     cont <= "000";
  elsif rising_edge(clock) then
    if EA = PADRAO1 then
      cont <= cont + 1;
	end if;
	if EA = PADRAO2 then
      cont <= cont + 1;
	end if;
	if EA = PADRAO3 then
      cont <= cont + 1;
	end if;
  end if;
  end process;

  ------------------------------------
  -- REGISTRADORES QUE DEPENDEM DA
  -- MAQUINA DE ESTADOS
  ------------------------------------
  process(clock, reset)
  begin
    if reset = '1' then
	reg_p1 <= (others => '0');
	reg_p2 <= (others => '0');
	reg_p3 <= (others => '0');
	valid_p1 <= '0';
	valid_p2 <= '0';
	valid_p3 <= '0';
	elsif rising_edge(clock) then
		if cont = "111" then
			if PE <= PADRAO1 then
			  reg_p1 <= reg_prog;
			  valid_p1 <= '1';    
			end if;
			if PE <= PADRAO2 then
			  reg_p2 <= reg_prog;
			  valid_p2 <= '1';    
			end if;
			if PE <= PADRAO3 then
			  reg_p3 <= reg_prog;
			  valid_p3 <= '1';    
			end if;
		end if;
	end if;
  end process;

  ------------------------------------
  -- REGISTRADORES QUE DEPENDEM DO
  -- SINAL MATCH_VERIF
  ------------------------------------
  process(clock, reset)
  begin
      if reset = '1' then
		pattern_int <= (others => '0');
		alarme_int <= '0';
	  elsif rising_edge(clock) then
		if EA = START then
		  if match_verif = '1' then
		  pattern <= pattern_int;
		  alarme <= alarme_int;
		  end if;
		end if;
		if EA = RESTART then
		  alarme <= '0';
		  pattern <= "00";
		end if;
	end if;
  end process;

  ------------------------------------
  -- REGISTRADOR PARA ATIVAR O MATCH_EN
  ------------------------------------
  process(clock, reset)
  begin
	  if reset = '1' then
      match_en <= '0';
	  elsif rising_edge(clock) then
      if EA = START then
      match_en <= '1';
	  end if;
	  if EA = RESTART then
      match_en <= '1';
	  end if;
	end if;
  end process;

  ------------------------------------
  -- CIRCUITOS COMBINACIONAIS
  ------------------------------------
  comp_p1  <= '1' when reg_din = reg_p1 else '0';
  comp_p2  <= '1' when reg_din = reg_p2 else '0';
  comp_p3  <= '1' when reg_din = reg_p3 else '0';
  match_p1 <= '1' when comp_p1 = '1' and valid_p1 = '1' else '0';
  match_p2 <= '1' when comp_p2 = '1' and valid_p2 = '1' else '0';
  match_p3 <= '1' when comp_p3 = '1' and valid_p3 = '1' else '0';
  match    <= '1' when match_p1 = '1' or match_p2 = '1' or match_p3 = '1' else '0';
  match_verif <= '1' when match = '1' and match_en = '1' else '0';

  alarme <= '1' when alarme_int = '1' else '0';
  dout   <= '1' when din = '1' and (not alarme_int) = '1' else '0';

  pattern_int <= "11" when match_p3 = '1' else
			     "10" when match_p2 = '1' else
				 "01" when match_p1 = '1' else
				 "00";
end architecture;