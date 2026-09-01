-- PC.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains the ALU control s_typeion.
--
-- 0x00400000
-- NOTES:
-- 10/02/2023 by Sabrina Francis::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity PC is
  port(i_CLK : in std_logic;
       i_RST : in std_logic;
       i_input        : in std_logic_Vector(31 downto 0);
       PC           : out std_logic_Vector(31 downto 0));   

end PC;

architecture structural of PC is


  --signal s_D    : std_logic_Vector(31 downto 0);    -- Multiplexed input to the FF
  signal s_Q    : std_logic_Vector(31 downto 0);    -- Output of the FF

begin
  PC <= s_Q;
  -- The output of the FF is fixed to s_Q


process(i_CLK, i_RST, i_input)
begin
    if (i_RST = '1') then
      s_Q <= x"00400000"; -- Use "(others => '0')" for N-bit values
    elsif (rising_edge(i_CLK)) then
    --else
      s_Q <= i_input;
    end if;


  end process;




end structural;