library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lte_convolutional_encoder is
  port (
    clk            : in  std_logic;                        -- clock in

    init_word    : in std_logic_vector(5 downto 0);
    load         : in  std_logic;
    din          : in  std_logic;
    din_valid    : in  std_logic;
    din_last     : in  std_logic;

    dout         : out std_logic_vector(2 downto 0);
    dout_last    : out std_logic;
    dout_valid   : out std_logic
  );
end lte_convolutional_encoder;


architecture rtl of lte_convolutional_encoder is
  signal conv_sr_r   : std_logic_vector(5 downto 0);   -- shift registr for the convolution bit-by-bit
begin

process(clk) begin
  if rising_edge(clk) then
    -- register output and valid
    dout_valid <= din_valid;
    dout(0) <= din xor conv_sr_r(4)  xor conv_sr_r(3) xor conv_sr_r(1) xor conv_sr_r(0); --oct(133)  = bin(1_011_011)
    dout(1) <= din xor conv_sr_r(5)  xor conv_sr_r(4) xor conv_sr_r(3) xor conv_sr_r(0); --oct(171)  = bin(1_111_001)
    dout(2) <= din xor conv_sr_r(5)  xor conv_sr_r(4) xor conv_sr_r(2) xor conv_sr_r(0); --oct(165)  = bin(1_110_101)

    -- shift register
    if load then 
      conv_sr_r <= init_word;
    elsif din_valid then
      conv_sr_r <= din & conv_sr_r(5 downto 1);
    end if;

  end if;
end process;

end architecture;