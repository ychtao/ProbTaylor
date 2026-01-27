.PHONY: all clean
OCAMLC = ocamlfind ocamlc 
PKGS = owl
FLAGS = -package $(PKGS) -linkpkg

BIN_DIR := bin
RES_DIR := results
TARGET := pt 

all: $(BIN_DIR)/$(TARGET)

$(BIN_DIR)/$(TARGET):
	@mkdir -p $(BIN_DIR)
	$(MAKE) -C src all 
	cp src/$(TARGET) $(BIN_DIR)/$(TARGET)

clean:
	$(MAKE) -C src clean
	rm -rf $(BIN_DIR)
	rm -rf $(RES_DIR)
	rm benchmarks/scalability/*.txt
	