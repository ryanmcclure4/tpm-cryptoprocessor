library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.aes_resources.all;
use IEEE.MATH_REAL.all;

entity AES_CIPHER_TESTBENCH is
end AES_CIPHER_TESTBENCH;

architecture BEHAVIORAL of AES_CIPHER_TESTBENCH is

  COMPONENT AES_CIPHER
  port (clk : in STD_LOGIC;
        key : in ROW_OF_BYTES (15 downto 0); 
        ptext : in ROW_OF_BYTES (15 downto 0); 
        ctext : out ROW_OF_BYTES (15 downto 0));
  END COMPONENT;

  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL key : ROW_OF_BYTES (15 downto 0);
  SIGNAL ptext : ROW_OF_BYTES (15 downto 0) := (
         X"01",X"AE",X"02",X"EF",X"01",X"AE",X"02",X"EF",
         X"01",X"AE",X"02",X"EF",X"01",X"AE",X"02",X"EF");
  SIGNAL ctext : ROW_OF_BYTES (15 downto 0);

BEGIN

  key <= GEN_KEY (POSITIVE(15));

   C : AES_CIPHER PORT MAP (
      clk => clk,
      key => key,
      ptext => ptext,
      ctext => ctext);
  
  process(clk)
  begin
    clk <= not clk after 10 ns;
  end process;
    
END BEHAVIORAL;
