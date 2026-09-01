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

entity onesComp is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_X          : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));

end onesComp;

architecture structural of onesComp is

  component invg is

  port(i_A          : in std_logic;
       o_F          : out std_logic);
  end component;

begin

  -- Instantiate N mux instances.
  G_OnesComp: for i in 0 to N-1 generate
    INVGI: invg port map(
              i_A      => i_X(i),  -- ith instance's data 1 input hooked up to ith data 1 input.
              o_F      => o_O(i));  -- ith instance's data output hooked up to ith data output.
  end generate G_OnesComp;
  
end structural;