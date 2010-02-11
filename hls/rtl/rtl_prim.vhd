library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------
-- Incrementer
-------------------------------------------------------------------------------
entity add_one is

  generic (
    delay : TIME);

  port (
    input  : in  std_logic_vector;      -- input to be incremented
    output : out std_logic_vector);     -- the incremented value
end add_one;

architecture add_one_arch of add_one is

begin  -- add_one_arch
  process (input)
  begin
    output <= input + 1 after delay;
  end process;
end add_one_arch;


-------------------------------------------------------------------------------
-- Register
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reg is

  generic (
    delay : TIME);

  port (
    input  : in  std_logic_vector;      -- input to be incremented
    output : out std_logic_vector;
    LD     : in  std_logic;
    RST    : in  std_logic;
    CLK    : in  std_logic);     -- the incremented value
  
end reg;

architecture reg_arch of reg is
begin  -- reg_arch
  process (CLK)
    variable storage : std_logic_vector(input'range);  -- the input data is stored here
  begin
    if (CLK='1' and CLK'event) then
      if(RST = '1') then
        storage := (others => '0');
      end if;
        
    end if;
  end process;
end reg_arch;

-------------------------------------------------------------------------------
-- RAM
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ram is

  generic (
    delay : TIME);

  port (
    LD     : in  std_logic;      -- '1' = Load, '0' => write
    RST    : in  std_logic;
    CLK    : in  std_logic;
    CS     : in  std_logic;     
    address: in  std_logic_vector;
    data   : inout std_logic_vector);
--  data   : inout array(0 to address'HIGH - 1) of std_logic_vector;     -- the incremented value
end ram;

architecture ram_arch of ram is
  type intern_storage is array (0 to address'high - 1) of std_logic_vector(0 to data'high - 1);
  signal storage : intern_storage;
  
begin  -- reg_arch  
  process (CLK) 
  begin
    if (CLK='1' and CLK'event) then

      if(RST = '1') then
        storage <= (others => (others => '0'));
      end if;

      if (LD = '1') then
       -- storage(address)() <= data;
      end if;

      if(OE = '1') then
        -- data <= storage;
      end if;
        
    end if;
  end process;
end ram_arch;

-------------------------------------------------------------------------------
-- DEMUX BIT
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity demux_bit is

  generic (
    delay : TIME);

  port (
    input     : in  std_logic_vector;
    output    : out std_logic;
    bit_select: in  std_logic_vector);
end demux_bit;

-------------------------------------------------------------------------------
-- DEMUX VECTOR
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity demux_vector is
  
  generic (
    delay : TIME);
  
  port (
--    input        : in array(integer range <>) of std_logic_vector;
    IN0,IN1,IN2,IN3: in std_logic_vector;
    output       : out std_logic_vector;
    vector_select: in std_logic_vector);
end demux_vector;

-------------------------------------------------------------------------------
-- MUX BIT
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mux_bit is 
  generic (
    delay : TIME);  
  port (
    input     : in  std_logic;
    output    : out std_logic_vector;
    bit_select: in  std_logic_vector);
end mux_bit;
  
architecture mux_arch of mux_bit is

begin  -- add_one_arch

  process(input,bit_select)
  begin
    for i in output'range loop
      if (i = bit_select) then
        output(i) <= '1';
      else
        output(i) <= '0';
      end if;
    end loop;  -- i
  end process;
  
end mux_arch;
