# FPGA LTE 4G Encoders and Decoders (Turbo and Convolutional)
This repository contains synthesizable VHDL implementations of Turbo and Convolutional Encoders and Decoders used in 4G LTE systems. It aims to provide a free, open-source, and high-performance implementation of standard channel coding schemes compliant with 3GPP specifications.


Main features:
* Fully synthesizable VHDL code aimed for FPGA implementation
* Highly pipelined implementation (Max Frequency of 500MHz on a Xilinx Spartan Series FPGA)
* Reference MATLAB simulations for test vectors and golden references generation

## Folder Structure
```
.
|-- convolutional
|   |-- decoder
|   `-- encoder
|       |-- matlab
|       |-- src
|       |-- tb
`-- turbo
    |-- decoder
    `-- encoder
        |-- matlab
        |-- src
        `-- tb
```
Convolutional encoder and Turbo Encoder folders are fully populated, tested and 3GPP compliant. The "decoder" folders are still WIP.

## How to use
All source code are self contained in the folder "src" of each component. There are no external libraries required and all the necessary files are in the repository.

The project is using standard VHDL-2008 and it's mandatory to synthesize and use these IpCores with VHDL2008 compliant tools.

Compilation lists are provided in src folder with correct compilation order.

## Testbenches
In each folder is also presented a complete testbench showing the expected interfacing with the modules and the obtained results. In order to get a full output reference a full MATLAB model is provided and the results are automatically generated and ready to be be used in the testbench.


## About LTE Convolutional Coder
LTE Convolutional coder is used for channel coding, particularly in the Physical Broadcast Channel (PBCH) and Physical Downlink Control Channel (PDCCH). This code uses a constraint length of 7 and a coding rate of 1/3 (each input bit becomes 3 output bits), employing generator polynomials G0=133(o), G1=171(o), and G2=165(o).
A peculiar feature is the tail-biting implementation: the state registers are initialized with the last bits of the message before starting shifting in the message data, this design choice enables an easier decoding and a better Bit Error Rate (BER) at a cost of a slightly more difficult implementation of the encoder. This also guarantees that the final state of the Encoder is 0x00.

![alt text](https://www.researchgate.net/publication/303760187/figure/fig5/AS:368777502969861@1464934816769/LTE-convolutional-code-9.png)
[cit.https://www.researchgate.net/publication/303760187/figure/fig5/AS:368777502969861@1464934816769/LTE-convolutional-code-9.png ]

This design is streaming based and, after the initialization, each valid input corresponds to a valid output achiveing

Maximum Throughput of $Fclk [bit/s]$

In the tested usecase on a Xilinx Spartan 7 500Mbps are easily achivable.

## About LTE Turbo Coder
Turbo coding improves the previous Convolutional Code performances obtaining BER close to the theoretical Nyquist Limit. Turbo encoders are based on a convolutional shift register with feedback and interleaving on the third branch.

LTE Turbo has a coding rate of 1/3 and it's a systematic and interleaved scheme (for each input bit we will obtain three output bits: 
* the first bit is the systematic one (equal to the input)
* the second is an encoded version of the input
* the third one is an encoded version of the interleaved input

![alt text](https://www.researchgate.net/publication/255992186/figure/fig1/AS:341836196532224@1458511508008/Parallel-turbo-code-used-in-LTE-and-UMTS-The-turbo-encoder-shown-in-Fig-5-consists-of.png)
[cit.https://www.researchgate.net/publication/255992186/figure/fig1/AS:341836196532224@1458511508008/Parallel-turbo-code-used-in-LTE-and-UMTS-The-turbo-encoder-shown-in-Fig-5-consists-of.png]

The proposed implementation is fully compliant with 3GPP standard : https://www.etsi.org/deliver/etsi_ts/136200_136299/136212/15.02.01_60/ts_136212v150201p.pdf

The most difficult part of the Turbo Encoder is the hardware implementation of the Interleaver Polynomial.

The 3GPP standard provides the following formula:

$\pi_i = (f_1 \cdot i + f_2 \cdot i^2)mod K$ 

Where K is the block_size (number of input bits to be encoded) and f1 and f2 are constant from a table depending on K.
This operation is not easy synthesizable as is because of the square multiplication, the addition and the heavy modulo operation so an iterative solution has been used.

$ \pi_{0}=0$\
$ \pi_{i+1}={\pi_i+g_i} $\
$ g_{0}=f_1+f_2$\
$ g_{i+1}={g_i+2f_2}$

Since $f1+f2<K$ and $g+2f_2<K$ the modulo operation becomes a subtration by $K$ when the operation is greater then $K$

The interleaved design requires to buffer the entire input before starting the processing and a ping-pong buffer is exploited to achieve maximum throughput.
Maximum theoretical throughput is $\frac{Nbits}{Nbits+6} * Fclk  [bit/sec]$
So for the biggest 4GPP transpost block off ~6000bits at 500MHz a theoretical 499.8Mbsp is achieved.