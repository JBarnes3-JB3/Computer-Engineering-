-- ALU.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains the ALU control function.
--
--
-- NOTES:
-- 10/02/2023 by Sabrina Francis::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ALU is
  port(rst               : in std_logic;
       clk		: in std_logic;
       A       		: in std_logic_Vector(31 downto 0);
       B       		: in std_logic_Vector(31 downto 0);
       shftamt          : in std_logic_Vector(4 downto 0);
       s_F     		: in std_logic_Vector(4 downto 0) := "11111";
       output           : out std_logic_Vector(31 downto 0);
       zero  		: out std_logic;
       overflow         : out std_logic);   

end ALU;

architecture structural of ALU is

component Add_Sub_MIPS1 is
  generic(N : integer := 32); 
  port(rst               : in std_logic;
       clk               : in std_logic;
       i_Af              : in std_logic_vector(N-1 downto 0);
       i_Bf              : in std_logic_vector(N-1 downto 0);
       immidiate	 : in std_logic_vector(N-1 downto 0);
       i_Sf              : in std_logic;
       ALUsrc		 : in std_logic;
       s_O               : in std_logic;
       o_Of              : out std_logic_vector(N-1 downto 0);
       o_Cf      	 : out std_logic;
       overflow          : out std_logic);
end component;

component extension is
  port(input             : in std_logic_Vector(15 downto 0);
       i_S               : in std_logic; -- if 0 then zero extend, if 1 then sign extend
       output            : out std_logic_Vector(31 downto 0));
end component;

component barrel_shifter is
  port(input             : in std_logic_vector(31 downto 0);
       i_shftamt         : in std_logic_vector(4 downto 0);       
       i_dir             : in std_logic;                          
       i_type            : in std_logic;                          
       output            : out std_logic_vector(31 downto 0));
end component;

component and_32bit is
  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));
end component;

component nor_32bit is
  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));
end component;

component or_32bit is
  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));
end component;

component xor_32bit is
  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));
end component;

component slt is
  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));
end component;

signal a_temp_overflow : std_logic;
signal ai_temp_overflow : std_logic;
signal aiu_temp_overflow : std_logic;
signal au_temp_overflow : std_logic;
signal s_temp_overflow : std_logic;
signal su_temp_overflow : std_logic;
signal lui_temp_overflow : std_logic;
signal lw_temp_overflow : std_logic;
signal sw_temp_overflow : std_logic;

signal extended : std_logic_vector(31 downto 0);
signal add_output : std_logic_vector(31 downto 0);
signal addi_output : std_logic_vector(31 downto 0);
signal addiu_output : std_logic_vector(31 downto 0);
signal addu_output : std_logic_vector(31 downto 0);
signal sub_output : std_logic_vector(31 downto 0);
signal subu_output : std_logic_vector(31 downto 0);
signal sll_output : std_logic_vector(31 downto 0);
signal srl_output : std_logic_vector(31 downto 0);
signal sra_output : std_logic_vector(31 downto 0);
signal and_output : std_logic_vector(31 downto 0);
signal andi_output : std_logic_vector(31 downto 0);
signal nor_output : std_logic_vector(31 downto 0);
signal xor_output : std_logic_vector(31 downto 0);
signal xori_output : std_logic_vector(31 downto 0);
signal or_output : std_logic_vector(31 downto 0);
signal ori_output : std_logic_vector(31 downto 0);
signal slt_output : std_logic_vector(31 downto 0);
signal slti_output : std_logic_vector(31 downto 0);


signal signExt : std_logic := '0';

signal Foutput : std_logic_vector(31 downto 0);
signal Fzero : std_logic;
signal Foverflow : std_logic;

signal lui_output_unshifted : std_logic_vector(31 downto 0);
signal lui_output_shifted : std_logic_vector(31 downto 0);
signal lw_output : std_logic_vector(31 downto 0);
signal sw_output : std_logic_vector(31 downto 0);


begin

P0: process(s_F)
begin
if (s_F = "10000") then
	signExt <= '1';
elsif (s_F = "10001") then
	signExt <= '1';
elsif (s_F = "10111") then
	signExt <= '1';
else
signExt <= '0';
end if;
--wait for 2 ns;
end process;



