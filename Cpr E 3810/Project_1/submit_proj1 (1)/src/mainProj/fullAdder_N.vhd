-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 2:1
-- mux using structural VHDL, generics, and generate statements.
--
--
-- NOTES:
-- 1/6/20 by H3::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity fullAdder_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(rst               : in std_logic;
       clk               : in std_logic;
       i_A1              : in std_logic_vector(N-1 downto 0);
       i_B1              : in std_logic_vector(N-1 downto 0);
       i_C1              : in std_logic;
       s_O               : in std_logic;
       o_S1              : out std_logic_vector(N-1 downto 0);
       o_C1              : out std_logic;
       overflow          : out std_logic);

end fullAdder_N;

architecture structural of fullAdder_N is

  component fullAdder is
    port(i_A1              : in std_logic;
       i_B1              : in std_logic;
       i_C1              : in std_logic;
       o_S1              : out std_logic;
       o_C1              : out std_logic);
  end component;

component xorg2 is
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

signal t : std_logic_vector(N-1 downto 1);
signal over : std_logic := '0';
signal temp : std_logic;
constant c: INTEGER := N-1;
signal t_overflow : std_logic := '0';

begin
   --Instantiate N mux instances.


   
--overflow <= t_overflow;
  --G_NBit_ADDERI: for i in 0 to N-1 generate

     C1: fullAdder port map(
               	i_A1      => i_A1(0),    
               	i_B1     => i_B1(0), 
               	i_C1     => i_C1, 
               	o_S1      => o_S1(0),
  	      	o_C1      => t(1)); 
     C2: for i in 1 to N-2 generate
     	ADDI: fullAdder port map(
               	i_A1      => i_A1(i),    
               	i_B1     => i_B1(i), 
               	i_C1     => t(i), 
               	o_S1      => o_S1(i),
  	      	o_C1      => t(i+1)); 
 	end generate;
     C3: fullAdder port map(
               	i_A1      => i_A1(c),    
               	i_B1     => i_B1(c), 
               	i_C1     => t(c), 
               	o_S1      => o_S1(c),
  	      	o_C1      => temp); 

     XORI: xorg2 port map(i_A => t(c),
 			i_B => temp,
 			o_F => over);

--P1: process(rst,clk,i_A1, i_B1, s_O)
--begin
--if (s_O = '0') then
-- 	t_overflow <= '0';
-- else
-- 	t_overflow <= over;
-- end if;
--end process;
 o_C1 <= temp;
--overflow <= t_overflow;
  --end generate G_NBit_ADDERI;
overflow <= (over and s_O);
--overflow <= ((t(c) XOR temp) and s_O);



--overflow <= t_overflow;
  
end structural;