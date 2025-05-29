OCAMLC = ocamlfind ocamlc 
PKGS = owl
FLAGS = -package $(PKGS) -linkpkg

all:
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
	ocamlfind ocamlc -package owl -linkpkg -c expectation_num.ml
	# ocamlc -c main.ml
	ocamlc -c div.ml
	# ocamlc -o a.out -I +unix unix.cma lexer.cmo parser.cmo expr.cmo input_parser.cmo ops.cmo expectation.cmo error2.cmo main.cmo 
	ocamlfind ocamlc -package owl -linkpkg  -o b.out lexer.cmo parser.cmo expr.cmo input_parser.cmo ops.cmo expectation.cmo expectation_num.cmo error2.cmo div.cmo

clean:
	rm -f calc *.cmo *.cmi lexer.ml parser.ml parser.mli tilde.txt