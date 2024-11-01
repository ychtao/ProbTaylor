%{
    open Tilde
%}

%token <float> CONST 
%token <string> VAR
%token PLUS MINUS TIMES DIV 
%token LPAREN RPAREN
%token EOL
%left PLUS MINUS 
%left TIMES DIV
%nonassoc UMINUS 
%start main
%type <Tilde.expr> main 
%%
main:
    expr EOL { $1 }
;
expr:
      CONST { Const $1 }
    | VAR { Var $1 }
    | LPAREN expr RPAREN { $2 }
    | expr PLUS expr { Add ($1, $3) }
    | expr MINUS expr { Min ($1, $3) }
    | expr TIMES expr { Mul ($1, $3) }
    | expr DIV expr { Div ($1, $3) }
    | MINUS expr %prec UMINUS { Min (Const 0., $2) }
;