package ARRAY_ACC_PKG is
  type UI16 is range 0 to 2 ** 16 - 1;
  type ARRAY_UI16 is array ( UI16 range <> ) of UI16;
end;


-- components

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.ARRAY_ACC_PKG.all;

ENTITY MUX2_UI16 IS
  PORT ( D0   : IN  UI16;
         D1   : IN  UI16;
         SEL  : IN  UI16;
         DOUT : OUT UI16 
       );
END;

ARCHITECTURE basic OF MUX2_UI16 IS
BEGIN
C1:
  PROCESS ( D0, D1, SEL )
  BEGIN
      if ( SEL = 0 ) then
        DOUT <= D0;
      else
        DOUT <= D1;
      end if;
  END PROCESS;
END;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.ARRAY_ACC_PKG.all;

ENTITY mux_ui16 IS
  GENERIC ( input_elem_num : ui16 := 10);
  PORT ( input : IN  array_ui16 ( 0 to input_elem_num - 1 );
         sel   : IN  ui16;
         dout  : OUT ui16 
       );
END;

ARCHITECTURE basic OF mux_ui16 IS
BEGIN
  PROCESS ( input, sel )
  BEGIN
    if ( sel <= input_elem_num - 1 ) then
      dout <= input(sel);
    else
      dout <= 0;
    end if;
  END PROCESS;
END;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.ARRAY_ACC_PKG.all;

ENTITY reg_ui16 IS
  PORT ( din  : IN ui16;
         enb  : IN bit;
         set  : IN bit;
         rst  : IN bit;
         clk  : IN bit;
         dout : OUT ui16
       );
END;

