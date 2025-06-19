all:
	ocamlc -c tilde.ml
	ocamllex lexer.mll
	ocamlyacc parser.mly
	ocamlc -c parser.mli
	ocamlc -c lexer.ml
	ocamlc -c parser.ml
	ocamlc -c calc.ml
	ocamlc -o calc tilde.cmo lexer.cmo parser.cmo calc.cmo 

clean:
	rm -f calc *.cmo *.cmi lexer.ml parser.ml parser.mli tilde.txt