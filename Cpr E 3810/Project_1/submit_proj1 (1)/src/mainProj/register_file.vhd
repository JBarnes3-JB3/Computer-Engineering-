-- dffg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an edge-triggered
-- flip-flop with parallel access and reset.
--
--
-- NOTES:
-- 8/19/16 by JAZ::Design created.
-- 11/25/19 by H3:Changed name to avoid name conflict with Quartus
--          primitives.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MIPS_types.all;

entity register_file is
generic(N : integer := 32);
  port(rs           : in std_logic_Vector(4 downto 0);     
       rt           : in std_logic_Vector(4 downto 0);     
       wrt          : in std_logic_Vector(4 downto 0);
       rd	    : in std_logic_Vector(N-1 downto 0);     
       clk          : in std_logic;
       reset        : in std_logic;
       enable       : in std_logic;  
       o_O1         : out std_logic_Vector(N-1 downto 0);
       o_O2         : out std_logic_Vector(N-1 downto 0));   

end register_file;

architecture structural of register_file is

component decoder is
  port(i_D        : in std_logic_Vector(4 downto 0); 
       o_OUT        : out std_logic_Vector(31 downto 0));
end component;

component andg2 is
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

component register_N is
generic(N : integer := 32);
  port(i_clk        : in std_logic;    
       i_reset      : in std_logic;   
       i_enable     : in std_logic;   
       i_D          : in std_logic_Vector(N-1 downto 0);    
       o_Q          : out std_logic_Vector(N-1 downto 0));   
end component;

component mux32t1 is
  generic(N : integer := 32); 
  port(i_S          : in std_logic_vector(4 downto 0);
       D	    : in bus_array;
       o_O          : out std_logic_vector(N-1 downto 0));
end component;

signal o_decoder : std_logic_vector(N-1 downto 0);
signal o_and : std_logic_vector(N-1 downto 0);
signal o_reg : bus_array;

begin


C1: decoder port map(
	i_D => wrt, 
	o_OUT => o_decoder);

C2: for i in 0 to N-1 generate
	ANDI: andg2 port map(
		i_A => o_decoder(i),
		i_B => enable,
		o_F => o_and(i));
    end generate;

C3a: register_N port map(
		i_clk => clk,
		i_reset => '1',
		i_enable => '0',
		i_D => rd,
		o_Q => o_reg(0));

C3b: for i in 1 to N-1 generate
	REGI: register_N port map(
		i_clk => clk,
		i_reset => reset,
		i_enable => o_and(i),
		i_D => rd,
		o_Q => o_reg(i));
    end generate;

C4: mux32t1 port map(
	i_S => rs,
	D => o_reg,
	o_O => o_O1);

C5: mux32t1 port map(
	i_S => rt,
	D => o_reg,
	o_O => o_O2);


  
end structural;