package ARRAY_ACC_PKG is
  type UI16 is range 0 to 2 ** 16 - 1;
  type ARRAY_UI16 is array ( UI16 range <> ) of UI16;
end;
use work.ARRAY_ACC_PKG.all;

entity TB_ARRAY_ACC_STRUCTURAL IS
end TB_ARRAY_ACC_STRUCTURAL;

architecture TEST_BENCH_STRUCTURAL of TB_ARRAY_ACC_STRUCTURAL is

  -- Input data
  constant ARRAY_LEN_CON : UI16 := 10;
  constant A_CON : ARRAY_UI16 ( 0 to ARRAY_LEN_CON - 1 ) := ( 6, 5, 7, 91, 9, 35, 112, 17, 75, 23 );
  constant B_CON : ARRAY_UI16 ( 0 to ARRAY_LEN_CON - 1 ) := ( 9, 25, 49, 29, 10, 65, 65, 18, 123, 255 );

  -- define clock period
  constant PERIOD : time := 10 ns;

  signal X_SIG	   : ARRAY_UI16 ( 0 to ARRAY_LEN_CON - 1 );
  signal Y_SIG     : ARRAY_UI16 ( 0 to ARRAY_LEN_CON - 1 );
  signal CLK_SIG   : bit;
  signal RST_SIG   : bit;
  signal SUM_SIG   : UI16;
  signal DV_SIG    : bit;

  component ARRAY_ACC_STRUCTURAL
    generic ( ARRAY_LEN : UI16 := ARRAY_LEN_CON );
    port    ( X   : in  ARRAY_UI16 ( 0 to ARRAY_LEN - 1 );
              Y   : in  ARRAY_UI16 ( 0 to ARRAY_LEN - 1 );
              CLK : in  bit;
              RST : in  bit;
              SUM : out UI16;
              DV  : out bit
            );
  end component;

begin
  -- Component instantiation
  ARRAY_ACC_STRUCTURAL_1 : ARRAY_ACC_STRUCTURAL
    generic map ( ARRAY_LEN_CON ) 
    port map ( X_SIG, Y_SIG, CLK_SIG, RST_SIG, SUM_SIG, DV_SIG );

  P_CLOCK : process ( CLK_SIG )
  begin
    CLK_SIG <= ( not CLK_SIG ) after PERIOD;
  end process P_CLOCK;

  P_DATAINPUT : process ( RST_SIG )
  begin
     if ( RST_SIG = '0' ) then
       X_SIG <= A_CON;
       Y_SIG <= B_CON;
     end if;
  end process P_DATAINPUT; 
--
--  P_RESET : process ( DV_SIG )
--  begin
--    if ( DV_SIG = '1') then
--      RST_SIG <= '1' after 220 ns, '0' after 225 ns;
--    end if;
--  end process P_RESET;
end TEST_BENCH_STRUCTURAL;
