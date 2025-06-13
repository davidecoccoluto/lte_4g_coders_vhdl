-- MIT License
-- Copyright (c) 2025 davidecoccoluto
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.library IEEE;
----------------------------------------------------------------------------------
-- LTE TURBO TRELLIS TERMINATION
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity turbo_trellis_termination is
  Port (
    clk          : in std_logic;
    rst          : in std_logic;

    din          : in std_logic_vector(3 downto 0);
    din_valid    : in std_logic;
    din_ready    : out std_logic;
    din_last     : in std_logic;

    dout         : out std_logic_vector(2 downto 0);
    dout_valid   : out std_logic;
    dout_last    : out std_logic
   );
end turbo_trellis_termination;

architecture rtl of turbo_trellis_termination is

  type din_shift_reg_t is array (2 downto 0) of std_logic_vector(3 downto 0);
  signal din_shift_reg: din_shift_reg_t;

  signal valid_shift_reg: std_logic_vector(2 downto 0);
  signal last_shift_reg: std_logic_vector(2 downto 0);

  type trellis_fsm_t is (SHIFTING, TRELLIS0,TRELLIS1,TRELLIS2,TRELLIS3, CLEANUP);
  signal trellis_fsm: trellis_fsm_t;


begin

  process(clk) begin
    if rising_edge(clk) then
      dout_valid <= '0';
      dout_last  <= '0';
      case trellis_fsm is
        when SHIFTING =>
          if din_valid then
            din_ready <= '0';
            valid_shift_reg       <= valid_shift_reg(1 downto 0)        & din_valid;
            last_shift_reg        <= last_shift_reg(1 downto 0)         & din_last;
            din_shift_reg         <= din_shift_reg(1 downto 0)          & din;

            dout <= din_shift_reg(2)(3) & din_shift_reg(2)(2) & din_shift_reg(2)(0); 
            dout_valid <= valid_shift_reg(2);

            if din_last then
              trellis_fsm <= TRELLIS0;
            end if;
          end if;

        when TRELLIS0 =>
          trellis_fsm <= TRELLIS1;
          dout_valid <= '1';
          dout <= din_shift_reg(2)(3) & din_shift_reg(2)(2) & din_shift_reg(1)(3);   --  (X),   (Z),  (X+1) 

        when TRELLIS1 =>
          trellis_fsm <= TRELLIS2;
          dout_valid <= '1';
          dout <= din_shift_reg(1)(2) & din_shift_reg(0)(3) & din_shift_reg(0)(2);   --  (Z+1),   (X+2),  (Z+2) 

        when TRELLIS2 =>
          trellis_fsm <= TRELLIS3;
          dout_valid <= '1';
          dout <= din_shift_reg(2)(1) & din_shift_reg(2)(0) & din_shift_reg(1)(1);   --  (X'),   (Z'),  (X'+1)

        when TRELLIS3 =>
          trellis_fsm <= CLEANUP;
          dout_valid <= '1';
          dout_last  <= '1';
          dout <= din_shift_reg(1)(0) & din_shift_reg(0)(1) & din_shift_reg(0)(0);   --  (Z'+1),   (X'+2),  (Z'+2)

        when CLEANUP =>
          valid_shift_reg        <= (others => '0');
          last_shift_reg         <= (others => '0');
          din_shift_reg          <= (others => (others => '0'));
          trellis_fsm <= SHIFTING;
          din_ready <= '1';
      end case;


      if rst then
        trellis_fsm <= CLEANUP;
      end if;

    end if;
  end process;

end rtl;
