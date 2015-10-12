library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.MATH_REAL.all;
use IEEE.NUMERIC_STD.all;

package SHA_RESOURCES is

  TYPE VECT_ARR_OF_WORDS is ARRAY (INTEGER range <>) of STD_LOGIC_VECTOR (31 downto 0);
  TYPE VECT_ARR_M is ARRAY (INTEGER range <>) of STD_LOGIC_VECTOR (511 downto 0);
  
  function STRING_TO_SLV (str : STRING) return STD_LOGIC_VECTOR;

  function CALC_K (message_length : INTEGER) return INTEGER;

  function PAD_MESSAGE (message : STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR;

  function SPLIT_MESSAGE (message : STD_LOGIC_VECTOR) return VECT_ARR_M;

  function CALC_PAD_MESS_LENGTH (message_length : INTEGER) return INTEGER;

  function "+" (a : STD_LOGIC_VECTOR; b : STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR;

end SHA_RESOURCES;

package body SHA_RESOURCES is

  -- STRING_TO_SLV ------------------------------------------------------------
  function STRING_TO_SLV (str : STRING) return STD_LOGIC_VECTOR is
    VARIABLE slv : STD_LOGIC_VECTOR (8 * str'length - 1 downto 0);
    VARIABLE ascii : UNSIGNED (7 downto 0);
  begin

    for I in str'range loop
      ascii := to_unsigned(character'pos(str(I)), 8);
      slv((I-1) * 8 + 7 downto (I-1) * 8) := STD_LOGIC_VECTOR(ascii);
    end loop;

    return slv;

  end function STRING_TO_SLV;

  -- CALC_K -------------------------------------------------------------------
  function CALC_K (message_length : INTEGER) return INTEGER is
    VARIABLE k : INTEGER;
  begin

    k := (512 + 448 - (message_length MOD 512)) MOD 512;
    return k;

  end function CALC_K;

  -- CALC_PAD_MESS_LENGTH -----------------------------------------------------
  function CALC_PAD_MESS_LENGTH (message_length : INTEGER) return INTEGER is
    VARIABLE length : INTEGER := 0;
  begin

    length := message_length + CALC_K(message_length) + 64;-- + 1;
    return length;

  end function CALC_PAD_MESS_LENGTH;

  -- PAD_MESSAGE --------------------------------------------------------------
  function PAD_MESSAGE (message : STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
    VARIABLE padded_message : STD_LOGIC_VECTOR (
             message'length + CALC_K(message'length) + 64 - 1 downto 0) := (others => '0');  
    VARIABLE message_length_binary : STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
    VARIABLE padded_length, total : INTEGER := 0;
  begin
  
    message_length_binary := STD_LOGIC_VECTOR(to_unsigned(message'length, 64));
    padded_length := padded_message'length;
    padded_message (padded_length - 1 downto padded_length - message'length) := message;
    padded_message (padded_length - message'length - 1) := '1';
    padded_message (63 downto 0) := message_length_binary;
    
    return padded_message;

  end function PAD_MESSAGE;

  -- SPLIT_MESSAGE ------------------------------------------------------------
  function SPLIT_MESSAGE (message : STD_LOGIC_VECTOR) return VECT_ARR_M is
    VARIABLE pos : INTEGER := message'length;
    VARIABLE index : INTEGER := message'length / 512 - 1;
    VARIABLE ret : VECT_ARR_M(message'length / 512 - 1 downto 0);
  begin
  
    while pos > 0 loop
      ret(index) := message(pos - 1 downto pos - 512);
      report "ret(index) " & integer'image(index);
      pos := pos - 512;
      index := index - 1;
    end loop;

    return ret;

  end function SPLIT_MESSAGE;

  -- LOWER_SIG_0 ---------------------------------------------------------------
  function LOWER_SIG_0 (x : STD_LOGIC_VECTOR (31 downto 0)) return STD_LOGIC_VECTOR is
  begin

    return to_stdlogicvector((to_bitvector(x) ROR 7)  
           XOR (to_bitvector(x) ROR 18) 
           XOR (to_bitvector(x) SRL 3));

  end function;

  -- LOWER_SIG_1 ---------------------------------------------------------------
  function LOWER_SIG_1 (x : STD_LOGIC_VECTOR (31 downto 0)) return STD_LOGIC_VECTOR is
  begin

    return to_stdlogicvector((to_bitvector(x) ROR 17)  
           XOR (to_bitvector(x) ROR 19) 
           XOR (to_bitvector(x) SRL 10));

  end function;

  -- UPPER_SIG_0 ---------------------------------------------------------------
  function UPPER_SIG_0 (x : STD_LOGIC_VECTOR (31 downto 0)) return STD_LOGIC_VECTOR is
  begin

    return to_stdlogicvector((to_bitvector(x) ROR 2)  
           XOR (to_bitvector(x) ROR 13) 
           XOR (to_bitvector(x) ROR 22));

  end function;

  -- UPPER_SIG_1 ---------------------------------------------------------------
  function UPPER_SIG_1 (x : STD_LOGIC_VECTOR (31 downto 0)) return STD_LOGIC_VECTOR is
  begin

    return to_stdlogicvector((to_bitvector(x) ROR 6)  
           XOR (to_bitvector(x) ROR 11) 
           XOR (to_bitvector(x) ROR 25));

  end function;

  -- CH -------------------------------------------------------------------------
  function CH (x, y, z : STD_LOGIC_VECTOR (31 downto 0)) return STD_LOGIC_VECTOR is
  begin

    return to_stdlogicvector((to_bitvector(x) AND to_bitvector(y)) 
           XOR (NOT(to_bitvector(x)) AND to_bitvector(z)));

  end function;

  -- MAJ ------------------------------------------------------------------------
  function MAJ (x, y, z : STD_LOGIC_VECTOR (31 downto 0)) return STD_LOGIC_VECTOR is
  begin

    return to_stdlogicvector((to_bitvector(x) AND to_bitvector(y)) 
             XOR (to_bitvector(x) AND to_bitvector(z)) 
             XOR (to_bitvector(y) AND to_bitvector(z)));
  
  end function;

  -- + OVERLOAD -----------------------------------------------------------------
  function "+" (a : STD_LOGIC_VECTOR; b : STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
  begin

    return STD_LOGIC_VECTOR((unsigned(a) + unsigned(b)));
  
  end function;

end package body;
