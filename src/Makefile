.PHONY: all clean
OCAMLC = ocamlfind ocamlc 
PKGS = owl
FLAGS = -package $(PKGS) -linkpkg

all:
	eval `opam config env`
	ocamlc -c expr.ml
	ocamllex lexer.mll
	ocamlyacc parser.mly
	ocamlc -c parser.mli
	ocamlc -c lexer.ml
	ocamlc -c parser.ml
	ocamlc -c input_parser.ml
	ocamlc -c ops.ml
	ocamlc -c expectation.ml
	ocamlc -c error2.ml
	ocamlc -c partition.ml
	ocamlc -c poly.ml
	ocamlc -c div.ml
	ocamlc -c main.ml
	ocamlc -o pt -I +unix unix.cma lexer.cmo parser.cmo expr.cmo input_parser.cmo ops.cmo expectation.cmo partition.cmo error2.cmo poly.cmo div.cmo main.cmo

clean:
	rm -f calc *.cmo *.cmi lexer.ml parser.ml parser.mli tilde.txt error2.txt pt