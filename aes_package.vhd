library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.MATH_REAL.all;
use IEEE.NUMERIC_STD.all;

package AES_RESOURCES is

  TYPE ROW_OF_BYTES   is ARRAY (INTEGER range <>) of STD_LOGIC_VECTOR (7 downto 0);
  TYPE TABLE_OF_BYTES is ARRAY (15 downto 0) of ROW_OF_BYTES (15 downto 0);
  TYPE STATE_BLOCK    is ARRAY (3 downto 0) of ROW_OF_BYTES (3 downto 0);
  TYPE KEY_BLOCK      is ARRAY (3 downto 0) of STD_LOGIC_VECTOR (31 downto 0);
  TYPE SCHEDULE_ARR   is ARRAY (43 downto 0) of STD_LOGIC_VECTOR (31 downto 0);

  CONSTANT Nk : INTEGER := 4;
  CONSTANT Nb : INTEGER := 4;
  CONSTANT Nr : INTEGER := 10;
  CONSTANT SIZE : INTEGER := 128;

  CONSTANT S : TABLE_OF_BYTES := (
    (X"63", X"7C", X"77", X"7B", X"F2", X"6B", X"6F", X"C5", 
     X"30", X"01", X"67", X"2B", X"FE", X"D7", X"AB", X"76"),
    (X"CA", X"82", X"C9", X"7D", X"FA", X"59", X"47", X"F0", 
     X"AD", X"D4", X"A2", X"AF", X"9C", X"A4", X"72", X"C0"),
    (X"B7", X"FD", X"93", X"26", X"36", X"3F", X"F7", X"CC", 
     X"34", X"A5", X"E5", X"F1", X"71", X"D8", X"31", X"15"),
    (X"04", X"C7", X"23", X"C3", X"18", X"96", X"05", X"9A", 
     X"07", X"12", X"80", X"E2", X"EB", X"27", X"B2", X"75"),
    (X"09", X"83", X"2C", X"1A", X"1B", X"6E", X"5A", X"A0", 
     X"52", X"3B", X"D6", X"B3", X"29", X"E3", X"2F", X"84"),
    (X"53", X"D1", X"00", X"ED", X"20", X"FC", X"B1", X"5B", 
     X"6A", X"CB", X"BE", X"39", X"4A", X"4C", X"58", X"CF"),
    (X"D0", X"EF", X"AA", X"FB", X"43", X"4D", X"33", X"85", 
     X"45", X"F9", X"02", X"7F", X"50", X"3C", X"9F", X"A8"),
    (X"51", X"A3", X"40", X"8F", X"92", X"9D", X"38", X"F5", 
     X"BC", X"B6", X"DA", X"21", X"10", X"FF", X"F3", X"D2"),
    (X"CD", X"0C", X"13", X"EC", X"5F", X"97", X"44", X"17", 
     X"C4", X"A7", X"7E", X"3D", X"64", X"5D", X"19", X"73"),
    (X"60", X"81", X"4F", X"DC", X"22", X"2A", X"90", X"88", 
     X"46", X"EE", X"B8", X"14", X"DE", X"5E", X"0B", X"DB"),
    (X"E0", X"32", X"3A", X"0A", X"49", X"06", X"24", X"5C", 
     X"C2", X"D3", X"AC", X"62", X"91", X"95", X"E4", X"79"),
    (X"E7", X"C8", X"37", X"6D", X"8D", X"D5", X"4E", X"A9", 
     X"6C", X"56", X"F4", X"EA", X"65", X"7A", X"AE", X"08"),
    (X"BA", X"78", X"25", X"2E", X"1C", X"A6", X"B4", X"C6", 
     X"E8", X"DD", X"74", X"1F", X"4B", X"BD", X"8B", X"8A"),
    (X"70", X"3E", X"B5", X"66", X"48", X"03", X"F6", X"0E", 
     X"61", X"35", X"57", X"B9", X"86", X"C1", X"1D", X"9E"),
    (X"E1", X"F8", X"98", X"11", X"69", X"D9", X"8E", X"94", 
     X"9B", X"1E", X"87", X"E9", X"CE", X"55", X"28", X"DF"),
    (X"8C", X"A1", X"89", X"0D", X"BF", X"E6", X"42", X"68", 
     X"41", X"99", X"2D", X"0F", X"B0", X"54", X"BB", X"16")
  );
 
  CONSTANT RCON : ROW_OF_BYTES (255 downto 0) := (
    X"8D", X"01", X"02", X"04", X"08", X"10", X"20", X"40", 
    X"80", X"1B", X"36", X"6C", X"D8", X"AB", X"4D", X"9A", 
    X"2F", X"5E", X"BC", X"63", X"C6", X"97", X"35", X"6A", 
    X"D4", X"B3", X"7D", X"FA", X"EF", X"C5", X"91", X"39", 
    X"72", X"E4", X"D3", X"BD", X"61", X"C2", X"9F", X"25", 
    X"4A", X"94", X"33", X"66", X"CC", X"83", X"1D", X"3A", 
    X"74", X"E8", X"CB", X"8D", X"01", X"02", X"04", X"08", 
    X"10", X"20", X"40", X"80", X"1B", X"36", X"6C", X"D8", 
    X"AB", X"4D", X"9A", X"2F", X"5E", X"BC", X"63", X"C6", 
    X"97", X"35", X"6A", X"D4", X"B3", X"7D", X"FA", X"EF", 
    X"C5", X"91", X"39", X"72", X"E4", X"D3", X"BD", X"61", 
    X"C2", X"9F", X"25", X"4A", X"94", X"33", X"66", X"CC", 
    X"83", X"1D", X"3A", X"74", X"E8", X"CB", X"8D", X"01", 
    X"02", X"04", X"08", X"10", X"20", X"40", X"80", X"1B", 
    X"36", X"6C", X"D8", X"AB", X"4D", X"9A", X"2F", X"5E", 
    X"BC", X"63", X"C6", X"97", X"35", X"6A", X"D4", X"B3", 
    X"7D", X"FA", X"EF", X"C5", X"91", X"39", X"72", X"E4", 
    X"D3", X"BD", X"61", X"C2", X"9F", X"25", X"4A", X"94", 
    X"33", X"66", X"CC", X"83", X"1D", X"3A", X"74", X"E8", 
    X"CB", X"8D", X"01", X"02", X"04", X"08", X"10", X"20", 
    X"40", X"80", X"1B", X"36", X"6C", X"D8", X"AB", X"4D", 
    X"9A", X"2F", X"5E", X"BC", X"63", X"C6", X"97", X"35", 
    X"6A", X"D4", X"B3", X"7D", X"FA", X"EF", X"C5", X"91", 
    X"39", X"72", X"E4", X"D3", X"BD", X"61", X"C2", X"9F", 
    X"25", X"4A", X"94", X"33", X"66", X"CC", X"83", X"1D", 
    X"3A", X"74", X"E8", X"CB", X"8D", X"01", X"02", X"04", 
    X"08", X"10", X"20", X"40", X"80", X"1B", X"36", X"6C", 
    X"D8", X"AB", X"4D", X"9A", X"2F", X"5E", X"BC", X"63", 
    X"C6", X"97", X"35", X"6A", X"D4", X"B3", X"7D", X"FA", 
    X"EF", X"C5", X"91", X"39", X"72", X"E4", X"D3", X"BD", 
    X"61", X"C2", X"9F", X"25", X"4A", X"94", X"33", X"66", 
    X"CC", X"83", X"1D", X"3A", X"74", X"E8", X"CB", X"8D"
  );

  CONSTANT A : STATE_BLOCK := (
    (X"02", X"03", X"01", X"01"),
    (X"01", X"02", X"03", X"01"),
    (X"01", X"01", X"02", X"03"),
    (X"03", X"01", X"01", X"02"));

  function GEN_KEY (seed : POSITIVE) return ROW_OF_BYTES;

  function ROTATE (word : STD_LOGIC_VECTOR (31 downto 0)) return STD_LOGIC_VECTOR;

  function SUB_BYTES (state : STATE_BLOCK) return STATE_BLOCK;

  function SUB_WORD (word : STD_LOGIC_VECTOR (31 downto 0)) return STD_LOGIC_VECTOR;

  function SHIFT_ROWS (state : STATE_BLOCK) return STATE_BLOCK;

  function MIX_COLS (state : STATE_BLOCK) return STATE_BLOCK;

  function ADD_ROUND_KEY (state : STATE_BLOCK; key : KEY_BLOCK) return STATE_BLOCK;

  function KEY_EXPANSION (key : ROW_OF_BYTES (15 downto 0)) return SCHEDULE_ARR;

