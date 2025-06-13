`timescale 1ns / 1ps

module lte_convolutional_encoder_tb();
  const time CLK_PERIOD = 10ns;
  const string BASE_PATH = "C:/Users/coccolutod/Documents/lte_4g_coders_vhdl/convolutional/encoder/tb/";
  int BLOCK_SIZE = 1028;

  logic clk = 0;
  logic din =0;
  logic din_valid =0;
  logic din_last =0;
  logic dout_last;
  logic[2:0] dout;
  logic[2:0] dout_reverse;
  logic dout_valid;
  logic[5:0] init_word;
  logic load;

  lte_convolutional_encoder DUT
   (
    .clk,
    .init_word,
    .load,
    .din,
    .din_valid,
    .din_last,
    .dout,
    .dout_last,
    .dout_valid
  );

always #(CLK_PERIOD/2) clk = ~clk;


int input_fid;
string input_path;
string ref_path = $sformatf("%s/TV_%0d/ref.txt", BASE_PATH, BLOCK_SIZE);
int ref_fid;

int input_bits[];

initial begin
  input_bits = new[BLOCK_SIZE];
  #1ns;
  #(50*CLK_PERIOD);

  input_path = $sformatf("%s/TV_%0d/in.txt", BASE_PATH, BLOCK_SIZE);
  $display({">>> ", input_path});
  input_fid = $fopen(input_path, "r");
  if(!input_fid) begin $display(">> ERROR: could not open input file at %s", input_path); $finish; end


  for(int i = 0;i< BLOCK_SIZE; i++) begin
    $fscanf(input_fid, "%d\n", input_bits[i]);    
  end
  $display(">>> Input file finished");
  
  init_word[0] = input_bits[BLOCK_SIZE-6];
  init_word[1] = input_bits[BLOCK_SIZE-5];
  init_word[2] = input_bits[BLOCK_SIZE-4];
  init_word[3] = input_bits[BLOCK_SIZE-3];
  init_word[4] = input_bits[BLOCK_SIZE-2];
  init_word[5] = input_bits[BLOCK_SIZE-1];
  load = 1;
  #(CLK_PERIOD);
  load = 0;
  #(5*CLK_PERIOD);

  for(int i = 0; i< BLOCK_SIZE; i++) begin
    din_valid = 1;
    din = input_bits[i];
    #(CLK_PERIOD);
  end
  din_valid = 0;
end

int ref_bit;
int error_counter;
initial begin
  error_counter=0;
  #1ns;
  #(50*CLK_PERIOD);

  $display({">>> ", ref_path});
  ref_fid = $fopen(ref_path, "r");
  if(!ref_fid) begin $display(">> ERROR: could not open ref file at %s", input_path); $finish; end


  while(1) begin
    @(posedge(clk));
    if(dout_valid) begin
      $fscanf(ref_fid, "%d\n", ref_bit);
      dout_reverse = {<<{dout}};
      if(ref_bit !== dout_reverse) begin $display("ERROR FOUND expected %d, obtained %d", ref_bit, dout_reverse); error_counter= error_counter+1; end
      else $display("SUCCESS");

      if(dout_last) break;
    end

  end

  $display(">>> END COMPARISON WITH %0d ERRORS", error_counter);
end


endmodule
