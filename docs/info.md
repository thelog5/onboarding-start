<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
this design uses SPI to configure 16 output pins, with optional PWM, running on a 10 MHz clock.  
SPI write transactions update registers that control output enables, PWM enables, and the PWM duty cycle.

## How to test

design tested in simulation using cocotb

## External hardware

none
