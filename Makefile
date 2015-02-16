
#Teensy path
TEENSYPATH  := /home/tully/ArduinoSDK/1.0.5/
TOOLSPATH   := $(TEENSYPATH)/hardware/tools

#Compiler and Linker
COMPILERPATH := $(TEENSYPATH)/hardware/tools/arm-none-eabi/bin

CC          := $(abspath $(COMPILERPATH))/arm-none-eabi-gcc
CXX         := $(abspath $(COMPILERPATH))/arm-none-eabi-g++
OBJCOPY     := $(abspath $(COMPILERPATH))/arm-none-eabi-objcopy
SIZE        := $(abspath $(COMPILERPATH))/arm-none-eabi-size

#The Target Binary Program
TARGET      := TeensyPanel

#The Directories, Source, Includes, Objects, Binary and Resources
SRCDIR      := src
INCDIR      := inc
BUILDDIR    := obj
TARGETDIR   := bin
CXXEXT      := cpp
CEXT        := c
DEPEXT      := d
OBJEXT      := o

# Teensy configuration
OPTIONS     := -DF_CPU=96000000 -DUSB_SERIAL -DLAYOUT_US_ENGLISH

# Arduino library compatibility options
ARDCOMPAT   := -D__MK20DX256__ -DARDUINO=105 -ffunction-sections -fdata-sections

#Flags, Libraries and Includes
CPPFLAGS    := -Wall -g -Os -mcpu=cortex-m4 -mthumb -nostdlib $(OPTIONS)
CXXFLAGS    := -std=gnu++0x -felide-constructors -fno-exceptions -fno-rtti
CFLAGS      := 
LDFLAGS     := -Os -Wl,--gc-sections -mcpu=cortex-m4 -mthumb
LIB         := -lm
INC         := -I$(INCDIR) -I./core
INCDEP      := -I$(INCDIR)

#---------------------------------------------------------------------------------
#DO NOT EDIT BELOW THIS LINE
#---------------------------------------------------------------------------------
CXXSOURCES  := $(shell find $(SRCDIR) -type f -name *.$(CXXEXT))
CSOURCES    := $(shell find $(SRCDIR) -type f -name *.$(CEXT))
SOURCES     := $(CXXSOURCES:.$(CXXEXT)=.$(OBJEXT)) $(CSOURCES:.$(CEXT)=.$(OBJEXT))
OBJECTS     := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES))

#Default Make
all: directories $(TARGET).hex

#Remake
remake: cleaner all

#Make the Directories
directories:
	@mkdir -p $(TARGETDIR)
	@mkdir -p $(BUILDDIR)

#Clean only Objecst
clean:
	@$(RM) -rf $(BUILDDIR)

#Full Clean, Objects and Binaries
cleaner: clean
	@$(RM) -rf $(TARGETDIR)

#Pull in dependency info for *existing* .o files
-include $(OBJECTS:.$(OBJEXT)=.$(DEPEXT))

#Link
$(TARGET).elf: $(OBJECTS) mk20dx256.ld
	$(CC) $(LDFLAGS) -Tmk20dx256.ld -o $(TARGETDIR)/$(TARGET).elf $(OBJECTS) $(LIB)

#Hexfile
%.hex: %.elf
	$(SIZE) $<
	$(OBJCOPY) -O ihex -R .eeprom $< $@
	#./teensy_loader -mmcu=mk20dx128 -w -v $(TARGET).hex
	#$(abspath $(TOOLSPATH))/teensy_post_compile -file=$(basename $@) -path=$(shell pwd) -tools=$(abspath $(TOOLSPATH))
	#-$(abspath $(TOOLSPATH))/teensy_reboot

#Compile CXX files
$(BUILDDIR)/%.$(OBJEXT): $(SRCDIR)/%.$(CXXEXT)
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CXXFLAGS) $(INC) -c -o $@ $<
	@$(CC) $(CPPFLAGS) $(CXXFLAGS) $(INCDEP) -MM $(SRCDIR)/$*.$(CXXEXT) > $(BUILDDIR)/$*.$(DEPEXT)
	@cp -f $(BUILDDIR)/$*.$(DEPEXT) $(BUILDDIR)/$*.$(DEPEXT).tmp
	@sed -e 's|.*:|$(BUILDDIR)/$*.$(OBJEXT):|' < $(BUILDDIR)/$*.$(DEPEXT).tmp > $(BUILDDIR)/$*.$(DEPEXT)
	@sed -e 's/.*://' -e 's/\\$$//' < $(BUILDDIR)/$*.$(DEPEXT).tmp | fmt -1 | sed -e 's/^ *//' -e 's/$$/:/' >> $(BUILDDIR)/$*.$(DEPEXT)
	@rm -f $(BUILDDIR)/$*.$(DEPEXT).tmp

#Compile C files
$(BUILDDIR)/%.$(OBJEXT): $(SRCDIR)/%.$(CEXT)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INC) -c -o $@ $<
	@$(CC) $(CFLAGS) $(INCDEP) -MM $(SRCDIR)/$*.$(CEXT) > $(BUILDDIR)/$*.$(DEPEXT)
	@cp -f $(BUILDDIR)/$*.$(DEPEXT) $(BUILDDIR)/$*.$(DEPEXT).tmp
	@sed -e 's|.*:|$(BUILDDIR)/$*.$(OBJEXT):|' < $(BUILDDIR)/$*.$(DEPEXT).tmp > $(BUILDDIR)/$*.$(DEPEXT)
	@sed -e 's/.*://' -e 's/\\$$//' < $(BUILDDIR)/$*.$(DEPEXT).tmp | fmt -1 | sed -e 's/^ *//' -e 's/$$/:/' >> $(BUILDDIR)/$*.$(DEPEXT)
	@rm -f $(BUILDDIR)/$*.$(DEPEXT).tmp

#Non-File Targets
.PHONY: all remake clean cleaner