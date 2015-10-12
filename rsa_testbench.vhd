library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.resources.all;
use IEEE.MATH_REAL.all;

entity RSA_TESTBENCH is
end RSA_TESTBENCH;

architecture BEHAVIORAL of RSA_TESTBENCH is
  COMPONENT RSA
  port (clk : in STD_LOGIC;
        p_out, q_out, n_out, e_out, d_out : out STD_LOGIC_VECTOR);

  END COMPONENT;

  SIGNAL p, q : STD_LOGIC_VECTOR (1023 downto 0) := (others => '0');
  SIGNAL n, e, d : STD_LOGIC_VECTOR (2047 downto 0) := (others => '0');
  SIGNAL clk : STD_LOGIC := '0';

BEGIN

   R : RSA PORT MAP (
      clk => clk,
      p_out => p,
      q_out => q,
      n_out => n,
      e_out => e,
      d_out => d);

  testbench : process(clk)
  begin
    clk <= not clk after 10 ns;
  end process;
    
END BEHAVIORAL;
