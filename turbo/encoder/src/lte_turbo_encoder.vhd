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
-- LTE TURBO ENCODER TOP
----------------------------------------------------------------------------------

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lte_turbo_encoder is
  Port (
    clk          : in  std_logic;
    rst          : in  std_logic;

    din          : in  std_logic;
    din_valid    : in  std_logic;
    din_ready    : out std_logic;
    din_last     : in  std_logic;

    dout         : out std_logic_vector(2 downto 0);
    dout_valid   : out std_logic;
    dout_last    : out std_logic

   );
end lte_turbo_encoder;

architecture Behavioral of lte_turbo_encoder is

  type wr_mem_fsm_t is (WR_RAM0,WR_RAM1);
  signal wr_fsm: wr_mem_fsm_t;
  type rd_mem_fsm_t is (WAIT_RAM0, READ_RAM0, COOLDOWN_RAM0, WAIT_RAM1, READ_RAM1, COOLDOWN_RAM1);
  signal rd_fsm: rd_mem_fsm_t;

  signal in_bit_cnt         : integer;
  signal cooldown_cnt       : integer range 0 to 3;
  signal out_bit_cnt        : integer range 0 to 7000;
  signal block_size         : integer range 0 to 7000;
  signal block_size0        : integer range 0 to 7000;
  signal block_size1        : integer range 0 to 7000;

  signal inter_start                     : std_logic;
  signal parity_addr_valid               : std_logic;
  signal parity0_addr, parity1_addr      : unsigned(12 downto 0);
  signal constituent_encoder_0_din       : std_logic;
  signal constituent_encoder_1_din       : std_logic;

  signal ram0_busy          : std_logic;
  signal set_ram0_busy      : std_logic;
  signal reset_ram0_busy    : std_logic;
  signal ram1_busy          : std_logic;
  signal set_ram1_busy      : std_logic;
  signal reset_ram1_busy    : std_logic;

  signal ram0_wren_a        : std_logic;
  signal ram0_wren_b        : std_logic;
  signal ram0_addr_a        : std_logic_vector(12 downto 0);
  signal ram0_addr_b        : std_logic_vector(12 downto 0);
  signal ram0_din_a         : std_logic;
  signal ram0_din_b         : std_logic;
  signal ram0_dout_a        : std_logic;
  signal ram0_dout_b        : std_logic;
  signal ram1_wren_a        : std_logic;
  signal ram1_wren_b        : std_logic;
  signal ram1_addr_a        : std_logic_vector(12 downto 0);
  signal ram1_addr_b        : std_logic_vector(12 downto 0);
  signal ram1_din_a         : std_logic;
  signal ram1_din_b         : std_logic;
  signal ram1_dout_a        : std_logic;
  signal ram1_dout_b        : std_logic;

  signal termination        : std_logic := '0';

  signal enc_din_last       : std_logic;
  signal enc_din_valid      : std_logic;

  signal trellis_din        : std_logic_vector(3 downto 0);
  signal trellis_din_valid  : std_logic;
  signal trellis_din_last   : std_logic;
  signal trellis_din_ready  : std_logic;

