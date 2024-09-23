PROJECT_NAME=TurboSound

.PHONY: all clean run

ASSRC:=$(wildcard *.asm)

all: $(PROJECT_NAME).bin

dis: all
	z88dk-dis -x $(PROJECT_NAME).map -o CRT_ORG_CODE $(PROJECT_NAME).bin | less

run: all
	aquarius_emu -u . -t "\nrun $(PROJECT_NAME).aqex\n"

%.bin: $(ASSRC)
	zcc +aquarius -pragma-include:zpragma.inc -m -clib=aqplus $(ASSRC) -o $@ -create-app -subtype=aqex

clean:
	rm -f *.bin *.aqex *.map

