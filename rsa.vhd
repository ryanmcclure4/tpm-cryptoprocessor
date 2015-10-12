library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.rsa_resources.all;

entity RSA is
  -- N represents the size of the desired key n in bits
  -- default is 2048, which is within standards for TPM specifications
  generic (BIT_SIZE : INTEGER := 2048);
  -- p, q : the primes
  -- n    : the public key
  -- e    : exponent
  -- d    : the private key
  port (clk : in STD_LOGIC;
        p_out, q_out, n_out, e_out, d_out : out STD_LOGIC_VECTOR);
end;

architecture BEHAVIORAL of RSA is
  
  SIGNAL p : STD_LOGIC_VECTOR (31 downto 0);
  SIGNAL q : STD_LOGIC_VECTOR (31 downto 0);
  SIGNAL n : STD_LOGIC_VECTOR (63 downto 0);
  SIGNAL phi : STD_LOGIC_VECTOR (63 downto 0);
  SIGNAL e : STD_LOGIC_VECTOR (63 downto 0);
  SIGNAL d : STD_LOGIC_VECTOR (63 downto 0);
  SIGNAL seed : POSITIVE := 15;
  SIGNAL step : INTEGER := 0;

begin

-- Calculate primes p and q of size N / 2 -------------------------------------
  p <= GEN_LARGE_PRIME(seed);
  q <= GEN_LARGE_PRIME(seed);

  process (clk)
  begin
    
    if clk'event then
      -- STEP 0 ---------------------------------------------------------------
      if step = 0 then

        -- calculate the public key, n
        n <= STD_LOGIC_VECTOR(UNSIGNED(p) * UNSIGNED(q));
        -- calculate phi
        phi <= STD_LOGIC_VECTOR((UNSIGNED(p) - 1) * (UNSIGNED(q) - 1));
        step <= 1;
      
      -- STEP 1 ---------------------------------------------------------------
      elsif step = 1 then

        -- calculate e
        e <= GEN_E(phi);
        step <= 2;

      -- STEP 2 ---------------------------------------------------------------
      elsif step = 2 then
        
        -- compute secret exponent d
        d <= INVERSE_MOD (e, phi);
        step <= 3;

      -- STEP 3 ---------------------------------------------------------------
      elsif step = 3 then

        -- set output
        p_out <= p;
        q_out <= q;
        n_out <= n;
        e_out <= e;
        d_out <= d;

      end if;
    end if;
  end process;


end BEHAVIORAL;
