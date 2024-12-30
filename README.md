# libopencm3-template
Cortex-M Embedded C template using libopencm3

Pre-requisites: `arm-none-eabi-gcc`, `openocd`, `arm-none-eabi-gdb`.

Platforms:

- [x] Linux
- [ ] Windows (Theoretically yes, untested)

```sh
git clone --recurse-submodules https://github.com/resyfer/libopencm3-template
cd libopencm3-template
```

```sh
cd lib/libopencm3
git apply ../libopencm3.diff
cd -
```

Modify the memory locations in the file `./lib/libopencm3/ld/linker.ld.S` as per need. For STM32, the diff applied should be OK.