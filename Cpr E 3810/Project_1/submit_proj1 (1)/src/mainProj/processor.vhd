-- processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains the ALU control function.
--
--
-- NOTES:
-- 10/02/2023 by Team::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity processor is
  port(clk : in std_logic;
       overflow          : out std_logic);   

end processor;

architecture structural of processor is

component Add_Sub_MIPS1 is
  generic(N : integer := 32); 
  port(i_Af              : in std_logic_vector(N-1 downto 0);
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
  port(input            : in std_logic_Vector(15 downto 0);
       i_S              : in std_logic; -- if 0 then zero extend, if 1 then sign extend
       output              : out std_logic_Vector(31 downto 0));
end component;


component register_file is
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
end component;

component mem is
	generic 
	(
		DATA_WIDTH : natural := 32;
		ADDR_WIDTH : natural := 10
	);

	port 
	(
		clk		: in std_logic;
		addr	        : in std_logic_vector((ADDR_WIDTH-1) downto 0);
		data	        : in std_logic_vector((DATA_WIDTH-1) downto 0);
		we		: in std_logic := '1';
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);
end component;

component fullAdder_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_A1              : in std_logic_vector(N-1 downto 0);
       i_B1              : in std_logic_vector(N-1 downto 0);
       i_C1              : in std_logic;
       s_O               : in std_logic;
       o_S1              : out std_logic_vector(N-1 downto 0);
       o_C1              : out std_logic;
       overflow          : out std_logic);
end component;

component mux2t1_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));
  end component;

component ALU is
  port(A       		: in std_logic_Vector(31 downto 0);
       B       		: in std_logic_Vector(31 downto 0);
       s_F     		: in std_logic_Vector(4 downto 0) := "11111";
       output       : out std_logic_Vector(31 downto 0);
       zero  		: out std_logic;
       overflow         : out std_logic);  
end component;

component ALUcontrol is
  port(s_type       : in std_logic_Vector(5 downto 0);
       opcode       : in std_logic_Vector(5 downto 0);
       s_out        : out std_logic_Vector(4 downto 0));   
end component;

component control is
port( readIn   :   in std_logic_vector(5 downto 0); --bits 31-26 opcode
      ALUControl   :   out std_logic_vector(5 downto 0); --0010 will perform add of A and B
      ALUSrc   :   out std_logic; --use correcty extended immediate from B
      MemtoReg   :   out std_logic; -- on 0 does not read from memory
      MemRead   :   out std_logic;
      s_DMemWr   :   out std_logic; --memwrite from text, on 0 does not write to memory
      s_RegWr   :   out std_logic; --Regwrite from text, on 1 writes back to a register
	Jump	: 	out std_logic;
	Branch	: 	out std_logic;
      RegDst   :   out std_logic); --uses rt as destination register rather than rd

end component;

component barrel_shifter is

  port(input            : in std_logic_vector(31 downto 0);      -- 32 bit input
       i_shftamt        : in std_logic_vector(4 downto 0);       -- # of bits to shift
       i_dir            : in std_logic;                          -- direction of shift (0 = right, 1 = left)
       i_type           : in std_logic;                          -- type of shift (0 = logical, 1 = arithmetic)
       output           : out std_logic_vector(31 downto 0));    -- shifted output

end component;

component JumpAddress is
  port(inst         : in std_logic_Vector(25 downto 0);
       PC           : in std_logic_Vector(3 downto 0);
       jumpAddress  : out std_logic_Vector(31 downto 0));   

end component;

component andg2 is
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

component instruction_memory is
  port(clk          : in std_logic;
       readAddress  : in std_logic_vector(31 downto 0);
       instruction  : out std_logic_vector(31 downto 0));   

end component;

component PC is
  port(input        : in std_logic_Vector(31 downto 0) := x"00400000";
       PC           : out std_logic_Vector(31 downto 0));   
end component;



signal PCval : std_logic_vector(31 downto 0);

signal instruction : std_logic_vector(31 downto 0);

signal rt_rd : std_logic_vector(4 downto 0);
signal addr_data : std_logic_vector(31 downto 0);
signal A : std_logic_vector(31 downto 0);
signal Bo : std_logic_vector(31 downto 0);
signal Bi : std_logic_vector(31 downto 0);

