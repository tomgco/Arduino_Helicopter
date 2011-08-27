// Connect anode (+) of IR LED to 5V and connect
// cathode (-) to pin 8 using a 100 ohm resistor

#define LED 8
#define STATUS 13
bool finished;
bool handshakeComplete;

void setup() {
	pinMode(LED, OUTPUT); // setup pins
	digitalWrite(LED, HIGH);
	pinMode(STATUS, OUTPUT); // setup pins
	digitalWrite(STATUS, LOW);
	finished = false;
	handshakeComplete = false;
	Serial.begin(300); // setup serial communication we will start at 300 baud
}
//sends 38Khz pulse when using a 16Mhz ic
void sendPulse(long us) {
	for(int i = 0; i < (us / 26) - 1; i++) {
		 digitalWrite(LED, HIGH);
		 delayMicroseconds(10);
		 digitalWrite(LED, LOW);
		 delayMicroseconds(10);
	}
}

void sendHeader() {
	// Start 38Khz pulse for 2000us
	sendPulse(2002);

	// 2000us off.
	delayMicroseconds(1998);
}

void sendFooter() {
	sendPulse(312);
	delay(60);
}

/*
* Start of transmission is a 2000us on, 2000us off.
*/
void sendControlPacket(byte yaw, byte pitch, byte throttle, byte trim) {
	static byte dataPointer, maskPointer;
	static const byte mask[] = {1, 2, 4, 8, 16, 32, 64, 128};
	static byte data[4];
	// Control bytes.
	data[0] = yaw - 1; // 0 -> 127 where 63 is the mid point.
	data[1] = pitch - 1; // ditto
	data[2] = throttle - 1; // Channel 1 = 0 -> 127 & Channel 2 = 0 -> 127
	data[3] = trim - 1;

	dataPointer = 4;
	maskPointer = 8;

	sendHeader();

	while(dataPointer > 0) {
		sendPulse(312);	

		if(data[4 - dataPointer] & mask[--maskPointer]) {
			delayMicroseconds(688); // send 1 - possibly 600
		} else {
			delayMicroseconds(288); // send 0 - possibly 300
		}

		if(!maskPointer) {
			maskPointer = 8; // reset mask
			dataPointer--; // decrement pointer in data byte array
		}
	}

	sendFooter();
}

void loop() {
	int incomingByte = 0;
	/* The Real Stuff. */

	if (Serial.available() > 5) {
  
		if (Serial.read() == 0x4C && Serial.read() == 0x4F) {
			sendControlPacket(Serial.read(), Serial.read(), Serial.read(), Serial.read());
		}
	} else {
		/*sendControlPacket(63, 63, 50 [> channelCode <], 63);*/
	}
	/*
	static int i;
	while(!finished) {

		for(i = 30; i < 90; i++) {
			sendControlPacket(63, 63, i, 63);
		}

		for(i = 90; i > 0; --i) {
			sendControlPacket(63, 63, i, 63);
		}

		finished = true;
	}
	*/
}

