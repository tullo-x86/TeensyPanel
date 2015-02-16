#include <Arduino.h>

int main()
{
	pinMode(13, OUTPUT);

	while(true)
	{
		delay(500);
		digitalWriteFast(13, HIGH);
		delay(500);
		digitalWriteFast(13, LOW);
	}
}


