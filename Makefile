ODIR = obj
SDIR = src
BDIR = bin
IDIR = include

OBJ_PLINGUA = y.tab.o lex.yy.o node_value.o scope.o syntax_tree.o system.o init.o parser.o pattern.o formats.o cplusplus.o 

OBJ_PSIM = psim.o command_line.o

OBJ_MLINGUA = mli_parser.o cytos_xml.o mlingua_main.o

OBJ_MSIM = mli_parser.o cytos_xml.o msim.o msim_main.o

OBJ_RLINGUA = rli_parser.o rlingua_main.o
      
BIN_PLINGUA = plingua

BIN_PSIM = psim

BIN_MLINGUA = mlingua

BIN_MSIM = msim

BIN_RLINGUA = rlingua

CFlags=-c -O3 -Wall -std=gnu++11 
LDFlags=-lfl -lboost_system -lboost_filesystem -lboost_program_options
CC=g++
RM=rm
FLEX=flex
BISON=bison

all: grammar compiler simulator mcompiler msimulator rcompiler extensions

grammar: y.tab.c lex.yy.c

compiler: $(OBJ_PLINGUA) $(BIN_PLINGUA) 

simulator: $(OBJ_PSIM) $(BIN_PSIM)

mcompiler: $(OBJ_MLINGUA) $(BIN_MLINGUA)

msimulator: $(OBJ_MSIM) $(BIN_MSIM)

rcompiler: $(OBJ_RLINGUA) $(BIN_RLINGUA)

$(BIN_PLINGUA): $(patsubst %,$(ODIR)/%,$(OBJ_PLINGUA))
	@mkdir -p $(BDIR)
	$(CC) $^ $(LDFlags) -o $(BDIR)/$@ 
	
$(BIN_PSIM): $(patsubst %,$(ODIR)/%,$(OBJ_PSIM))
	@mkdir -p $(BDIR)
	$(CC) $^ $(LDFlags) -o $(BDIR)/$@ 	

$(BIN_MLINGUA): $(patsubst %,$(ODIR)/%,$(OBJ_MLINGUA))
	@mkdir -p $(BDIR)
	$(CC) $^ -o $(BDIR)/$@

$(BIN_MSIM): $(patsubst %,$(ODIR)/%,$(OBJ_MSIM))
	@mkdir -p $(BDIR)
	$(CC) $^ -o $(BDIR)/$@

$(BIN_RLINGUA): $(patsubst %,$(ODIR)/%,$(OBJ_RLINGUA))
	@mkdir -p $(BDIR)
	$(CC) $^ -o $(BDIR)/$@

%.o: $(SDIR)/%.cpp	
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $(ODIR)/$@ $<

%.o: $(SDIR)/psystem/%.cpp	
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $(ODIR)/$@ $<

%.o: $(SDIR)/parser/%.cpp	
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $(ODIR)/$@ $<

%.o: $(SDIR)/simulator/%.cpp	
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $(ODIR)/$@ $<


%.o: $(SDIR)/simulator/psim/%.cpp	
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $(ODIR)/$@ $<

%.o: $(SDIR)/generators/cplusplus/%.cpp	
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $(ODIR)/$@ $<

%.o: $(SDIR)/msystem/%.cpp
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $(ODIR)/$@ $<

%.o: $(SDIR)/rlingua/%.cpp
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $(ODIR)/$@ $<

# RR/OpenCog extension targets (header-only + standalone demos)
extensions: $(BDIR)/rr_simple_demo $(BDIR)/rr_demo $(BDIR)/demo_repl $(BDIR)/test_rr_enhanced $(BDIR)/test_next_directions $(BDIR)/test_opencog_integration $(BDIR)/adaptive_foraging $(BDIR)/test_rlingua $(BDIR)/test_e2e

$(BDIR)/rr_simple_demo: examples/rr/rr_simple_demo.cpp
	@mkdir -p $(BDIR)
	$(CC) -O3 -Wall -std=gnu++11 -I$(IDIR) -o $@ $<

$(BDIR)/rr_demo: examples/rr/rr_demo.cpp
	@mkdir -p $(BDIR)
	$(CC) -O3 -Wall -std=gnu++11 -I$(IDIR) -o $@ $<

