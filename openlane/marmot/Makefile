TARGET = macro_obs.tcl macro_pdn.tcl

all: $(TARGET)

macro_obs.tcl: macro.cfg
	../../../script/mk_obstruction.py $< > $@

macro_pdn.tcl: macro.cfg
	../../../script/mk_pdn_macro_hooks.py $< > $@

clean:
	rm -f $(TARGET)
