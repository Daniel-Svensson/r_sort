-- AND gate primitive
entity AND2 is
  generic(DEL: TIME := 2 ns);
  port(I1,I2: in BIT; O: out BIT);
end AND2;

architecture DF of AND2 is
begin
  O <= I1 and I2 after DEL;
end DF;


-- Buffer primitive
entity BUF is
  generic(DATA_DEL, Z_DEL: TIME := 2 ns);
  port(I,EN: in BIT; O: out BIT);
end BUF;

architecture ALG of BUF is
begin
  process(I,EN)
  begin
    if EN = '1' then
      O <= I after DATA_DEL;
    else
      O <=  '1' after Z_DEL;
    end if;
  end process;
end ALG;


-- Full adder primitive
entity FULL_ADDER is
  generic(SUM_DEL,CARRY_DEL:TIME := 2 ns);
  port(A,B,CI: in BIT; SUM,COUT: out BIT);
end FULL_ADDER;

architecture DF of FULL_ADDER is
begin
  SUM <= A xor B xor CI after SUM_DEL;
  COUT <= (A and B) or (A and CI) or (B and CI)
          after CARRY_DEL;
end DF;


-- Multiplexer primitive
entity FOUR_TO_1_MUX is
  generic(DEL: TIME := 2 ns);
  port(IN0,IN1,IN2,IN3: in BIT_VECTOR(3 downto 0);
       SEL: in BIT_VECTOR(1 downto 0);
       O: out BIT_VECTOR(3 downto 0));
end FOUR_TO_1_MUX;

architecture DF of FOUR_TO_1_MUX is
begin
  O <= IN0 after DEL when SEL = "00" else
       IN1 after DEL when SEL = "01" else
       IN2 after DEL when SEL = "10" else
       IN3 after DEL;
end DF;


-- Decoder primitive
entity TWO_TO_4_DEC is
  generic(DEL: TIME := 2 ns);
  port(I: in  BIT_VECTOR(1 downto 0);
       O: out BIT_VECTOR(3 downto 0));
end TWO_TO_4_DEC;

architecture ALG of TWO_TO_4_DEC is
begin
  process(I)
  begin
    case I is
      when "00" => O<= "0001" after DEL;
      when "01" => O<= "0010" after DEL;
      when "10" => O<= "0100" after DEL;
      when "11" => O<= "1000" after DEL;
    end case;
  end process;
end ALG;


-- Encoder primitive
entity FOUR_TO_2_ENC is
  generic(DEL: TIME := 2 ns);
  port(I: in  BIT_VECTOR(3 downto 0);
       O: out BIT_VECTOR(1 downto 0));
end FOUR_TO_2_ENC;

architecture DF of FOUR_TO_2_ENC is
begin
  O <= "00" after DEL when I(0) = '1' else
       "01" after DEL when I(1) = '1' else
       "10" after DEL when I(2) = '1' else
       "11" after DEL;
end DF;


-- Shifter primitive
entity SHIFTER is
  generic(DEL: TIME := 2 ns);
  port(DATA_IN: in BIT_VECTOR(3 downto 0);
       SR,SL: in BIT; IL,IR: in BIT;
       DATA_OUT: out BIT_VECTOR(3 downto 0));
end SHIFTER;

architecture  ALG of SHIFTER is
begin
  process(SR,SL,DATA_IN,IL,IR)
    variable CON: BIT_VECTOR(0 to 1);
  begin
    CON := SR&SL;
    case CON is
      when "00" => DATA_OUT <= DATA_IN after DEL;
      when "01" => DATA_OUT <= DATA_IN(2 downto 0) & IL
                   after DEL;
      when "10" => DATA_OUT <= IR & DATA_IN(3 downto 1)
                   after DEL;
      when "11" => DATA_OUT <= DATA_IN after DEL;
    end case;
  end process;
end ALG;



-- Data operations package
package PRIMS is
  procedure ADD(A,B: in BIT_VECTOR; CIN: in BIT;
                SUM: out BIT_VECTOR; COUT: out BIT);
  function INC(X : BIT_VECTOR) return BIT_VECTOR;
  function DEC(X : BIT_VECTOR) return BIT_VECTOR;
  function INTVAL(VAL : BIT_VECTOR) return INTEGER;
end PRIMS;

