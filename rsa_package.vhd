library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.MATH_REAL.all;
use IEEE.NUMERIC_STD.all;

package RSA_RESOURCES is
  
  CONSTANT N : INTEGER := 64;
  CONSTANT N_INDEX : INTEGER := 63;
  CONSTANT N_HALF : INTEGER := 32;
  CONSTANT N_HALF_INDEX : INTEGER := 31;

  function INVERSE_MOD (e, phi : STD_LOGIC_VECTOR (N_INDEX downto 0)) return STD_LOGIC_VECTOR;
  
  function GCD (x, y : UNSIGNED (N_INDEX downto 0)) return UNSIGNED;

  function GEN_E (phi : STD_LOGIC_VECTOR (N_INDEX downto 0)) return STD_LOGIC_VECTOR;

  function GEN_LARGE_PRIME (seed : POSITIVE) return STD_LOGIC_VECTOR;

  function MILLER_RABIN (prime : STD_LOGIC_VECTOR (N_HALF_INDEX downto 0)) return STD_LOGIC;

  function MONT_MOD_EXP (B, E, M : UNSIGNED (N_HALF_INDEX downto 0)) return UNSIGNED;

  function MONTGOMERY_MULT (x, y, m : UNSIGNED (N_HALF_INDEX downto 0)) return UNSIGNED;

end RSA_RESOURCES;

