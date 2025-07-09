# UART from scratch

## Overview
This project implements a UART communication system in Verilog, consisting of two core components: a receiver (RX) module and a transmitter (TX) module. The RX module is responsible for deserializing incoming 8-bit data packets based on a defined baud rate, sampling each bit over a fixed number of clock cycles to ensure accurate reception. The TX module handles the reverse operation, serializing 8-bit data for transmission by inserting start and stop bits around the data payload. Both modules are designed to operate with a 25 MHz clock and a baud rate of 115200, resulting in 217 clock cycles per bit. The system is rigorously tested through a comprehensive testbench that simulates the sending and receiving of multiple 8-bit values. The testbench validates correctness by comparing the received data against expected values after each transmission, using controlled timing delays and waveform observations to ensure protocol compliance and data integrity.  The clock frequency can be modified to run at a different frequency depending the board or system.  Changing clock frequency would also require clock cycles per bit to modified as well.

## Results

### Reciever Results

The screenshots below demostrate the RX (reciever) of this UART module to be working correctly.  Initiall the data line, called r_RX_Serial is held high.  The UART is waiting for the data line to transition to low, and begins to recieving data.  In this design, it takes approximately 8 ns for sampling to begin.  As shown in the 4th screenshot, the data line returns high as the value being recieved is 0x37 or 00110111. However, UART reads data from the LSB first, so that is why the data line returned back 1.  It takes approximatly 80 us for a data packet to be read.  The w_RX_DV is a flag that indicates that the data packet has finished.  This particular signal will be active for 1 clock cycle.  The console output verifies that the design worked in a condensed format.

![Reciever Console Output](./screenshots/RX_console.png)
![Reciever Output 1](./screenshots/RX_waveform1.png)
![Reciever Output 2](./screenshots/RX_waveform2.png)
![Reciever Output 3](./screenshots/RX_waveform3.png)
![Reciever Output 4](./screenshots/RX_waveform4.png)
![Reciever Output 5](./screenshots/RX_waveform5.png)

### Transmitter Results

The screenshots below illustrate the TX (transmitter) portion of the UART module in operation. To verify that the transmitter correctly sends data and that it is properly received, several internal signals are observed. The w_TX_Serial signal shows the serialized data stream being transmitted bit by bit, while w_UART_Line reflects the actual line state shared between TX and RX. The w_RX_DV signal asserts when a complete byte has been received, confirming successful transmission. Additionally, w_RX_Byte is monitored to ensure the received data matches the original value sent from r_TX_Byte. The combined use of TX and RX modules in this waveform confirms reliable end-to-end UART communication.


![Transmitter Console Output](./screenshots/TX_console.png)
![Transmitter Output 1](./screenshots/TX_waveform1.png)
![Transmitter Output 2](./screenshots/TX_waveform2.png)
![Transmitter Output 3](./screenshots/TX_waveform3.png)
![Transmitter Output 4](./screenshots/TX_waveform4.png)
![Transmitter Output 5](./screenshots/TX_waveform5.png)


## To Do 
- Obtain USBUART Pmod from Digilent and connect UART module to serial terminal to send data from PC to Zybo.