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
use work.MIPS_types.all;

entity mux32t1 is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_S          : in std_logic_vector(4 downto 0);
       D	    : in bus_array;
       o_O          : out std_logic_vector(N-1 downto 0));

end mux32t1;

architecture structural of mux32t1 is
begin
  --P1: process(i_S, D(0 to 31)) is
  --begin
    with i_S select
	o_O <=   D(0) when "00000",
		 D(1) when "00001",
 		 D(2) when "00010",
		 D(3) when "00011",
		 D(4) when "00100",
		 D(5) when "00101",
		 D(6) when "00110",
		 D(7) when "00111",
		 D(8) when "01000",
		 D(9) when "01001",
 		 D(10) when "01010",
		 D(11) when "01011",
		 D(12) when "01100",
		 D(13) when "01101",
		 D(14) when "01110",
		 D(15) when "01111",
		 D(16) when "10000",
		 D(17) when "10001",
 		 D(18) when "10010",
		 D(19) when "10011",
		 D(20) when "10100",
		 D(21) when "10101",
		 D(22) when "10110",
		 D(23) when "10111",
		 D(24) when "11000",
		 D(25) when "11001",
 		 D(26) when "11010",
		 D(27) when "11011",
		 D(28) when "11100",
		 D(29) when "11101",
		 D(30) when "11110",
		 D(31) when "11111",
		 x"00000000" when others;

  --end process;

end structural;