PROJECT = jt89
SOURCE_FILES = jt89.sdc ../hdl/jt89_mixer.v ../hdl/jt89_noise.v ../hdl/jt89_tone.v ../hdl/jt89.v ../hdl/jt89_vol.v ../hdl/jt89_verilog.qip
ASSIGNMENT_FILES = jt89.qpf jt89.qsf

all: smart.log $(PROJECT).asm.rpt $(PROJECT).sta.rpt

clean:
	rm -rf *.rpt *.chg smart.log *.htm *.eqn *.pin *.sof *.pof db incremental_db *jdi *fit.* *summary
	rm $(PROJECT).qsf

map: smart.log $(PROJECT).map.rpt
fit: smart.log $(PROJECT).fit.rpt
asm: smart.log $(PROJECT).asm.rpt
sta: smart.log $(PROJECT).sta.rpt
smart: smart.log

MAP_ARGS = --family="Cyclone III"
FIT_ARGS = --part=EP3C25E144C8
ASM_ARGS =
STA_ARGS =

STAMP = echo done >

$(PROJECT).map.rpt: map.chg $(SOURCE_FILES)
	quartus_map $(MAP_ARGS) $(PROJECT)
	$(STAMP) asm.chg
	$(STAMP) sta.chg

$(PROJECT).fit.rpt: fit.chg $(PROJECT).map.rpt
	quartus_fit $(FIT_ARGS) $(PROJECT)
	$(STAMP) asm.chg
	$(STAMP) sta.chg

$(PROJECT).asm.rpt: asm.chg $(PROJECT).fit.rpt
	quartus_asm $(ASM_ARGS) $(PROJECT)

$(PROJECT).sta.rpt: sta.chg $(PROJECT).fit.rpt
	quartus_sta $(STA_ARGS) $(PROJECT)

smart.log: $(ASSIGNMENT_FILES)
	quartus_sh --determine_smart_action $(PROJECT) > smart.log

$(ASSIGNMENT_FILES):
	quartus_sh --prepare $(PROJECT) 
	quartus_sh --set QIP_FILE=../hdl/jt89_verilog.qip $(PROJECT)

map.chg:
	$(STAMP) map.chg
fit.chg:
	$(STAMP) fit.chg
sta.chg:
	$(STAMP) sta.chg
asm.chg:
	$(STAMP) asm.chg

