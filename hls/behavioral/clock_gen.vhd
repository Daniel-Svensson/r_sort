entity CLOCK_GEN is

generic (
  CLOCK_INTERVAL : TIME;  -- Clock pulse interval
  CLOCK_CYCLES : INTEGER --Total number of clock cycles
  );
  
port (
  CLK_OUT : out bit       -- The clock pulse output
  );
    
end CLOCK_GEN;

architecture BEHAVIORAL of CLOCK_GEN is

begin  -- BEHAVIORAL
CLK_MAIN : process
  begin
    for i in 1 to CLOCK_CYCLES loop
      CLK_OUT <= '0';
      wait for CLOCK_INTERVAL;
      CLK_OUT <= '1';
      wait for CLOCK_INTERVAL;
      -- clock period = 10 ns
    end loop;
  end process CLK_MAIN;
end BEHAVIORAL;
