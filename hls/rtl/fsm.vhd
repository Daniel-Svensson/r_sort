-- R-sort behavioral description
library ieee;
use ieee.std_logic_1164.all;

entity FSM is
  
  port (
    
    TMP_MAX : in std_logic; 
    CURRENT_S_BIT : in std_logic;
    LAST_BIT : in std_logic;            -- Is the significant bit the last
    IDX_0_DONE : in std_logic;          -- True when all IDX index the last number in B0
   
    TMP_IDX_INC : out std_logic;        -- True if TMP_IDX should increment
    TMP_ENABLE : out std_logic;         -- Chips select for TMP RAM
    TMP_LD : out std_logic;             -- '1' to load ram if enabled, '0' write

    IN_REG_OE : out std_logic;

    OUT_REG_LD : inout std_logic;

    DR : out std_logic;

    REG_INC : out std_logic;                        -- Increment selected reg
    REG_SELECT : out std_logic_vector(1 downto 0);  -- Which reg to select
    -- 00 = B0_IDX
    -- 01 = B1_IDX
    -- 10 = B_IDX
    -- 11 = S_BIT

    RESET_B_IDX : out std_logic;
    RESET_B0_IDX : out std_logic;
    RESET_B1_IDX : out std_logic;
    
    B0_ENABLE : out std_logic;          -- True if B_LD, B_OE should affect B0
    B1_ENABLE : out std_logic;          -- True if B_LD, B_OE should affect B1
    B_LD : out std_logic;               -- Load the enabled buckets
    

    CLK : in  std_logic;                -- clock signal
    RST : in  std_logic                 -- async reset signal
    );

end FSM;


architecture states of FSM is

  constant DONT_CARE : std_logic := 'Z';
  
  type STATE_TYPE is (IDLE,             -- The initial IDLE state
                      INPUT,            -- States when sorting data into buckets from input
                      R_0,              -- State corresponding to for loop
                                        -- header in r_sort. (per significant bit)
                      BUCKETIZE,        -- States when sorting data into
                                        -- buckets from temp
                      MERGE0_0, MERGE0_1,  -- States for merging, buckets
                      MERGE1_0, MERGE1_1,  -- buckets -> temp or output
                      DONE);           -- AS IDLE, but don't start reading

  --Entites that can access the bus
  type BUSS_DIRECTION  is (TO_B0,
                           TO_B1,
                           FROM_B0,
                           FROM_B1,
                           NONE);  -- Buss direction
  
  signal buss_dir : BUSS_DIRECTION;   -- Who should read data to the bus
  
  signal current_state : STATE_TYPE := IDLE;
  signal next_state: STATE_TYPE := IDLE;

  constant B0_IDX : std_logic_vector(1 downto 0) := "00";  -- B0 reg_select value
  constant B1_IDX : std_logic_vector(1 downto 0) := "01";  -- B1 reg_select value
  constant B_IDX : std_logic_vector(1 downto 0) := "10";   -- B reg_select value
  constant S_BIT : std_logic_vector(1 downto 0) := "11";   -- S_BIT reg_select value
  