package body PRIMS is
  procedure ADD(A,B: in BIT_VECTOR; CIN: in BIT;
                SUM: out BIT_VECTOR; COUT: out BIT) is
    variable SUMV,AV,BV: BIT_VECTOR(A'LENGTH-1 downto 0);
    variable CARRY: BIT;
  begin
    AV := A;
    BV := B;
    CARRY := CIN;
    for I in 0 to SUMV'HIGH loop
      SUMV(I) := AV(I) xor BV(I) xor CARRY;
      CARRY := (AV(I) and BV(I)) or (AV(I) and CARRY)
                or (BV(i) and CARRY);
    end loop;
    COUT := CARRY;
    SUM := SUMV;
  end ADD;

  function INC(X : BIT_VECTOR) return BIT_VECTOR is
    variable XV: BIT_VECTOR(X'LENGTH-1 downto 0);
  begin
    XV := X;
    for I in 0 to XV'HIGH loop
      if XV(I) = '0' then
        XV(I) := '1';
        exit;
      else XV(I) := '0';
      end if;
    end loop;
    return XV;
  end INC;


  function DEC(X : BIT_VECTOR) return BIT_VECTOR is
    variable XV: BIT_VECTOR(X'LENGTH-1 downto 0);
  begin
    XV := X;
    for I in 0 to XV'HIGH loop
      if XV(I) = '1' then
        XV(I) := '0';
        exit;
      else XV(I) := '1';
      end if;
    end loop;
    return XV;
  end DEC;

  function INTVAL ( VAL: BIT_VECTOR) return INTEGER is
    variable VALV: BIT_VECTOR(VAL'LENGTH - 1 downto 0);
    variable SUM: INTEGER := 0;
  begin
    VALV := VAL;
    for N in VALV'LOW to VALV'HIGH loop
      if VALV(N) = '1' then
        SUM := SUM + (2**N);
      end if;
    end loop;
    return SUM;
  end INTVAL;

end PRIMS;


-- ALU primitive
use work.PRIMS.all;
entity ALU is
  generic(DEL: TIME := 2 ns);
  port(A,B: in BIT_VECTOR(3 downto 0); CI: in BIT;
       FSEL: in BIT_VECTOR(1 downto 0);
       F: out BIT_VECTOR(3 downto 0); COUT: out BIT);
end ALU;

architecture ALG of ALU is
begin
  process(A,B,CI,FSEL)
    variable  FV: BIT_VECTOR(3 downto 0);
    variable COUTV: BIT;
  begin
    case FSEL is
      when "00" => F <= A after DEL;
      when "01" => F <= not(A) after DEL;
      when "10" => ADD(A,B,CI,FV,COUTV);
                   F <= FV after DEL;
                   COUT <= COUTV after DEL;
      when "11" => F <= A and B after DEL;
    end case;
  end process;
end ALG;



-- Register model
entity REG is
  generic(DEL: TIME := 2 ns);
  port(RESET,LOAD,CLK: in BIT;
       DATA_IN: in BIT_VECTOR(3 downto 0);
       Q: inout BIT_VECTOR(3 downto 0));
end REG;

architecture DF of REG is
begin
  REG: block(not CLK'STABLE and CLK ='1')
  begin
    Q <= guarded "0000" after DEL when RESET ='1' else
         DATA_IN after DEL when LOAD ='1' else
         Q;
  end block REG;
end DF;


-- Latch primitive
entity LATCH is
  generic(LATCH_DEL:TIME := 2 ns);
  port(D: in BIT_VECTOR(7 downto 0);
       CLK: in BIT; LOUT: out BIT_VECTOR(7 downto 0));
end LATCH;

architecture DFLOW of LATCH is
begin
  LATCH: block(CLK = '1')
  begin
    LOUT <= guarded D after LATCH_DEL;
  end block LATCH;
end DFLOW;


-- Shift register primitive
entity SHIFTREG is
  generic(DEL: TIME := 2 ns);
  port(DATA_IN: in BIT_VECTOR(3 downto 0);
       CLK,LOAD,SR,SL: in BIT; IL,IR: in BIT;
       Q: inout BIT_VECTOR(3 downto 0));
end SHIFTREG;

architecture  DF of SHIFTREG is
begin
  SH:block(not CLK'STABLE and CLK ='1')
  begin
    Q <= guarded DATA_IN after DEL when LOAD= '1' else
    Q(2 downto 0) & IL after DEL when SL='1' and SR='0' else
    IR & Q(3 downto 1) after DEL when SL='0' and SR='1' else
    Q;
  end block SH;
end DF;


-- Counter primitive
use work.PRIMS.all;
entity COUNTER is
  generic(DEL:TIME := 2 ns);
  port(RESET,LOAD,COUNT,UP,CLK: in BIT;
       DATA_IN: in BIT_VECTOR(3 downto 0);
       CNT: inout BIT_VECTOR(3 downto 0));
end COUNTER;

architecture ALG of COUNTER is
begin
  process(CLK)
  begin
    if CLK = '1' then
      if RESET = '1' then
        CNT <= "0000" after DEL;
      elsif LOAD ='1' then
        CNT <= DATA_IN after DEL;
      elsif COUNT ='1' then
        if UP = '1' then
          CNT <= INC(CNT) after DEL;
        else
          CNT <= DEC(CNT) after DEL;
        end if;
      end if;
    end if;
  end process;
end ALG;


-- RAM primitive
use work.PRIMS.all;
entity RAM is
  generic (RDEL,DISDEL: TIME := 2 ns);
  port (DATA: inout BIT_VECTOR(3 downto 0);
        ADDRESS: in BIT_VECTOR(4 downto 0);
        RD,WR,NCS: in BIT);
end RAM;

architecture SIMPLE of RAM is
  type MEMORY is array(0 to 31) of BIT_VECTOR(3 downto 0);
begin
  process(RD,WR,NCS,ADDRESS,DATA)
    variable MEM: MEMORY;
  begin
    if NCS='0' then
      if RD='1' then
        DATA <= MEM(INTVAL(ADDRESS)) after RDEL;
      elsif WR='1'then
        MEM(INTVAL(ADDRESS)) := DATA;
      end if;
    else
      DATA <= "1111" after DISDEL;
    end if;
  end process;
end SIMPLE;
