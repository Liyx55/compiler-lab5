%{
    #include "common.h"
    #define YYSTYPE TreeNode *  
    TreeNode* root;
    extern int lineno;
    int yylex();
    int yyerror( char const * );
%}

%token T_CHAR T_INT T_STRING T_BOOL VOID

%token LOP_ASSIGN//+= -= *= /=

%token WHILE FOR IF ELSE RETURN PRINTF SCANF

%token LPAREN RPAREN LBRACE RBRACE COMMA POS

%token MOD
%token PLUS MINUS
%token MULT DIV
%token AND OR 
%token NOT 
%token DMINUS DPLUS//++ --
%token RELOP//== != > < >= <=

%token IDENTIFIER INTEGER CHAR BOOL STRING

%token SEMICOLON //分号

%nonassoc IFX//%nonassoc的含义是没有结合性。
%nonassoc ELSE//它一般与%prec结合使用表示该操作有同样的优先级。

%right COMMA//逗号

%right LOP_ASSIGN EQ_ASSIGN//+= -= *= /=  后一个=
%left OR //运算符
%left AND 
%left RELOP//== != > < >= <=
%left PLUS MINUS
%left MOD
%left MULT DIV

%right NOT
%right POS//按位与&
%right UDMINUS UDPLUS
%right UMINUS//负号
%right POINTER
%left DMINUS DPLUS

%%

program
: statements {root = new TreeNode(0, NODE_PROG); root->addChild($1);};

statements
:  statement {$$=$1;}
|  statements statement {$$=$1; $$->addSibling($2);}
;

statement
: SEMICOLON  {$$ = new TreeNode(lineno, NODE_STMT); $$->stype = STMT_SKIP;}
| matched_stmt %prec IFX{$$ = $1;}
| unmatched_stmt {$$ = $1;}
;

matched_stmt
: function {$$ = $1;}
| while_stmt {$$ = $1;}
| for_stmt {$$ = $1;}
| ASSIGN_stmt SEMICOLON {$$ = $1;}
| RETURN_stmt SEMICOLON {$$ = $1;}
| declaration SEMICOLON {$$ = $1;}
| printf_stmt SEMICOLON {$$ = $1;}
| scanf_stmt SEMICOLON {$$ = $1;}
| expr SEMICOLON {$$ = $1;}
| matched_if_stmt {$$ = $1;}
;

unmatched_stmt
: unmatched_if_stmt {$$ = $1;}
;

function
: T IDENTIFIER LPAREN params RPAREN LBRACE statements RBRACE {//函数有传参数的情况
    TreeNode* node = new TreeNode($1->lineno, NODE_FUNC);
    node->type = new Type(COMPOSE_FUNCTION);
    node->type->addRet($1->type);
    TreeNode* cur = $4;
    while(cur != nullptr)
    {
        node->type->addParam(cur->type);
        cur = cur->sibling;
    }
    node->addChild($1);
    node->addChild($2);
    node->addChild($4);
    node->addChild($7);
    $$ = node;
}
| T IDENTIFIER LPAREN RPAREN LBRACE statements RBRACE {//函数无参数的情况
    TreeNode* node = new TreeNode($1->lineno, NODE_FUNC);
    node->type = new Type(COMPOSE_FUNCTION);
    node->type->addRet($1->type);
    node->addChild($1);
    node->addChild($2);
    node->addChild($6);
    $$ = node;
}
;

params
: T IDENTIFIER {//简单的一个参数
    $$ = $1;
    $$->addChild($2);
}
| T IDENTIFIER EQ_ASSIGN CONST {//参数已赋值
    $$ = $1;
    $$->addChild($2);
    $$->addChild($4);
}
| params COMMA params {//多个参数
    $$ = $1;
    $$->addSibling($3);
}
;

ASSIGN_stmt
: IDENTIFIER LOP_ASSIGN expr {//+= -= *= /= 
    $$ = $2;
    $$->addChild($1);
    $$->addChild($3);
}
| IDENTIFIER EQ_ASSIGN expr {// =
    $$ = $2;
    $$->addChild($1);
    $$->addChild($3);
}
;

RETURN_stmt
: RETURN expr {
    $$ = $1;
    $$->addChild($2);
}
;

declaration
: T declare_id_list { // declare and init
    TreeNode* node = new TreeNode($1->lineno, NODE_STMT);
    node->stype = STMT_DECL;
    node->addChild($1);
    node->addChild($2);
    $$ = node;   
}
;

while_stmt
: WHILE LPAREN expr RPAREN statement {//while后面只接一句代码
    $$ = $1;
    $$->addChild($3);
    $$->addChild($5);
}
| WHILE LPAREN expr RPAREN LBRACE statements RBRACE {//while后接语句块
    $$ = $1;
    $$->addChild($3);
    $$->addChild($6);
}
;

for_stmt
: FOR LPAREN ASSIGN_stmt SEMICOLON expr SEMICOLON expr RPAREN statement {//for(int i=; ; )后接单句代码
    $$ = $1;
    $$->addChild($3);
    $$->addChild($5);
    $$->addChild($7);
    $$->addChild($9);
}
| FOR LPAREN declaration SEMICOLON expr SEMICOLON expr RPAREN statement {//for(int i; ; )后接单句代码（仅声明变量）
    $$ = $1;
    $$->addChild($3);
    $$->addChild($5);
    $$->addChild($7);
    $$->addChild($9);
}
| FOR LPAREN ASSIGN_stmt SEMICOLON expr SEMICOLON expr RPAREN LBRACE statements RBRACE {//后接代码段
    $$ = $1;
    $$->addChild($3);
    $$->addChild($5);
    $$->addChild($7);
    $$->addChild($10);
}
| FOR LPAREN declaration SEMICOLON expr SEMICOLON expr RPAREN LBRACE statements RBRACE {
    $$ = $1;
    $$->addChild($3);
    $$->addChild($5);
    $$->addChild($7);
    $$->addChild($10);
}
;


