clc; clear; close all;

BLOCK_SIZE = 1028;
folder_name = ['./TV_' num2str(BLOCK_SIZE)];
mkdir(folder_name);

c = randi([0 1],1, BLOCK_SIZE);

o = lte_conv_encode(c);


c_dec = bin2dec(char(c' + '0'));
o_dec = bin2dec(char(o.'+'0'));
dlmwrite([folder_name "/in.txt"], c_dec);
dlmwrite([folder_name "/ref.txt"], o_dec);
