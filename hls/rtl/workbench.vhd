entity workbench is

end workbench;

use work.R_SORT_PKG.all;
library IEEE;
use ieee.std_logic_1164.all;
use IEEE.numeric_bit.all;

architecture sort_test of workbench is
  component R_SORT
     port (
    A   : in  NUM;   -- unsorted input array
    CLK : in  std_logic;                                    -- clock signal
    RST : in  std_logic;                                    -- async reset signal
    DR  : out std_logic;                                    -- data ready output bit
    S   : out NUM  -- sorted output array
		);
  end component;

  component CLOCK_GEN
    generic (
        CLOCK_INTERVAL : TIME;  -- Clock pulse interval
        CLOCK_CYCLES : INTEGER --Total number of clock cycles
        );

    port (
      CLK_OUT : out std_logic       -- The clock pulse output
      );
  end component;

  signal test_input : NUM;        -- test data
  signal output : NUM;            -- output
  signal data_ready : std_logic;              -- set when sorter is done

  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
begin  -- sort_test
--  test_input <= ("0010","0101","0111","1000"),
--                ("1001","0110","1000","0001") after 1 ms;

  rst <= '1',
         '0' after 50 ns;
  
  test_input <= "0000",
                "1001" after 50 ns,
                "0110" after 100 ns,
                "1000" after 150 ns,
                "0001" after 200 ns;
  
  
  sorter : R_SORT port map (
    A => test_input,
    CLK => clk,
    RST => rst,
    DR => data_ready,
    S => output);

  clock_generator : CLOCK_GEN
    generic map (50 ns, 10)
    port map (clk);
                


end sort_test;

