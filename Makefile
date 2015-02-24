

TARGET = TeensyPanel

TEENSYPATH = /home/tully/ArduinoSDK/1.0.5/

# Configurable options
OPTIONS = -DF_CPU=96000000 -DUSB_SERIAL -DLAYOUT_US_ENGLISH

# Arduino library compatibility options
OPTIONS += -D__MK20DX256__ -DARDUINO=105 -ffunction-sections -fdata-sections

# Teensy utilities
TOOLSPATH = $(TEENSYPATH)/hardware/tools

# Compiler location
COMPILERPATH = $(TEENSYPATH)/hardware/tools/arm-none-eabi/bin

CC = $(abspath $(COMPILERPATH))/arm-none-eabi-gcc
CXX = $(abspath $(COMPILERPATH))/arm-none-eabi-g++
OBJCOPY = $(abspath $(COMPILERPATH))/arm-none-eabi-objcopy
SIZE = $(abspath $(COMPILERPATH))/arm-none-eabi-size

INCLUDEPATHS = -I./core -I./FastLED -I./ChibiOS_ARM -I./SdFat -I./ustl

# Flags for C and C++
CPPFLAGS = $(INCLUDEPATHS) -Wall -g -Os -mcpu=cortex-m4 -mthumb -nostdlib -MMD $(OPTIONS) -I.

# C++-only flags
CXXFLAGS = -std=gnu++0x -felide-constructors -fno-exceptions -fno-rtti

# C-only flags
CFLAGS = 

# Linker flags
LDFLAGS = -Os -Wl,--gc-sections -mcpu=cortex-m4 -mthumb -Tmk20dx256.ld

# additional libraries to link
LIBS = -lm


OBJDIR := obj

# automatically create lists of the sources and objects
# TODO: this does not handle Arduino libraries yet...
TEENSYCORE_C_FILES := $(wildcard core/*.c) 
TEENSYCORE_CPP_FILES := $(wildcard core/*.cpp)
C_FILES := $(wildcard src/*.c)
CPP_FILES := $(wildcard src/*.cpp)
FASTLED_C_FILES := $(wildcard FastLED/*.c)
FASTLED_CPP_FILES := $(wildcard FastLED/*.cpp)
OBJS := $(TEENSYCORE_C_FILES:.c=.o) $(TEENSYCORE_CPP_FILES:.cpp=.o) \
			$(C_FILES:.c=.o) $(CPP_FILES:.cpp=.o) \
			$(FASTLED_C_FILES:.c=.o) $(FASTLED_CPP_FILES:.cpp=.o)


# RULES section
all: $(TARGET).hex

# Compiler rule


# Linker rule
$(TARGET).elf: $(OBJS) mk20dx256.ld
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

%.hex: %.elf
	$(SIZE) $<
	$(OBJCOPY) -O ihex -R .eeprom $< $@
	#./teensy_loader -mmcu=mk20dx128 -w -v $(TARGET).hex

install: all
	$(abspath $(TOOLSPATH))/teensy_post_compile -file=$(basename $(TARGET).hex) -path=$(shell pwd) -tools=$(abspath $(TOOLSPATH))
	$(abspath $(TOOLSPATH))/teensy_reboot

monitor:
	screen /dev/ttyACM0 115200

# compiler generated dependency info
-include $(OBJS:.o=.d)

clean:
	find ./ -type f -name "*.o" -delete
	rm -f *.o *.d $(TARGET).elf $(TARGET).hex