signal extended_imm : std_logic_vector(31 downto 0);


signal RegDst : std_logic;
signal Jump : std_logic;
signal Branch : std_logic;
signal MemRead : std_logic;
signal MemtoReg : std_logic;
signal ALUOp : std_logic_vector(5 downto 0);
signal MemWrite : std_logic;
signal ALUSrc : std_logic;
signal RegWrite : std_logic; 

signal ALU_control : std_logic_vector(4 downto 0);
signal ALU_result : std_logic_vector(31 downto 0);

signal shifted2 : std_logic_vector(31 downto 0);
signal branchAdded : std_logic_vector(31 downto 0);
signal PC_4 : std_logic_vector(31 downto 0);

signal mem_data : std_logic_vector(31 downto 0);

signal zero : std_logic;
signal s_branch : std_logic; 
signal branched : std_logic_vector(31 downto 0); --choose between branch or PC
signal jump_Addr : std_logic_vector(31 downto 0);
signal wb_address : std_logic_vector(31 downto 0);




begin

PC_COMP: PC port map(
	input => wb_address,
	PC => PCval);


INSTRUCTION_MEM: instruction_memory port map(
	clk => clk,
	readAddress => PCval,
	instruction => instruction);

CNTRL: control port map(
	readIn => instruction(31 downto 26),
	ALUControl => ALUOp,
	ALUSrc => ALUSrc,
	MemtoReg => MemtoReg,
	MemRead => MemRead,
	s_DMemWr => MemWrite,
	s_RegWr => RegWrite,
	Branch => Branch,
	Jump => Jump,
	RegDst => RegDst);

EXTEND_IMM: extension port map(
	input => instruction(15 downto 0),
	i_S => '1',
	output => extended_imm);

SHIFT_I: barrel_shifter port map(
	input => extended_imm,
	i_shftamt => "00001",
	i_dir => '1',
	i_type => '0',
	output => shifted2);

ALU_CONT: ALUcontrol port map(
	s_type => instruction(5 downto 0),
        opcode => ALUOp,
        s_out => ALU_control);

MUX_RT_RD: mux2t1_N port map(
	i_S => RegDst,
	i_D0 => instruction(20 downto 16),
	i_D1 => instruction(15 downto 11),
	o_O => rt_rd);

MAIN_REG_FILE: register_file port map(
       rs => instruction(25 downto 21),
       rt => instruction(20 downto 16),      
       wrt => rt_rd,
       rd => addr_data,     
       clk => clk,
       reset => '0',
       enable => RegWrite,
       o_O1 => A,
       o_O2 => Bo); 

MUX_B_IMM: mux2t1_N port map(
	i_S => ALUSrc,
	i_D0 => Bo,
	i_D1 => extended_imm,
	o_O => Bi);

MAIN_ALU: ALU port map(
        A => A,
        B => Bi,
        s_F => ALU_control,
        output => ALU_result,
        zero => zero, 
        overflow => overflow);  

ANDI: andg2 port map(
	i_A => zero,
	i_B => Branch,
	o_F => s_branch);

MEMORY: mem port map(
	clk => clk,
	addr => ALU_result(11 downto 2),
	data => Bo,
	we => MemWrite,
	q => mem_data);

MUX_ADDR_DATA: mux2t1_N port map(
	i_S => MemtoReg,
	i_D0 => ALU_result,
	i_D1 => mem_data,
	o_O => addr_data);

ADD_BRANCH: fullAdder_N port map(
	i_A1 => PC_4,
	i_B1 => shifted2,
	i_C1 => '0',
	s_O => '0',
	o_S1 => branchAdded);

MUX_BRANCH: mux2t1_N port map(
	i_S => s_branch,
	i_D0 => PC_4,
	i_D1 => branchAdded,
	o_O => branched);

JUMPADDR: JumpAddress port map(
	inst => instruction(25 downto 0),
	PC => PC_4(31 downto 28),
	jumpAddress => jump_Addr);

MUX_BRANCH_JUMP: mux2t1_N port map(
	i_S => Jump,
	i_D0 => branched,
	i_D1 => jump_Addr,
	o_O => wb_address);








end structural;