package body RSA_RESOURCES is
  -- GCD ----------------------------------------------------------------------
  function GCD (x, y : UNSIGNED (N_INDEX downto 0)) return UNSIGNED is
    VARIABLE x_temp : UNSIGNED (N_INDEX downto 0) := x;
    VARIABLE y_temp : UNSIGNED (N_INDEX downto 0) := y;
  begin

    while y_temp > 0 loop
      x_temp := y_temp;
      y_temp := x_temp MOD y_temp;
    end loop;

    return x_temp;
  
  end function;

  -- INVERSE_MOD ---------------------------------------------------------------
  function INVERSE_MOD (e, phi : STD_LOGIC_VECTOR (N_INDEX downto 0)) return STD_LOGIC_VECTOR is
    VARIABLE t : UNSIGNED (N_INDEX downto 0) := to_unsigned(0, N);
    VARIABLE r : UNSIGNED (N_INDEX downto 0) := UNSIGNED(phi);
    VARIABLE t_new : UNSIGNED (N_INDEX downto 0) := to_unsigned(1, N);
    VARIABLE r_new : UNSIGNED (N_INDEX downto 0) := UNSIGNED(e);
    VARIABLE q, t_temp, r_temp: UNSIGNED (N_INDEX downto 0);
  begin
    
    while r_new /= 0 loop
      q := r / r_new;
      t_temp := t;
      r_temp := r;
      t := t_new;
      r := r_new;

      t_new := resize(t_temp - (q * t_new), t_new'length);
      r_new := resize(r_temp - (q * r_new), r_new'length);
    end loop;
    if r > 1 then
      return "0";
    elsif t < 0 then
      t := t + r;
    end if;
    
    return STD_LOGIC_VECTOR(t);

  end function;

  -- GEN_E --------------------------------------------------------------------
  function GEN_E (phi : STD_LOGIC_VECTOR (N_INDEX downto 0)) return STD_LOGIC_VECTOR is
    VARIABLE e : UNSIGNED (N_INDEX downto 0);
    VARIABLE p : UNSIGNED (N_INDEX downto 0) := UNSIGNED(phi);
  begin

    if (p MOD 41) /= 0 then
      e := to_unsigned(41, N); 
    elsif p MOD 257 /= 0 then
      e := to_unsigned(257, N);
    else
      e := to_unsigned(65537, N);
      while GCD (e, p) /= 1 loop
        e := e + 2;
      end loop;
    end if; 

    return STD_LOGIC_VECTOR(e);

  end function;
  
  -- GEN_LARGE_PRIME -----------------------------------------------------------
  function GEN_LARGE_PRIME (seed : POSITIVE) return STD_LOGIC_VECTOR is
    VARIABLE s1 : POSITIVE := seed;
    VARIABLE s2 : POSITIVE;
    VARIABLE random : REAL;
    VARIABLE small_random : STD_LOGIC_VECTOR (31 downto 0);
    VARIABLE large_random : STD_LOGIC_VECTOR (N_HALF_INDEX downto 0);
    VARIABLE prime : STD_LOGIC := '0';
    VARIABLE gen_first : STD_LOGIC := '0';
  begin

    while prime /= '1' loop
      if gen_first = '0' then
        for I in 0 to (N_HALF)/32 -1 loop
          UNIFORM(s1, s2, random); 
          small_random := STD_LOGIC_VECTOR(to_unsigned(INTEGER(TRUNC(random * REAL(1000000000))), 32));
          large_random (I*32 + 31 downto I*32) := small_random;
        end loop;
        large_random(0) := '1';
        --large_random(N/2 -1) := '1';
        gen_first := '1';
      else
        large_random := STD_LOGIC_VECTOR(UNSIGNED(large_random) + to_unsigned(2, N_HALF));
      end if;
      prime := MILLER_RABIN (large_random);
    end loop;
    
    return large_random;
  
  end function;

  -- MILLER_RABIN ---------------------------------------------------------------
  function MILLER_RABIN (prime : STD_LOGIC_VECTOR (N_HALF_INDEX downto 0)) return STD_LOGIC is
    VARIABLE t : INTEGER := 1;
    VARIABLE s : INTEGER := 0;
    VARIABLE temp, r, a, x, j, p: UNSIGNED (N_HALF_INDEX downto 0);
    VARIABLE small_random : UNSIGNED (31 downto 0);
    VARIABLE large_random : UNSIGNED (N_HALF_INDEX downto 0);
    VARIABLE s1, s2 : POSITIVE;
    VARIABLE random : REAL;
  begin
    
    p := UNSIGNED(prime);
    report "checking primality of " & integer'image(to_integer(p));
    
    if p MOD 2 = 0 OR p MOD 3 = 0 then
      return '0';
    else
      -- calculate n - 1 = 2^s * r such that r is odd
      r := p - 1;
      while r MOD 2 = 0 loop
        r := r / 2;
        s := s + 1;
      end loop;
      
      for K in 1 to t loop
        -- choose random a, 2 <= a <= n-2
        for I in 0 to ((N_HALF)/32 - 1) loop
          UNIFORM(s1, s2, random); 
          small_random := to_unsigned(INTEGER(TRUNC(random * REAL(1000000000))), 32);
          large_random (I*32 + 31 downto I*32) := small_random;
        end loop;

        a := large_random;
        temp := r;
        x := MONT_MOD_EXP (a, temp, p);
        
        for i in 0 to s loop
          if (temp /= (p - 1) AND x /= 1 AND x /= (p - 1)) then
            x := MONT_MOD_EXP (x, to_unsigned(2, N_HALF), p); 
            temp := resize(temp * 2, temp'length);
          else
            exit;
          end if;
        end loop;
        
        if x /= (p - 1) AND temp MOD 2 = 0 then
          return '0';
        end if;

      end loop;
      return '1';
    end if;
  
  end function;

  -- MONT_MOD_EXP -------------------------------------------------------------
  function MONT_MOD_EXP (B, E, M : UNSIGNED (N_HALF_INDEX downto 0)) return UNSIGNED is
    VARIABLE K : UNSIGNED (N/2 -1 downto 0) := to_unsigned(0, N_HALF);
    VARIABLE E_TEMP : UNSIGNED (N_HALF_INDEX downto 0) := E;
    VARIABLE B_TEMP : UNSIGNED (N_HALF_INDEX downto 0) := B;
  begin

    for i in 0 to N_HALF_INDEX loop
      if E_TEMP > 0 then
        if E_TEMP MOD 2 = 1 then
          K := MONTGOMERY_MULT (K, B_TEMP, M);
        end if; 
        E_TEMP := E_TEMP / to_unsigned(2, N_HALF);
        B_TEMP := MONTGOMERY_MULT (B_TEMP, B_TEMP, M);
      else
        exit;
      end if; 
    end loop;

    return K;

  end function;

  -- INVERSE_MOD ---------------------------------------------------------------
  function MONTGOMERY_MULT (X, Y, M : UNSIGNED (N_HALF_INDEX downto 0)) return UNSIGNED is
    VARIABLE S, C : UNSIGNED (N_HALF_INDEX downto 0) := (others => '0'); 
    VARIABLE R, I: UNSIGNED (N_HALF_INDEX downto 0);
    VARIABLE P : UNSIGNED (N_HALF_INDEX downto 0);
  begin
    
    -- precompute value for R
    R := Y + M;
    
    for j in 0 to N_HALF_INDEX loop
      if S(0) = C(0) AND (X(j) = '0') then I := (others => '0'); end if;
      if S(0) /= C(0) AND (X(j) = '0') then I := M; end if;
      if (S(0) XOR C(0) XOR Y(0)) = '0' AND X(j) = '1' then I := Y; end if;
      if (S(0) XOR C(0) XOR Y(0)) = '1' AND X(j) = '1' then I := R; end if;
      S := S + C + I;
      C := S;
      S := S / 2;
      C := S / 2;
    end loop;
    
    P := S + C;
    if P >= M then P := P - M; end if;
    
    return P;

  end function;
end package body;
