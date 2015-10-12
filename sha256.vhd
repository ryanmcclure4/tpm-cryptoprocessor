library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.sha_resources.all;

entity SHA256 is
  generic (m_length : INTEGER := 65);
  port (message  : in STRING;
        clk      : in STD_LOGIC;
        hash_out : out STD_LOGIC_VECTOR (255 downto 0));
end;


architecture BEHAVIORAL of SHA256 is

  -- initialize constant values K
  CONSTANT K : VECT_ARR_OF_WORDS (0 to 63) := (
    X"428a2f98", X"71374491", X"b5c0fbcf", X"e9b5dba5", 
    X"3956c25b", X"59f111f1", X"923f82a4", X"ab1c5ed5",
    X"d807aa98", X"12835b01", X"243185be", X"550c7dc3", 
    X"72be5d74", X"80deb1fe", X"9bdc06a7", X"c19bf174",
    X"e49b69c1", X"efbe4786", X"0fc19dc6", X"240ca1cc", 
    X"2de92c6f", X"4a7484aa", X"5cb0a9dc", X"76f988da",
    X"983e5152", X"a831c66d", X"b00327c8", X"bf597fc7", 
    X"c6e00bf3", X"d5a79147", X"06ca6351", X"14292967",
    X"27b70a85", X"2e1b2138", X"4d2c6dfc", X"53380d13", 
    X"650a7354", X"766a0abb", X"81c2c92e", X"92722c85",
    X"a2bfe8a1", X"a81a664b", X"c24b8b70", X"c76c51a3", 
    X"d192e819", X"d6990624", X"f40e3585", X"106aa070",
    X"19a4c116", X"1e376c08", X"2748774c", X"34b0bcb5", 
    X"391c0cb3", X"4ed8aa4a", X"5b9cca4f", X"682e6ff3",
    X"748f82ee", X"78a5636f", X"84c87814", X"8cc70208", 
    X"90befffa", X"a4506ceb", X"bef9a3f7", X"c67178f2");

  -- hash values
  SIGNAL Hash : VECT_ARR_OF_WORDS (0 to 7) := (
    X"6a09e667", X"bb67ae85", X"3c6ef372", X"a54ff53a",
    X"510e527f", X"9b05688c", X"1f83d9ab", X"5be0cd19");
  
  -- convert message from STRING to STD_LOGIC_VECTOR so we have binary representation
  SIGNAL message_binary : STD_LOGIC_VECTOR (m_length * 8 - 1 downto 0);-- := STRING_TO_SLV(message);
  
  SIGNAL padded_message : STD_LOGIC_VECTOR (CALC_PAD_MESS_LENGTH (m_length * 8) - 1 downto 0);

  -- array of 32-bit STD_LOGIC_VECTOR words representing each block of message
  SIGNAL M : VECT_ARR_M (CALC_PAD_MESS_LENGTH (m_length * 8) / 512 - 1 downto 0) := 
         ((others => (others => '0')));
  
  SIGNAL N : INTEGER := 0;
  SIGNAL W : VECT_ARR_OF_WORDS (63 downto 0);
  SIGNAL step : INTEGER := 0;
  SIGNAL w_count : INTEGER := 0;
  SIGNAL init_stage : INTEGER := 0;
  SIGNAL t_count: INTEGER := 0;
  SIGNAL init : STD_LOGIC := '0';

  -- working variables
  SIGNAL a, b, c, d, e, f, g, h : STD_LOGIC_VECTOR (31 downto 0);
  
begin
  message_binary <= STRING_TO_SLV (message);
  
  process (clk)
    VARIABLE T_1, T_2 : STD_LOGIC_VECTOR (31 downto 0);
  begin

    if clk'event then
    
    -- PREPROCESSING ------------------------------------------------------------
    
      if init = '0' then
        if init_stage = 0 then
          -- set initial hash values
          message_binary <= STRING_TO_SLV (message);
          init_stage <= 1;
        elsif init_stage = 1 then
          padded_message <= PAD_MESSAGE (message_binary);
          init_stage <= 2;
        elsif init_stage = 2 then
        -- populate M with blocks of the padded message
          M <= SPLIT_MESSAGE (padded_message);
          step <= 0;
          init <= '1';
        end if;
    
      -- HASHING ALGORITHM --------------------------------------------------------
      -- STEP 1 -------------------------------------------------------------------
      elsif (step = 0) AND init = '1' then
        
        -- prepare message schedule
        if w_count = 0 then
          
          -- initialize the eight working variables
          a <= Hash(0);
          b <= Hash(1);
          c <= Hash(2);
          d <= Hash(3);
          e <= Hash(4);
          f <= Hash(5);
          g <= Hash(6);
          h <= Hash(7);
          
          for T in 0 to 15 loop
            W(T) <= M(N)((32 * (T + 1)) - 1 downto 32 * T);
          end loop;
          w_count <= 16;
        elsif w_count >= 16 and w_count <= 63 then
          
          W(w_count) <= lower_sig_1(W(w_count-2)) + W(w_count-7) + lower_sig_0(W(w_count-15)) + W(w_count-16);
          w_count <= w_count + 1;
        elsif w_count > 63 then
          w_count <= 0;
          step <= 1;
        end if;
        -- initialize loop counter for next step
        t_count <= 0;

      -- STEP 2 -------------------------------------------------------------------
      elsif (step = 1) AND init = '1' then
        
          T_1 := h + upper_sig_1(e) + ch(e, f, g) + K(t_count) + W(t_count);
          T_2 := upper_sig_0(a) + maj(a, b, c);
          h <= g;
          g <= f;
          f <= e;
          e <= d + T_1;
          d <= c;
          c <= b;
          b <= a;
          a <= T_1 + T_2;
    
        -- can proceed to next step if all 64 rounds are completed
        if t_count = 63 then
          step <= 2;    
          t_count <= 0;
        else
          t_count <= t_count + 1;
        end if;

      -- STEP 3 -------------------------------------------------------------------
      elsif (step = 2) AND init = '1' then

        Hash(0) <= a + Hash(0);
        Hash(1) <= b + Hash(1);
        Hash(2) <= c + Hash(2);
        Hash(3) <= d + Hash(3);
        Hash(4) <= e + Hash(4);
        Hash(5) <= f + Hash(5);
        Hash(6) <= g + Hash(6);
        Hash(7) <= h + Hash(7);

        -- all blocks of the message have been processed
        if N + 1 = M'length then
          step <= 3;
        -- blocks still remain
        else
          N <= N + 1;
          step <= 0;
        end if;

      elsif step = 3 then
        hash_out (255 downto 224) <= Hash(0);
        hash_out (223 downto 192) <= Hash(1);
        hash_out (191 downto 160) <= Hash(2);
        hash_out (159 downto 128) <= Hash(3);
        hash_out (127 downto  96) <= Hash(4);
        hash_out (95  downto  64) <= Hash(5);
        hash_out (63  downto  32) <= Hash(6);
        hash_out (31  downto   0) <= Hash(7);
        step <= -1;
      end if;
    end if;

end process;
end BEHAVIORAL;
