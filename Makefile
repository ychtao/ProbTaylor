.PHONY: all clean
OCAMLC = ocamlfind ocamlc 
PKGS = owl
FLAGS = -package $(PKGS) -linkpkg

all:
	$(MAKE) -C src all

# test: 
# 	ocamlc -c expr.ml
# 	ocamllex lexer.mll
# 	ocamlyacc parser.mly
# 	ocamlc -c parser.mli
# 	ocamlc -c lexer.ml
# 	ocamlc -c parser.ml
# 	ocamlc -c input_parser.ml
# 	ocamlc -c ops.ml
# 	ocamlc -c expectation.ml
# 	ocamlc -c error2.ml
# 	ocamlfind ocamlc -package owl -linkpkg -c expectation_num.ml
# 	ocamlc -c temp.ml
# 	ocamlfind ocamlc -package owl -linkpkg  -o test.out lexer.cmo parser.cmo expr.cmo input_parser.cmo ops.cmo expectation.cmo expectation_num.cmo error2.cmo temp.cmo

# ocamlfind ocamlc -package owl -linkpkg -o a.out lexer.cmo parser.cmo expr.cmo input_parser.cmo ops.cmo expectation.cmo expectation_num.cmo error2.cmo partition.cmo poly.cmo 
# ocamlfind ocamlc -package owl -linkpkg -o b.out lexer.cmo parser.cmo expr.cmo input_parser.cmo ops.cmo expectation.cmo expectation_num.cmo partition.cmo error2.cmo div.cmo

clean:
	$(MAKE) -C src clean