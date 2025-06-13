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
-- LTE TURBO INTERLEAVER
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity turbo_interleaver is
  Port (
    clk: in std_logic;
    rst: in std_logic;

    start: in std_logic;
    block_size: in unsigned(12 downto 0);

    parity0_addr: out unsigned(12 downto 0);
    parity1_addr: out unsigned(12 downto 0);
    parity_addr_valid: out std_logic
  );
end turbo_interleaver;

architecture Behavioral of turbo_interleaver is
  type inter_fsm_t  is (IDLE, ROM_LAT_1, LOAD_BLOCK_SIZE, INTER);
  signal inter_fsm: inter_fsm_t;

  signal block_size_reg : integer range 0 to 7000;

  signal pi, dpi: integer range 0 to 7000;
  signal pi_valid: std_logic;

  signal out_cnt: integer range 0 to 7000;
  
  signal f1f2_u, f2_u: unsigned(9 downto 0);
  signal f1f2, f2: integer range 0 to 1023;
  
begin

  process(clk)
    variable pi_v, dpi_v: integer range 0 to 7000;
  begin
    if rising_edge(clk) then
      case inter_fsm is
        when IDLE =>
          out_cnt <= 0;
          pi_valid <= '0';
          if start then
            block_size_reg <= to_integer(block_size);
            inter_fsm <= ROM_LAT_1;
          end if;
        
        when ROM_LAT_1 =>
          inter_fsm <= LOAD_BLOCK_SIZE;

        when LOAD_BLOCK_SIZE =>
          pi_v := 0;
          dpi_v := f1f2;
          pi_valid <= '1';
          inter_fsm <= INTER;

        when INTER =>
          pi_valid <= '1';
          pi_v := pi + dpi;
          if pi_v >= block_size_reg then
            pi_v := pi_v - block_size_reg;
          end if;

          dpi_v := dpi + 2*f2;
          if dpi_v >= block_size_reg then
            dpi_v := dpi_v - block_size_reg;
          end if;

          out_cnt <= out_cnt +1;
          if out_cnt = block_size_reg -1 then
            pi_valid <= '0';
            inter_fsm <= IDLE;
          end if;

      end case;

      pi <= pi_v;
      dpi <= dpi_v;


      if rst then
        inter_fsm <= IDLE;
        pi_valid <= '0';
        out_cnt <= 0;
      end if;

    end if;
  end process;

  parity0_addr <= to_unsigned(out_cnt, parity0_addr'length);
  parity1_addr <= to_unsigned(pi, parity1_addr'length);
  parity_addr_valid <= pi_valid;

  block_param_rom_inst : entity work.turbo_block_param_rom
  port map (
    clk => clk,
    block_size => to_unsigned(block_size_reg, 13),
    f1f2_o => f1f2_u,
    f2_o => f2_u
  );

  f1f2 <= to_integer(f1f2_u);
  f2   <= to_integer(f2_u);

end Behavioral;