ARCHITECTURE basic OF reg_ui16 IS
BEGIN
c1: 
  PROCESS ( din, enb, set, rst, clk )
  BEGIN
    IF ( rst = '1' ) THEN
        dout <= 0;
    ELSIF ( set = '1' ) THEN
        dout <= 1;
    ELSIF ( enb = '1' ) THEN
      IF ( clk'event AND clk = '0' ) THEN
        dout <= din;
      END IF;
    END IF;
  END PROCESS;
END;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.ARRAY_ACC_PKG.all;

ENTITY gte_ui16 IS
  PORT ( A   : IN  ui16;
         B   : IN  ui16;
         GTE : OUT bit
        );
END;

ARCHITECTURE basic OF gte_ui16 IS
BEGIN
c1: 
  process( a, b )
  BEGIN
    IF ( a >= b ) THEN
      GTE <= '1';
    ELSE
      GTE <= '0';
    END IF;
  END PROCESS;
END;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.ARRAY_ACC_PKG.all;

ENTITY adder_ui16 IS
  PORT ( A : IN  ui16;
         B : IN  ui16;
         O : OUT ui16
        );
END;

ARCHITECTURE basic OF adder_ui16 IS
BEGIN
c1: 
  process( a, b )
  BEGIN
    o <= a + b;
  END PROCESS;
END;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.all;
use work.ARRAY_ACC_PKG.all;

entity FSM is
  port ( CLK           : in  bit; 
         RST           : in  bit; 
         ASX_OUT       : in  UI16;
         GTE_OUT       : in  bit;
         MS_SEL        : out UI16;
         MI_SEL        : out UI16;
         RS_ENB        : out bit; 
         RI_ENB        : out bit; 
         RX_ENB        : out bit; 
         RY_ENB        : out bit; 
         SUM           : out UI16;
         DV            : out bit
       );
end FSM;

architecture CONTROLLER of FSM is 
  -- FSM state declaration
  type STATE_TYPE is ( S1, S2, S3, S4 );
  signal PRESENT_STATE  : STATE_TYPE;
  signal NEXT_STATE     : STATE_TYPE;
begin  -- FSM controller
  STATE_REGISTER : process ( RST, CLK )
  begin
    if ( RST = '1' ) then
      PRESENT_STATE <= S1;
    elsif ( CLK'EVENT and CLK = '0' ) then
      PRESENT_STATE <= NEXT_STATE;
    end if;
  end process STATE_REGISTER;
  
  OUTPUT_DECODE_LOGIC : process ( PRESENT_STATE, ASX_OUT, GTE_OUT )
  begin
        MS_SEL <= 0;
        MI_SEL <= 0;
    case PRESENT_STATE is
      when S1 => 
        RX_ENB <= '0';
        RY_ENB <= '0';
        RS_ENB <= '0';
        RI_ENB <= '0';
        MS_SEL <= 1;
        MI_SEL <= 1;
        SUM    <= ASX_OUT;
        DV     <= GTE_OUT;
      when S2 => 
        RX_ENB <= '1';
        RY_ENB <= '1';
        RS_ENB <= '1';
        RI_ENB <= '0';
        MS_SEL <= 1;
        MI_SEL <= 1;
        SUM    <= ASX_OUT;
        DV     <= GTE_OUT;
      when S3 => 
        RX_ENB <= '0';
        RY_ENB <= '0';
        RS_ENB <= '0';
        RI_ENB <= '1';
        MS_SEL <= 1;
        MI_SEL <= 1;
        SUM    <= ASX_OUT;
        DV     <= GTE_OUT;
      when S4 => 
        RX_ENB <= '0';
        RY_ENB <= '0';
        RS_ENB <= '0';
        RI_ENB <= '0';
        MS_SEL <= 0;
        MI_SEL <= 0;
        SUM    <= ASX_OUT;
        DV     <= '1';  --GTE_OUT;
    end case;
  end process OUTPUT_DECODE_LOGIC;
  
  STATE_DECODE_LOGIC : process ( PRESENT_STATE, GTE_OUT )
  begin
    case PRESENT_STATE is
      when S1 =>
        if( GTE_OUT = '1' ) then
          NEXT_STATE <= S4;
        else
          NEXT_STATE <= S2;
        end if;
      when S2 => 
        NEXT_STATE <= S3;
      when S3 => 
        NEXT_STATE <= S1;
      when S4 => 
        NEXT_STATE <= S4;
    end case;
  end process STATE_DECODE_LOGIC;
end CONTROLLER;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.all;
use work.ARRAY_ACC_PKG.all;

entity ARRAY_ACC_STRUCTURAL is
  generic ( ARRAY_LEN : UI16 := 10 );
  port    ( X   : in  ARRAY_UI16 ( 0 to ARRAY_LEN - 1 );
            Y   : in  ARRAY_UI16 ( 0 to ARRAY_LEN - 1 );
            CLK : in  bit;
            RST : in  bit;
            SUM : out UI16;
            DV  : out bit
          );
end ARRAY_ACC_STRUCTURAL;

architecture STRUCTURAL of ARRAY_ACC_STRUCTURAL is
  -- data path component declarations
  component MUX2_UI16
    port ( D0   : IN  UI16;
           D1   : IN  UI16;
           SEL  : IN  UI16;
           DOUT : OUT UI16 
         );
  end component;

  component MUX_UI16
    generic ( INPUT_ELEM_NUM : UI16 );
    port ( INPUT  : IN  ARRAY_UI16 ( 0 to INPUT_ELEM_NUM - 1 );
           SEL    : IN  UI16;
           DOUT   : OUT UI16 
         );
  end component;

  component REG_UI16
    port ( DIN   : IN  UI16;
           ENB   : IN  bit;
           SET   : IN  bit;
           RST   : IN  bit;
           CLK   : IN  bit;
           DOUT  : OUT UI16
         );
  end component;

  component GTE_UI16
    port ( A    : IN  UI16;
           B    : IN  UI16;
           GTE  : OUT bit
         );
  end component;

  component ADDER_UI16
    port ( A : IN  UI16;
           B : IN  UI16;
           O : OUT UI16
          );
  end component;

  component FSM
    port ( CLK           : in  bit; 
           RST           : in  bit; 
           ASX_OUT       : in  UI16;
           GTE_OUT       : in  bit;
           MS_SEL        : out UI16;
           MI_SEL        : out UI16;
           RS_ENB        : out bit; 
           RI_ENB        : out bit; 
           RX_ENB        : out bit; 
           RY_ENB        : out bit; 
           SUM           : out UI16;
           DV            : out bit
         );
  end component;

  -- signal declarations
  signal MS_SEL         : UI16  := 0;
  signal MS_OUT         : UI16  := 0;

  signal MI_SEL         : UI16  := 0;
  signal MI_OUT         : UI16  := 0;

  signal RS_ENB         : bit   := '0';
  signal RS_SET         : bit   := '0';
  signal RS_RST         : bit   := '0';
  signal RS_OUT         : UI16  := 0;

  signal RI_ENB         : bit   := '0';
  signal RI_SET         : bit   := '0';
  signal RI_RST         : bit   := '0';
  signal RI_OUT         : UI16  := 0;

  signal MX_OUT         : UI16  := 0;
  signal MY_OUT         : UI16  := 0;

  signal RX_ENB         : bit   := '0';
  signal RX_SET         : bit   := '0';
  signal RX_RST         : bit   := '0';
  signal RX_OUT         : UI16  := 0;

  signal RY_ENB         : bit   := '0';
  signal RY_SET         : bit   := '0';
  signal RY_RST         : bit   := '0';
  signal RY_OUT         : UI16  := 0;

  signal ASX_OUT        : UI16  := 0;
  signal AXY_OUT        : UI16  := 0;
  signal AI1_OUT        : UI16  := 0;
  signal GTE_OUT        : bit   := '0';

  signal ARRAY_LEN_SIG  : UI16  := ARRAY_LEN;
  signal UI0_CON        : UI16  := 0;
  signal UI1_CON        : UI16  := 0;
  signal BIT0_CON       : bit   := '0';
  signal BIT1_CON       : bit   := '0';

begin

  -- component instantiations
  MUX2_SUM : MUX2_UI16
    port map ( UI0_CON, ASX_OUT, MS_SEL, MS_OUT );

  MUX2_IDX : MUX2_UI16
    port map ( UI0_CON, AI1_OUT, MI_SEL, MI_OUT );

  REG16_SUM : REG_UI16
    port map ( MS_OUT, RS_ENB, RS_SET, RST, CLK, RS_OUT );

  REG16_IDX : REG_UI16
    port map ( MI_OUT, RI_ENB, RI_SET, RST, CLK, RI_OUT );

  COMP : GTE_UI16
    port map ( RI_OUT, ARRAY_LEN_SIG, GTE_OUT );

  MUX16_X : MUX_UI16
    generic map ( ARRAY_LEN )
    port map ( X, RI_OUT, MX_OUT );

  MUX16_Y : MUX_UI16
    generic map ( ARRAY_LEN )
    port map ( Y, RI_OUT, MY_OUT );

  REG16_X : REG_UI16
    port map ( MX_OUT, RX_ENB, RX_SET, RST, CLK, RX_OUT );

  REG16_Y : REG_UI16
    port map ( MY_OUT, RY_ENB, RY_SET, RST, CLK, RY_OUT );

  ADD16_SX : ADDER_UI16
    port map ( RS_OUT, RX_OUT, ASX_OUT );

  ADD16_XY : ADDER_UI16
    port map ( RX_OUT, RY_OUT, AXY_OUT );

  ADD16_I1 : ADDER_UI16
    port map ( RI_OUT, UI1_CON, AI1_OUT );

  FSM1 : FSM port map
       ( CLK          ,
         RST          ,
         ASX_OUT      ,
         GTE_OUT      ,
         MS_SEL       ,
         MI_SEL       ,
         RS_ENB       ,
         RI_ENB       ,
         RX_ENB       ,
         RY_ENB       ,
         SUM          ,
         DV           
       );

  -- constants
  UI0_CON  <= 0;
  UI1_CON  <= 1;
  BIT0_CON <= '0';
  BIT1_CON <= '1';

end STRUCTURAL;
