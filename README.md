# Syma 107 Arduino Helicopter

## Installation
Do not use this software is pre-pre-alpha, IE I haven't even got the chance to test it yet.

	git clone git://github.com/tomgallacher/Arduino_Helicopter.git

Open in Arduino Ide or use avrdude, what ever you beef compile and upload to your device.

## Preface 

Here it goes my first real venture into the fabulous world of Arduino's, Hardware and possibly intense 1's and 0's; I have made various small projects using my Arduino Uno, none of them worth documenting, this one is an exception.
I will be interfacing with the Syma 107 IR LED controlled helicopter. I ordered mine on Monday 23rd August 2011 however I thought I could start working on the software and getting the protocol nailed down before it arrives, so most likely what you are reading here is not even relevant, but lets assume it is, and I have got it right first time. =]

### Research
After researching the IR Protocol for the Syma 107, I came across this thread. I found some sample code which will move the helicopter up and down by gently increasing the throttle and back down again. The thing I need to do is research the IR protocol between the transmitter (Tx from now on) and the helicopter (Rx) - thankfully this had already done for me and this is what I found; The Tx sends a continuous stream of bits, 77 cycles of the LED (~2000us) for the header then 12 cycles (~300us) to mark the start of a command and then 4 bytes for commanding the Yaw, Pitch, Channel, Throttle and Trim (Fig 1.) This is then followed by another 12 cycles. (~2000) to end the command.

Binary Alert

	Fig 1.                ↓
	0YYYYYYY   0PPPPPPP   CTTTTTTT   0AAAAAAA
	Yaw        Pitch      Throttle   Trim (Adjustment)

C - denoted by the arrow, is the channel that the helicopter is on. Yaw / Pitch have the same mapping where 0 is left / backward and 127 is right / forward, as the channel's 8th bit on the throttle is the channel the bit range that we get for channel one is 0->127 and for channel two 128->254. 
As you may know I am using a Arduino Uno this has a Atmega 328P-PU with a clock speed of 16Mhz which will be needed otherwise the timings will be wrong. The circuit I have hacked up is a simple serial connection of the infrared led which I de-soldered from a Samsung TV remote, linked up to PIN 8 and with a 320ohm resistor to ground.

Hold Tight for even more Helicopter love when the beast is delivered!
