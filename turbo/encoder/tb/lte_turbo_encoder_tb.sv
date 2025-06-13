`timescale 1ns / 1ps

module lte_turbo_encoder_tb();
  const time CLK_PERIOD = 10ns;
  const string BASE_PATH = "ABSOLUTE_PATH_TO_TB_FOLDER";
  int BLOCK_SIZE = 152;

  logic clk = 0;
  logic rst;
  logic din =0;
  logic din_valid =0;
  logic din_ready;
  logic din_last=0;
  logic[2:0] dout;
  logic dout_valid;
  logic dout_last;

lte_turbo_encoder DUT(
  .clk,
  .rst,
  .din,
  .din_valid,
  .din_ready,
  .din_last,
  .dout,
  .dout_valid,
  .dout_last
  );

always #(CLK_PERIOD/2) clk = ~clk;
initial begin
  rst = 1;
  #(10*CLK_PERIOD);
  rst = 0;
end

int input_fid;
string input_path;
string ref_path = $sformatf("%s/TV_%0d/ref.txt", BASE_PATH, BLOCK_SIZE);
int ref_fid;

initial begin
  #1ns;
  #(50*CLK_PERIOD);

  input_path = $sformatf("%s/TV_%0d/in.txt", BASE_PATH, BLOCK_SIZE);
  $display({">>> ", input_path});
  input_fid = $fopen(input_path, "r");
  if(!input_fid) begin $display(">> ERROR: could not open input file at %s", input_path); $finish; end


  for(int i = 0;i< BLOCK_SIZE; i++) begin
    $fscanf(input_fid, "%d\n", din);    
    din_valid = 1;

    if(i==BLOCK_SIZE-1) din_last = 1;
  
    #(CLK_PERIOD);
  end
  din_valid = 0;
  din_last = 0;
  #(CLK_PERIOD);

  $display("wait for next ready");
  BLOCK_SIZE = 40;
  while(din_ready !== 1)  @(posedge(clk)); 

  input_path = $sformatf("%s/TV_%0d/in.txt", BASE_PATH, BLOCK_SIZE);
  input_fid = $fopen(input_path, "r");
  if(!input_fid) begin $display(">> ERROR: could not open input file at %s", input_path); $finish; end


  for(int i = 0;i< BLOCK_SIZE; i++) begin
    $fscanf(input_fid, "%d\n", din);    
    din_valid = 1;

    if(i==BLOCK_SIZE-1) din_last = 1;
    $display("%0d\n",i);
  
    #(CLK_PERIOD);
  end
  din_valid = 0;
  din_last = 0;
  #(CLK_PERIOD);



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
      if(ref_bit !== dout) begin $display("ERROR FOUND"); error_counter= error_counter+1; end
      else $display("SUCCESS");

      if(dout_last) break;
    end

  end

  $display(">>> END COMPARISON WITH %0d ERRORS", error_counter);
end


endmodule