begin  -- HIGH_LEVEL

  --Change state synchronously
  STATE_CHANGE: process(RST, CLK)
  begin
    if (rst = '1') then
      current_state <= IDLE;
    elsif (CLK='1' and CLK'event) then
      current_state <= next_state;
    end if;
  end process STATE_CHANGE;


  -----------------------------------------------------------------------------
  -- Decode the next state
  -----------------------------------------------------------------------------
  decode_logic: process(RST,
                        current_state,
                        CURRENT_S_BIT,
                        LAST_BIT,
                        IDX_0_DONE,
                        TMP_MAX)
  begin
    case current_state is
      -------------------------------------------------------------------------
      -- IDLE
      -------------------------------------------------------------------------
      when IDLE =>
        next_state <= INPUT;
        reg_select <= B0_IDX;
        buss_dir <= NONE;
        reg_inc <= '0';
        tmp_idx_inc <= '0';

        RESET_B_IDX <= '1';
        RESET_B0_IDX <= '1';
        RESET_B1_IDX <= '1';
        
        -----------------------------------------------------------------------
        -- INPUT, input step, load input data to correct bucket, until all data
        -- is processed
        -----------------------------------------------------------------------
      when INPUT =>



        if (CURRENT_S_BIT = '0') then
          buss_dir <= TO_B0;
          REG_SELECT <= B0_IDX; 
        else
          buss_load <= TO_B1;
          REG_SELECT <= B1_IDX;
        end if;


        RESET_B0_IDX <= '0';
        RESET_B1_IDX <= '0';
        
        --Increase TMP_INC and REG_INC, out counters
        REG_INC <= '1';
        TMP_IDX_INC <= '1';

        --All data read move to M_0, else continue reading
        if (TMP_MAX = '1') then
          NEXT_STATE <= MERGE0_0;
        else
          NEXT_STATE <= INPUT;    
        end if;

        -----------------------------------------------------------------------
        -- BUCKETIZE, input step, load input data to correct bucket, until all data
        -- is processed
        -----------------------------------------------------------------------
      when BUCKETIZE =>

         if (CURRENT_S_BIT = '0') then
          buss_dir <= TO_B0;
          REG_SELECT <= B0_IDX; 
        else
          buss_load <= TO_B1;
          REG_SELECT <= B1_IDX;
        end if;
        
        RESET_B0_IDX <= '0';
        RESET_B1_IDX <= '0';
        
        --Increase TMP_INC and B_X, out counters
        REG_INC <= '1';
        TMP_IDX_INC <= '1';

        --All data read move to MERGE 0, else continue reading
        if (TMP_MAX = '1') then
          NEXT_STATE <= MERGE0_0;
        else
          NEXT_STATE <= BUCKETIZE;    
        end if;
        
        -----------------------------------------------------------------------
        -- M_0, one of two steps in moving from bucket 0 to temp 
        -----------------------------------------------------------------------
      when MERGE0_0 =>
        -- Reset B_IDX to 0, since we start indexing from 0
        -- Use B_IDX as index, into B0 (needed to read IDX_0_DONE)
        REG_SELECT <= B_IDX;
        REG_INC <= '0';
        TMP_IDX_INC <= '0';

        -- No one should read data from the buss
        buss_dir <= NONE;

        -- Make Sure B_IDX is 0 when we start using it in M0_0
        RESET_B_IDX <= '1';        
        if IDX_0_DONE = '1' then
          next_state <= MERGE1_0;
        else
          --TODO optimize 
          next_state <= MERGE0_1;       --MERGE1_1 
        end if;

        
        -----------------------------------------------------------------------
        -- M0_1 Copy all numbers in bucket 0 to temp
        -----------------------------------------------------------------------
      when MERGE0_1 =>
        buss_dir <= FROM_B0;

        --Increase TMP_INC and REG_INC, out counters
        REG_INC <= '1';
        TMP_IDX_INC <= '1';

        -- Use ++B_IDX as index, into B0
        REG_SELECT <= B_IDX;
        
        RESET_B_IDX <= '0';
        
        --All data read move to M1_0, else continue reading
        if (IDX_0_DONE = '1') then

          -- Have we written the last, we should quit merging
          if TMP_MAX = '1' then
            NEXT_STATE <= R_0;
          else
            -- merge back all the ones                       
            NEXT_STATE <= MERGE1_0;              
          end if;

          -- Make Sure B_IDX is 0 when we start using it in M1_0
        else
          -- Stay here until all is copied
          NEXT_STATE <= MERGE0_1;    
        end if;

        -----------------------------------------------------------------------
        -- M1_0 , check if data should be copied from bucket 1
        -- We onlu come here if there is at  least one number left to copy
        -- but, we must reset B_IDX
        -----------------------------------------------------------------------
      when MERGE1_0 =>
        -- Reset B_IDX to 0, since we start indexing from 0       
        RESET_B_IDX <= '1';
        REG_INC <= '0';                 --Don't add now
        TMP_IDX_INC <= '0';
        -- Use B_IDX
        REG_SELECT <= (others => DONT_CARE); 

        -- No one should read data from the buss
        buss_dir <= NONE;

        --move rest of the numbers
        next_state <= MERGE1_1;           -- Start copying 
        -----------------------------------------------------------------------
        -- M1_1 Copy all numbers in bucket 0 to temp,        
        -----------------------------------------------------------------------
      when MERGE1_1 =>
        buss_dir <= B_1;

        --Increase TMP_INC and REG_INC, out counters
        REG_INC <= '1';
        TMP_IDX_INC <= '1';
        -- Use B_IDX as index into B1
        REG_SELECT <= B_IDX;

        RESET_B_IDX <= '0';
        
        --All data read move to M_0, else continue reading
        if (TMP_MAX = '1') then
          NEXT_STATE <= R_0;
          --If this was the last bit, start outputting numbers
        else
          NEXT_STATE <= MERGE1_1;    
        end if;

        -----------------------------------------------------------------------
        -- R_0 , r_sorts outer loop, check if we should continue and increate counter
        -----------------------------------------------------------------------
        when R_0 =>

        -- S_BIT++
        REG_SELECT <= S_BIT;
        REG_INC <= '1';
        
        if( LAST_BIT = '1') then
          NEXT_STATE <= DONE;
        else
          -- Begin next rund of bucketizing
          NEXT_STATE <= BUCKETIZE;
        end if;

        RESET_B0_IDX <= '1';
        RESET_B1_IDX <= '1';
        
        tmp_idx_inc <= '0';
        buss_dir <= NONE;
        
        -----------------------------------------------------------------------
        -- Done, do nothing returns to idle on reset
        -----------------------------------------------------------------------
        when DONE =>
        next_state <= DONE;
        reg_select <= (others => DONT_CARE);
        buss_dir <= NONE;
        reg_inc <= '0';
        tmp_idx_inc <= '0';

        RESET_B_IDX <= '1';
        RESET_B0_IDX <= '1';
        RESET_B1_IDX <= '1';
        -----------------------------------------------------------------------
        -- Others, should never happen
        -----------------------------------------------------------------------
      end case;
        
        
  end process decode_logic;   


  -----------------------------------------------------------------------------
  -- Code for accessing buss
  -----------------------------------------------------------------------------
  buss_logic: process(buss_load, buss_write)
  begin

    --The buss_write logic takes care of the X_LD signals

    -- TMP or an IO_register should read data from the buss
    if( buss_load = TMP_OR_IO ) then
      -- Set TMP in load mode
      TMP_LD <= '1';

      -- Read into OUT_REG if this is the last round
      if (LAST_BIT = '1') then 
        OUT_REG_LD <= '1';
        TMP_ENABLE <= '0';
      else
        OUT_REG_LD <= '0';
        TMP_ENABLE <= '1';
      end if;

      -- TMP or an IO_register should write data from the buss
    elsif (buss_write = TMP_OR_IO) then     
      TMP_LD <= '0';
      TMP_ENABLE <= '1';      
      OUT_REG_LD <= '0';
    else      
      TMP_ENABLE <= '0';
      TMP_LD <= DONT_CARE;
      OUT_REG_LD <= '0';
    end if;



        if (CURRENT_S_BIT = '0') then
          buss_load <= B_0;
          REG_SELECT <= B0_IDX; 
        elsif (CURRENT_S_BIT = '1') then
          buss_load <= B_1;
          REG_SELECT <= B1_IDX;
        end if;

    
    if buss_load = B_0 or buss_write = B_0 then
      B0_ENABLE <= '1';
    else
      B0_ENABLE <= '0';        
    end if;

    if buss_load = B_1 or buss_write = B_1 then
      B1_ENABLE <= '1';
    else
      B1_ENABLE <= '0';
    end if;

    if (buss_load = B_0 or buss_load = B_1) then
      B_LD <= '1';
    else
      B_LD <= '0';        
    end if;

    if buss_write = IN_REG then
      IN_REG_OE <= '1';
    else
      IN_REG_OE <= '0';        
    end if;

  end process buss_logic;


  -- D-flipflop for DR signal (active when out reg contains a valid new value)
  DR_OUTPUT: process(CLK,RST)
  begin
    if RST = '1' then
      DR <= '0';
    elsif CLK'event and CLK = '1' then
      DR <= OUT_REG_LD;
    end if;
  end process DR_OUTPUT;

end states;