$(BDIR)/demo_repl: src/rr/demo_repl.cpp
	@mkdir -p $(BDIR)
	$(CC) -O2 -Wall -std=gnu++11 -I$(IDIR) -o $@ $<

$(BDIR)/test_rr_enhanced: src/rr/test_rr_enhanced.cpp
	@mkdir -p $(BDIR)
	$(CC) -O2 -Wall -std=gnu++11 -I$(IDIR) -o $@ $<

$(BDIR)/test_next_directions: src/rr/test_next_directions.cpp
	@mkdir -p $(BDIR)
	$(CC) -O2 -Wall -std=gnu++11 -I$(IDIR) -o $@ $<

$(BDIR)/test_opencog_integration: src/rr/test_opencog_integration.cpp
	@mkdir -p $(BDIR)
	$(CC) -O2 -Wall -std=gnu++11 -I$(IDIR) -o $@ $<

$(BDIR)/adaptive_foraging: examples/rr/adaptive_foraging.cpp
	@mkdir -p $(BDIR)
	$(CC) -O3 -Wall -std=gnu++11 -I$(IDIR) -o $@ $<

$(BDIR)/test_rlingua: src/rr/test_rlingua.cpp src/rlingua/rli_parser.cpp
	@mkdir -p $(BDIR)
	$(CC) -O2 -Wall -std=gnu++11 -I$(IDIR) -o $@ $^

$(BDIR)/test_e2e: src/rr/test_e2e.cpp
	@mkdir -p $(BDIR)
	$(CC) -O2 -Wall -std=gnu++11 -I$(IDIR) -o $@ $<

%.o: $(SDIR)/parser/%.c	
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $(ODIR)/$@ $<

y.tab.c: $(SDIR)/parser/plingua.y
	$(BISON) -o $(SDIR)/parser/$@ -yd $<

lex.yy.c: $(SDIR)/parser/plingua.l
	$(FLEX) -o $(SDIR)/parser/$@ $<  
	
clean:
	$(RM) -f $(patsubst %,$(ODIR)/%,$(OBJ_PLINGUA)) $(patsubst %,$(ODIR)/%,$(OBJ_PSIM)) $(patsubst %,$(ODIR)/%,$(OBJ_MLINGUA)) $(patsubst %,$(ODIR)/%,$(OBJ_MSIM)) $(patsubst %,$(ODIR)/%,$(OBJ_RLINGUA)) $(BDIR)/$(BIN_PLINGUA) $(BDIR)/$(BIN_PSIM) $(BDIR)/$(BIN_MLINGUA) $(BDIR)/$(BIN_MSIM) $(BDIR)/$(BIN_RLINGUA) $(BDIR)/rr_simple_demo $(BDIR)/rr_demo $(BDIR)/demo_repl $(BDIR)/test_rr_enhanced $(BDIR)/test_next_directions $(BDIR)/test_opencog_integration $(BDIR)/adaptive_foraging $(BDIR)/test_rlingua $(BDIR)/test_e2e $(SDIR)/parser/y.tab.c $(SDIR)/parser/y.tab.h $(SDIR)/parser/lex.yy.c
	
install:
	@mkdir -p /usr/local/PLingua/$(BIN_PLINGUA)/
	@mkdir -p /usr/local/PLingua/$(BIN_PSIM)/
	@cp $(BDIR)/$(BIN_PLINGUA) /usr/local/PLingua/$(BIN_PLINGUA)/
	@cp $(BDIR)/$(BIN_PSIM) /usr/local/PLingua/$(BIN_PSIM)/
	@cp LICENSE /usr/local/PLingua/
	@ln -sf /usr/local/PLingua/$(BIN_PLINGUA)/$(BIN_PLINGUA) /usr/local/bin/
	@ln -sf /usr/local/PLingua/$(BIN_PSIM)/$(BIN_PSIM) /usr/local/bin/
	@cp -rf $(IDIR)/cereal/ /usr/local/include/
	@mkdir -p /usr/local/include/plingua/
	@cp -f $(IDIR)/serialization.* /usr/local/include/plingua/

