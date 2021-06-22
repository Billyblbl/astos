#ifndef GMAIN
# define GMAIN

#include <types.cpp>

extern "C" void kernel_main() {

	volatile u16*	buffer = (u16*)0xb8000;

	u8 fg = 0;	//black
	u8 bg = 10;	//green
	u8 color = fg | bg << 4;

	buffer[0] = (u16)'O' | (u16) (color << 8);
	buffer[1] = (u16)'K' | (u16) (color << 8);

}

#endif