ADD: Add_Sub_MIPS1 port map(rst => rst,
			clk => clk,
			i_Af => A,
			i_Bf => B,
			immidiate => B,
			s_O => '1',
			i_Sf => '0',
			ALUsrc => '0',
			o_Of => add_output,
			overflow => a_temp_overflow);

ADDI: Add_Sub_MIPS1 port map(rst => rst,
			clk => clk,
			i_Af => A,
			i_Bf => B,
			immidiate => B,
			s_O => '1',
			i_Sf => '0',
			ALUsrc => '0',
			o_Of => addi_output,
			overflow => ai_temp_overflow);

ZEROE: extension port map(input => B(15 downto 0),
			i_S => signExt,
			output => extended);

ADDIU: Add_Sub_MIPS1 port map(rst => rst,
			clk => clk,
			i_Af => A,
			i_Bf => extended,
			immidiate => B,
			s_O => '0',
			i_Sf => '0',
			ALUsrc => '0',
			o_Of => addiu_output,
			overflow => aiu_temp_overflow);

ADDU: Add_Sub_MIPS1 port map(rst => rst,
			clk => clk,
			i_Af => A,
			i_Bf => B,
			immidiate => B,
			s_O => '0',
			i_Sf => '0',
			ALUsrc => '0',
			o_Of => addu_output,
			overflow => au_temp_overflow);

SUB: Add_Sub_MIPS1 port map(rst => rst,
			clk => clk,
			i_Af => A,
			i_Bf => B,
			immidiate => B,
			s_O => '1',
			i_Sf => '1',
			ALUsrc => '0',
			o_Of => sub_output,
			overflow => s_temp_overflow);

SUBU: Add_Sub_MIPS1 port map(rst => rst,
			clk => clk,
			i_Af => A,
			i_Bf => B,
			immidiate => B,
			s_O => '0',
			i_Sf => '1',
			ALUsrc => '0',
			o_Of => subu_output,
			overflow => su_temp_overflow);

SHIFT_LEFT_L: barrel_shifter port map(input => B,
			i_shftamt => shftamt,
			i_dir => '1',
			i_type => '0',
			output => sll_output);

SHIFT_RIGHT_L: barrel_shifter port map(input => B,
			i_shftamt => shftamt,
			i_dir => '0',
			i_type => '0',
			output => srl_output);

SHIFT_RIGHT_A: barrel_shifter port map(input => B,
			i_shftamt => shftamt,
			i_dir => '0',
			i_type => '1',
			output => sra_output);

AND_32: and_32bit port map(i_A => A,
			i_B    => B,
		        o_F    => and_output);

AND_32I: and_32bit port map(i_A => A,
			i_B    => extended,
		        o_F    => andi_output);

NOR_32: nor_32bit port map(i_A => A,
			i_B    => B,
		        o_F    => nor_output);

XOR_32: xor_32bit port map(i_A => A,
			i_B    => B,
		        o_F    => xor_output);

XOR_32I: xor_32bit port map(i_A => A,
			i_B    => extended,
		        o_F    => xori_output);

OR_32: or_32bit port map(i_A => A,
			i_B    => B,
		        o_F    => or_output);

OR_32I: or_32bit port map(i_A => A,
			i_B    => extended,
		        o_F    => ori_output);

SLT1: slt port map(i_A => A,
			i_B    => B,
		        o_F    => slt_output);

SLTI: slt port map(i_A => A,
			i_B    => extended,
		        o_F    => slti_output);

LUI_UNSHIFTED: Add_Sub_MIPS1 port map(rst => rst,
			clk => clk,
			i_Af => A,
			i_Bf => extended,
			immidiate => B,
			s_O => '0',
			i_Sf => '0',
			ALUsrc => '0',
			o_Of => lui_output_unshifted,
			overflow => lui_temp_overflow);

LUI_SHIFTED: barrel_shifter port map(input => lui_output_unshifted,
			i_shftamt => "10000",
			i_dir => '1',
			i_type => '0',
			output => lui_output_shifted);

LW: Add_Sub_MIPS1 port map(rst => rst,
			clk => clk,
			i_Af => A,
			i_Bf => extended,
			immidiate => B,
			s_O => '0',
			i_Sf => '0',
			ALUsrc => '0',
			o_Of => lw_output,
			overflow => lw_temp_overflow);

