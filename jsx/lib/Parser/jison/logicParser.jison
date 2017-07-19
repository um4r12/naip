/* using JISON Lexical analysis with Flex pattern matching (http://dinosaur.compilertools.net/flex/flex_11.html) */

/* description: Parses end executes mathematical expressions. */

/* lexical grammar */
%lex
%%

\s+                                 /* skip whitespace */
"null"                              return 'null'
"true"                              return 'true'
"false"                             return 'false'
"E"                                 return 'E'
"PI"                                return 'PI'
\d+("."\d+)?\b                      return 'NUMBER'
"*"                                 return '*'
"/"                                 return '/'
"-"                                 return '-'
"+"                                 return '+'
"^"                                 return '^'
"="                                 return '='
"!"                                 return '!'
"%"                                 return '%'
"("                                 return '('
")"                                 return ')'
","                                 return ','
"<>"								return '<>'
"<="								return '<='
">="								return '>='
"<"                                 return '<'
">"                                 return '>'
"and"                               return 'and'
"or"                                return 'or'
"not"                               return 'not'
[_a-zA-Z0-9]\w*                     return 'VARIABLE'
"\""[^"]*"\""                       return 'ESTRING'
"'"[^']*"'"                         return 'STRING'
"["                                 return '['
"]"                                 return ']'
<<EOF>>                             return 'EOF'
.                                   return 'INVALID'

/lex

/* operator associations and precedence */

%left 'and' 'or'
%right 'not'
%left '=' '<' '>' '<>' '<=' '>='
%left '+' '-'
%left '*' '/'
%left '^'
%right '!'
%right '%'
%left UMINUS

%start expressions

%% /* language grammar */

expressions
    : e EOF
        { return $1; }
    ;

arguments
    : e ',' arguments
        //js
        { $$ = [$1].concat($3); } //
        //php { $$ = [$1].$3; } //
    | e
        { $$ = [$1]; }
    ;

variable
    : VARIABLE
        { $$ = yytext; }
    ;

constant
    : 'E'
        //js
        { $$ = Math.E; } //
        //php { $$ = M_E; } //
    | 'PI'
        //js
        { $$ = Math.PI; } //
        //php { $$ = M_PI; } //
    ;

accessors
    : '[' variable ']' accessors
        //js
        { $$ = [$2].concat($4); } //
        //php { $$ = [$2].$4; } //
    | '[' variable '(' NUMBER ')' ']' accessors
        //js
        { $$ = [$2].concat($4, $7); } //
        //php { $$ = [$2].$4.$7; } //
    | '[' variable '(' variable ')' ']' accessors
        //js
        { $$ = [$2].concat($4, $7); } //
        //php { $$ = [$2].$4.$7; } //
    | '[' variable '(' NUMBER ')' ']'
        //js
        { $$ = [$2].concat($4); } //
        //php { $$ = [$2].$4; } //
    | '[' variable '(' variable ')' ']'
        //js
        { $$ = [$2].concat($4); } //
        //php { $$ = [$2].$4; } //
    | '[' variable ']'
        { $$ = [$2]; }
    ;
e
    : e '=' e
        //js
        { $$ = {tag: 'BinaryOp', op: 'eq', args: [$1, $3]}; } //
        //php { $$ = array('tag' => 'BinaryOp', 'op' => 'eq', 'args' => [$1, $3]); } //
    | e '<' e
        //js
        { $$ = {tag: 'BinaryOp', op: 'lt', args: [$1, $3]}; } //
        //php { $$ = array('tag' => 'BinaryOp', 'op' => 'lt', 'args' => [$1, $3]); } //
    | e '>' e
        //js
        { $$ = {tag: 'BinaryOp', op: 'gt', args: [$1, $3]}; } //
        //php { $$ = array('tag' => 'BinaryOp', 'op' => 'gt', 'args' => [$1, $3]); } //
    | e '<>' e
        //js
        { $$ = {tag: 'BinaryOp', op: 'neq', args: [$1, $3]}; } //
        //php { $$ = array('tag' => 'BinaryOp', 'op' => 'neq', 'args' => [$1, $3]); } //
    | e '<=' e
        //js
        { $$ = {tag: 'BinaryOp', op: 'leq', args: [$1, $3]}; } //
        //php { $$ = array('tag' => 'BinaryOp', 'op' => 'leq', 'args' => [$1, $3]); } //
    | e '>=' e
        //js
        { $$ = {tag: 'BinaryOp', op: 'geq', args: [$1, $3]}; } //
        //php { $$ = array('tag' => 'BinaryOp', 'op' => 'geq', 'args' => [$1, $3]); } //
	| e '+' e
        //js
        { $$ = {tag: 'BinaryOp', op: 'add', args: [$1, $3]}; } //
        //php { $$ = array('tag' => 'BinaryOp', 'op' => 'add', 'args' => [$1, $3]); } //
    | e '-' e
        //js
        { $$ = {tag: 'BinaryOp', op: 'sub', args: [$1, $3]}; } //
        //php { $$ = array('tag' => 'BinaryOp', 'op' => 'sub', 'args' => [$1, $3]); } //
    | e '*' e
        //js
        { $$ = {tag: 'BinaryOp', op: 'mul', args: [$1, $3]}; } //
        //php { $$ = array('tag' => 'BinaryOp', 'op' => 'mul', 'args' => [$1, $3]); } //
    | e '/' e
        //js
        { $$ = {tag: 'BinaryOp', op: 'div', args: [$1, $3]}; } //
        //php { $$ = array('tag' => 'BinaryOp', 'op' => 'div', 'args' => [$1, $3]); } //
    | e '^' e
        //js
        { $$ = {tag: 'BinaryOp', op: 'pow', args: [$1, $3]}; } //
        //php { $$ = array('tag' => 'BinaryOp', 'op' => 'pow', 'args' => [$1, $3]); } // 
    | e '%' e
        //js
        { $$ = {tag: 'BinaryOp', op: 'mod', args: [$1, $3]}; } //
        //php { $$ = array('tag' => 'BinaryOp', 'op' => 'mod', 'args' => [$1, $3]); } //
    | e 'and' e
        //js
        { $$ = {tag: 'BinaryOp', op: 'and', args: [$1, $3]}; } //
        //php { $$ = array('tag' => 'BinaryOp', 'op' => 'and', 'args' => [$1, $3]); } //
    | e 'or' e
        //js
        { $$ = {tag: 'BinaryOp', op: 'or', args: [$1, $3]}; } //
        //php { $$ = array('tag' => 'BinaryOp', 'op' => 'or', 'args' => [$1, $3]); } //
    | 'not' e
        //js
        { $$ = {tag: 'UnaryOp', op: 'not', args: [$2]}; } //
        //php { $$ = array('tag' => 'UnaryOp', 'op' => 'not', 'args' => [$2]); } //
	| e '%'
        //js
        { $$ = {tag: 'UnaryOp', op: 'per', args: [$1]}; } //
        //php { $$ = array('tag' => 'UnaryOp', 'op' => 'per', 'args' => [$1]); } //
    | e '!'
        //js
        { $$ = {tag: 'UnaryOp', op: 'fact', args: [$1]}; } //
        //php { $$ = array('tag' => 'UnaryOp', 'op' => 'fact', 'args' => [$1]); } //
    | '-' e %prec UMINUS
        //js
        { $$ = {tag: 'UnaryOp', op: 'negate', args: [$2]}; } //
        //php { $$ = array('tag' => 'UnaryOp', 'op' => 'negate', 'args' => [$2]); } //
    | '(' e ')'
        //js
        { $$ = {tag: 'NestedExpression', args: [$2]}; } //
        //php { $$ = array('tag' => 'NestedExpression', 'args' => [$2]); } //
    | variable '(' arguments ')'
        //js
        { $$ = {tag: 'FuncApplication', args:[$1, $3]}; } //
        //php { $$ = array('tag' => 'FuncApplication', 'args' => [$1, $3]); } //
    | "[" variable "]" accessors
        //js
        { $$ = {tag: 'NestedVariables', args: [$2, $4]}; } //
        //php { $$ = array('tag' => 'NestedVariables', 'args' => [$2, $4]; } //
    | "[" variable "]"
        //js
        { $$ = {tag: 'Variable', args: [$2]}; } //
        //php { $$ = array('tag' => 'Variable', 'args' => [$2]; } //
    | "[" variable "(" NUMBER ")" "]" accessors
        //js
        { $$ = {tag: 'NestedVariables', args: [$2, [$4]]}; } //
        //php { $$ = array('tag' => 'NestedVariables', 'args' => [$2, [$4]]); } //
    | "[" variable "(" variable ")" "]" accessors
        //js
        { $$ = {tag: 'NestedVariables', args: [$2, [$4]]}; } //
        //php { $$ = array('tag' => 'NestedVariables', 'args' => [$2, [$4]]); } //
    | "[" variable "(" NUMBER ")" "]"
        //js
        { $$ = {tag: 'NestedVariables', args: [$2, [$4]]}; } //
        //php { $$ = array('tag' => 'NestedVariables', 'args' => [$2, [$4]]); } //
    | "[" variable "(" variable ")" "]"
        //js
        { $$ = {tag: 'NestedVariables', args: [$2, [$4]]}; } //
        //php { $$ = array('tag' => 'NestedVariables', 'args' => [$2, [$4]]); } //
	| constant
        //js
        { $$ = {tag: 'Literal', args: [$1]}; } //
        //php { $$ = array('tag' => 'Literal', 'args' => [$1]); } //
    | NUMBER
        //js
        { $$ = {tag: 'Literal', args: [Number(yytext)]}; } //
        //php { $$ = array('tag' => 'Literal', 'args' => [floatval(yytext)]); } //
    | STRING
        //js
        { $$ = {tag: 'String', args: [yytext]}; } //
        //php { $$ = array('tag' => 'String', 'args' => [yytext]); } //
    | ESTRING
        //js
        { $$ = {tag: 'String', args: [yytext]}; } //
        //php { $$ = array('tag' => 'String', 'args' => [yytext]); } //
    | 'false'
        //js
        { $$ = {tag: 'Literal', args: [false]}; } //
        //php { $$ = array('tag' => 'Literal', 'args' => [false]); } //
    | 'true'
        //js
        { $$ = {tag: 'Literal', args: [true]}; } //
        //php { $$ = array('tag' => 'Literal', 'args' => [true]); } //
    | 'null'
        //js
        { $$ = {tag: 'Literal', args: [null]}; } //
        //php { $$ = array('tag' => 'Literal', 'args' => [null]); } //
    ;