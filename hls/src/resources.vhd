package ARRAY_ACC_PKG is
  type UI16 is range 0 to 2 ** 16 - 1;
  type ARRAY_UI16 is array ( UI16 range <> ) of UI16;
end;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

PACKAGE local_defs IS

  FUNCTION signextend ( arg1 : STD_LOGIC_VECTOR ; size : NATURAL ) RETURN STD_LOGIC_VECTOR;

  FUNCTION zeroextend( q : STD_LOGIC_VECTOR; i : INTEGER ) RETURN STD_LOGIC_VECTOR;
  -- Declaration of Synthesis directive attributes
  ATTRIBUTE synthesis_return : string ;
  ATTRIBUTE is_signed : boolean ;

  FUNCTION max_of( a, b : integer) RETURN integer;

END;

PACKAGE BODY local_defs IS

  FUNCTION signextend ( arg1 : STD_LOGIC_VECTOR; size : NATURAL ) RETURN STD_LOGIC_VECTOR IS
    VARIABLE answer : STD_LOGIC_VECTOR( size - 1 DOWNTO 0 ) := ( OTHERS => '0' ) ;
      -- Signed vector to Signed vector conversion with size adjustment
    ATTRIBUTE is_signed OF arg1 : CONSTANT IS TRUE ;
    ATTRIBUTE synthesis_return OF answer : VARIABLE IS "FEED_THROUGH" ; 
	  ALIAS local_input : STD_LOGIC_VECTOR( arg1'length - 1 DOWNTO 0 ) IS arg1;
  BEGIN
    IF ( arg1'length > size ) THEN
       answer := local_input( size - 1 DOWNTO 0 );
    ELSE
       answer := ( OTHERS => arg1( arg1'left ) );
       answer( arg1'length - 1 DOWNTO 0 ) := arg1;
    END IF;
    RETURN( answer );
  END ;

  FUNCTION zeroextend( q : STD_LOGIC_VECTOR; i : INTEGER ) RETURN STD_LOGIC_VECTOR IS
     VARIABLE qs : STD_LOGIC_VECTOR( 1 TO i );
     VARIABLE qt : STD_LOGIC_VECTOR( 1 TO q'length );
     -- Hidden function. Synthesis directives are present in its callers
  BEGIN
    qt := q;
    IF i < q'length THEN
        qs := qt( ( q'length - i + 1 ) TO qt'right );
    ELSIF i > q'length THEN
        qs := ( OTHERS => '0' );
        qs := qs( 1 TO ( i - q'length ) ) & qt;
    ELSE
        qs := qt;
    END IF;
    RETURN qs;
  END;

  FUNCTION max_of( a, b : integer) RETURN integer IS
  BEGIN
    IF ( b > a ) THEN
      RETURN b;
    ELSE 
      RETURN a;
    END IF;
  END;

END;


























-- logical gates

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

Entity AndGate IS
  generic ( input_width : integer := 2 );
  port ( input : std_logic_vector( input_width - 1 downto 0 );
         -- all gate input are in one vector to
         -- allow for telescoping gates
         -- not output is only
         OUTPUT : out std_logic
        );  -- pragma map_to_resource andgate
End;

Architecture basic of AndGate IS
BEGIN
p1: 
  process ( input)
    variable local: std_logic := '1';
  begin
    local := '1';
    for idx in input'Range loop
      local := local AND input(idx);
    END LOOP;
    output <= local;
  end process;
END;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

Entity BufferGate IS
  port ( input : std_logic;
         OUTPUT : out std_logic);   -- pragma map_to_resource buffergate
End;  -- not output is only

Architecture basic of BufferGate IS
BEGIN
  output <= input;
END;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;


Entity TriState IS
  port ( input : std_logic;
         en    : std_logic;
         OUTPUT : out std_logic);   -- pragma map_to_resource tristate
End;

Architecture basic of Tristate IS
BEGIN
  output <= input when en = '1' else 'Z';
END;


--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE ieee.std_logic_arith.all;
--
--Entity Inverter IS
--  port ( INPUT  : std_logic;
--         OUTPUT : out std_logic
--        );   -- pragma map_to_resource inverter
--End;
--
--Architecture basic of inverter IS
--BEGIN
--  OUTPUT <= NOT INPUT;
--END;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

Entity OrGate IS
  generic ( input_width : integer := 2 );
  port ( input : std_logic_vector( input_width -1 downto 0);
                              -- all gate inputs are in one vector to
                                 -- allow for telescoping gates
                              -- not output is only
         OUTPUT : out std_logic);  -- pragma map_to_resource orgate
End;

Architecture Basic of OrGate IS
BEGIN
p1: 
  process ( input)
    variable local: std_logic := '0';
  begin
    local := '0';
    for idx in input'Range loop
      local := local OR input(idx);
    END LOOP;
    output <= local;
  end process;
END;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

Entity NAndGate IS
  generic ( input_width : integer := 2 );
  port ( input : std_logic_vector( input_width -1 downto 0);
                              -- all gate inputs are in one vector to
                                 -- allow for telescoping gates
                                 -- not output is only
         OUTPUT : out std_logic);   -- pragma map_to_resource nandgate
End;

Architecture basic of NAndGate IS
BEGIN
p1: 
  process ( input)
    variable local: std_logic := '1';
  begin
    local := '1';
    for idx in input'Range loop
      local := local AND input(idx);
    END LOOP;
    OUTPUT <= NOT local;
  end process;
END;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

Entity NORGate IS
  generic ( input_width : integer := 2 );
  port ( input : std_logic_vector( input_width -1 downto 0);
                              -- all gate inputs are in one vector to
                                 -- allow for telescoping gates
                               -- not output is only
         OUTPUT : out std_logic);   -- pragma map_to_resource norgate
End;

Architecture basic of NORGate IS
BEGIN
p1: 
  process ( input)
    variable local: std_logic := '0';
  begin
    local := '0';
    for idx in input'Range loop
      local := local OR input(idx);
    END LOOP;
    OUTPUT <= NOT local;
  end process;
END;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

Entity XORGate IS

  generic ( input_width : integer := 2 );
  port ( input : std_logic_vector( input_width -1 downto 0);
                              -- all gate inputs are in one vector to
                                 -- allow for telescoping gates
         OUTPUT : out std_logic);   -- pragma map_to_resource xorgate
End; -- not output is only

Architecture basic of XORGate IS
BEGIN
p1: 
  process ( input)
    variable local: std_logic := '0';
  begin
    local := '0';
    for idx in input'Range loop
      local := local XOR input(idx);
    END LOOP;
    OUTPUT <= local;
  end process;
END;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

Entity XNORGate IS
  generic ( input_width : integer := 2 );
  port ( input : std_logic_vector( input_width -1 downto 0);
                              -- all gate inputs are in one vector to
                              -- allow for telescoping gates
                              -- not output is only
         OUTPUT : out std_logic);   -- pragma map_to_resource xnorgate
End;

Architecture basic of XNORGate IS
BEGIN
p1: 
  process ( input)
    variable local: std_logic := '0';
  begin
    local := '0';
    for idx in input'Range loop
      local := local XOR input(idx);
    END LOOP;
    OUTPUT <= NOT local;
  end process;
END;

--LIBRARY ieee;
--library work;
--use work.std_logic_arith.all;
--USE ieee.std_logic_1164.all;
--
--entity Absolute IS
---- This implements an absolute function
--
--  Generic(  A_WIDTH :  INTEGER := 8 ;
--            A_SIGNED:  BOOLEAN := true ; -- IF TRUE A is signed
--            D_WIDTH :  INTEGER := 8 ;
--            D_SIGNED:  BOOLEAN := true   -- If TRUE C is signed
--         );
--  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
--         D : OUT std_logic_vector( D_WIDTH - 1 downto 0)
--        );  -- pragma map_to_resource absolute
--END;
--
--ARCHITECTURE basic OF Absolute IS
--BEGIN
--c1: 
--  process( a)
--  -- declare both signed and unsigned versions
--  -- of inputs and output so we can use the standard
--  -- packages
--  VARIABLE ua : std_logic_vector ( d_width  downto 0 );
--  VARIABLE ub : std_logic_vector( d_width  downto 0 );
--  VARIABLE result : std_logic_vector( d_width  downto 0 );
--
--  BEGIN
--    IF ( a_signed  ) THEN
--      IF ( a(a'left) = '1') THEN
--         ua := SXT( (NOT a) + "01", d_width+1);
--      ELSE
--         ua := SXT( a, d_width+1);
--      END IF;
--    ELSE
--      ua := zero_extend( a, d_width+1);
--    END IF;
--
--    result := ua;
--    d <= result( d_width -1 downto 0);
--  END PROCESS;
--END;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY Adder IS
  -- This implements a general n-bit+m_bit adder with carry in and carry out.
  GENERIC ( A_WIDTH   : INTEGER := 16;
            A_SIGNED  : BOOLEAN := true; -- IF TRUE A is signed
            B_WIDTH   : INTEGER := 16;
            B_SIGNED  : BOOLEAN := true; -- If TRUE B is signed
            O_WIDTH   : INTEGER := 16;
            O_SIGNED  : BOOLEAN := true  -- If TRUE C is signed
           );
  PORT ( A    : IN  std_logic_vector( A_WIDTH - 1 downto 0 );
         B    : IN  std_logic_vector( B_WIDTH - 1 downto 0 );
         O    : OUT std_logic_vector( O_WIDTH - 1 downto 0 );
         CIN  : IN  std_logic := '0';  -- default value so we can be unconnected
         COUT : OUT std_logic
        );  -- pragma map_to_resource adder
END;

ARCHITECTURE basic OF Adder IS
BEGIN
c1: 
  process( A, B, CIN )
  -- declare both signed and unsigned versions
  -- of inputs and output so we can use the standard packages
    VARIABLE ucin   : std_logic_vector( O_WIDTH downto 0 );
    VARIABLE ua     : std_logic_vector( O_WIDTH downto 0 );
    VARIABLE ub     : std_logic_vector( O_WIDTH downto 0 );
    VARIABLE result : std_logic_vector( O_WIDTH downto 0 );
  BEGIN
    ucin := zeroextend( '0' & CIN, O_WIDTH + 1 );

    IF ( A_SIGNED ) THEN
      ua := signextend( A, O_WIDTH + 1 );
    ELSE
      ua := zeroextend( A, O_WIDTH + 1 );
    END IF;

    IF ( B_SIGNED ) THEN
      ub := signextend( B, O_WIDTH + 1 );
    ELSE
      ub := zeroextend( B, O_WIDTH + 1 );
    END IF;

    result := ua + ub + ucin;

    O <= result( O_WIDTH - 1 downto 0 );
    COUT <= result( O_WIDTH );
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



LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY AdderSubtracter IS
  -- This implements a general n-bit+m_bit adder with carry in and carry out.
  Generic(  A_WIDTH  : INTEGER := 16;
            A_SIGNED : BOOLEAN := true; -- IF TRUE A is signed
            B_WIDTH  : INTEGER := 16;
            B_SIGNED : BOOLEAN := true; -- If TRUE B is signed
            O_WIDTH  : INTEGER := 16;
            O_SIGNED : BOOLEAN := true -- If TRUE C is signed
          );
  PORT ( A    : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         B    : IN  std_logic_vector( B_WIDTH - 1 downto 0);
         O    : OUT std_logic_vector( O_WIDTH - 1 downto 0);
         CIN  : IN std_logic := '0';  -- default value so we can be unconnected
         CNT  : IN std_logic := '0';  -- if '0' we subtract, '1' we add
         COUT : OUT std_logic
        );  -- pragma map_to_resource addersubtracter
END;

ARCHITECTURE basic OF AdderSubtracter IS
BEGIN
c1: 
  process( A, B, CIN, CNT )
  -- declare both signed and unsigned versions
  -- of inputs and output so we can use the standard packages
    VARIABLE ucin : std_logic_vector( O_WIDTH downto 0 );
    VARIABLE ua : std_logic_vector( O_WIDTH downto 0 );
    VARIABLE ub : std_logic_vector( O_WIDTH downto 0 );
    VARIABLE result : std_logic_vector( O_WIDTH downto 0 );
  BEGIN
    ucin := zeroextend( '0' & CIN, O_WIDTH + 1);
    IF ( A_SIGNED ) THEN
      ua := signextend( A, O_WIDTH + 1 );
    ELSE
      ua := zeroextend( A, O_WIDTH + 1 );
    END IF;

    IF ( B_SIGNED ) THEN
      ub := signextend( B, O_WIDTH + 1 );
    ELSE
      ub := zeroextend( B, O_WIDTH + 1 );
    END IF;

    IF ( CNT = '1') THEN
      result := ua + ub + ucin;
    ELSE
      result := ua - ub - ucin;
    END IF;

    O <= result( O_WIDTH - 1 downto 0);
    COUT <= result( O_WIDTH );
  END PROCESS;
END;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY Comparator IS
  -- This implements a general n-bit to m_bit comparator
  Generic ( A_WIDTH  : INTEGER := 16;
            A_SIGNED : BOOLEAN := true; -- IF TRUE A is signed
            B_WIDTH  : INTEGER := 16;
            B_SIGNED : BOOLEAN := true  -- If TRUE B is signed
           );
  PORT ( A   : IN  std_logic_vector( A_WIDTH - 1 downto 0 );
         B   : IN  std_logic_vector( B_WIDTH - 1 downto 0 );
	       LT  : OUT std_logic;
         LTE : OUT std_logic;
         EQ  : OUT std_logic;
         NEQ : OUT std_logic;
         GT  : OUT std_logic;
         GTE : OUT std_logic
        );  -- pragma map_to_resource comparator
END;

ARCHITECTURE basic OF comparator IS
BEGIN
c1: 
  process( A, B )
  -- declare both signed and unsigned versions
  -- of inputs and output so we can use the standard packages
   CONSTANT width : INTEGER := max_of( A_WIDTH, B_WIDTH );
   VARIABLE ua : std_logic_vector( width-1  downto 0 );
   VARIABLE ub : std_logic_vector( width-1  downto 0 );
  BEGIN
    IF ( A_SIGNED ) THEN
      ua := signextend( A, width );
    ELSE
      ua := zeroextend( A, width );
    END IF;
  
    IF ( B_SIGNED ) THEN
      ub := signextend( B, width );
    ELSE
      ub := zeroextend( B, width );
    END IF;
        
    IF ( ua = ub ) THEN
      EQ  <= '1';
      NEQ <= '0';
      LT  <= '0';
      LTE <= '1';
      GT  <= '0';
      GTE <= '1';
    ELSE
      EQ  <= '0';
      NEQ <= '1';
    END IF;
   
    IF ( B_SIGNED AND A_SIGNED ) THEN
      IF ( ( ub( ub'left ) = '1' ) AND ( ua ( ua'left ) = '1' ) ) THEN
        IF ( ua < ub ) THEN
          LT  <= '1';
          LTE <= '1';
          GT  <= '0';
          GTE <= '0';
        ELSIF ( ua > ub ) THEN
          LT  <= '0';
          LTE <= '0';
          GT  <= '1';
          GTE <= '1';
        END IF;
      ELSIF ( ( ub( ub'left ) = '0' ) AND ( ua( ua'left ) = '1' ) ) THEN
        -- A is negative, B is positive
        LT  <= '1';
        LTE <= '1';
        GT  <= '0';
        GTE <= '0';
      ELSIF ( ( ub( ub'left ) = '1' ) AND ( ua( ua'left ) = '0' ) ) THEN
        -- B is negative, A is positive
        LT  <= '0';
        LTE <= '0';
        GT  <= '1';
        GTE <= '1';
      ELSE
        -- both A and B are positive
        IF ( ua < ub ) THEN
          LT  <= '1';
          LTE <= '1';
          GT  <= '0';
          GTE <= '0';
        ELSIF ( ua > ub ) THEN
          LT  <= '0';
          LTE <= '0';
          GT  <= '1';
          GTE <= '1';
        END IF;
      END IF;
    ELSIF ( B_SIGNED AND NOT A_SIGNED ) THEN
      IF ( ub( ub'left ) = '1') THEN
        -- negative number less than A always
        LT  <= '0';
        LTE <= '0';
        GT  <= '1';
        GTE <= '1';    
      ELSIF ( ua < ub ) THEN
        LT  <= '1';
        LTE <= '1';
        GT  <= '0';
        GTE <= '0';
      ELSIF ( ua > ub ) THEN
        LT  <= '0';
        LTE <= '0';
        GT  <= '1';
        GTE <= '1';
      END IF;
    ELSIF ( A_SIGNED AND NOT B_SIGNED ) THEN
      IF ( ua( ua'left ) = '1' ) THEN
        -- negative number less than B always
        LT  <= '1';
        LTE <= '1';
        GT  <= '0';
        GTE <= '0';    
      ELSIF ( ua < ub ) THEN
        LT  <= '1';
        LTE <= '1';
        GT  <= '0';
        GTE <= '0';
      ELSIF ( ua > ub ) THEN
        LT  <= '0';
        LTE <= '0';
        GT  <= '1';
        GTE <= '1';
      END IF;
    ELSE 
      IF ( ua < ub ) THEN
        LT  <= '1';
        LTE <= '1';
        GT  <= '0';
        GTE <= '0';
      ELSIF ( ua > ub ) THEN
        LT  <= '0';
        LTE <= '0';
        GT  <= '1';
        GTE <= '1';
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
    IF ( a >= b) THEN
      GTE <= '1';
    ELSE
      GTE <= '0';
    END IF;
  END PROCESS;
END;



LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY Counter IS
-- This implements a general counter

  Generic(  DIN_WIDTH :  INTEGER := 8;
            DIN_SIGNED:  BOOLEAN := true; -- IF TRUE DIN is signed
            DOUT_WIDTH :  INTEGER := 8;
            DOUT_SIGNED:  BOOLEAN := true  -- If TRUE B is signed
         );
  PORT ( DIN : IN  std_logic_vector( DIN_WIDTH - 1 downto 0);
	       SET : IN  std_logic;
	       RESET : IN  std_logic;
         CNT : IN std_logic := '0';
         CLK : IN std_logic := '0';
         DOUT : OUT  std_logic_vector( DOUT_WIDTH - 1 downto 0)
        );  -- pragma map_to_resource counter
END;

ARCHITECTURE basic OF Counter IS
BEGIN
c1: 
  process( din, set, reset, clk)
  -- declare both signed and unsigned versions
  -- of inputs and output so we can use the standard
  -- packages
  VARIABLE local : std_logic_vector ( dout_width-1  downto 0);

  BEGIN
    IF ( set = '1' ) THEN
      IF ( DIN_SIGNED ) THEN
        local := signextend(din, dout_width);
      ELSE
        local := signextend(din, dout_width);
      END IF;
      dout <= local;
    ELSIF ( reset = '1') THEN
      local := ( others => '0');
      dout <= local;   
    ELSIF ( clk'event AND clk = '1' ) THEN
      IF ( CNT = '0') THEN
         local := local + "01";
      ELSE
         local := local - "01";
      END IF;
      dout <= local;
    END IF;
  END PROCESS;
END;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY Decoder IS
-- This implements a general decoder
  Generic(  SEL_WIDTH   :  INTEGER := 3;
            DOUT_WIDTH  :  INTEGER := 8
         );
  PORT ( SEL : IN  std_logic_vector( SEL_WIDTH - 1 downto 0);
         DOUT: OUT std_logic_vector( 0 to DOUT_WIDTH -1)
        );  -- pragma map_to_resource decoder
END;

ARCHITECTURE basic OF Decoder IS
BEGIN
c1: 
  PROCESS (sel)
    VARIABLE idx : INTEGER;
  BEGIN
    dout <= ( others => '0');
    IF ( NOT Is_X(std_logic_vector(sel) )) THEN
      idx := to_integer('0'& sel);
      IF ( idx >= 0 AND idx < DOUT_WIDTH) THEN
        dout(idx) <= '1';		  
      END IF;
    END IF;
  END PROCESS;

END;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY Decoder_Offset IS
-- This implements a general decoder that
-- only has DOUT_WIDTH number of outputs and
-- starts at OFFSET and goes to OFFSET+DOUT_WIDTH-1
-- used for arrays with non-zero bounds.

  Generic(  SEL_WIDTH   :  INTEGER := 3;
            DOUT_WIDTH  :  INTEGER := 8;
	          OFFSET      :  INTEGER := 0
         );
  PORT ( SEL : IN  std_logic_vector( SEL_WIDTH - 1 downto 0 );
         DOUT: OUT std_logic_vector( 0 to DOUT_WIDTH - 1 )
        );  -- pragma map_to_resource decoder_offset
END;

ARCHITECTURE basic OF Decoder_Offset IS
BEGIN
c1: 
  PROCESS (sel)
    VARIABLE idx : INTEGER;
  BEGIN
    dout <= ( others => '0');
    IF ( NOT Is_X(std_logic_vector(sel) )) THEN
      idx := to_integer('0' & sel);
      IF ( idx >= OFFSET AND idx < DOUT_WIDTH+OFFSET) THEN
        dout(idx-OFFSET) <= '1';		  
      END IF;
    END IF;
  END PROCESS;
END;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY Decrementer IS
-- This implements a general n-bit to m_bit decremeneter with barrow out

  Generic(  A_WIDTH :  INTEGER := 8;
            A_SIGNED:  BOOLEAN := true; -- IF TRUE A is signed
            O_WIDTH :  INTEGER := 8;
            O_SIGNED:  BOOLEAN := true  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0);
         COUT: OUT std_logic
        );  -- pragma map_to_resource decrementer
END;

ARCHITECTURE basic OF Decrementer IS
BEGIN
c1: 
  process( a)
  -- declare both signed and unsigned versions
  -- of inputs and output so we can use the standard
  -- packages
  VARIABLE ua : std_logic_vector ( o_width  downto 0);
  VARIABLE result : std_logic_vector( o_width  downto 0);

  BEGIN
    IF ( a_signed ) THEN
      ua := signextend( a, o_width+1);
    ELSE
      ua := zeroextend( a, o_width+1);
    END IF;

    result := ua - "01";
    o <= result( o_width -1 downto 0);
    cout <= result( o_width);
  END PROCESS;
END;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY divider IS
-- This implements a general n-bit and m_bit divider

  Generic(  A_WIDTH :  INTEGER := 8;
            A_SIGNED:  BOOLEAN := true; -- IF TRUE A is signed
            B_WIDTH :  INTEGER := 8;
            B_SIGNED:  BOOLEAN := true; -- If TRUE B is signed
            O_WIDTH :  INTEGER := 8;
            O_SIGNED:  BOOLEAN := true  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         B : IN  std_logic_vector( B_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
        );  -- pragma map_to_resource divider
END;

ARCHITECTURE basic OF Divider IS

BEGIN

c1: 
  process( a, b)
  -- declare both signed and unsigned versions
  -- of inputs and output so we can use the standard
  -- packages
  CONSTANT width : integer := max_of( max_of( a_width, b_width),o_width);
  VARIABLE ua : std_logic_vector ( width-1  downto 0);
  VARIABLE ub : std_logic_vector( width-1  downto 0);
  VARIABLE una : unsigned ( width-1 downto 0);
  VARIABLE unb : unsigned ( width-1 downto 0);
  VARIABLE sgna : signed ( width-1 downto 0);
  VARIABLE sgnb : signed ( width-1 downto 0);
  VARIABLE sgnr : signed ( width-1 downto 0);
  VARIABLE unr : unsigned ( width-1 downto 0);
  VARIABLE result : std_logic_vector( o_width  downto 0);

  BEGIN
    IF ( a_signed ) THEN
      ua := signextend( a, width);
    ELSE
      ua := zeroextend( a, width);
    END IF;

    IF ( b_signed ) THEN
      ub := signextend( b, width);
    ELSE
      ub := zeroextend( b, width);
    END IF;

    IF ( o_signed ) THEN
      FOR  i IN width-1 DOWNTO 0 LOOP
        sgna(i) := ua(i);
        sgnb(i) := ub(i);
      END LOOP;
      sgnr := sgna / sgnb;
      FOR i IN o_width-1 DOWNTO 0 LOOP
        o(i) <= sgnr(i);
      END LOOP;
    ELSE
      FOR  i IN width-1 DOWNTO 0 LOOP
        una(i) := ua(i);
        unb(i) := ub(i);
      END LOOP;
      unr := una / unb;
      FOR i IN o_width-1 DOWNTO 0 LOOP
        o(i) <= unr(i);
      END LOOP;
    END IF;
  END PROCESS;
END;


--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY exponent IS
---- This implements a general n-bit to  m-bit power
--
--  Generic(  A_WIDTH :  INTEGER := 8;
--            A_SIGNED:  BOOLEAN := true; -- IF TRUE A is signed
--            B_WIDTH :  INTEGER := 8;
--            B_SIGNED:  BOOLEAN := true; -- If TRUE B is signed
--            O_WIDTH :  INTEGER := 8;
--            O_SIGNED:  BOOLEAN := true  -- If TRUE C is signed
--         );
--  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
--         B : IN  std_logic_vector( B_WIDTH - 1 downto 0);
--         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
--        );  -- pragma map_to_resource exponent
--END;
--
--ARCHITECTURE basic OF exponent IS
--
--BEGIN
--
--c1: 
--  process( a, b)
--  -- declare both signed and unsigned versions
--  -- of inputs and output so we can use the standard
--  -- packages
--  CONSTANT width : integer := max_of( max_of( a_width, b_width),o_width);
--  VARIABLE ua : std_logic_vector ( width-1  downto 0);
--  VARIABLE ub : std_logic_vector( width-1  downto 0);
--  VARIABLE una : unsigned ( width-1 downto 0);
--  VARIABLE unb : unsigned ( width-1 downto 0);
--  VARIABLE sgna : signed ( width-1 downto 0);
--  VARIABLE sgnb : signed ( width-1 downto 0);
--  VARIABLE sgnr : signed ( width-1 downto 0);
--  VARIABLE unr : unsigned ( width-1 downto 0);
--
--  BEGIN
--    IF ( a_signed ) THEN
--      ua := signextend( a, width);
--    ELSE
--      ua := zeroextend( a, width);
--    END IF;
--
--    IF ( b_signed ) THEN
--      ub := signextend( b, width);
--    ELSE
--      ub := zeroextend( b, width);
--    END IF;
--
--    IF ( o_signed ) THEN
--      FOR  i IN width-1 DOWNTO 0 LOOP
--        sgna(i) := ua(i);
--        sgnb(i) := ub(i);
--      END LOOP;
--      sgnr := sgna ** sgnb;
--      FOR i IN o_width-1 DOWNTO 0 LOOP
--        o(i) <= sgnr(i);
--      END LOOP;
--    ELSE
--      FOR  i IN width-1 DOWNTO 0 LOOP
--        una(i) := ua(i);
--        unb(i) := ub(i);
--      END LOOP;
--      unr := una ** unb;
--      FOR i IN o_width-1 DOWNTO 0 LOOP
--        o(i) <= unr(i);
--      END LOOP;
--    END IF;
--  END PROCESS;
--END;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY IncDec IS
-- This implements a general n-bit to m_bit incremeneter/decrementer with carry out

  Generic(  A_WIDTH :  INTEGER := 8;
            A_SIGNED:  BOOLEAN := true; -- IF TRUE A is signed
            O_WIDTH :  INTEGER := 8;
            O_SIGNED:  BOOLEAN := true -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         CNT : IN std_logic := '0'; -- 1 increment, 0 decrement
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0);
         COUT: OUT std_logic
        );  -- pragma map_to_resource incdec
END;

ARCHITECTURE basic OF IncDec IS
BEGIN
c1: 
  process( a, cnt )
  -- declare both signed and unsigned versions
  -- of inputs and output so we can use the standard
  -- packages
  VARIABLE ua : std_logic_vector ( o_width  downto 0);
  VARIABLE result : std_logic_vector( o_width  downto 0);

  BEGIN
    IF ( a_signed ) THEN
      ua := signextend( a, o_width+1);
    ELSE
      ua := zeroextend( a, o_width+1);
    END IF;

    IF ( CNT = '1') THEN
      result := ua + "01";		    
    ELSIF ( CNT = '0') THEN
      result := ua - "01";
    ELSE 
      result := ( others => 'X');
    END IF;
    o <= result( o_width -1 downto 0);
    cout <= result( o_width);
  END PROCESS;
END;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY Incrementer IS
-- This implements a general n-bit to m_bit incremeneter with carry out

  Generic(  A_WIDTH :  INTEGER := 8;   
            A_SIGNED:  BOOLEAN := true; -- IF TRUE A is signed
            O_WIDTH :  INTEGER := 8;   
            O_SIGNED:  BOOLEAN := true -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0);
         COUT: OUT std_logic
        );  -- pragma map_to_resource incrementer
END;

ARCHITECTURE basic OF Incrementer IS
BEGIN
c1: 
  process( a)
  -- declare both signed and unsigned versions
  -- of inputs and output so we can use the standard
  -- packages
  VARIABLE ua : std_logic_vector ( o_width  downto 0);
  VARIABLE result : std_logic_vector( o_width  downto 0);

  BEGIN
    IF ( a_signed ) THEN
      ua := signextend( a, o_width+1);
    ELSE
      ua := zeroextend( a, o_width+1);
    END IF;

    result := ua + "01";
    o <= result( o_width -1 downto 0);
    cout <= result( o_width);
  END PROCESS;
END;


--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY Latch IS
--  PORT ( din : IN std_logic;
--         set : IN std_logic := '0';
--         reset: IN std_logic := '0';
--         clk : IN std_logic;
--         dout : OUT std_logic
--       );   -- pragma map_to_resource latch
--END;
--
--ARCHITECTURE basic OF Latch IS
--BEGIN
--c1: 
--  PROCESS ( din, set, reset, clk)
--  BEGIN
--    IF ( set = '1') THEN
--       dout <= '1';
--    ELSIF ( reset = '1' ) THEN
--       dout <= '0';
--    ELSIF ( clk = '1') THEN
--       dout <= din;
--    END IF;
--  END PROCESS;
--END;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;


ENTITY Latch_vec IS
  Generic(  DIN_WIDTH   :  INTEGER := 8;   
            SET_WIDTH   :  INTEGER := 8;
            RESET_WIDTH :  INTEGER := 8;   
            DOUT_WIDTH  :  INTEGER := 8
         );

  PORT ( din : IN std_logic_vector ( DIN_WIDTH - 1 downto 0);
         set : IN std_logic_vector( SET_WIDTH -1 downto 0) := ( others =>'0');
         reset: IN std_logic_vector( RESET_WIDTH -1 downto 0) := ( others =>'0');
         clk : IN std_logic;
         dout : OUT std_logic_vector( DOUT_WIDTH -1 downto 0)
       );  -- pragma map_to_resource latch_vec
END ;

ARCHITECTURE basic OF Latch_vec IS
BEGIN
c1: 
  PROCESS ( din, set, reset, clk)
  BEGIN
    FOR I IN DIN_WIDTH -1 DOWNTO 0 LOOP    	       
      IF ( SET_WIDTH = 1 AND set(0) = '1') THEN
        dout(i) <= '1';
      ELSIF ( SET_WIDTH /= 1 AND set(i) = '1') THEN
        dout(i) <= '1';
      ELSIF ( RESET_WIDTH = 1 AND reset(0) = '1') THEN
        dout(i) <= '0';
      ELSIF ( RESET_WIDTH /= 1 AND reset(i) = '1') THEN
        dout(i) <= '0';
      ELSIF ( clk = '1') THEN
        dout(i) <= din(i);
      END IF;
    END LOOP;
  END PROCESS;
END;


--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY Modulus IS
---- This implements a general n-bit and m_bit modulus
--  Generic(  A_WIDTH :  INTEGER := 8;   
--            A_SIGNED:  BOOLEAN := true; -- IF TRUE A is signed
--            B_WIDTH :  INTEGER := 8;   
--            B_SIGNED:  BOOLEAN := true; -- If TRUE B is signed
--            O_WIDTH :  INTEGER := 8;
--            O_SIGNED:  BOOLEAN := true -- If TRUE C is signed
--         );                    
--  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
--         B : IN  std_logic_vector( B_WIDTH - 1 downto 0);
--         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
--        );  -- pragma map_to_resource modulus
--END;
--
--ARCHITECTURE basic OF Modulus IS
--BEGIN
--C1: 
--  process( a, b)
--  -- declare both signed and unsigned versions
--  -- of inputs and output so we can use the standard
--  -- packages
--  CONSTANT width : integer := max_of( max_of( a_width, b_width),o_width);
--  VARIABLE ua : std_logic_vector ( width-1  downto 0);
--  VARIABLE ub : std_logic_vector( width-1  downto 0);
--  VARIABLE una : unsigned ( width-1 downto 0);
--  VARIABLE unb : unsigned ( width-1 downto 0);
--  VARIABLE sgna : signed ( width-1 downto 0);
--  VARIABLE sgnb : signed ( width-1 downto 0);
--  VARIABLE sgnr : signed ( width-1 downto 0);
--  VARIABLE unr : unsigned ( width-1 downto 0);
--
--  BEGIN
--    IF ( a_signed ) THEN
--      ua := signextend( a, width);
--    ELSE
--      ua := zeroextend( a, width);
--    END IF;
--
--    IF ( b_signed ) THEN
--      ub := signextend( b, width);
--    ELSE
--      ub := zeroextend( b, width);
--    END IF;
--
--    IF ( o_signed ) THEN
--      FOR  i IN width-1 DOWNTO 0 LOOP
--        sgna(i) := ua(i);
--        sgnb(i) := ub(i);
--      END LOOP;
--      sgnr := sgna MOD sgnb;
--      FOR i IN o_width-1 DOWNTO 0 LOOP
--        o(i) <= sgnr(i);
--      END LOOP;
--    ELSE
--      FOR  i IN width-1 DOWNTO 0 LOOP
--        una(i) := ua(i);
--        unb(i) := ub(i);
--      END LOOP;
--      unr := una MOD unb;
--      FOR i IN o_width-1 DOWNTO 0 LOOP
--        o(i) <= unr(i);
--      END LOOP;
--    END IF;
--  END PROCESS;
--END;


--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY Multiplexer IS
--  -- This implements a general multiplexer carry out.
--  Generic(  INPUT_WIDTH :  INTEGER := 8;
--            SEL_WIDTH   :  INTEGER := 8
--          );
--  PORT ( INPUT : IN  std_logic_vector( 0 to INPUT_WIDTH - 1 );
--         SEL   : IN  std_logic_vector( SEL_WIDTH - 1 downto 0);
--         DOUT  : OUT std_logic
--        );  -- pragma map_to_resource multiplexer
--END;
--
--ARCHITECTURE basic OF Multiplexer IS
--BEGIN
--
--A1 : ASSERT ( 2 ** sel_width >= input_width ) 
--     REPORT "Unable to select some inputs";
--
--c1: 
--  PROCESS ( input, sel )
--    VARIABLE idx : INTEGER;
--  BEGIN
--    IF ( NOT Is_X(std_logic_vector(sel) )) THEN
--      idx := to_integer('0' & sel);
--      dout <= input( idx);
--    ELSE
--      dout <= 'X';
--    END IF;
--  END PROCESS;
--
--END;
--
--
--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY Multiplexer_vec IS
--  -- This implements a general multiplexer
--  GENERIC ( INPUT_WIDTH : INTEGER := 16;
--            SEL_WIDTH   : INTEGER := 16;
--            DOUT_WIDTH  : INTEGER := 16
--           );
--  PORT ( INPUT  : IN  std_logic_vector( INPUT_WIDTH - 1 DOWNTO 0 );
--         SEL    : IN  std_logic_vector( SEL_WIDTH - 1 DOWNTO 0 );
--         DOUT   : OUT std_logic_vector( DOUT_WIDTH - 1 DOWNTO 0 )
--        );  -- pragma map_to_resource multiplexer_vec
--END;
--
--ARCHITECTURE basic OF Multiplexer_vec IS
--BEGIN
--A1 :
--  ASSERT ( 2 ** SEL_WIDTH * DOUT_WIDTH >= INPUT_WIDTH ) 
--  REPORT "Unable to select some inputs";
--C1: 
--  PROCESS ( INPUT, SEL )
--    VARIABLE idx : INTEGER;
--    VARIABLE cnt : INTEGER;
--  BEGIN
--    IF ( NOT Is_X( std_logic_vector( SEL ) ) ) THEN
--      idx := to_integer( '0' & SEL );
--      DOUT <= INPUT( ( idx * DOUT_WIDTH + DOUT_WIDTH - 1 ) DOWNTO ( idx * DOUT_WIDTH ) );
--    ELSE
--      DOUT <= ( OTHERS => 'X' );
--    END IF;
--  END PROCESS;
--END;



library ieee;
use ieee.std_logic_1164.all;
use work.std_logic_arith.all;
use work.local_defs.all;

entity MULTIPLEXER_4TO1 is
  generic ( DATA_WIDTH : integer := 16 );
  port ( DIN0 : in  std_logic_vector ( DATA_WIDTH - 1 downto 0 );
         DIN1 : in  std_logic_vector ( DATA_WIDTH - 1 downto 0 );
         DIN2 : in  std_logic_vector ( DATA_WIDTH - 1 downto 0 );
         DIN3 : in  std_logic_vector ( DATA_WIDTH - 1 downto 0 );
         SEL  : in  std_logic_vector ( 1 downto 0 );
         DOUT : out std_logic_vector ( DATA_WIDTH - 1 downto 0 ) 
       );
END;

architecture BASIC of MULTIPLEXER_4TO1 is
begin
  process ( DIN0, DIN1, DIN2, DIN3, SEL )
  begin
    case SEL is
      when "00" => DOUT <= DIN0;
      when "01" => DOUT <= DIN1;
      when "10" => DOUT <= DIN2;
      when "11" => DOUT <= DIN3;
      when others => DOUT <= ( others => 'X' );
    end case;
  end process;
end BASIC;



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
      --elsif ( SEL = 1 ) then
      else
        DOUT <= D1;
      end if;
  END PROCESS;
END;


--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--entity mux2_bit8 is
--  port ( di0  : in  std_logic_vector( 7 downto 0 );
--         di1  : in  std_logic_vector( 7 downto 0 );
--         dsel : in  std_logic;
--         zout : out std_logic_vector( 7 downto 0 )
--       );
--end mux2_bit8;
--
--architecture baisc of mux2_bit8 is
--  component Multiplexer_vec_new
--    PORT ( INPUT : IN  std_logic_vector( 15 downto 0 );
--           SEL   : IN  std_logic;
--           DOUT  : OUT std_logic_vector( 7 downto 0 )
--         );
--  end component;
--  -- signals
--  signal muxv_in  : std_logic_vector( 15 downto 0 );
--  signal muxv_sel : std_logic;
--  signal muxv_out : std_logic_vector( 7 downto 0 );
--begin
--  muxv_in( 7 downto 0 )  <= di0;
--  muxv_in( 15 downto 8 ) <= di1;
--  mux1 : Multiplexer_vec_new 
--    port map ( muxv_in, dsel, zout );
--end;


--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY Multiplexer1hot IS
--  -- This implements a general 1 hot multiplexer or selector carry out.
--  Generic(  INPUT_WIDTH : INTEGER := 8;
--            SEL_WIDTH   : INTEGER := 8
--         );
--  PORT ( INPUT : IN  std_logic_vector( INPUT_WIDTH - 1 downto 0);
--         SEL : IN  std_logic_vector( SEL_WIDTH - 1 downto 0);
--         DOUT: OUT std_logic
--        );  -- pragma map_to_resource multiplexer1hot
--END;
--
--ARCHITECTURE basic OF Multiplexer1hot IS
--BEGIN
--A1 : ASSERT ( sel_width = input_width) 
--     REPORT "Unable to select some inputs";
--
--C1: 
--  PROCESS (input, sel)
--  BEGIN
--    FOR idx IN SEL_WIDTH-1 DOWNTO 0 LOOP
--      IF ( sel(idx) = '1') THEN
--        dout <= input(idx);
--        EXIT;
--      END IF;
--    END LOOP;
--  END PROCESS;
--
--END;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY Multiplexer1hot_vec IS
-- This implements a general 1 hot multiplexer or selector carry out.
  Generic(  INPUT_WIDTH :  INTEGER := 16;
            SEL_WIDTH   :  INTEGER := 1;
            DOUT_WIDTH  :  INTEGER := 8
         );
  PORT ( INPUT : IN  std_logic_vector( INPUT_WIDTH - 1 downto 0);
         SEL : IN  std_logic_vector( SEL_WIDTH - 1 downto 0);
         DOUT: OUT std_logic_vector( DOUT_WIDTH - 1 downto 0)
        );  -- pragma map_to_resource Multiplexer1hot_vec
END;

ARCHITECTURE basic OF Multiplexer1hot_vec IS
BEGIN

A1 : ASSERT ( sel_width * DOUT_WIDTH = input_width) 
     REPORT "Unable to select some inputs";

c1: 
  PROCESS (input, sel)
    variable cnt, base: integer;
  BEGIN
    cnt := 0;
    FOR idx IN SEL_WIDTH-1 DOWNTO 0 LOOP
      IF ( sel(idx) = '1') THEN
        cnt := idx;
        EXIT;
      END IF;
    END LOOP;
    base :=  cnt * DOUT_WIDTH;
    FOR idx IN DOUT_WIDTH-1 DOWNTO 0 LOOP
      dout ( idx) <= input(base+idx);
    END LOOP;
  END PROCESS;

END;



LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY Multiplier IS
  -- This implements a general n-bit and m_bit divider
  Generic(  A_WIDTH :  INTEGER := 8;
            A_SIGNED:  BOOLEAN := false; -- IF TRUE A is signed
            B_WIDTH :  INTEGER := 8;
            B_SIGNED:  BOOLEAN := false; -- If TRUE B is signed
            O_WIDTH :  INTEGER := 8;
            O_SIGNED:  BOOLEAN := false  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0 );
         B : IN  std_logic_vector( B_WIDTH - 1 downto 0 );
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0 )
        ); -- pragma map_to_resource multiplier
END;

ARCHITECTURE basic OF Multiplier IS
BEGIN
C1: 
  process( a, b)
  -- declare both signed and unsigned versions
  -- of inputs and output so we can use the standard
  -- packages
  CONSTANT width : integer := max_of( max_of( a_width, b_width),o_width);
  VARIABLE ua : std_logic_vector ( width-1  downto 0);
  VARIABLE ub : std_logic_vector( width-1  downto 0);
  VARIABLE una : unsigned ( width-1 downto 0);
  VARIABLE unb : unsigned ( width-1 downto 0);
  VARIABLE sgna : signed ( width-1 downto 0);
  VARIABLE sgnb : signed ( width-1 downto 0);
  VARIABLE sresult : signed ( 2*width-1 downto 0);
  VARIABLE sgnr : signed ( width-1 downto 0);
  VARIABLE uresult : unsigned ( 2*width-1 downto 0);
  VARIABLE unr : unsigned ( width-1 downto 0);

  BEGIN
    IF ( a_signed ) THEN
      ua := signextend( a, width);
    ELSE
      ua := zeroextend( a, width);
    END IF;

    IF ( b_signed ) THEN
      ub := signextend( b, width);
    ELSE
      ub := zeroextend( b, width);
    END IF;

    IF ( o_signed ) THEN
      FOR  i IN width-1 DOWNTO 0 LOOP
        sgna(i) := ua(i);
        sgnb(i) := ub(i);
      END LOOP;
      sresult := sgna * sgnb;
      sgnr := sresult(width-1 downto 0);
      FOR i IN o_width-1 DOWNTO 0 LOOP
        o(i) <= sgnr(i);
      END LOOP;
    ELSE
      FOR  i IN width-1 DOWNTO 0 LOOP
        una(i) := ua(i);
        unb(i) := ub(i);
      END LOOP;
      uresult := una * unb;
      unr := uresult(width-1 downto 0);
      FOR i IN o_width-1 DOWNTO 0 LOOP
        o(i) <= unr(i);
      END LOOP;
    END IF;
  END PROCESS;
END;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY Reg IS
  PORT ( din : IN std_logic;
         set : IN std_logic := '0';
         reset: IN std_logic := '0';
         clk : IN std_logic;
         dout : OUT std_logic
       ); -- pragma map_to_resource reg
END;

ARCHITECTURE basic OF Reg IS
BEGIN
c1: 
  PROCESS ( din, set, reset, clk)
  BEGIN
    IF ( set = '1') THEN
       dout <= '1';
    ELSIF ( reset = '1' ) THEN
       dout <= '0';
    ELSIF ( clk = '1' AND clk'event) THEN
       dout <= din;
    END IF;
  END PROCESS;
END;


--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY Reg_new IS
--  PORT ( din : IN std_logic;
--         set : IN std_logic := '0';
--         reset: IN std_logic := '0';
--         clk : IN std_logic;
--         dout : OUT std_logic
--       ); -- pragma map_to_resource reg
--END;
--
--ARCHITECTURE basic OF Reg_new IS
--BEGIN
--c1: 
--  PROCESS ( din, set, reset, clk)
--  BEGIN
--    IF ( set = '1') THEN
--       dout <= '1';
--    ELSIF ( reset = '1' ) THEN
--       dout <= '0';
--    ELSIF ( clk'event AND clk = '0' ) THEN
--       dout <= din;
--    END IF;
--  END PROCESS;
--END;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY Reg_vec IS
  Generic(  DIN_WIDTH   :  INTEGER := 16;
            SET_WIDTH   :  INTEGER := 16;
            RESET_WIDTH :  INTEGER := 16;
            DOUT_WIDTH  :  INTEGER := 16
         );

  PORT ( din   :  IN std_logic_vector ( DIN_WIDTH - 1 downto 0 );
         set   :  IN std_logic_vector ( SET_WIDTH - 1 downto 0 ) := ( others => '0');
         reset :  IN std_logic_vector ( RESET_WIDTH -1 downto 0 ) := ( others => '0');
         clk   :  IN std_logic;
         dout  :  OUT std_logic_vector( DOUT_WIDTH -1 downto 0)
       ); -- pragma map_to_resource reg_vec
END;

ARCHITECTURE basic OF Reg_vec IS
BEGIN
c1: 
  PROCESS ( din, set, reset, clk)
  BEGIN
    FOR I IN DIN_WIDTH - 1 DOWNTO 0 LOOP    	       
      IF ( SET_WIDTH = 1 AND set(0) = '1') THEN
        dout(i) <= '1';
      ELSIF ( SET_WIDTH /= 1 AND set(i) = '1') THEN
        dout(i) <= '1';
      ELSIF ( RESET_WIDTH = 1 AND reset(0) = '1') THEN
        dout(i) <= '0';
      ELSIF ( RESET_WIDTH /= 1 AND reset(i) = '1') THEN
        dout(i) <= '0';
      ELSIF ( clk = '1' AND clk'event) THEN
        dout(i) <= din(i);
      END IF;
    END LOOP;
  END PROCESS;
END;



--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY Reg_vec_new IS
--  PORT ( din : IN std_logic_vector ( 7 downto 0);
--         set : IN std_logic;
--         reset: IN std_logic;
--         clk : IN std_logic;
--         dout : OUT std_logic_vector( 7 downto 0)
--       ); -- pragma map_to_resource reg_vec
--END;
--
--ARCHITECTURE basic OF Reg_vec_new IS
--BEGIN
--c1: 
--  PROCESS ( din, set, reset, clk)
--  BEGIN
--    FOR I IN 7 DOWNTO 0 LOOP    	       
--      IF ( set = '1') THEN
--        dout(i) <= '1';
--      ELSIF ( reset = '1') THEN
--        dout(i) <= '0';
--      ELSIF ( clk'event AND clk = '0' ) THEN
--        dout(i) <= din(i);
--      END IF;
--    END LOOP;
--  END PROCESS;
--END;




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





--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY Remainder IS
---- This implements a general n-bit and m_bit divider
--
--  Generic(  A_WIDTH :  INTEGER := 8;
--            A_SIGNED:  BOOLEAN := false; -- IF TRUE A is signed
--            B_WIDTH :  INTEGER := 8;
--            B_SIGNED:  BOOLEAN := false; -- If TRUE B is signed
--            O_WIDTH :  INTEGER := 8;
--            O_SIGNED:  BOOLEAN := false  -- If TRUE C is signed
--         );
--  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
--         B : IN  std_logic_vector( B_WIDTH - 1 downto 0);
--         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
--        ); -- pragma map_to_resource remainder
--END;
--
--ARCHITECTURE basic OF Remainder IS
--BEGIN
--C1: 
--  process( a, b )
--  -- declare both signed and unsigned versions
--  -- of inputs and output so we can use the standard
--  -- packages
--  CONSTANT width : integer := max_of( max_of( a_width, b_width), o_width);
--  VARIABLE ua : std_logic_vector ( width-1  downto 0);
--  VARIABLE ub : std_logic_vector( width-1  downto 0);
--  VARIABLE una : unsigned ( width-1 downto 0);
--  VARIABLE unb : unsigned ( width-1 downto 0);
--  VARIABLE sgna : signed ( width-1 downto 0);
--  VARIABLE sgnb : signed ( width-1 downto 0);
--  VARIABLE sgnr : signed ( width-1 downto 0);
--  VARIABLE unr : unsigned ( width-1 downto 0);
--
--  BEGIN
--    IF ( a_signed ) THEN
--      ua := signextend( a, width);
--    ELSE
--      ua := zeroextend( a, width);
--    END IF;
--
--    IF ( b_signed ) THEN
--      ub := signextend( b, width);
--    ELSE
--      ub := zeroextend( b, width);
--    END IF;
--
--    IF ( o_signed ) THEN
--      FOR  i IN width-1 DOWNTO 0 LOOP
--        sgna(i) := ua(i);
--        sgnb(i) := ub(i);
--      END LOOP;
--      sgnr := sgna rem sgnb;
--      FOR i IN o_width-1 DOWNTO 0 LOOP
--        o(i) <= sgnr(i);
--      END LOOP;
--    ELSE
--      FOR  i IN width-1 DOWNTO 0 LOOP
--        una(i) := ua(i);
--        unb(i) := ub(i);
--      END LOOP;
--      unr := una rem unb;
--      FOR i IN o_width-1 DOWNTO 0 LOOP
--        o(i) <= unr(i);
--      END LOOP;
--    END IF;
--  END PROCESS;
--END;



--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY RotateLeft IS
---- This implements a general n-bit rotate
--
--  Generic(  A_WIDTH    :  INTEGER := 16;
--            A_SIGNED   :  BOOLEAN := false; -- IF TRUE A is signed
--            CNT_WIDTH  :  INTEGER := 16;
--            CNT_SIGNED :  BOOLEAN := false; -- If TRUE B is signed
--            O_WIDTH    :  INTEGER := 16;
--            O_SIGNED   :  BOOLEAN := false  -- If TRUE C is signed
--         );
--  PORT ( A   : IN  std_logic_vector( A_WIDTH - 1 downto 0 );
--         CNT : IN  std_logic_vector( CNT_WIDTH - 1 downto 0 );
--         O   : OUT std_logic_vector( O_WIDTH - 1 downto 0 )
--       ); -- pragma map_to_resource rotateleft
--END;
--
--ARCHITECTURE basic OF RotateLeft IS
--BEGIN
--A1: ASSERT ( a_width = o_width) 
--    REPORT "Input and output must be the same size";
--
--c1: 
--  process( a, cnt )
--  -- declare both signed and unsigned versions
--  -- of inputs and output so we can use the standard
--  -- packages
--  VARIABLE i : INTEGER;
--  VARIABLE sgncnt : signed( CNT_WIDTH -1 downto 0);
--  BEGIN
--  IF ( cnt_signed ) THEN
--    FOR idx IN CNT_WIDTH-1 DOWNTO 0 LOOP
--      sgncnt(idx) := cnt(idx);
--    END LOOP;
--    i := to_integer( sgncnt);
--  ELSE
--    i := to_integer('0' & cnt);
--  END IF;
--  
--  IF ( i < 0 ) THEN
--    i := -i;
--    i := i mod a_width;
--    o <=  a( i-1 downto 0 ) & a( a_width - 1 downto i );
--  ELSIF ( i = 0 ) THEN
--    o <= a;
--  ELSE
--    i := i mod a_width;
--    o <=  a( a_width - 1 - i  downto 0 ) &
--          a( a_width - 1 downto a_width - 1 - i + 1 );
--  END IF;
--
--  END PROCESS;
--END;
--
--
--
--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY RotateRight IS
---- This implements a general n-bit rotate
--
--  Generic(  A_WIDTH    :  INTEGER := 8;
--            A_SIGNED   :  BOOLEAN := false; -- IF TRUE A is signed
--            CNT_WIDTH  :  INTEGER := 8;
--            CNT_SIGNED :  BOOLEAN := false; -- If TRUE B is signed
--            O_WIDTH    :  INTEGER := 8;
--            O_SIGNED   :  BOOLEAN := false -- If TRUE C is signed
--         );
--  PORT ( A   : IN  std_logic_vector( A_WIDTH - 1 downto 0 );
--         CNT : IN  std_logic_vector( CNT_WIDTH - 1 downto 0 );
--         O   : OUT std_logic_vector( O_WIDTH - 1 downto 0 )
--       ); -- pragma map_to_resource rotateright
--END;
--
--
--ARCHITECTURE basic OF RotateRight IS
--BEGIN
--A1: ASSERT ( a_width = o_width) 
--    REPORT "Input and output must be the same size";
--
--c1: 
--  process( a, cnt)
--  -- declare both signed and unsigned versions
--  -- of inputs and output so we can use the standard
--  -- packages
--  VARIABLE i : INTEGER;
--  VARIABLE sgncnt : signed( CNT_WIDTH -1 downto 0);
--  BEGIN
--  IF ( cnt_signed) THEN
--    FOR  idx IN CNT_WIDTH-1 DOWNTO 0 LOOP
--      sgncnt(idx) := cnt(idx);
--    END LOOP;
--    i := to_integer( sgncnt);
--  ELSE  
--    i := to_integer('0' & cnt);
--  END IF;
--  
--  IF ( i < 0 ) THEN
--    i := -i;
--    i := i mod a_width;
--    o <=  a ( a_width - 1 - i - 1 downto 0 ) & a( a_width - 1 downto  a_width - 1 - i);
--  ELSIF ( i = 0 ) THEN
--    o <= a;
--  ELSE
--    i := i mod a_width;
--    o <=  a ( i-1 downto 0 ) & a( a_width - 1 downto  i);
--  END IF;
--
--  END PROCESS;
--END;
--
--
--
--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY ShiftLeftArith IS
---- This implements a general n-bit shift
--
--  Generic(  A_WIDTH :  INTEGER := 8;
--            A_SIGNED:  BOOLEAN := false; -- IF TRUE A is signed
--            CNT_WIDTH :  INTEGER := 8;
--            CNT_SIGNED:  BOOLEAN := false; -- If TRUE B is signed
--            O_WIDTH :  INTEGER := 8;
--            O_SIGNED:  BOOLEAN := false -- If TRUE C is signed
--         );
--  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
--         CNT : IN  std_logic_vector( CNT_WIDTH - 1 downto 0);
--         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
--        ); -- pragma map_to_resource shiftleftarith
--END;
--
--ARCHITECTURE basic OF ShiftLeftArith IS
--BEGIN
--A1: ASSERT ( a_width = o_width) 
--    REPORT "Input and output must be the same size";
--
--c1: 
--  process( a, cnt)
--  -- declare both signed and unsigned versions
--  -- of inputs and output so we can use the standard
--  -- packages
--  VARIABLE i : INTEGER;
--  VARIABLE sgncnt : signed( CNT_WIDTH -1 downto 0);
--  VARIABLE tmp : std_logic_vector( A_WIDTH -1 downto 0);
--  BEGIN
--  IF ( cnt_signed) THEN
--    FOR  idx IN CNT_WIDTH-1 DOWNTO 0 LOOP
--      sgncnt(idx) := cnt(idx);
--    END LOOP;
--    i := to_integer( sgncnt);
--  ELSE  
--    i := to_integer('0' & cnt);
--  END IF;
--  
--
--  ASSERT( i >= 0 ) REPORT "must be non-negative values for shift left arithemetic";
--
--  IF ( i = 0 ) THEN
--    o <= a;
--  ELSIF ( i >= a_width) THEN
--    o <= ( others => a(0));
--  ELSE
--    tmp := ( others => a(0)); 
--    tmp( a_width-1 downto a_width -1 - (a_width - 1 - i)) :=
--        a(  a_width -1 - i downto 0);
--
--    o <=  tmp;
--  END IF;
--
--  END PROCESS;
--END;
--
--
--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY ShiftLeftLogical IS
---- This implements a general n-bit rotate
--  Generic(  A_WIDTH :  INTEGER := 8;
--            A_SIGNED:  BOOLEAN := false; -- IF TRUE A is signed
--            CNT_WIDTH :  INTEGER := 8;
--            CNT_SIGNED:  BOOLEAN := false; -- If TRUE B is signed
--            O_WIDTH :  INTEGER := 8;
--            O_SIGNED:  BOOLEAN := false -- If TRUE C is signed
--         );
--  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
--         CNT : IN  std_logic_vector( CNT_WIDTH - 1 downto 0);
--         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
--        ); -- pragma map_to_resource shiftleftlogical
--END;
--
--ARCHITECTURE basic OF ShiftLeftLogical IS
--BEGIN
--A1: ASSERT ( a_width = o_width) 
--    REPORT "Input and output must be the same size";
--
--c1: 
--  process( a, cnt)
--  -- declare both signed and unsigned versions
--  -- of inputs and output so we can use the standard
--  -- packages
--  VARIABLE i : INTEGER;
--  VARIABLE sgncnt : signed( CNT_WIDTH -1 downto 0);
--  VARIABLE tmp : std_logic_vector( A_WIDTH -1 downto 0);
--  BEGIN
--  IF ( cnt_signed) THEN
--    FOR  idx IN CNT_WIDTH-1 DOWNTO 0 LOOP
--      sgncnt(idx) := cnt(idx);
--    END LOOP;
--    i := to_integer( sgncnt);
--  ELSE  
--    i := to_integer('0' & cnt);
--  END IF;
--  
--
--  ASSERT( i >= 0 ) REPORT "must be non-negative values for shift left logical";
--
--  IF ( i = 0 ) THEN
--    o <= a;
--  ELSIF ( i >= a_width) THEN
--    o <= ( others => '0');
--  ELSE
--    tmp := ( others => '0' ) ;
--    tmp( a_width-1 downto a_width -1 - (a_width - 1 - i)) :=
--        a(  a_width -1 - i downto 0);
--
--    o <=  tmp;
--  END IF;
--
--  END PROCESS;
--END;
--
--
--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY ShiftRightArith IS
---- This implements a general n-bit shift
--
--  Generic(  A_WIDTH :  INTEGER := 8;
--            A_SIGNED:  BOOLEAN := false; -- IF TRUE A is signed
--            CNT_WIDTH :  INTEGER := 8;
--            CNT_SIGNED:  BOOLEAN := false; -- If TRUE B is signed
--            O_WIDTH :  INTEGER := 8;
--            O_SIGNED:  BOOLEAN := false -- If TRUE C is signed
--         );
--  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
--         CNT : IN  std_logic_vector( CNT_WIDTH - 1 downto 0);
--         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
--        ); -- pragma map_to_resource shiftrightarith
--END;
--
--ARCHITECTURE basic OF ShiftRightArith IS
--BEGIN
--A1: ASSERT ( a_width = o_width) 
--    REPORT "Input and output must be the same size";
--
--c1: 
--  process( a, cnt)
--  -- declare both signed and unsigned versions
--  -- of inputs and output so we can use the standard
--  -- packages
--  VARIABLE i : INTEGER;
--  VARIABLE sgncnt : signed( CNT_WIDTH -1 downto 0);
--  VARIABLE tmp : std_logic_vector( A_WIDTH -1 downto 0);
--  BEGIN
--  IF ( cnt_signed) THEN
--    FOR  idx IN CNT_WIDTH-1 DOWNTO 0 LOOP
--      sgncnt(idx) := cnt(idx);
--    END LOOP;
--    i := to_integer( sgncnt);
--  ELSE  
--    i := to_integer('0' & cnt);
--  END IF;
--  
--
--  ASSERT( i >= 0 ) REPORT "must be non-negative values for shift right arithemetic";
--
--  IF ( i = 0 ) THEN
--    o <= a;
--  ELSIF ( i >= a_width) THEN
--    o <= ( others => a(a_width-1));
--  ELSE
--    tmp := ( others => a(a_width-1) ) ;
--    tmp(  a_width -1 - i downto 0) :=
--        a( a_width-1 downto a_width -1 - (a_width - 1 - i));
--
--    o <=  tmp;
--  END IF;
--
--  END PROCESS;
--END;
--
--
--
--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--USE work.local_defs.all;
--
--ENTITY ShiftRightLogical IS
--  -- This implements a general n-bit shift
--  GENERIC ( A_WIDTH    : INTEGER := 16;
--            A_SIGNED   : BOOLEAN := false; -- IF TRUE A is signed
--            CNT_WIDTH  : INTEGER := 2;
--            CNT_SIGNED : BOOLEAN := false; -- If TRUE B is signed
--            O_WIDTH    : INTEGER := 16;
--            O_SIGNED   : BOOLEAN := false  -- If TRUE C is signed
--           );
--  PORT ( A   : IN  std_logic_vector( A_WIDTH - 1 downto 0 );
--         CNT : IN  std_logic_vector( CNT_WIDTH - 1 downto 0 );
--         O   : OUT std_logic_vector( O_WIDTH - 1 downto 0 )
--        ); -- pragma map_to_resource shiftrightlogical
--END;
--
--ARCHITECTURE basic OF ShiftRightLogical IS
--BEGIN
--A1:
--  ASSERT ( A_WIDTH = O_WIDTH ) 
--  REPORT "Input and output must be the same size";
--
--C1: 
--  process( A, CNT )
--  -- declare both signed and unsigned versions
--  -- of inputs and output so we can use the standard packages
--    VARIABLE i : INTEGER;
--    VARIABLE sgncnt : signed( CNT_WIDTH -1 downto 0 );
--    VARIABLE j : INTEGER;
--    VARIABLE tmp : std_logic_vector( A_WIDTH - 1 downto 0);
--  BEGIN
--    IF ( CNT_SIGNED ) THEN
--      FOR  idx IN CNT_WIDTH - 1 DOWNTO 0 LOOP
--        sgncnt(idx) := CNT(idx);
--      END LOOP;
--      i := to_integer( sgncnt );
--    ELSE  
--      i := to_integer( '0' & CNT );
--    END IF;
--
--A2:
--    ASSERT( i >= 0 ) 
--    REPORT "must be non-negative values for shift right logical";
--
--    IF ( i = 0 ) THEN
--      O <= A;
--    ELSIF ( i >= A_WIDTH ) THEN
--      O <= ( others => '0' );
--    ELSE
--      tmp := ( others => '0' );
--      tmp( A_WIDTH - 1 - i downto 0 ) :=
--        A( A_WIDTH - 1 downto A_WIDTH - 1 - ( A_WIDTH - 1 - i ) );
--      O <= tmp;
--    END IF;
--  END PROCESS;
--END;



library ieee;
use ieee.std_logic_1164.all;
use work.std_logic_arith.all;
use work.local_defs.all;

entity LOGIC_SHIFTER is
  generic(DEL: TIME := 2 ns;
          DATA_WIDTH: integer := 16);
  port(DATA_IN: in std_logic_vector(DATA_WIDTH - 1 downto 0);
       SR,SL: in std_logic;
       IL,IR: in std_logic;
       DATA_OUT: out std_logic_vector(DATA_WIDTH - 1 downto 0));
end LOGIC_SHIFTER;

architecture BASIC of LOGIC_SHIFTER is
begin
  process(SR,SL,DATA_IN,IL,IR)
    variable CON: std_logic_vector(1 downto 0);
  begin
    CON := SR&SL;
    case CON is
      when "00" => DATA_OUT <= DATA_IN after DEL;
      when "01" => DATA_OUT <= DATA_IN(DATA_WIDTH - 2 downto 0) & IL after DEL;
      when "10" => DATA_OUT <= IR & DATA_IN(DATA_WIDTH - 1 downto 1) after DEL;
      when "11" => DATA_OUT <= DATA_IN after DEL;
      when others => DATA_OUT <= (others => 'X');
    end case;
  end process;
end BASIC;





LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

ENTITY Subtracter IS
  -- This implements a general n-bit+m_bit subtracter 
  -- with borrow in and borrow out
  GENERIC ( A_WIDTH :  INTEGER := 16;
            A_SIGNED:  BOOLEAN := false; -- IF TRUE A is signed
            B_WIDTH :  INTEGER := 16;
            B_SIGNED:  BOOLEAN := false; -- If TRUE B is signed
            O_WIDTH :  INTEGER := 16;
            O_SIGNED:  BOOLEAN := false  -- If TRUE C is signed
           );
  PORT ( A    : IN  std_logic_vector( A_WIDTH - 1 downto 0 );
         B    : IN  std_logic_vector( B_WIDTH - 1 downto 0 );
         O    : OUT std_logic_vector( O_WIDTH - 1 downto 0 );
         BIN  : IN std_logic := '0'; -- default value so we can be unconnected
         BOUT : OUT std_logic
        );  -- pragma map_to_resource subtracter
END;

ARCHITECTURE basic OF Subtracter IS
BEGIN
C1: 
  process( A, B, BIN )
  -- Declare both signed and unsigned versions
  -- of inputs and output so we can use the standard packages
    VARIABLE ubin   : std_logic_vector( O_WIDTH  downto 0 );
    VARIABLE ua     : std_logic_vector( O_WIDTH  downto 0 );
    VARIABLE ub     : std_logic_vector( O_WIDTH  downto 0 );
    VARIABLE result : std_logic_vector( O_WIDTH  downto 0 );
  BEGIN
    ubin := zeroextend( '0' & BIN, O_WIDTH + 1 );
    IF ( A_SIGNED ) THEN
      ua := signextend( A, O_WIDTH + 1 );
    ELSE
      ua := zeroextend( A, O_WIDTH + 1 );
    END IF;

    IF ( B_SIGNED ) THEN
      ub := signextend( B, O_WIDTH + 1 );
    ELSE
      ub := zeroextend( B, O_WIDTH + 1 );
    END IF;

    result := ua - ub - ubin;

    O <= result( O_WIDTH - 1 downto 0);
    BOUT <= result( O_WIDTH );
  END PROCESS;
END;



LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;
USE work.local_defs.all;

entity Uminus IS
-- This implements a general n-bit negate operator borrow out
  GENERIC(  B_WIDTH :  INTEGER := 8;
            B_SIGNED:  BOOLEAN := false; -- If TRUE B is signed
            O_WIDTH :  INTEGER := 8;
            O_SIGNED:  BOOLEAN := false -- If TRUE C is signed
         );
  PORT ( B : IN  std_logic_vector( B_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
        ); -- pragma map_to_resource uminus
END;

ARCHITECTURE basic OF Uminus IS
BEGIN

c1: 
  process(b)
  -- declare both signed and unsigned versions
  -- of inputs and output so we can use the standard
  -- packages
  VARIABLE ub : std_logic_vector( o_width -1  downto 0);
  VARIABLE result : std_logic_vector( o_width -1  downto 0);

  BEGIN
    IF ( b_signed ) THEN
      ub := signextend( b, o_width);
    ELSE
      ub := zeroextend( b, o_width);
    END IF;

    result := "00" - ub;
    o <= result( o_width -1 downto 0);

  END PROCESS;
END;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.std_logic_arith.all;

PACKAGE components IS

COMPONENT Absolute 
-- This implements an absolute function
  Generic(  A_WIDTH :  INTEGER ;
            A_SIGNED:  BOOLEAN ; -- IF TRUE A is signed
            D_WIDTH :  INTEGER ;
            D_SIGNED:  BOOLEAN   -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         D : OUT std_logic_vector( D_WIDTH - 1 downto 0)
        );
END COMPONENT;

COMPONENT Adder 
  -- This implements a general n-bit+m_bit adder with carry in and carry out
  Generic ( A_WIDTH  : INTEGER;
            A_SIGNED : BOOLEAN;  -- IF TRUE A is signed
            B_WIDTH  : INTEGER;
            B_SIGNED : BOOLEAN;  -- If TRUE B is signed
            O_WIDTH  : INTEGER;
            O_SIGNED : BOOLEAN   -- If TRUE C is signed
           );
  PORT ( A    : IN  std_logic_vector( A_WIDTH - 1 downto 0 );
         B    : IN  std_logic_vector( B_WIDTH - 1 downto 0 );
         O    : OUT std_logic_vector( O_WIDTH - 1 downto 0 );
         CIN  : IN  std_logic := '0'; -- default value so we can be unconnected
         COUT : OUT std_logic
        );
END COMPONENT;

COMPONENT AdderSubtracter 
-- This implements a general n-bit+m_bit adder subtracter with
-- borrow/carry in and borow/carry out.
  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            B_WIDTH :  INTEGER;
            B_SIGNED:  BOOLEAN; -- If TRUE B is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         B : IN  std_logic_vector( B_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0);
         CIN : IN std_logic := '0'; -- default value so we can be unconnected
         CNT : IN std_logic := '0'; -- if zero we subtract, 1 we add
         COUT: OUT std_logic
        );
END COMPONENT;

COMPONENT Comparator
-- This implements a general n-bit to m_bit comparator
  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            B_WIDTH :  INTEGER;
            B_SIGNED:  BOOLEAN  -- If TRUE B is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         B : IN  std_logic_vector( B_WIDTH - 1 downto 0);
	 LT : OUT std_logic;
         LTE : OUT std_logic;
         EQ : OUT std_logic;
         NEQ : OUT std_logic;
         GT : OUT std_logic;
         GTE : OUT std_logic
        );
END COMPONENT;

COMPONENT Counter 
-- This implements a general n-bit counter
  Generic(  DIN_WIDTH :  INTEGER;
            DIN_SIGNED:  BOOLEAN; -- IF TRUE DIN is signed
            DOUT_WIDTH :  INTEGER;
            DOUT_SIGNED:  BOOLEAN  -- If TRUE B is signed
         );
  PORT ( DIN : IN  std_logic_vector( DIN_WIDTH - 1 downto 0);
	 SET : IN  std_logic;
	 RESET : IN  std_logic;
         CNT : IN std_logic := '0';
         CLK : IN std_logic := '0';
         DOUT : OUT  std_logic_vector( DOUT_WIDTH - 1 downto 0)
        );
END COMPONENT;

COMPONENT Decoder
-- This implements a general decoder

-- pragma here to tell we are a resource
-- map_to_resource decoder

  Generic(  SEL_WIDTH :  INTEGER;
            DOUT_WIDTH :  INTEGER
         );
  PORT ( SEL : IN  std_logic_vector( SEL_WIDTH - 1 downto 0);
         DOUT: OUT std_logic_vector( 0 to DOUT_WIDTH -1)
        );
END COMPONENT;


COMPONENT Decrementer
-- This implements a general n-bit to m_bit decrementer with barrow out

-- pragma here to tell we are a resource

  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0);
         COUT: OUT std_logic
        );
END COMPONENT;

COMPONENT Decoder_Offset
-- This implements a general decoder that
-- only has DOUT_WIDTH number of outputs and
-- starts at OFFSET and goes to OFFSET+DOUT_WIDTH-1
-- used for arrays with non-zero bounds.

-- pragma here to tell we are a resource
-- map_to_resource decoder

  Generic(  SEL_WIDTH :  INTEGER;
            DOUT_WIDTH :  INTEGER;
	    OFFSET     :  INTEGER
         );
  PORT ( SEL : IN  std_logic_vector( SEL_WIDTH - 1 downto 0);
         DOUT: OUT std_logic_vector( 0 to DOUT_WIDTH -1)
        );
END COMPONENT;

COMPONENT divider 
-- This implements a general n-bit and m_bit divider


-- pragma here to tell we are a resource

  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            B_WIDTH :  INTEGER;
            B_SIGNED:  BOOLEAN; -- If TRUE B is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         B : IN  std_logic_vector( B_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
        );
END COMPONENT;

COMPONENT exponent 
-- This implements a general n-bit to  m-bit power


-- pragma here to tell we are a resource

  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            B_WIDTH :  INTEGER;
            B_SIGNED:  BOOLEAN; -- If TRUE B is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         B : IN  std_logic_vector( B_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
        );
END COMPONENT;

COMPONENT IncDec
-- This implements a general n-bit to m_bit incremeneter/decrementer with carry out

-- pragma here to tell we are a resource

  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         CNT : IN std_logic := '0'; -- 1 increment, 0 decrement
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0);
         COUT: OUT std_logic
        );
END COMPONENT;

COMPONENT Incrementer
-- This implements a general n-bit to m_bit incremeneter with carry out

-- pragma here to tell we are a resource

  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0);
         COUT: OUT std_logic
        );
END COMPONENT;


COMPONENT Latch
  PORT ( din : IN std_logic;
         set : IN std_logic := '0';
         reset: IN std_logic := '0';
         clk : IN std_logic;
         dout : OUT std_logic
       );
END COMPONENT;

COMPONENT Latch_vec 
  Generic(  DIN_WIDTH :  INTEGER;
            SET_WIDTH :  INTEGER;
            RESET_WIDTH :  INTEGER;
            DOUT_WIDTH :  INTEGER
         );

  PORT ( din : IN std_logic_vector ( DIN_WIDTH - 1 downto 0);
         set : IN std_logic_vector( SET_WIDTH -1 downto 0) := ( others =>'0');
         reset: IN std_logic_vector( RESET_WIDTH -1 downto 0) := ( others =>'0');
         clk : IN std_logic;
         dout : OUT std_logic_vector( DOUT_WIDTH -1 downto 0)
       );
END COMPONENT;

COMPONENT Modulus
-- This implements a general n-bit and m_bit divider


-- pragma here to tell we are a resource

  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            B_WIDTH :  INTEGER;
            B_SIGNED:  BOOLEAN; -- If TRUE B is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         B : IN  std_logic_vector( B_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
        );
END COMPONENT;

COMPONENT Multiplexer
-- This implements a general multiplexer
-- carry out.

-- pragma here to tell we are a resource
-- map_to_resource Adder

  Generic(  INPUT_WIDTH :  INTEGER;
            SEL_WIDTH :  INTEGER
         );
  PORT ( INPUT : IN  std_logic_vector( 0 TO INPUT_WIDTH - 1);
         SEL : IN  std_logic_vector( SEL_WIDTH - 1 downto 0);
         DOUT: OUT std_logic
        );
END COMPONENT;

COMPONENT Multiplexer_vec 
-- This implements a general multiplexer

-- pragma here to tell we are a resource
-- map_to_resource multiplexer

  Generic(  INPUT_WIDTH :  INTEGER;
            SEL_WIDTH :  INTEGER;
            DOUT_WIDTH :  INTEGER
         );
  PORT ( INPUT : IN  std_logic_vector( 0 TO INPUT_WIDTH - 1);
         SEL : IN  std_logic_vector( SEL_WIDTH - 1 downto 0);
         DOUT: OUT std_logic_vector ( 0 TO DOUT_WIDTH - 1)
        );
END COMPONENT;

COMPONENT Multiplexer1hot
-- This implements a general 1 hot multiplexer or selector
-- carry out.

-- pragma here to tell we are a resource
-- map_to_resource Adder

  Generic(  INPUT_WIDTH :  INTEGER;
            SEL_WIDTH :  INTEGER
         );
  PORT ( INPUT : IN  std_logic_vector( INPUT_WIDTH - 1 downto 0);
         SEL : IN  std_logic_vector( SEL_WIDTH - 1 downto 0);
         DOUT: OUT std_logic
        );
END COMPONENT;

COMPONENT Multiplexer1hot_vec
-- This implements a general 1 hot multiplexer or selector
-- carry out.

-- pragma here to tell we are a resource
-- map_to_resource Adder

  Generic(  INPUT_WIDTH :  INTEGER;
            SEL_WIDTH :  INTEGER;
	    DOUT_WIDTH : INTEGER
         );
  PORT ( INPUT : IN  std_logic_vector( INPUT_WIDTH - 1 downto 0);
         SEL : IN  std_logic_vector( SEL_WIDTH - 1 downto 0);
         DOUT: OUT std_logic_vector( DOUT_WIDTH-1 downto 0)
        );
END COMPONENT;

COMPONENT Multiplier
-- This implements a general n-bit and m_bit multipiler


-- pragma here to tell we are a resource

  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            B_WIDTH :  INTEGER;
            B_SIGNED:  BOOLEAN; -- If TRUE B is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         B : IN  std_logic_vector( B_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
        );
END COMPONENT;


COMPONENT Reg
  PORT ( din : IN std_logic;
         set : IN std_logic := '0';
         reset: IN std_logic := '0';
         clk : IN std_logic;
         dout : OUT std_logic
       );
END COMPONENT;

COMPONENT Reg_vec 
  Generic(  DIN_WIDTH :  INTEGER;
            SET_WIDTH :  INTEGER;
            RESET_WIDTH :  INTEGER;
            DOUT_WIDTH :  INTEGER
         );

  PORT ( din : IN std_logic_vector ( DIN_WIDTH - 1 downto 0);
         set : IN std_logic_vector( SET_WIDTH -1 downto 0) := ( others =>'0');
         reset: IN std_logic_vector( RESET_WIDTH -1 downto 0) := ( others =>'0');
         clk : IN std_logic;
         dout : OUT std_logic_vector( DOUT_WIDTH -1 downto 0)
       );
END COMPONENT;

COMPONENT Remainder
-- This implements a general n-bit and m_bit remainder


-- pragma here to tell we are a resource

  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            B_WIDTH :  INTEGER;
            B_SIGNED:  BOOLEAN; -- If TRUE B is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         B : IN  std_logic_vector( B_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
        );
END COMPONENT;

COMPONENT RotateRight
-- This implements a general n-bit rotate


-- pragma here to tell we are a resource

  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            CNT_WIDTH :  INTEGER;
            CNT_SIGNED:  BOOLEAN; -- If TRUE B is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         CNT : IN  std_logic_vector( CNT_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
        );
END COMPONENT;

COMPONENT RotateLeft
-- This implements a general n-bit rotate


-- pragma here to tell we are a resource

  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            CNT_WIDTH :  INTEGER;
            CNT_SIGNED:  BOOLEAN; -- If TRUE B is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         CNT : IN  std_logic_vector( CNT_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
        );
END COMPONENT;

COMPONENT ShiftLeftArith
-- This implements a general n-bit shifter


-- pragma here to tell we are a resource

  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            CNT_WIDTH :  INTEGER;
            CNT_SIGNED:  BOOLEAN; -- If TRUE B is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         CNT : IN  std_logic_vector( CNT_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
        );
END COMPONENT;

COMPONENT ShiftLeftLogical
-- This implements a general n-bit shifter


-- pragma here to tell we are a resource

  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            CNT_WIDTH :  INTEGER;
            CNT_SIGNED:  BOOLEAN; -- If TRUE B is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         CNT : IN  std_logic_vector( CNT_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
        );
END COMPONENT;

COMPONENT ShiftRightArith
-- This implements a general n-bit shifter


-- pragma here to tell we are a resource

  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            CNT_WIDTH :  INTEGER;
            CNT_SIGNED:  BOOLEAN; -- If TRUE B is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         CNT : IN  std_logic_vector( CNT_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
        );
END COMPONENT;

COMPONENT ShiftRightLogical
-- This implements a general n-bit shifter


-- pragma here to tell we are a resource

  Generic(  A_WIDTH :  INTEGER;
            A_SIGNED:  BOOLEAN; -- IF TRUE A is signed
            CNT_WIDTH :  INTEGER;
            CNT_SIGNED:  BOOLEAN; -- If TRUE B is signed
            O_WIDTH :  INTEGER;
            O_SIGNED:  BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         CNT : IN  std_logic_vector( CNT_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
        );
END COMPONENT;

COMPONENT Subtracter
  -- This implements a general n-bit+m_bit subtracter 
  -- with borrow in and borrow out
  Generic(  A_WIDTH  : INTEGER;
            A_SIGNED : BOOLEAN; -- IF TRUE A is signed
            B_WIDTH  : INTEGER;
            B_SIGNED : BOOLEAN; -- If TRUE B is signed
            O_WIDTH  : INTEGER;
            O_SIGNED : BOOLEAN  -- If TRUE C is signed
         );
  PORT ( A    : IN  std_logic_vector( A_WIDTH - 1 downto 0);
         B    : IN  std_logic_vector( B_WIDTH - 1 downto 0);
         O    : OUT std_logic_vector( O_WIDTH - 1 downto 0);
         BIN  : IN  std_logic := '0'; -- default value so we can be unconnected
         BOUT : OUT std_logic
        );
END COMPONENT;

COMPONENT Uminus 
  -- This implements a general n-bit negate operator borrow out
  -- pragma here to tell we are a resource
  GENERIC(  B_WIDTH  :  INTEGER;
            B_SIGNED :  BOOLEAN; -- If TRUE B is signed
            O_WIDTH  :  INTEGER;
            O_SIGNED :  BOOLEAN  -- If TRUE C is signed
          );
  PORT ( B : IN  std_logic_vector( B_WIDTH - 1 downto 0);
         O : OUT std_logic_vector( O_WIDTH - 1 downto 0)
        );
END COMPONENT;


COMPONENT  XnorGate
  GENERIC ( input_width : integer);
  PORT ( input : std_logic_vector( input_width -1 downto 0);
                              -- all gate input are in one vector to
                                 -- allow for telescoping gates
         output : OUT std_logic); -- not output is only
END COMPONENT;

COMPONENT  XorGate 
  GENERIC ( input_width : integer);
  PORT ( input : std_logic_vector( input_width -1 downto 0);
                              -- all gate inputs are in one vector to
                                 -- allow for telescoping gates
         output : OUT std_logic); -- not output is only
END COMPONENT;

COMPONENT  OrGate
  GENERIC ( input_width : integer);
  PORT ( input : std_logic_vector( input_width -1 downto 0);
                              -- all gate inputs are in one vector to
                                 -- allow for telescoping gates
         output : OUT std_logic); -- not output is only
END COMPONENT;

COMPONENT  NorGate
  GENERIC ( input_width : integer);
  PORT ( input : std_logic_vector( input_width -1 downto 0);
                              -- all gate inputs are in one vector to
                                 -- allow for telescoping gates
         output : OUT std_logic); -- not output is only
END COMPONENT;

COMPONENT  NandGate
  GENERIC ( input_width : integer);
  PORT ( input : std_logic_vector( input_width -1 downto 0);
                              -- all gate inputs are in one vector to
                                 -- allow for telescoping gates
         output : OUT std_logic); -- not output is only
END COMPONENT;

COMPONENT  AndGate
  GENERIC ( input_width : integer);
  PORT ( input : std_logic_vector( input_width -1 downto 0);
                              -- all gate inputs are in one vector to
                                 -- allow for telescoping gates
         output : OUT std_logic); -- not output is only
END COMPONENT;

COMPONENT  BufferGate
  PORT ( input : std_logic;
         output : OUT std_logic); -- output is only
END COMPONENT;

COMPONENT  Tristate
  PORT ( input : std_logic;
         en    : std_logic;
         output : OUT std_logic); -- output is only
END COMPONENT;



COMPONENT  Inverter
  PORT ( input : std_logic;
         output : OUT std_logic); -- output is only
END COMPONENT;

END;




--LIBRARY ieee;
--LIBRARY work;
--USE work.components.all;
--USE ieee.std_logic_1164.all;
--USE work.std_logic_arith.all;
--
--entity testbench is
--end;
--
--architecture a of testbench is
-- signal a, b: std_logic_vector(3 downto 0);
-- signal r1,r2  : std_logic_vector( 4 downto 0);
-- signal cin : std_logic;
-- signal cout1, cout2 : std_logic;
--for all:Adder USE entity work.adder;
--begin
--c1: Adder
--     generic map ( a_width => a'length,
--	           a_signed => FALSE,
--                   b_width => b'length,
--	           b_signed => FALSE,
--        	   o_width => r1'length,
--	           o_signed => FALSE)
--     port map ( a, b, r1, cin, cout1);
--c2: Adder
--     generic map ( a_width => a'length,
--	           a_signed => TRUE,
--                   b_width => b'length,
--	           b_signed => TRUE,
--        	   o_width => r2'length,
--	           o_signed => TRUE)
--     port map ( a, b, r2, cin, cout2);
--
--gen: process
--     begin
--     l1 : for i1 in 0 to 15 loop
--             a <= to_stdlogicvector(i1,4);
--     l2 :    for i2 in 0 to 15 loop
--               b <= to_stdlogicvector(i2,4);
--               cin <= '0';
--               wait for 10 ns;
--               cin <= '1';
--               wait for 10 ns;
--             end loop;
--          end loop;
--     end process;
--
--end;
