library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.sha_resources.all;


entity SHA256_TESTBENCH is
end SHA256_TESTBENCH;

architecture BEHAVIORAL of SHA256_TESTBENCH is
  COMPONENT SHA256
    port (message  : in STRING;
          clk      : in STD_LOGIC;
          hash_out : out STD_LOGIC_VECTOR (255 downto 0));

  END COMPONENT;
  SIGNAL message : STRING (65 downto 1) := 
         "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzasdfasdfasdfa";
  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL test, h,d, e, f, g, W : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
  SIGNAL hash_out : STD_LOGIC_VECTOR (255 downto 0) := (others => '0');

BEGIN

   S : SHA256 PORT MAP (
      message => message,
      clk => clk,
      hash_out => hash_out);

  testbench : PROCESS (clk, test)
  BEGIN
    clk <= not clk after 10 ns;
  END PROCESS;

END BEHAVIORAL;
