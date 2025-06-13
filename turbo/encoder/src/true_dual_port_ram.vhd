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

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity true_dual_port_ram is
  generic(
    DATA_WIDTH: positive := 1;
    ADDR_WIDTH: positive := 13
  );
  port(
    clka : in std_logic;
    clkb : in std_logic;
    wren_a : in std_logic;
    wren_b : in std_logic;
    addr_a : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    addr_b : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    din_a : in std_logic_vector(DATA_WIDTH-1 downto 0);
    din_b : in std_logic_vector(DATA_WIDTH-1 downto 0);
    dout_a : out std_logic_vector(DATA_WIDTH-1 downto 0);
    dout_b : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end true_dual_port_ram;

architecture rtl of true_dual_port_ram is
  type ram_type is array ((2**ADDR_WIDTH) -1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
  shared variable RAM : ram_type;

begin

  process(CLKA) begin
    if rising_edge(clka) then
      dout_a <= RAM(to_integer(unsigned(addr_a)));
      if wren_a = '1' then
        RAM(to_integer(unsigned(addr_a))) := din_a;
      end if;
    end if;
  end process;

  process(CLKB) begin
    if rising_edge(clkb) then
      dout_b <= RAM(to_integer(unsigned(addr_b)));
      if wren_b = '1' then
        RAM(to_integer(unsigned(addr_b))) := din_b;
      end if;
    end if;
  end process;

end rtl;