begin

  -- Input is ready to accept new data the writing FSM
  -- is waiting to write on a ram that is able to accept new data
  din_ready <= '1' when (wr_fsm = WR_RAM0 and ram0_busy = '0') else 
               '1' when (wr_fsm = WR_RAM1 and ram1_busy = '0') else
               '0';
  
 \*
  * WR_FSM_PROC
  * --------------------------- 
  * writes the input bits buffers
  * starting from the ram0 and following on the ram1 with ping-pong
  * approach. When a block is written into a ram, the flag "ram_busy" is set
  *\ 
  wr_fsm_proc: process(clk) begin
    if rising_edge(clk) then
      set_ram0_busy <= '0';
      set_ram1_busy <= '0';
      case wr_fsm is
        when WR_RAM0 =>
          if din_valid and (not ram0_busy) then
            in_bit_cnt <= in_bit_cnt + 1;
          end if;

          if din_valid and din_last then
            block_size0 <= in_bit_cnt + 1;
            in_bit_cnt <= 0;
            set_ram0_busy <= '1';
            wr_fsm <= WR_RAM1;
          end if;

        when WR_RAM1 =>
          if din_valid and (not ram1_busy) then
            in_bit_cnt <= in_bit_cnt + 1;
          end if;

          if din_valid and din_last then
            block_size1 <= in_bit_cnt + 1;
            in_bit_cnt <= 0;
            set_ram1_busy <= '1';
            wr_fsm <= WR_RAM0;
          end if;

      end case;

      if rst then
        wr_fsm <= WR_RAM0;
        in_bit_cnt <= 0;
      end if;
      
    end if;
  end process;

 \*
  * RD_FSM_PROC
  * --------------------------- 
  *  reads from ram and provides data to the encoders
  *  manages the trellis termination and timing
  * 
  *\ 
  rd_fsm_proc: process(clk) begin
    if rising_edge(clk) then

      reset_ram0_busy <= '0';
      reset_ram0_busy <= '0';
      enc_din_valid   <= '0';
      enc_din_last    <= '0';
      termination     <= '0';
      inter_start     <= '0';

      case rd_fsm is
        when WAIT_RAM0 =>
          out_bit_cnt <= 0;
          if ram0_busy and trellis_din_ready then
            inter_start <= '1';
            block_size <= block_size0;
            rd_fsm <= READ_RAM0;
          end if;

        when READ_RAM0 =>
          if parity_addr_valid then
            enc_din_valid <= '1';
            out_bit_cnt <= out_bit_cnt +1;
            if out_bit_cnt = block_size0 - 1 then
              out_bit_cnt <= 0;
              rd_fsm <= COOLDOWN_RAM0;
              reset_ram0_busy <= '1';
            end if;
          end if;

        when COOLDOWN_RAM0 =>
          termination <= '1';
          enc_din_valid <= '1';
          cooldown_cnt <= cooldown_cnt +1;
          if cooldown_cnt = 2 then
            cooldown_cnt <= 0;
            rd_fsm <= WAIT_RAM1;
            enc_din_last <= '1';
          end if;

        when WAIT_RAM1 =>
          out_bit_cnt <= 0;
          if ram1_busy and trellis_din_ready then
            inter_start <= '1';
            block_size <= block_size1;
            rd_fsm <= READ_RAM1;
          end if;

        when READ_RAM1 =>
          if parity_addr_valid then
            enc_din_valid <= '1';
            out_bit_cnt <= out_bit_cnt +1;
            if out_bit_cnt = block_size1 - 1 then
              out_bit_cnt <= 0;
              rd_fsm <= COOLDOWN_RAM1;
              reset_ram1_busy <= '1';
            end if;
          end if;

        when COOLDOWN_RAM1 =>
          termination <= '1';
          enc_din_valid <= '1';
          cooldown_cnt <= cooldown_cnt +1;
          if cooldown_cnt = 2 then
            cooldown_cnt <= 0;
            rd_fsm <= WAIT_RAM0;
            enc_din_last <= '1';
          end if;
        
      end case;

      if rst then
        reset_ram0_busy <= '0';
        reset_ram1_busy <= '0';
        enc_din_last    <= '0';
        rd_fsm <= WAIT_RAM0;
      end if;
    end if;
  end process;  


 \*
  * RAM_BUSY_PROC
  * --------------------------- 
  *  set-reset registers
  *  ram_busy is a flag indicating when a buffer contains
  *  valid data or if is ready to be written 
  *\ 
  ram_busy_proc: process(clk) begin
    if rising_edge(clk) then
      if reset_ram0_busy then
        ram0_busy <= '0';
      elsif set_ram0_busy then
        ram0_busy <= '1';
      end if;
      if reset_ram1_busy then
        ram1_busy <= '0';
      elsif set_ram1_busy then
        ram1_busy <= '1';
      end if;
    
      if rst then
        ram0_busy <= '0';
        ram1_busy <= '0';
      end if;

    end if;
  end process;

 \*
  * TURBO INTERLEAVER INST
  * --------------------------- 
  *  generates the addresses for the ram reading
  *  - parity0 is a incremental address counting up from 0
  *  - pariry1 is the interleaved address
  *\ 
  turbo_interleaver_inst : entity work.turbo_interleaver
  port map (
    clk                 => clk,
    rst                 => rst,
    start               => inter_start,
    block_size          => to_unsigned(block_size, 13),
    parity0_addr        => parity0_addr,
    parity1_addr        => parity1_addr,
    parity_addr_valid   => parity_addr_valid
  );

  true_dual_port_ram_0_inst : entity work.true_dual_port_ram
  generic map (
    DATA_WIDTH => 1,
    ADDR_WIDTH => 13 
  )
  port map (
    clka       => clk,
    clkb       => clk,
    wren_a     => ram0_wren_a,
    wren_b     => ram0_wren_b,
    addr_a     => ram0_addr_a,
    addr_b     => ram0_addr_b,
    din_a(0)   => ram0_din_a,
    din_b(0)   => ram0_din_b,
    dout_a(0)  => ram0_dout_a,
    dout_b(0)  => ram0_dout_b
  );
  
  ram0_wren_a  <= '1' when (din_valid = '1' and din_ready = '1' and wr_fsm = WR_RAM0) else '0';
  ram0_wren_b  <= '0';
  ram0_addr_a  <= std_logic_vector(to_unsigned(in_bit_cnt, 13)) when wr_fsm = WR_RAM0 else
                  std_logic_vector(parity0_addr);
  ram0_addr_b  <= std_logic_vector(parity1_addr);
  ram0_din_a   <= din;
  ram0_din_b   <= '0';

  true_dual_port_ram_1_inst : entity work.true_dual_port_ram
  generic map (
    DATA_WIDTH => 1,
    ADDR_WIDTH => 13 
  )
  port map (
    clka       => clk,
    clkb       => clk,
    wren_a     => ram1_wren_a,
    wren_b     => ram1_wren_b,
    addr_a     => ram1_addr_a,
    addr_b     => ram1_addr_b,
    din_a(0)   => ram1_din_a,
    din_b(0)   => ram1_din_b,
    dout_a(0)  => ram1_dout_a,
    dout_b(0)  => ram1_dout_b
  );
  ram1_wren_a  <= '1' when (din_valid = '1' and din_ready = '1' and wr_fsm = WR_RAM1) else '0';
  ram1_wren_b  <= '0';
  ram1_addr_a  <= std_logic_vector(to_unsigned(in_bit_cnt, 13)) when wr_fsm = WR_RAM1 else
                  std_logic_vector(parity0_addr);
  ram1_addr_b  <= std_logic_vector(parity1_addr);
  ram1_din_a   <= din;
  ram1_din_b   <= '0';

  
 \*
  * CONSTITUENTS ENCODERS
  * --------------------------- 
  *  implements the polinomial encoders
  *\ 
  constituent_encoder_0_din <= ram0_dout_a when (rd_fsm = READ_RAM0 or rd_fsm = COOLDOWN_RAM0) else ram1_dout_a;
  constituent_encoder_parity_0_inst : entity work.turbo_constituent_encoder
  port map (
    clk           => clk,
    rst           => rst,
    ce_i          => enc_din_valid,
    termination_i => termination,
    din_i         => constituent_encoder_0_din,
    sys_dout_o    => trellis_din(3),
    parity_dout_o => trellis_din(2)
  );

  constituent_encoder_1_din <= ram0_dout_b when (rd_fsm = READ_RAM0 or rd_fsm = COOLDOWN_RAM0) else ram1_dout_b;
  constituent_encoder_parity_1_inst : entity work.turbo_constituent_encoder
  port map (
    clk           => clk,
    rst           => rst,
    ce_i          => enc_din_valid,
    termination_i => termination,
    din_i         => constituent_encoder_1_din,
    sys_dout_o    => trellis_din(1),
    parity_dout_o => trellis_din(0)
  );

 \*
  * TRELLIS TERMINATION
  * --------------------------- 
  *  takes the encoder outputs and generates the final encoded outputs 
  *  taking care of the termination and the final bits organization for the ending 4 words
  *\ 
  trellis_din_valid <= enc_din_valid;
  trellis_din_last  <= enc_din_last;
  trellis_termination_inst: entity work.turbo_trellis_termination
    Port map(
      clk          => clk,
      rst          => rst,

      din          => trellis_din,
      din_valid    => trellis_din_valid,
      din_last     => trellis_din_last,
      din_ready    => trellis_din_ready,

      dout         => dout,
      dout_valid   => dout_valid,
      dout_last    => dout_last
    );

end Behavioral;
