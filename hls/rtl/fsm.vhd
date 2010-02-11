-- R-sort behavioral description
library ieee;
use ieee.std_logic_1164.all;

entity FSM is
  
  port (
    
    TMP_MAX : in std_logic; 
    CURRENT_S_BIT : in std_logic;
    LAST_BIT : in std_logic;            -- Is the significant bit the last
    IDX_0_DONE : in std_logic; -- True when all IDX index the last number in B0
   
    TMP_IDX_INC : out std_logic;         -- True if TMP_IDX should increment
    TMP_ENABLE : out std_logic;         -- Chips select for TMP RAM
    TMP_LD : out std_logic;             -- '1' to load ram if enabled, '0' write

    IN_REG_OE : out std_logic;

    OUT_REG_LD : out std_logic;

    DR : out std_logic;

    REG_INC : out std_logic;            -- Increment selected reg
    REG_SELECT : out std_logic_vector(1 downto 0);  -- Which reg to select
    -- 00 = B0_IDX
    -- 01 = B1_IDX
    -- 10 = B_IDX
    -- 11 = S_BIT

    
    B0_ENABLE : out std_logic;          -- True if B_LD, B_OE should affect B0
    B1_ENABLE : out std_logic;          -- True if B_LD, B_OE should affect B1
    B_LD : out std_logic;               -- Load the enabled buckets ,
    

    CLK : in  std_logic;                                    -- clock signal
    RST : in  std_logic                                    -- async reset signal
    );

end FSM;


architecture states of FSM is

  type STATE_TYPE is (IDLE,
                      I_0, I_1, I_2,    -- States when reading input
                      B_0,              -- States when sorting temp to buckets
                      M_0,              -- States for merging, buckets -> temp
                      O_0, O_1 );       -- States for outputing result

  --Entites that can access the buss
  type BUSS_ENTITY_TYPE is (TMP,B_0,B_1,IN_REG,OUT_REG,NONE);
  

  signal buss_load : BUSS_ENTITY_TYPE := NONE;  --Who should read data to the buss
  signal buss_write : BUSS_ENTITY_TYPE;  -- Who should write to buss
  
  signal current_state : STATE_TYPE := IDLE;
  signal next_state: STATE_TYPE;

  constant BO_IDX : std_logic_vector(1 downto 0) := "00";  -- B0 reg_select value
  constant B1_IDX : std_logic_vector(1 downto 0) := "01";  -- B1 reg_select value
  constant B_IDX : std_logic_vector(1 downto 0) := "10";  -- B reg_select value
  constant S_BIT : std_logic_vector(1 downto 0) := "11";  -- S_BIT reg_select value
  
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
        next_state <= I_0;
   
        -----------------------------------------------------------------------
        -- I_0, input step, load input data to correct bucket, until all data
        -- is processed
        -----------------------------------------------------------------------
      when I_0 =>
        buss_write <= IN_REG;
        
        -- Select bucet to put data in
        if (CURRENT_S_BIT = '0') then
          buss_load <= B_0;
          REG_SELECT <= BO_IDX; 
        elsif (CURRENT_S_BIT = '1') then
          buss_load <= B_1;
          REG_SELECT <= B1_IDX;
        end if;

        --Increase TMP_INC and REG_INC, out counters
        REG_INC <= '1';
        TMP_IDX_INC <= '1';

        --All data read move to M_0, else continue reading
        if (TMP_MAX = '1') then
          NEXT_STATE <= M_0;
        else
          NEXT_STATE <= I_0;    
        end if;
      when others =>
        DR <= '1';
        next_state <= IDLE;        
      end case;
        
  end process decode_logic;   


  -----------------------------------------------------------------------------
  -- Code for accessing buss
  -----------------------------------------------------------------------------
  buss_logic: process(buss_load, buss_write)
  begin

    --The buss_write logic takes care of the X_LD signals
    if( buss_load = TMP ) then
      TMP_ENABLE <= '1';
      TMP_LD <= '1';
    elsif (buss_write = TMP) then
      TMP_ENABLE <= '1';
      TMP_LD <= '0';
    else
      TMP_ENABLE <= '0';
      TMP_LD <= 'X';
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
      B_LD <= '1';        
    end if;

    if buss_write = IN_REG then
      IN_REG_OE <= '1';
    else
      IN_REG_OE <= '0';        
    end if;

    if buss_load = OUT_REG then
      OUT_REG_LD <= '1';
    else
      OUT_REG_LD <= '0';
    end if;
      

  end process buss_logic;


end states;

