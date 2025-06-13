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
-- LTE TURBO BLOCK PARAMETER
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity turbo_block_param_rom is
  Port (
    clk        : in  std_logic;
    block_size : in  unsigned(12 downto 0);
    f1f2_o     : out unsigned(9 downto 0);
    f2_o       : out unsigned(9 downto 0)
  );
end turbo_block_param_rom;

architecture Behavioral of turbo_block_param_rom is

  signal f1f2, f2: integer range 0 to 1023;

begin
  f1f2_o <= to_unsigned(f1f2, 10);
  f2_o <= to_unsigned(f2, 10);

process(clk) begin
  if rising_edge(clk) then
    case to_integer(block_size) is
      when 40 => f1f2 <= 13; f2 <= 10; 
      when 48 => f1f2 <= 19; f2 <= 12; 
      when 56 => f1f2 <= 61; f2 <= 42; 
      when 64 => f1f2 <= 23; f2 <= 16; 
      when 72 => f1f2 <= 25; f2 <= 18; 
      when 80 => f1f2 <= 31; f2 <= 20; 
      when 88 => f1f2 <= 27; f2 <= 22; 
      when 96 => f1f2 <= 35; f2 <= 24; 
      when 104 => f1f2 <= 33; f2 <= 26; 
      when 112 => f1f2 <= 125; f2 <= 84; 
      when 120 => f1f2 <= 193; f2 <= 90; 
      when 128 => f1f2 <= 47; f2 <= 32; 
      when 136 => f1f2 <= 43; f2 <= 34; 
      when 144 => f1f2 <= 125; f2 <= 108; 
      when 152 => f1f2 <= 47; f2 <= 38; 
      when 160 => f1f2 <= 141; f2 <= 120; 
      when 168 => f1f2 <= 185; f2 <= 84; 
      when 176 => f1f2 <= 65; f2 <= 44; 
      when 184 => f1f2 <= 103; f2 <= 46; 
      when 192 => f1f2 <= 71; f2 <= 48; 
      when 200 => f1f2 <= 63; f2 <= 50; 
      when 208 => f1f2 <= 79; f2 <= 52; 
      when 216 => f1f2 <= 47; f2 <= 36; 
      when 224 => f1f2 <= 83; f2 <= 56; 
      when 232 => f1f2 <= 143; f2 <= 58; 
      when 240 => f1f2 <= 89; f2 <= 60; 
      when 248 => f1f2 <= 95; f2 <= 62; 
      when 256 => f1f2 <= 47; f2 <= 32; 
      when 264 => f1f2 <= 215; f2 <= 198; 
      when 272 => f1f2 <= 101; f2 <= 68; 
      when 280 => f1f2 <= 313; f2 <= 210; 
      when 288 => f1f2 <= 55; f2 <= 36; 
      when 296 => f1f2 <= 93; f2 <= 74; 
      when 304 => f1f2 <= 113; f2 <= 76; 
      when 312 => f1f2 <= 97; f2 <= 78; 
      when 320 => f1f2 <= 141; f2 <= 120; 
      when 328 => f1f2 <= 103; f2 <= 82; 
      when 336 => f1f2 <= 199; f2 <= 84; 
      when 344 => f1f2 <= 279; f2 <= 86; 
      when 352 => f1f2 <= 65; f2 <= 44; 
      when 360 => f1f2 <= 223; f2 <= 90; 
      when 368 => f1f2 <= 127; f2 <= 46; 
      when 376 => f1f2 <= 139; f2 <= 94; 
      when 384 => f1f2 <= 71; f2 <= 48; 
      when 392 => f1f2 <= 341; f2 <= 98; 
      when 400 => f1f2 <= 191; f2 <= 40; 
      when 408 => f1f2 <= 257; f2 <= 102; 
      when 416 => f1f2 <= 77; f2 <= 52; 
      when 424 => f1f2 <= 157; f2 <= 106; 
      when 432 => f1f2 <= 119; f2 <= 72; 
      when 440 => f1f2 <= 201; f2 <= 110; 
      when 448 => f1f2 <= 197; f2 <= 168; 
      when 456 => f1f2 <= 143; f2 <= 114; 
      when 464 => f1f2 <= 305; f2 <= 58; 
      when 472 => f1f2 <= 147; f2 <= 118; 
      when 480 => f1f2 <= 269; f2 <= 180; 
      when 488 => f1f2 <= 213; f2 <= 122; 
      when 496 => f1f2 <= 219; f2 <= 62; 
      when 504 => f1f2 <= 139; f2 <= 84; 
      when 512 => f1f2 <= 95; f2 <= 64; 
      when 528 => f1f2 <= 83; f2 <= 66; 
      when 544 => f1f2 <= 103; f2 <= 68; 
      when 560 => f1f2 <= 647; f2 <= 420; 
      when 576 => f1f2 <= 161; f2 <= 96; 
      when 592 => f1f2 <= 93; f2 <= 74; 
      when 608 => f1f2 <= 113; f2 <= 76; 
      when 624 => f1f2 <= 275; f2 <= 234; 
      when 640 => f1f2 <= 119; f2 <= 80; 
      when 656 => f1f2 <= 267; f2 <= 82; 
      when 672 => f1f2 <= 295; f2 <= 252; 
      when 688 => f1f2 <= 107; f2 <= 86; 
      when 704 => f1f2 <= 199; f2 <= 44; 
      when 720 => f1f2 <= 199; f2 <= 120; 
      when 736 => f1f2 <= 231; f2 <= 92; 
      when 752 => f1f2 <= 117; f2 <= 94; 
      when 768 => f1f2 <= 265; f2 <= 48; 
      when 784 => f1f2 <= 123; f2 <= 98; 
      when 800 => f1f2 <= 97; f2 <= 80; 
      when 816 => f1f2 <= 229; f2 <= 102; 
      when 832 => f1f2 <= 77; f2 <= 52; 
      when 848 => f1f2 <= 345; f2 <= 106; 
      when 864 => f1f2 <= 65; f2 <= 48; 
      when 880 => f1f2 <= 247; f2 <= 110; 
      when 896 => f1f2 <= 327; f2 <= 112; 
      when 912 => f1f2 <= 143; f2 <= 114; 
      when 928 => f1f2 <= 73; f2 <= 58; 
      when 944 => f1f2 <= 265; f2 <= 118; 
      when 960 => f1f2 <= 89; f2 <= 60; 
      when 976 => f1f2 <= 181; f2 <= 122; 
      when 992 => f1f2 <= 189; f2 <= 124; 
      when 1008 => f1f2 <= 139; f2 <= 84; 
      when 1024 => f1f2 <= 95; f2 <= 64; 
      when 1056 => f1f2 <= 83; f2 <= 66; 
      when 1088 => f1f2 <= 375; f2 <= 204; 
      when 1120 => f1f2 <= 207; f2 <= 140; 
      when 1152 => f1f2 <= 107; f2 <= 72; 
      when 1184 => f1f2 <= 93; f2 <= 74; 
      when 1216 => f1f2 <= 115; f2 <= 76; 
      when 1248 => f1f2 <= 97; f2 <= 78; 
      when 1280 => f1f2 <= 439; f2 <= 240; 
      when 1312 => f1f2 <= 103; f2 <= 82; 
      when 1344 => f1f2 <= 463; f2 <= 252; 
      when 1376 => f1f2 <= 107; f2 <= 86; 
      when 1408 => f1f2 <= 131; f2 <= 88; 
      when 1440 => f1f2 <= 209; f2 <= 60; 
      when 1472 => f1f2 <= 137; f2 <= 92; 
      when 1504 => f1f2 <= 895; f2 <= 846; 
      when 1536 => f1f2 <= 119; f2 <= 48; 
      when 1568 => f1f2 <= 41; f2 <= 28; 
      when 1600 => f1f2 <= 97; f2 <= 80; 
      when 1632 => f1f2 <= 127; f2 <= 102; 
      when 1664 => f1f2 <= 287; f2 <= 104; 
      when 1696 => f1f2 <= 1009; f2 <= 954; 
      when 1728 => f1f2 <= 223; f2 <= 96; 
      when 1760 => f1f2 <= 137; f2 <= 110; 
      when 1792 => f1f2 <= 141; f2 <= 112; 
      when 1824 => f1f2 <= 143; f2 <= 114; 
      when 1856 => f1f2 <= 173; f2 <= 116; 
      when 1888 => f1f2 <= 399; f2 <= 354; 
      when 1920 => f1f2 <= 151; f2 <= 120; 
      when 1952 => f1f2 <= 669; f2 <= 610; 
      when 1984 => f1f2 <= 309; f2 <= 124; 
      when 2016 => f1f2 <= 533; f2 <= 420; 
      when 2048 => f1f2 <= 95; f2 <= 64; 
      when 2112 => f1f2 <= 83; f2 <= 66; 
      when 2176 => f1f2 <= 307; f2 <= 136; 
      when 2240 => f1f2 <= 629; f2 <= 420; 
      when 2304 => f1f2 <= 469; f2 <= 216; 
      when 2368 => f1f2 <= 811; f2 <= 444; 
      when 2432 => f1f2 <= 721; f2 <= 456; 
      when 2496 => f1f2 <= 649; f2 <= 468; 
      when 2560 => f1f2 <= 119; f2 <= 80; 
      when 2624 => f1f2 <= 191; f2 <= 164; 
      when 2688 => f1f2 <= 631; f2 <= 504; 
      when 2752 => f1f2 <= 315; f2 <= 172; 
      when 2816 => f1f2 <= 131; f2 <= 88; 
      when 2880 => f1f2 <= 329; f2 <= 300; 
      when 2944 => f1f2 <= 137; f2 <= 92; 
      when 3008 => f1f2 <= 345; f2 <= 188; 
      when 3072 => f1f2 <= 143; f2 <= 96; 
      when 3136 => f1f2 <= 41; f2 <= 28; 
      when 3200 => f1f2 <= 351; f2 <= 240; 
      when 3264 => f1f2 <= 647; f2 <= 204; 
      when 3328 => f1f2 <= 155; f2 <= 104; 
      when 3392 => f1f2 <= 263; f2 <= 212; 
      when 3456 => f1f2 <= 643; f2 <= 192; 
      when 3520 => f1f2 <= 477; f2 <= 220; 
      when 3584 => f1f2 <= 393; f2 <= 336; 
      when 3648 => f1f2 <= 541; f2 <= 228; 
      when 3712 => f1f2 <= 503; f2 <= 232; 
      when 3776 => f1f2 <= 415; f2 <= 236; 
      when 3840 => f1f2 <= 451; f2 <= 120; 
      when 3904 => f1f2 <= 607; f2 <= 244; 
      when 3968 => f1f2 <= 623; f2 <= 248; 
      when 4032 => f1f2 <= 295; f2 <= 168; 
      when 4096 => f1f2 <= 95; f2 <= 64; 
      when 4160 => f1f2 <= 163; f2 <= 130; 
      when 4224 => f1f2 <= 307; f2 <= 264; 
      when 4288 => f1f2 <= 167; f2 <= 134; 
      when 4352 => f1f2 <= 885; f2 <= 408; 
      when 4416 => f1f2 <= 173; f2 <= 138; 
      when 4480 => f1f2 <= 513; f2 <= 280; 
      when 4544 => f1f2 <= 499; f2 <= 142; 
      when 4608 => f1f2 <= 817; f2 <= 480; 
      when 4672 => f1f2 <= 183; f2 <= 146; 
      when 4736 => f1f2 <= 515; f2 <= 444; 
      when 4800 => f1f2 <= 191; f2 <= 120; 
      when 4864 => f1f2 <= 189; f2 <= 152; 
      when 4928 => f1f2 <= 501; f2 <= 462; 
      when 4992 => f1f2 <= 361; f2 <= 234; 
      when 5056 => f1f2 <= 197; f2 <= 158; 
      when 5120 => f1f2 <= 119; f2 <= 80; 
      when 5184 => f1f2 <= 127; f2 <= 96; 
      when 5248 => f1f2 <= 1015; f2 <= 902; 
      when 5312 => f1f2 <= 207; f2 <= 166; 
      when 5376 => f1f2 <= 587; f2 <= 336; 
      when 5440 => f1f2 <= 213; f2 <= 170; 
      when 5504 => f1f2 <= 107; f2 <= 86; 
      when 5568 => f1f2 <= 217; f2 <= 174; 
      when 5632 => f1f2 <= 221; f2 <= 176; 
      when 5696 => f1f2 <= 223; f2 <= 178; 
      when 5760 => f1f2 <= 281; f2 <= 120; 
      when 5824 => f1f2 <= 271; f2 <= 182; 
      when 5888 => f1f2 <= 507; f2 <= 184; 
      when 5952 => f1f2 <= 233; f2 <= 186; 
      when 6016 => f1f2 <= 117; f2 <= 94; 
      when 6080 => f1f2 <= 237; f2 <= 190; 
      when 6144 => f1f2 <= 743; f2 <= 480; 

      when others => f1f2 <= 0; f2 <= 0; 

    end case;
  end if;
end process;

end Behavioral;