end AES_RESOURCES;

package body AES_RESOURCES is
  -- GEN_KEY ------------------------------------------------------------------
  function GEN_KEY (seed : POSITIVE) return ROW_OF_BYTES is
    VARIABLE s1 : POSITIVE := seed;
    VARIABLE s2 : POSITIVE := seed * 2;
    VARIABLE random : REAL;
    VARIABLE small_random : STD_LOGIC_VECTOR (7 downto 0);
    VARIABLE key : ROW_OF_BYTES (15 downto 0);
  begin
    for I in 0 to 15 loop
      UNIFORM (s1, s2, random);
      small_random := STD_LOGIC_VECTOR(to_unsigned(INTEGER(TRUNC(random * REAL(100))), 8));
      key (I) := small_random;
    end loop;
    return key;
  end function;

  -- ROTATE --------------------------------------------------------------------
  function ROTATE (word : STD_LOGIC_VECTOR (31 downto 0)) return STD_LOGIC_VECTOR is
  begin
    return to_stdlogicvector(to_bitvector(word) ROL 8);
  end function;

  -- SUB_BYTES ------------------------------------------------------------------
  function SUB_BYTES (state : STATE_BLOCK) return STATE_BLOCK is
    VARIABLE ret_state : STATE_BLOCK;
    VARIABLE row, col : INTEGER;
  begin
    for i in 0 to 3 loop
      for j in 0 to 3 loop
        row := to_integer(UNSIGNED(state(i)(j)(7 downto 4)));
        col := to_integer(UNSIGNED(state(i)(j)(3 downto 0)));
        ret_state(i)(j) := S(row)(col);
      end loop;
    end loop;
    return ret_state;
  end function;

  -- SUB_WORD -------------------------------------------------------------------
  function SUB_WORD (word : STD_LOGIC_VECTOR (31 downto 0)) return STD_LOGIC_VECTOR is
    VARIABLE ret_word : STD_LOGIC_VECTOR (31 downto 0);
    VARIABLE row, col : INTEGER;
  begin
    for j in 0 to 3 loop
      row := to_integer(UNSIGNED(word(j * 8 + 7 downto j * 8 + 4)));
      col := to_integer(UNSIGNED(word(j * 8 + 7 - 4 downto j * 8)));
      ret_word(j * 8 + 7 downto j * 8) := S(row)(col);
    end loop;
    return ret_word;
  end function;

  -- SHIFT_ROWS ------------------------------------------------------------------
  function SHIFT_ROWS (state : STATE_BLOCK) return STATE_BLOCK is
    VARIABLE ret_state : STATE_BLOCK;
  begin
    -- first row is not shifted
    ret_state (0) := state (0);
    -- rotate row 1 by 1 byte
    ret_state (1)(0) := state (1)(1);
    ret_state (1)(1) := state (1)(2);
    ret_state (1)(2) := state (1)(3);
    ret_state (1)(3) := state (1)(0);
    -- rotate row 2 by 2 bytes
    ret_state (2)(0) := state (2)(2);
    ret_state (2)(1) := state (2)(3);
    ret_state (2)(2) := state (2)(0);
    ret_state (2)(3) := state (2)(1);
    -- rotate row 3 by 3 bytes
    ret_state (3)(0) := state (3)(3);
    ret_state (3)(1) := state (3)(0);
    ret_state (3)(2) := state (3)(1);
    ret_state (3)(3) := state (3)(2);
    return ret_state;
  end function;
  
  -- MIX_COLS -------------------------------------------------------------------
  function MIX_COLS (state : STATE_BLOCK) return STATE_BLOCK is
    VARIABLE ret_state : STATE_BLOCK;
    VARIABLE row : ROW_OF_BYTES (3 downto 0);
    VARIABLE temp : ROW_OF_BYTES (3 downto 0);
    VARIABLE temp_byte : STD_LOGIC_VECTOR (7 downto 0);
    VARIABLE msb : STD_LOGIC;
  begin
    for i in 0 to 3 loop
      for j in 0 to 3 loop
        row(j) := state(j)(i);
      end loop;
      for j in 0 to 3 loop
        for k in 0 to 3 loop
          temp(k) := row(k);
          if A(j)(k) = X"02" then
            msb := temp(k)(7);
            temp(k) := to_stdlogicvector(to_bitvector(temp(k)) SLL 1);
            if msb = '1' then
              temp(k) := temp(k) XOR X"1B";
            end if;
          elsif A(j)(k) = X"03" then
            temp_byte := temp(k);
            msb := temp(k)(7);
            temp(k) := to_stdlogicvector(to_bitvector(temp(k)) SLL 1);
            if msb = '1' then
              temp(k) := temp(k) XOR X"1B";
            end if;
            temp(k) := temp(k) XOR temp_byte;
          end if;
        end loop;
        ret_state(j)(i) := temp(0) XOR temp(1) XOR temp(2) XOR temp(3);
      end loop;
    end loop;

    return ret_state;
  end function;

  -- ADD_ROUND_KEY ----------------------------------------------------------------
  function ADD_ROUND_KEY (state : STATE_BLOCK; key : KEY_BLOCK) return STATE_BLOCK is
    VARIABLE col, new_col : STD_LOGIC_VECTOR (31 downto 0);
    VARIABLE ret_state : STATE_BLOCK;
  begin
    for i in 0 to 3 loop
      for j in 0 to 3 loop
        col (j*8 + 7 downto j*8) := state(j)(i);
      end loop;
      new_col := col XOR key(i);
      for j in 0 to 3 loop
        ret_state(j)(i) := col (j*8 + 7 downto j*8);
      end loop;
    end loop;
    return ret_state;
  end function;

  -- KEY_EXPANSION -----------------------------------------------------------------
  function KEY_EXPANSION (key : ROW_OF_BYTES (15 downto 0)) return SCHEDULE_ARR is
    VARIABLE key_schedule : SCHEDULE_ARR;
    VARIABLE temp_word : STD_LOGIC_VECTOR (31 downto 0);
    VARIABLE rcon_word : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
  begin
    for i in 0 to Nk - 1 loop
      temp_word(7 downto 0) := key(4*i);
      temp_word(15 downto 8) := key(4*i+1);
      temp_word(23 downto 16) := key(4*i+2);
      temp_word(31 downto 24) := key(4*i+3);
      key_schedule(i) := temp_word;
    end loop;
    
    for i in Nk to Nb * (Nr + 1) - 1 loop
      temp_word := key_schedule(i-1);
      if i mod Nk = 0 then
        rcon_word (7 downto 0) := RCON(i/Nk);
        temp_word := SUB_WORD(ROTATE(temp_word)) XOR rcon_word;
      elsif (Nk > 6) AND (i MOD Nk = 4) then
        temp_word := SUB_WORD(temp_word);
      end if;
      key_schedule(i) := key_schedule(i - Nk) XOR temp_word;
    end loop;

    return key_schedule;
  end function;
end package body;
