MARMOT_RTL_DIR = /home/shc/Development/RISC-V/chipyard/vlsi/rtl
VSRCS = $(MARMOT_RTL_DIR)/MarmotCaravelChip.vc

copy:
	@for v in `egrep \.v$$ $(VSRCS) | egrep -ve '^ *(\+|-)'` ; do \
    cp -p $(MARMOT_RTL_DIR)/$$v . ; \
  done
	diff user_project_wrapper.v ..
	rm -f user_project_wrapper.v
	
clean:
	rm -f *.v

