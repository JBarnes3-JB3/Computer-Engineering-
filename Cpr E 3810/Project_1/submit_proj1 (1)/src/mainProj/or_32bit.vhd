library IEEE;
use IEEE.std_logic_1164.all;

entity or_32bit is

  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));

end or_32bit;

architecture dataflow of or_32bit is

component org2 is
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

begin

  or_loop : for i in 0 to 31 generate
	or_gate : org2 port map(i_A    => i_A(i),
                       i_B    => i_B(i),
                       o_F    => o_F(i));
  end generate or_loop;

end dataflow;