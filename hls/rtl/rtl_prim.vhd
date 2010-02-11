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
  -- the input data is stored here
  signal storage : std_logic_vector(input'range) := (others => '0');
  
begin  -- reg_arch
  process (CLK,RST)
  begin
    if(RST = '1') then
      storage <= (others => '0');
    elsif (CLK='1' and CLK'event and LD = '1') then
      storage <= input;
    end if;
  end process;

  output <= storage;
end reg_arch;

-------------------------------------------------------------------------------
-- RAM
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

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
--  type intern_storage is array (0 to address'high - 1) of std_logic_vector(0 to data'high - 1);
  type intern_storage is array (0 to 3) of std_logic_vector(3 downto 0);
  signal storage : intern_storage := (others => (others => '0'));  
begin  -- reg_arch  
  process (CLK) 
  begin
    if(RST = '1') then
      storage <= (others => (others => '0'));
      data(data'range) <= (others => 'Z');
    elsif (CS = '0') then 
      for i in data'range loop
        data(i) <= 'Z' after delay;
      end loop;  -- i then          
    elsif (CLK='1' and CLK'event) then  --CS = 1
      if (LD = '1') then
        storage(to_integer(unsigned(address))) <= data;
      else
        --write
        data <= storage(to_integer(unsigned(address))) after delay;          
      end if;
    end if;                           --CLK
  end process;
end ram_arch;

-------------------------------------------------------------------------------
-- DEMUX BIT
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity demux_bit is

  generic (
    delay : TIME);

  port (
    input     : in  std_logic_vector;
    output    : out std_logic;
    bit_select: in  std_logic_vector);
end demux_bit;

  
architecture demux_arch of demux_bit is

begin  -- add_one_arch

  process(input,bit_select)
    variable res : std_logic := 'X';
  begin
    for i in input'range loop
      if (i = bit_select) then
        res := input(i);
      end if;
    end loop;  -- i
    output <= res after delay;
  end process;
    
  
end demux_arch;



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
    vector_select: in std_logic_vector(1 downto 0));
end demux_vector;

architecture demux_vector_arch of demux_vector is

begin  -- add_one_arch

  with vector_select select
    output <= IN0 after delay when "00",
              IN1 after delay when "01",
              IN2 after delay when "10",
              IN3 after delay when "11",
              "XX" after delay when others;

     
end demux_vector_arch;
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
        output(i) <= input after delay;
      else
        output(i) <= '0' after delay;
      end if;
    end loop;  -- i
  end process;
  
end mux_arch;
