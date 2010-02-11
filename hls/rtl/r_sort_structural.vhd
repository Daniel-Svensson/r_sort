-- R-sort behavioral description
library ieee;
use ieee.std_logic_1164.all;

package R_SORT_PKG is
  constant DATA_SIZE : integer := 4;   -- Data bits

  constant ARRAY_LEN : integer := 4;  -- Size of array
  constant INDEX_BITS : integer := 2;
  
  subtype NUM is std_logic_vector(DATA_SIZE -1 downto 0);
  type NUM_ARRAY is array (0 to ARRAY_LEN-1) of NUM;
  
  -- Used to index into the data arrays
  subtype INDEX_TYPE is std_logic_vector(INDEX_BITS-1 downto 0);

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use Work.R_SORT_PKG.all;
 

entity R_SORT is
  
  port (
    A   : in NUM;   -- unsorted input array
    CLK : in  std_logic;  -- clock signal
    RST : in  std_logic;  -- async reset signal
    DR  : out std_logic;  -- data ready output bit
    S   : out NUM  -- sorted output array
	);

end R_SORT;


architecture R_SORT_RTL of R_SORT is

  
  -----------------------------------------------------------------------------
  -- The incrementer
  -----------------------------------------------------------------------------
  component  add_one

  generic (
    delay : TIME);

  port (
    input  : in  std_logic_vector;      -- input to be incremented
    output : out std_logic_vector);     -- the incremented value
  
  end component;
  -----------------------------------------------------------------------------
  -- Register
  -----------------------------------------------------------------------------
  component reg
  
    generic (
      delay : TIME);

    port (
      input  : in  std_logic_vector;      -- input to be incremented
      output : out std_logic_vector;
      LD     : in  std_logic;
      RST    : in  std_logic;
      CLK    : in  std_logic);     -- the incremented value

    
  end component;
  -----------------------------------------------------------------------------
  -- RAM
  -----------------------------------------------------------------------------
   component ram

     generic (
       delay : TIME);

     port (
       LD     : in  std_logic;      -- input to be incremented
       RST    : in  std_logic;
       CLK    : in  std_logic;
       CS     : in  std_logic;
       address: in  std_logic_vector;
       data   : inout std_logic_vector);
   end component;
    
  -----------------------------------------------------------------------------
  -- DEMUX BIT
  -----------------------------------------------------------------------------
  component demux_bit
    generic (
      delay : TIME);

    port (
      input     : in  std_logic_vector;
      output    : out std_logic;
      bit_select: in  std_logic_vector);
  end component;

  -----------------------------------------------------------------------------
  -- MUX BIT
  -----------------------------------------------------------------------------
  component mux_bit
    generic (
      delay : TIME);

    port (
      input     : in  std_logic;
      output    : out std_logic_vector;
      bit_select: in  std_logic_vector);
  end component;

  -----------------------------------------------------------------------------
  -- Demux vector
  -----------------------------------------------------------------------------
  component demux_vector
     generic (
       delay : TIME);
  
     port (
       IN0,IN1,IN2,IN3: in std_logic_vector;
       output       : out std_logic_vector;
       vector_select: in std_logic_vector(1 downto 0));
  end component;

  -----------------------------------------------------------------------------
  -- FSM
  -----------------------------------------------------------------------------
  component FSM
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
    B_LD : out std_logic;               -- Load the enabled buckets

    CLK : in  std_logic;                                    -- clock signal
    RST : in  std_logic                                    -- async reset signal
    );
  end component;
  -----------------------------------------------------------------------------
  -- Internal signals
  ----------------------------------------------------------------------------- 

  -----------------------------------------------------------------------------
  -- Signals for TMP_IDX register
  -----------------------------------------------------------------------------
  signal TMP_IDX_PLUS_1 : INDEX_TYPE := (others => 'X');  -- TMP_IDX + 1
  signal INDEX_MAX_VALUE : INDEX_TYPE := (others => '1');
  signal TMP_IDX : INDEX_TYPE;          -- TMP_IDX value
  signal TMP_MAX : std_logic;           -- True when the tmp_idx index the last item in tmp
  
  signal TMP_IDX_LD : std_logic := 'X';  -- Increment TMP_IDX
  
  -----------------------------------------------------------------------------
  -- Signals for temp ram
  -----------------------------------------------------------------------------
  signal TMP_CS : std_logic := 'X';
  signal TMP_RST : std_logic := rst;   
  signal TMP_LD : std_logic := 'X';


  -----------------------------------------------------------------------------
  -- Signals for bucket 0 and 1
  -----------------------------------------------------------------------------
  signal B0_CS : std_logic := 'X';
  signal B1_CS : std_logic := 'X';
  signal B_LD : std_logic := 'X';
  signal B_IDX : INDEX_TYPE; 

  -----------------------------------------------------------------------------
  -- Signals for IDX_0,IDX_1,IDX and s_bit  registers
  -----------------------------------------------------------------------------
  type BUCKET_IDX is (B0, B1, B , S_BIT);
  signal REG_SELECTED : std_logic_vector(1 downto 0);-- The register to be added
  signal REG_PLUS_1   : INDEX_TYPE;        -- One of the registers below +1
  signal REG_VAL      : INDEX_TYPE;        -- One of the registers below
  
  signal B0_IDX_VAL : INDEX_TYPE;           -- Value of the IDX_0 reg  
  signal B1_IDX_VAL : INDEX_TYPE;           -- Value of the IDX_1 reg
  signal B_IDX_VAL  : INDEX_TYPE;           -- Value of the IDX reg
  signal S_BIT_VAL  : INDEX_TYPE;           -- Value of the S_BIT reg

  signal REG_LD : std_logic; --Load the selected register;
  signal REG_LD_VECTOR : std_logic_vector(0 to 3);
  alias B0_IDX_LD   : std_logic is REG_LD_VECTOR(0);
  alias B1_IDX_LD   : std_logic is REG_LD_VECTOR(1);
  alias B_IDX_LD    : std_logic is REG_LD_VECTOR(2);
  alias S_BIT_LD    : std_logic is REG_LD_VECTOR(3);

  -----------------------------------------------------------------------------
  -- IN and OUT registers
  -----------------------------------------------------------------------------
  signal IN_REG_OE  : std_logic;
  signal OUT_REG_LD : std_logic;
  signal IN_REG_VAL : NUM;              -- temp fix

  ----------------------------------------------------------------------------
  -- Mostly FSM related signals