matched_if_stmt
: IF LPAREN expr RPAREN matched_stmt ELSE matched_stmt {//if（）s   else s都接单句
    $$ = $1;
    $$->addChild($3);
    $$->addChild($5);
    $$->addSibling($6);
    $6->addChild($7);
}
| IF LPAREN expr RPAREN LBRACE statements RBRACE ELSE matched_stmt {//if（）{s } else s
    $$ = $1;
    $$->addChild($3);
    $$->addChild($6);
    $$->addSibling($8);
    $8->addChild($9);
}
| IF LPAREN expr RPAREN matched_stmt ELSE LBRACE statements RBRACE {//if（）else {s}
    $$ = $1;
    $$->addChild($3);
    $$->addChild($5);
    $$->addSibling($6);
    $6->addChild($8);
}
| IF LPAREN expr RPAREN LBRACE statements RBRACE ELSE LBRACE statements RBRACE {//if（）{s } else {s}
    $$ = $1;
    $$->addChild($3);
    $$->addChild($6);
    $$->addSibling($8);
    $8->addChild($10);
}
;

unmatched_if_stmt
: IF LPAREN expr RPAREN matched_stmt ELSE unmatched_stmt {//不与if匹配
    $$ = $1;
    $$->addChild($3);
    $$->addChild($5);
    $$->addSibling($6);
    $6->addChild($7);
}
| IF LPAREN expr RPAREN LBRACE statements RBRACE ELSE unmatched_stmt {
    $$ = $1;
    $$->addChild($3);
    $$->addChild($6);
    $$->addSibling($8);
    $8->addChild($9);
}
| IF LPAREN expr RPAREN statement {
    $$ = $1;
    $$->addChild($3);
    $$->addChild($5);
}
| IF LPAREN expr RPAREN LBRACE statements RBRACE %prec IFX {
    $$ = $1;
    $$->addChild($3);
    $$->addChild($6);
}
;

printf_stmt
: PRINTF LPAREN expr RPAREN {
    $$ = $1;
    $$->addChild($3);
}
| PRINTF LPAREN STRING COMMA printf_id_list RPAREN {
    $$ = $1;
    $$->addChild($3);
    $$->addChild($5);
}
;

scanf_stmt
: SCANF LPAREN STRING COMMA scanf_id_list RPAREN {
    $$ = $1;
    $$->addChild($3);
    $$->addChild($5);
}

expr
: expr MOD expr {
    $$ = $2;
    $$->addChild($1);
    $$->addChild($3);
}
| expr PLUS expr {
    $$ = $2;
    $$->addChild($1);
    $$->addChild($3);
}
| expr MINUS expr{
    $$ = $2;
    $$->addChild($1);
    $$->addChild($3);
}
| expr MULT expr{
    $$ = $2;
    $$->addChild($1);
    $$->addChild($3);
}
| expr DIV expr{
    $$ = $2;
    $$->addChild($1);
    $$->addChild($3);
}
| expr AND expr{
    $$ = $2;
    $$->addChild($1);
    $$->addChild($3);
}
| expr OR expr{
    $$ = $2;
    $$->addChild($1);
    $$->addChild($3);
}
| expr RELOP expr{//== != > < >= <=
    $$ = $2;
    $$->addChild($1);
    $$->addChild($3);
}
| DPLUS expr %prec UDPLUS {$$ = $1; $$->addChild($2);}
| expr DPLUS {$$ = $1; $$->addChild($2);}
| DMINUS expr %prec UDMINUS{$$ = $1; $$->addChild($2);}
| expr DMINUS {$$ = $1; $$->addChild($2);}
| NOT expr {$$ = $1; $$->addChild($2);}
| MINUS expr %prec UMINUS { $$ = $1; $$->addChild($2);}
| LPAREN expr RPAREN {$$ = $1; $$->addChild($2);}
| term {$$ = $1;}
;

term
: IDENTIFIER {
    $$ = $1;
}
| CONST {
    $$ = $1;
}
;

CONST
: INTEGER {
    $$ = $1;
}
| CHAR {
    $$ = $1;
}
| STRING {
    $$ = $1;
}
;

declare_id_list
: ASSIGN_stmt {$$ = $1; $$->nodeType = NODE_INIT;}
| MULT IDENTIFIER %prec POINTER {$$ = $2;}// *a ：指针
| IDENTIFIER {$$ = $1;}
| declare_id_list COMMA declare_id_list {$$ = $1; $$->addSibling($3);}
;

printf_id_list
: expr {$$ = $1;}
| printf_id_list COMMA printf_id_list {$$ = $1; $$->addSibling($3);}
;

scanf_id_list
: IDENTIFIER {$$ = $1;}
| POS IDENTIFIER {$$ = $2;}//例如&a
| scanf_id_list COMMA scanf_id_list {$$ = $1; $$->addSibling($3);}
;

T: T_INT {$$ = new TreeNode(lineno, NODE_TYPE); $$->type = TYPE_INT;} 
| T_CHAR {$$ = new TreeNode(lineno, NODE_TYPE); $$->type = TYPE_CHAR;}
| T_BOOL {$$ = new TreeNode(lineno, NODE_TYPE); $$->type = TYPE_BOOL;}
| VOID {$$ = new TreeNode(lineno, NODE_TYPE); $$->type = TYPE_VOID;}
;


%%

int yyerror(char const* message)
{
    cout << message << " at line " << lineno << endl;
    return -1;
}
