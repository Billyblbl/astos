
extern "C" void kernel_main() {

	volatile unsigned short*	buffer = (unsigned short*)0xb8000;

	unsigned char fg = 0;
	unsigned char bg = 10;
	unsigned char color = fg | bg << 4;

	buffer[0] = (unsigned short)'O' | (unsigned short) (color << 8);
	buffer[1] = (unsigned short)'K' | (unsigned short) (color << 8);

}