SW: Add_Sub_MIPS1 port map(rst => rst,
			clk => clk,
			i_Af => A,
			i_Bf => extended,
			immidiate => B,
			s_O => '0',
			i_Sf => '0',
			ALUsrc => '0',
			o_Of => sw_output,
			overflow => sw_temp_overflow);

P1: process(A(31 downto 0), B(31 downto 0), shftamt(4 downto 0), s_F(4 downto 0), clk)
--process
begin

if (s_F = "00011") then --add
	Foutput <= add_output;
	Foverflow <= a_temp_overflow;
	Fzero <= '0';
elsif (s_F = "01111") then --addi
	Foutput <= addi_output;
	--signExt <= '1';
	Foverflow <= ai_temp_overflow;
	Fzero <= '0';
elsif (s_F = "10000") then --addiu
	Foutput <= addiu_output;
	Foverflow <= aiu_temp_overflow;
	Fzero <= '0';
elsif (s_F = "00100") then --addu
	Foutput <= addu_output;
	Foverflow <= au_temp_overflow;
	Fzero <= '0';
elsif (s_F = "01010") then --sub
	Foutput <= sub_output;
	Foverflow <= s_temp_overflow;
	Fzero <= '0';
elsif (s_F = "01011") then --subu
	Foutput <= subu_output;
	Foverflow <= su_temp_overflow;
	Fzero <= '0';
elsif (s_F = "00000") then --sll
	Foutput <= sll_output;
	Foverflow <= '0';
	Fzero <= '0';
elsif (s_F = "00001") then --srl
	Foutput <= srl_output;
	Foverflow <= '0';
	Fzero <= '0';
elsif (s_F = "00010") then --sra
	Foutput <= sra_output;
	Foverflow <= '0';
	Fzero <= '0';
elsif (s_F = "00101") then --and
	Foutput <= and_output;
	Foverflow <= '0';
	Fzero <= '0';
elsif (s_F = "10010") then --andi
	Foutput <= andi_output;
	Foverflow <= '0';
	Fzero <= '0';
elsif (s_F = "00111") then --nor
	Foutput <= nor_output;
	Foverflow <= '0';
	Fzero <= '0';
elsif (s_F = "01100") then --xor
	Foutput <= xor_output;
	Foverflow <= '0';
	Fzero <= '0';
elsif (s_F = "10100") then --xori
	Foutput <= xori_output;
	--signExt <= '1';
	Foverflow <= '0';
	Fzero <= '0';
elsif (s_F = "01000") then --or
	Foutput <= or_output;
	Foverflow <= '0';
	Fzero <= '0';
elsif (s_F = "10011") then --ori
	Foutput <= ori_output;
	Foverflow <= '0';
	--signExt <= '0';
	Fzero <= '0';
elsif (s_F = "01001") then --slt
	Foutput <= slt_output;
	Foverflow <= '0';
	Fzero <= '0';
elsif (s_F = "10001") then --slti
	Foutput <= slti_output;
	Foverflow <= '0';
	Fzero <= '0';
elsif (s_F = "01101") then --beq
	  if (A = B) then
             Fzero <= '1';
	Foverflow <= '0';
          else
             Fzero <= '0';
	Foverflow <= '0';
          end if;
elsif (s_F = "01110") then --bne
	if (A = B) then
             Fzero <= '0';
	Foverflow <= '0';
          else
             Fzero <= '1';
	Foverflow <= '0';
          end if;
elsif (s_F = "10101") then --lui
	Foutput <= lui_output_shifted;
	Fzero <= '0';
	Foverflow <= '0';
elsif (s_F = "10110") then --lw
	Foutput <= lw_output;
	Fzero <= '0';
	Foverflow <= '0';
elsif (s_F = "10111") then --sw
	Foutput <= sw_output;
	Fzero <= '0';
	Foverflow <= '0';
elsif (s_F = "11000") then --jal
	Foutput <= add_output;
	Fzero <= '0';
	Foverflow <= '0';
elsif (s_F = "10111") then --j
	Fzero <= '0';
elsif (s_F = "10111") then --jr
	Fzero <= '0';
elsif (s_F = "10111") then --jal
	Fzero <= '0';
end if;
end process;

output <= Foutput;
zero <= Fzero;
overflow <= Foverflow;

end structural;
