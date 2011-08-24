// Connect anode (+) of IR LED to 5V and connect
// cathode (-) to pin 8 using a 100 ohm resistor

#define LED 8
bool finished;

void setup() {
	pinMode(LED, OUTPUT); // setup pins
	digitalWrite(LED, HIGH);
	finished = false;
	Serial.begin(9600); // setup serial communication
	Serial.println("");
}

void pulseIR(long μs) {
	cli(); //turns off back ground interrupts

	while(μs > 0) {
		digitalWrite(LED,LOW); //3 microseconds
		delayMicroseconds(10); //10 microseconds
		digitalWrite(LED, HIGH);
		delayMicroseconds(10);
		μs -= 26; // 26μs in total
	}

	sei(); // turns on interrupts
}

/*
* Start of transmission is a 2000μs on, 2000μsoff.
*/
void sendControlPacket(byte yaw, byte pitch, byte throttle, byte trim) {
	static byte markL, dataPointer, maskPointer, one, zero;
	static bool hasData;
	static const byte mask[] = {1, 2, 4, 8, 16, 32, 64, 128, 256};
	static byte data[4];

	data[0] = yaw; // 0 -> 127 where 63 is the mid point.
	data[1] = pitch; // ditto
	data[2] = throttle; // Channel 1 = 0 -> 127 & Channel 2 = 0 -> 127
	data[3] = trim;
	markL = 77; // 2000 / 26  == 76.9
	dataPointer = 4;
	maskPointer = 9;
	one = 0; // might not need
	zero = 0; // might not need
	hasData = true;

	while(markL--) {
		// Start 38Khz pulse for 2000us
		digitalWrite(LED,LOW); //3 microseconds
		delayMicroseconds(10); //10 microseconds
		digitalWrite(LED, HIGH);
		delayMicroseconds(10);
		// 26 microseconds
	}

	// 2000us off.
	delayMicroseconds(1998);

	markL = 12;

	while(hasData) {
		while(markL--) {
			digitalWrite(LED, LOW);
			delayMicroseconds(10);
			digitalWrite(LED, HIGH);
			delayMicroseconds(10);
		}
		//2336 microseconds

		markL = 12;

		if(data[4 - dataPointer] & mask[--maskPointer]) {
			one++;
			delayMicroseconds(688);
		} else {
			zero++;
			delayMicroseconds(288);
		}

		if(!maskPointer) {
			maskPointer = 9;
			dataPointer--;
		}

		if(!dataPointer) {
			hasData = false;
		}
	}

	while(markL--) {
		digitalWrite(LED, LOW);
		delayMicroseconds(10);
		digitalWrite(LED, HIGH);
		delayMicroseconds(10);
	}
	//2336 microseconds

	/*return((.1 - .014296 - one * .000688 - zero * .000288) * 1000); // in ms.*/
}

void loop() {

	static int i;
	int delayinus = 0;

	while(!finished) {
		//send 0->127 on throttle for channel 1 and
		// 128->254 for channel 2
		for(i = 128; i < 255; i++) {
			sendPacket(63, 63, i, 63);
			delay(65);
		}

		for(i = 0; i < 128; i++) {
			sendPacket(63, 63, i, 63);
			delay(65);
		}

		finished = true;
	}
}
