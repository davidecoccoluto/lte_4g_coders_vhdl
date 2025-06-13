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
-- LTE TURBO CONSTITUENT ENCODER
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity turbo_constituent_encoder is
  Port (
    clk: in std_logic;
    rst: in std_logic;

    ce_i: in std_logic;
    
    termination_i: in std_logic;
    din_i: in std_logic;

    sys_dout_o : out std_logic;
    parity_dout_o: out std_logic
    

  );
end turbo_constituent_encoder;

architecture Behavioral of turbo_constituent_encoder is

  signal xor_s: std_logic_vector(3 downto 0);
  signal reg_r: std_logic_vector(2 downto 0);
  signal tmp: std_logic;

begin

  process(clk) begin
    if rising_edge(clk) then
      if ce_i then
        reg_r(2) <= reg_r(1);
        reg_r(1) <= reg_r(0);
        reg_r(0) <= xor_s(0);
      end if;

      if rst then
        reg_r <= "000";
      end if;
    end if;
  end process;

  process(all) begin
    if termination_i then
      tmp <= xor_s(2); 
    else
      tmp <= din_i;
    end if;
  end process;

  xor_s(0) <= (tmp xor xor_s(2));
  xor_s(1) <= xor_s(0) xor reg_r(0);
  xor_s(2) <= reg_r(1) xor reg_r(2);
  xor_s(3) <= xor_s(1) xor reg_r(2);
  parity_dout_o <= xor_s(3);
  sys_dout_o  <= tmp;

end Behavioral;
