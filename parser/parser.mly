%token <float> CONST 
%token PLUS MINUS TIMES DIV 
%token LPAREN RPAREN
%token EOL
%left PLUS MINUS 
%left TIMES DIV
%nonassoc UMINUS 
%start main
%type <float> main 
%%
main:
    expr EOL { $1 }
;
expr:
      CONST { $1 }
    | LPAREN expr RPAREN { $2 }
    | expr PLUS expr { $1 +. $3 }
    | expr MINUS expr { $1 -. $3 }
    | expr TIMES expr { $1 *. $3 }
    | expr DIV expr { $1 /. $3 }
    | MINUS expr %prec UMINUS { -. $2 }
;