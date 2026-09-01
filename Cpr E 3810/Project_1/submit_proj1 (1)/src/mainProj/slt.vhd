library IEEE;
use IEEE.std_logic_1164.all;

entity slt is

  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));

end slt;

architecture dataflow of slt is
begin
process(i_A, i_B)
begin
if (i_A(31) = '1') then
	if (i_B(31) = '0') then
    		o_F <= x"00000001";
	else
		if (i_A > i_B) then
    			o_F <= x"00000000";
  		else
    			o_F <= x"00000001";
  		end if;
	end if;
else
	if (i_B(31) = '0') then
  		if (i_A < i_B) then
    			o_F <= x"00000001";
  		else
    			o_F <= x"00000000";
  		end if;
	else
		o_F <= x"00000000";
	end if;
end if;

if (i_A = i_B) then
	o_F <= x"00000000";
end if;

end process;


end dataflow;
