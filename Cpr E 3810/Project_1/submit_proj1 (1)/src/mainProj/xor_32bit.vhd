library IEEE;
use IEEE.std_logic_1164.all;

entity xor_32bit is

  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));

end xor_32bit;

architecture dataflow of xor_32bit is

component xorg2 is
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

begin

  xor_loop : for i in 0 to 31 generate
	xor_gate : xorg2 port map(i_A    => i_A(i),
                       i_B    => i_B(i),
                       o_F    => o_F(i));
  end generate xor_loop;

end dataflow;