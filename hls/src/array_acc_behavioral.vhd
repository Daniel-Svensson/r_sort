package ARRAY_ACC_PKG is
  type UI16 is range 0 to 2 ** 16 - 1;
  type ARRAY_UI16 is array ( UI16 range <> ) of UI16;
end;
use work.ARRAY_ACC_PKG.all;

entity ARRAY_ACC_BEHAVIORAL is
  generic ( ARRAY_LEN : UI16 := 10 );
  port    ( X   : in  ARRAY_UI16 ( 0 to ARRAY_LEN - 1 );
            Y   : in  ARRAY_UI16 ( 0 to ARRAY_LEN - 1 );
            CLK : in  bit;
            RST : in  bit;
            SUM : out UI16;
            DV  : out bit );
end ARRAY_ACC_BEHAVIORAL;

architecture BEHAVIORAL of ARRAY_ACC_BEHAVIORAL is
  signal Z_SIG : ARRAY_UI16 ( 0 to ARRAY_LEN - 1 );
begin
P_MAIN : 
  process
    variable SUM_VAR : UI16;
    variable IDX_VAR : UI16;
  begin
    LOOP_MAIN : loop
      wait until ( CLK'event and CLK = '0' ) or ( RST = '1' );
      exit LOOP_MAIN when RST = '1';
      SUM_VAR := 0;
      IDX_VAR := 0;
      while ( IDX_VAR <= ARRAY_LEN - 1 ) loop
        SUM_VAR := SUM_VAR + X( IDX_VAR );
        Z_SIG( IDX_VAR ) <= X( IDX_VAR ) + Y( IDX_VAR );
        IDX_VAR := IDX_VAR + 1;
      end loop;
      SUM <= SUM_VAR;
      DV <= '1';
    end loop LOOP_MAIN;
    SUM <= 0;
    DV <= '0';
  end process P_MAIN;
end BEHAVIORAL;
