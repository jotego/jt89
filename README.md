# JT89 FPGA Clone of sn76489an hardware by Jose Tejada (@topapate)
===================================================================

You can show your appreciation through
* [Patreon](https://patreon.com/topapate), by supporting releases
* [Paypal](https://paypal.me/topapate), with a donation


sn76489an compatible Verilog core, with emphasis on FPGA implementation and Megadrive/Master System compatibility.

This project aims to make a Verilog core that will:

* Produce signed output waveforms, with no DC offset
* Produce accurate volume
  * Have volume limiting like reportedly Master System had
  * Different volume settings for noise channel as reported
  * Test if Megadrive 2 version had different volume and apply it
* Reported variations on noise signal length
* Use one single clock for all registers, making it easy to synthesize and constraint on FPGAs
* It will fit well with JT12 (https://github.com/jotego/jt12) in order to produce the Megadrive sound system
* Have separate output channels, so they can be mixed using the interpolator before the sigma-delta DAC

# Silicon layout in Skywater 130

[![build Sky130 GDS](https://github.com/mattvenn/jt89/actions/workflows/install-mpw-6c.yaml/badge.svg)](https://github.com/mattvenn/jt89/actions/workflows/install-mpw-6c.yaml)

* More about the [Skywater open source PDK](https://www.youtube.com/playlist?list=PLUg3wIOWD8yoZCg9XpFSgEgljx6MSdm9L)
* GDS built with [OpenLane](https://github.com/The-OpenROAD-Project/OpenLane)
* Learn how to make your own chips on the [Zero to ASIC course](https://zerotoasiccourse.com/)
