TARGET = blink_led
MCU = stm32f4
TARGETS = stm32/f4
LIB_DIR = ./lib
LIBOPENCM3 = $(LIB_DIR)/libopencm3
BUILD_DIR = build
SRC_DIR = src

PREFIX = arm-none-eabi
CC = $(PREFIX)-gcc
AS = $(PREFIX)-as
LD = $(PREFIX)-ld
OBJCOPY = $(PREFIX)-objcopy

ASMFLAGS = -mcpu=cortex-m4 -mthumb -g -mfloat-abi=hard
CFLAGS = -Wall -mcpu=cortex-m4 -mthumb -nostdlib -ffreestanding -Os -MD -g -mfloat-abi=hard
LDFLAGS = -T$(LIBOPENCM3)/ld/linker.ld.S -L $(LIBOPENCM3)/lib -lopencm3_$(MCU)

OOCD ?= openocd
OOCD_INTERFACE = stlink
OOCD_TARGET = stm32f4x

SRCS = $(wildcard $(SRC_DIR)/*.c)
ASMS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.s, $(SRCS))
OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRCS))

all: $(BUILD_DIR)/$(TARGET).bin $(BUILD_DIR)/$(TARGET).elf $(LIBOPENCM3)/libopencm3_$(MCU).a
	@echo "  DONE"

flash: $(BUILD_DIR)/$(TARGET).elf
	@echo "  FLASHING  " $@
	(echo "halt; program $(realpath $(*).elf) verify reset" | nc -4 localhost 4444 2>/dev/null) || \
		$(OOCD) -f interface/$(OOCD_INTERFACE).cfg \
		-f target/$(OOCD_TARGET).cfg \
		-c "transport select hla_swd" \
		-c "program $< verify reset exit"

$(LIBOPENCM3)/libopencm3_$(MCU).a:
	@echo "  LIB       LIBOPENCM3 (" $@ ")"
	@$(MAKE) -C $(LIBOPENCM3) TARGETS='$(TARGETS)'

$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	@echo "  BINARY    " $@
	@$(OBJCOPY) -O binary $< $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJS) $(LIBOPENCM3)/libopencm3_$(MCU).a
	@echo "  ELF       " $@
	@$(LD) $(OBJS) -o $@ $(LDFLAGS) -I $(LIBOPENCM3)/include -I ./include

$(BUILD_DIR)/%.o: $(BUILD_DIR)/%.s
	@echo "  OBJ       " $@
	@$(AS) $(ASMFLAGS) -I $(LIBOPENCM3)/include -I ./include $< -o $@

$(BUILD_DIR)/%.s: $(SRC_DIR)/%.c
	@echo "  ASM       " $@
	@$(CC) $(CFLAGS) -S $< -o $@ -I $(LIBOPENCM3)/include -I ./include

clean:
	@echo "  CLEAN LIBOPENCM3"
	@$(MAKE) -C $(LIBOPENCM3) clean
	@echo "  CLEAN"
	@rm -rf $(BUILD_DIR)/*.s $(BUILD_DIR)/*.o $(BUILD_DIR)/*.elf $(BUILD_DIR)/*.bin

.PRECIOUS: $(ASMS)
.PHONY: all flash gdb

-include $(OBJS:.o=.d)