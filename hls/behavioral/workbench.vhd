entity workbench is

end workbench;

use work.R_SORT_PKG.all;
library IEEE;
use IEEE.numeric_bit.all;

architecture sort_test of workbench is
  component R_SORT
     port (
    A   : in  NUM_ARRAY;   -- unsorted input array
    CLK : in  BIT;                                    -- clock signal
    RST : in  BIT;                                    -- async reset signal
    DR  : out BIT;                                    -- data ready output bit
    S   : out NUM_ARRAY  -- sorted output array
		);
  end component;

  signal test_input : NUM_ARRAY;        -- test data
  signal output : NUM_ARRAY;            -- output
  signal data_ready : bit;              -- set when sorter is done

  signal clk : bit := '0';
  signal rst : bit := '0';
begin  -- sort_test
--  test_input <= ("0010","0101","0111","1000"),
--                ("1001","0110","1000","0001") after 1 ms;

    test_input <= ("1001","0110","1000","0001");

  
  sorter : R_SORT port map (
    test_input,
    clk,
    rst,
    data_ready,
    output);
                

  

end sort_test;

