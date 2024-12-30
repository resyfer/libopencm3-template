/*
 * A blink LED example.
 **/

#include <device.h>

#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/gpio.h>

int main(void) {
    rcc_periph_clock_enable(RCC_GPIOA);
    gpio_mode_setup(GPIOA, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, GPIO5);
	gpio_set(GPIOA, GPIO5);

	while(1) {
		for (int i = 0; i < 1000000; i++) {
			__asm__("nop");
		}
		gpio_toggle(GPIOA, GPIO5);
	}
}