-------------------------------------------------------------------------------
  signal CURRENT_S_BIT : std_logic;     -- The value of the significant bit on the bus
  signal LAST_BIT : std_logic;          -- True if the significant bit is the last
  signal IDX_0_DONE : std_logic;        -- True when all IDX index the last number in B0

  
  signal DATA  : NUM;  -- data buss

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------
  constant REG_DELAY : TIME  := 1 ns;   -- default reg delay
  constant RAM_DELAY : TIME  := 5 ns;   -- default reg delay
  constant ADD_DELAY : TIME  := 1 ns;   -- default reg delay
  constant DEMUX_VECTOR_DELAY : TIME  := 1 ns;   -- default reg delay
  constant DEMUX_BIT_DELAY : TIME  := 1 ns;   -- default reg delay
  constant MUX_BIT_DELAY : TIME  := 1 ns;   -- default reg delay

  
  
begin  -- HIGH_LEVEL2

  -- TMP_IDX
  R_TMP_IDX: reg
    generic map (delay => REG_DELAY)
    port map (input => TMP_IDX_PLUS_1,
              output => TMP_IDX,
              LD => TMP_IDX_LD,
              clk => clk,
              rst => rst);

  
  TMP_ADDER: add_one
    generic map (
      delay => ADD_DELAY )
    port map (
      input  => TMP_IDX,
      output => TMP_IDX_PLUS_1);

  TMP_RAM: ram
    generic map (
      delay  => RAM_DELAY)
    port map (
      LD => TMP_LD,
      RST => TMP_RST,
      CLK => clk,
      CS => TMP_CS,
      address => TMP_IDX,
      data => DATA);

  -----------------------------------------------------------------------------
  -- Buckets
  -----------------------------------------------------------------------------
  B0_RAM: ram
    generic map (
      delay  => RAM_DELAY)
    port map (
      LD => B_LD,
      RST => rst,
      CLK => clk,
      CS => B0_CS,
      address => B_IDX,
      data => DATA);

  B1_RAM: ram
    generic map (
      delay  => RAM_DELAY)
    port map (
      LD => B_LD,
      RST => rst,
      CLK => clk,
      CS => B1_CS,
      address => B_IDX,
      data => DATA);

  -----------------------------------------------------------------------------
  --
  ---------------------------------------------------------------------------
  R_B0_IDX: reg
    generic map (delay => REG_DELAY)
    port map (input => REG_PLUS_1,
              output => B0_IDX_VAL,
              LD => B0_IDX_LD,
              clk => clk,
              rst => rst);

  R_B1_IDX: reg
    generic map (delay => REG_DELAY)
    port map (input => REG_PLUS_1,
              output => B1_IDX_VAL,
              LD => B1_IDX_LD,
              clk => clk,
              rst => rst);

  R_B_IDX: reg
    generic map (delay => REG_DELAY)
    port map (input => REG_PLUS_1,
              output => B_IDX_VAL,
              LD => B_IDX_LD,
              clk => clk,
              rst => rst);

  R_S_BIT: reg
    generic map (delay => REG_DELAY)
    port map (input => REG_PLUS_1,
              output => S_BIT_VAL,
              LD => S_BIT_LD,
              clk => clk,
              rst => rst);

  REG_SELECT: demux_vector
     generic map (
       delay => DEMUX_VECTOR_DELAY) 
     port map(
       IN0 => B0_IDX_VAL,
       IN1 => B1_IDX_VAL,
       IN2 => B_IDX_VAL,
       IN3 => S_BIT_VAL,
       output => REG_VAL,
       vector_select => REG_SELECTED);
  
  B_IDX <= REG_VAL;

   REG_ADDER: add_one
     generic map (
       delay => ADD_DELAY)
     port map (
       input  => REG_VAL,
       output => REG_PLUS_1);

  REG_LD_DEMUX: mux_bit
    generic map (
      delay =>  DEMUX_BIT_DELAY )
    port map (
      input => REG_LD,
      output => REG_LD_VECTOR,
      bit_select => REG_SELECTED);
    

  -----------------------------------------------------------------------------
  -- Decode current significant bit
  -----------------------------------------------------------------------------
  MUX_SIGNIFICANT_BIT: demux_bit
  generic map (
    delay => DEMUX_BIT_DELAY )
  port map (
    input => DATA,
    output => CURRENT_S_BIT,
    bit_select => S_BIT_VAL);


  -----------------------------------------------------------------------------
  -- Comparators
  -----------------------------------------------------------------------------
  IDX_0_DONE <= '1' when ( REG_PLUS_1 = B_IDX_VAL)
                else '0';
  TMP_MAX    <= '1' when (TMP_IDX = INDEX_MAX_VALUE)
                else '0';
  LAST_BIT <= '1' when (S_BIT_VAL = INDEX_MAX_VALUE)
                else '0';
  

  -----------------------------------------------------------------------------
  -- FSM
  -----------------------------------------------------------------------------

  STATE_MACHINE : FSM
   port map(    
    TMP_MAX => TMP_MAX, 
    CURRENT_S_BIT => CURRENT_S_BIT,
    LAST_BIT => LAST_BIT,    
    IDX_0_DONE => IDX_0_DONE,
   
    TMP_IDX_INC => TMP_IDX_LD,
    TMP_ENABLE => TMP_CS,
    TMP_LD => TMP_LD ,

    IN_REG_OE => IN_REG_OE, 
    OUT_REG_LD => OUT_REG_LD,
    DR  => DR,

    REG_INC => REG_LD,            -- Increment selected reg
    REG_SELECT => REG_SELECTED,  -- Which reg to select
    
    B0_ENABLE => B0_CS,
    B1_ENABLE => B1_CS, 
    B_LD => B_LD,

    CLK => clk,                                    -- clock signal
    RST => rst
    );


  ----------------------------------------------------------------------------
  -- OUT REGISTER
  -----------------------------------------------------------------------------
  R_OUT_REG: reg
    generic map (delay => REG_DELAY)
    port map (input => data,
              output => S,
              LD => OUT_REG_LD,
              clk => clk,
              rst => rst);

  -----------------------------------------------------------------------------
  -- IN REG
  -----------------------------------------------------------------------------
  process(clk)
  begin
    if( clk'EVENT and clk ='1') then
      IN_REG_VAL <= A;                    --Read in next data      
    end if;
  end process;
  

--  with IN_REG_OE select
--    data <=
--    IN_REG_VAL      when '1',
--    (others => 'Z') when others;
   data <= IN_REG_VAL;
    
end R_SORT_RTL;

