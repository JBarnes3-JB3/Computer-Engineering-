-- JumpAddress.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains the ALU control s_typeion.
--
--
-- NOTES:
-- 10/02/2023 by Sabrina Francis::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity JumpAddress is
  port(inst         : in std_logic_Vector(25 downto 0);
       PC           : in std_logic_Vector(31 downto 0);
       jumpAddress  : out std_logic_Vector(31 downto 0));   

end JumpAddress;

architecture structural of JumpAddress is


begin

jumpAddress <= PC(31 downto 28) & inst & "00";

 
end structural;