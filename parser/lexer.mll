{
  open Parser
  open Tilde
  exception Eof
}
rule token = parse 
    [' ' '\t'] {token lexbuf}
  | ['\n'] {EOL}
  | ['0'-'9']+ ('.' ['0'-'9']*)? (['e' 'E'] ['+' '-']? ['0'-'9']+)? as lxm { CONST(float_of_string lxm) }
  | ['a'-'z' 'A'-'Z']+ (['0'-'9'])? as lxm { VAR(lxm) }
  | '+' { PLUS }
  | '-' { MINUS }
  | '*' { TIMES }
  | '/' { DIV }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | eof { raise Eof }