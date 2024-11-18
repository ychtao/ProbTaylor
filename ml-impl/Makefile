all:
	ocamlc -c expr.ml
	ocamllex lexer.mll
	ocamlyacc parser.mly
	ocamlc -c parser.mli
	ocamlc -c lexer.ml
	ocamlc -c parser.ml
	ocamlc -c input_parser.ml
	ocamlc -c main.ml
	ocamlc -o a.out lexer.cmo parser.cmo expr.cmo input_parser.cmo main.cmo 

clean:
	rm -f calc *.cmo *.cmi lexer.ml parser.ml parser.mli tilde.txt