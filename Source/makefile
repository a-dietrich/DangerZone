
DASM   = ../../DASM/bin/Mac/OSX/dasm
STELLA = ../../Stella/Stella.app/Contents/MacOS/Stella

PROJECT      = DangerZone
DEPENDENCIES = vcs.h *.asm

$(PROJECT): $(DEPENDENCIES)
	@$(DASM)  $(PROJECT).asm \
                -o$(PROJECT).bin \
                -l$(PROJECT).lst \
                -s$(PROJECT).sym \
                -f3

clean:
	@$(RM) $(PROJECT).bin $(PROJECT).lst $(PROJECT).sym

run: $(PROJECT)
	@$(STELLA) $(PROJECT).bin >/dev/null 2>&1

