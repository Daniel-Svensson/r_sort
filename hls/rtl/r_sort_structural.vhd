-- R-sort behavioral description
library ieee;
use ieee.std_logic_1164.all;

package R_SORT_PKG is
    constant DATA_SIZE : integer := 4;   -- Data bits
    constant ARRAY_LEN : integer := 4;  -- Size of array    

  subtype NUM is std_logic_vector(DATA_SIZE -1 downto 0);
  type NUM_ARRAY is array (0 to ARRAY_LEN-1) of NUM;
    
end;

library ieee;
use ieee.std_logic_1164.all;
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
  -- Demux vector
  -----------------------------------------------------------------------------
  component demux_vector
     generic (
    data_size : INTEGER;
    delay : TIME);
  
     port (
       IN0,IN1,IN2,IN3: in std_logic_vector;
       output       : out std_logic_vector;
       vector_select: in std_logic_vector);
  end component;


  -----------------------------------------------------------------------------
  -- Internal signals
  -----------------------------------------------------------------------------
  subtype INDEX_TYPE is std_logic_vector(0 to DATA_SIZE-1);  -- Used to index into the data arrays
  signal TMP_IDX_PLUS_1 : INDEX_TYPE := (others => 'X');  -- TMP_IDX + 1
  signal TMP_IDX : INDEX_TYPE;          -- TMP_IDX value
  signal TMP_MAX_IDX : std_logic := 'X';    -- 1 if TMP_IDX == max index
  signal TMP_IDX_LD : std_logic := 'X';  -- Increment TMP_IDX
  
  signal DATA : NUM;                    -- the databuss



  constant REG_DELAY : TIME  := 1 us;   -- default reg delay
  constant RAM_DELAY : TIME  := 5 us;   -- default reg delay

  
  
begin  -- HIGH_LEVEL2

  -- TMP_IDX
  R_TMP_IDX: reg
    generic map (delay => REG_DELAY)
    port map (input => TMP_IDX_PLUS_1,
              output => TMP_IDX,
              LD => TMP_IDX_LD,
              clk => clk,
              rst => rst);

  


end R_SORT_RTL;

