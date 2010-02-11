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
       OE     : in  std_logic;
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
       vector_select: in std_logic_vector);
  end component;


  -----------------------------------------------------------------------------
  -- Internal signals
  ----------------------------------------------------------------------------- 

  -----------------------------------------------------------------------------
  -- Signals for TMP_IDX register
  -----------------------------------------------------------------------------
  signal TMP_IDX_PLUS_1 : INDEX_TYPE := (others => 'X');  -- TMP_IDX + 1
  signal TMP_IDX : INDEX_TYPE;          -- TMP_IDX value
  signal TMP_MAX_IDX : std_logic := 'X';    -- 1 if TMP_IDX == max index
  signal TMP_IDX_LD : std_logic := 'X';  -- Increment TMP_IDX
  
  -----------------------------------------------------------------------------
  -- Signals for temp ram
  -----------------------------------------------------------------------------
  signal TMP_LD : std_logic := 'X';
  signal TMP_RST : std_logic := rst;   
  signal TMP_OE : std_logic := 'X';


  -----------------------------------------------------------------------------
  -- Signals for bucket 0 and 1
  -----------------------------------------------------------------------------
  signal B0_LD : std_logic := 'X';
  signal B0_OE : std_logic := 'X';
  signal B1_LD : std_logic := 'X';
  signal B1_OE : std_logic := 'X';
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
    
   ----------------------------------------------------------------------------
  -- Mostly FSM related signals
-------------------------------------------------------------------------------
  signal CURRENT_S_BIT : std_logic;     -- The value of the significant bit on the bus
  signal LAST_BIT : std_logic;          -- True if the significant bit is the last
  signal IDX_0_DONE : std_logic;        -- True when all IDX index the last number in B0
  signal TMP_MAX : std_logic;           -- True when the tmp_idx index the last item in tmp
  
  signal DATA  : NUM;  -- data buss

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------
  constant REG_DELAY : TIME  := 1 us;   -- default reg delay
  constant RAM_DELAY : TIME  := 5 us;   -- default reg delay
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
      OE => TMP_OE,
      address => TMP_IDX,
      data => DATA);

  -----------------------------------------------------------------------------
  -- Buckets
  -----------------------------------------------------------------------------
  B0_RAM: ram
    generic map (
      delay  => RAM_DELAY)
    port map (
      LD => B0_LD,
      RST => rst,
      CLK => clk,
      OE => B0_OE,
      address => B_IDX,
      data => DATA);

  B1_RAM: ram
    generic map (
      delay  => RAM_DELAY)
    port map (
      LD => B1_LD,
      RST => rst,
      CLK => clk,
      OE => B1_OE,
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
  TMP_MAX    <= '1' when (TMP_IDX = TMP_IDX'HIGH)
                else '0';
  LAST_BIT <= '1' when (S_BIT_VAL = S_BIT_VAL'HIGH)
                else '0';
  


end R_SORT_RTL;

