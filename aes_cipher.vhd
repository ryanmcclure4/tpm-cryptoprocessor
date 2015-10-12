library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.aes_resources.all;

entity AES_CIPHER is

  generic (length : INTEGER := 512);
  port (clk : in STD_LOGIC;
        key : in ROW_OF_BYTES (15 downto 0);
        ptext : in ROW_OF_BYTES (15 downto 0);
        ctext : out ROW_OF_BYTES (15 downto 0));

end;

architecture BEHAVIORAL of AES_CIPHER is

  CONSTANT Nk : INTEGER := 4;
  CONSTANT Nb : INTEGER := 4;
  CONSTANT Nr : INTEGER := 10; 

  SIGNAL init : STD_LOGIC := '0';
  SIGNAL step, round : INTEGER := 0;
  SIGNAL state : STATE_BLOCK;
  SIGNAL key_temp : ROW_OF_BYTES (15 downto 0);
  SIGNAL key_schedule : SCHEDULE_ARR;

begin

  process (clk)
    VARIABLE key_schedule_block : KEY_BLOCK;
    VARIABLE temp_state : STATE_BLOCK;
  begin
    if clk'event then
      -- initialization
      if init = '0' then
        -- generate key schedule
        key_schedule <= KEY_EXPANSION(key);
        -- read input block into state array
        for i in 0 to 3 loop
          for j in 0 to 3 loop
            state(j)(i) <= ptext (j + 4 * i);
          end loop;
        end loop;
        round <= 1;
        step <= 1;
        init <= '1';
      
      elsif step = 1 AND init = '1' then

        key_schedule_block(3) := key_schedule(Nb-1);
        key_schedule_block(2) := key_schedule(Nb-2);
        key_schedule_block(1) := key_schedule(Nb-3);
        key_schedule_block(0) := key_schedule(Nb-4);
        state <= ADD_ROUND_KEY(state, key_schedule_block);
        step <= 2;
      
      elsif step = 2 AND init = '1' then
        
        temp_state := SUB_BYTES (state);
        temp_state := SHIFT_ROWS (temp_state);
        temp_state := MIX_COLS (temp_state);
        key_schedule_block(3) := key_schedule((round+1) * Nb - 1);
        key_schedule_block(2) := key_schedule((round+1) * Nb - 2);
        key_schedule_block(1) := key_schedule((round+1) * Nb - 3);
        key_schedule_block(0) := key_schedule((round+1) * Nb - 4);
        state <= ADD_ROUND_KEY (temp_state, key_schedule_block);
        round <= round + 1;
        if round = Nr - 1 then
          step <= 3;
        end if;

      elsif step = 3 AND init = '1'then
        
        temp_state := SUB_BYTES (state);
        temp_state := SHIFT_ROWS (temp_state);
        key_schedule_block(3) := key_schedule((Nr+1) * Nb - 1);
        key_schedule_block(2) := key_schedule((Nr+1) * Nb - 2);
        key_schedule_block(1) := key_schedule((Nr+1) * Nb - 3);
        key_schedule_block(0) := key_schedule((Nr+1) * Nb - 4);
        state <= ADD_ROUND_KEY (temp_state, key_schedule_block);
        step <= 4;

      elsif step = 4 AND init = '1' then

        for i in 0 to 3 loop
          for j in 0 to 3 loop
            ctext(j + 4 * i) <= state(j)(i);
          end loop;
        end loop;
        step <= -1;

      end if;
    end if;
  end process;

end BEHAVIORAL;
