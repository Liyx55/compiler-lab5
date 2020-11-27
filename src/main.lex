%option nounput
%{
#include "common.h"
#include "main.tab.h"  // yacc header
int lineno = 1;  // 行号
%}

WHILE           while
FOR             for
IF              if
ELSE            else
RETURN          return
PRINTF          printf
SCANF           scanf

BLOCKCOMMENT \/\*([^\*^\/]*|[\*^\/*]*|[^\**\/]*)*\*\/
LINECOMMENT \/\/[^\n]*
EOL	(\r\n|\r|\n)
WHILTESPACE [[:blank:]]

ASSIGN          [*][=]|[+][=]|[-][=]|[/][=]
RELOP           [>]|[<]|[>][=]|[<][=]|[=][=]|[!][=]

INTEGER [0-9]+

CHAR \'.?\'
STRING \".+\"

IDENTIFIER [[:alpha:]_][[:alpha:][:digit:]_]*

%%

{BLOCKCOMMENT}  /* do nothing */
{LINECOMMENT}  /* do nothing */


"int" return T_INT;
"bool" return T_BOOL;
"char" return T_CHAR;
"void" return VOID;

"++" {
    TreeNode* node = new TreeNode(lineno, NODE_EXPR);
    node->optype = OP_DPLUS;
    yylval = node;
    return DPLUS;
}
"--" {
    TreeNode* node = new TreeNode(lineno, NODE_EXPR);
    node->optype = OP_DMINUS;
    yylval = node;
    return DMINUS;
}

"(" {
    TreeNode* node = new TreeNode(lineno, NODE_EXPR);
    node->optype = OP_P;
    yylval = node;
    return LPAREN;
}
")" return RPAREN;
"{" return LBRACE;
"}" return RBRACE;
"," return COMMA;
";" return  SEMICOLON;
"+" {
    TreeNode* node = new TreeNode(lineno, NODE_EXPR);
    node->optype = OP_PLUS;
    yylval = node;
    return PLUS;
}
"-" {
    TreeNode* node = new TreeNode(lineno, NODE_EXPR);
    node->optype = OP_MINUS;
    yylval = node;
    return MINUS;
}
"*" {
    TreeNode* node = new TreeNode(lineno, NODE_EXPR);
    node->optype = OP_MULT;
    yylval = node;
    return MULT;
}
"/" {
    TreeNode* node = new TreeNode(lineno, NODE_EXPR);
    node->optype = OP_DIV;
    yylval = node;
    return DIV;
}
"&&" {
    TreeNode* node = new TreeNode(lineno, NODE_EXPR);
    node->optype = OP_AND;
    yylval = node;
    return AND;
}
"||" {
    TreeNode* node = new TreeNode(lineno, NODE_EXPR);
    node->optype = OP_OR;
    yylval = node;
    return OR;
}
"!" {
    TreeNode* node = new TreeNode(lineno, NODE_EXPR);
    node->optype = OP_NOT;
    yylval = node;
    return NOT;
}
"&" {
    TreeNode* node = new TreeNode(lineno, NODE_EXPR);
    node->optype = OP_POS;
    yylval = node;
    return POS;
}
"%" {
    TreeNode* node = new TreeNode(lineno, NODE_EXPR);
    node->optype = OP_MOD;
    yylval = node;
    return MOD;
}


{WHILE} {
    TreeNode* node = new TreeNode(lineno, NODE_STMT);
    node->stype = STMT_WHILE;
    yylval = node;
    return WHILE;
}

{RETURN} {
    TreeNode* node = new TreeNode(lineno, NODE_STMT);
    yylval = node;
    return RETURN;
}

{FOR} {
    TreeNode* node = new TreeNode(lineno, NODE_STMT);
    node->stype = STMT_FOR;
    yylval = node;
    return FOR;
}

{IF} {
    TreeNode* node = new TreeNode(lineno, NODE_STMT);
    node->stype = STMT_IF;
    yylval = node;
    return IF;
}

{ELSE} {
    TreeNode* node = new TreeNode(lineno, NODE_STMT);
    node->stype = STMT_ELSE;
    yylval = node;
    return ELSE;
}

{PRINTF} {
    TreeNode* node = new TreeNode(lineno, NODE_STMT);
    node->stype = STMT_PRINTF;
    yylval = node;
    return PRINTF;
}

{SCANF} {
    TreeNode* node = new TreeNode(lineno, NODE_STMT);
    node->stype = STMT_SCANF;
    yylval = node;
    return SCANF;
}

{ASSIGN} {
    TreeNode* node = new TreeNode(lineno, NODE_STMT);
    node->stype = STMT_ASSIGN;
    yylval = node;
    if(!memcmp(yytext, "+=", 2))
        node->optype = OP_PLUSASSIGN;
    else if(!memcmp(yytext, "-=", 2))
        node->optype = OP_MINUSASSIGN;
    else if(!memcmp(yytext, "*=", 2))
        node->optype = OP_MULASSIGN;
    else if(!memcmp(yytext, "/=", 2))
        node->optype = OP_DIVASSIGN;
    return LOP_ASSIGN;
}

"=" {
    TreeNode* node = new TreeNode(lineno, NODE_STMT);
    node->stype = STMT_ASSIGN;
    node->optype = OP_ASSIGN;
    yylval = node;
    return EQ_ASSIGN;
}

{RELOP} {
    TreeNode* node = new TreeNode(lineno, NODE_EXPR);
    yylval = node;
    if(!memcmp(yytext, "==", 2))
        node->optype = OP_EQ;
    else if(!memcmp(yytext, "!=", 2))
        node->optype = OP_NEQ;
    else if(!memcmp(yytext, ">", 2))
        node->optype = OP_L;
    else if(!memcmp(yytext, ">=", 2))
        node->optype = OP_LEQ;
    else if(!memcmp(yytext, "<", 2))
        node->optype = OP_S;
    else if(!memcmp(yytext, "<=", 2))
        node->optype = OP_SEQ;
    return RELOP;
}

{INTEGER} {
    TreeNode* node = new TreeNode(lineno, NODE_CONST);
    node->type = TYPE_INT;
    node->int_val = atoi(yytext);
    yylval = node;
    return INTEGER;
}

{CHAR} {
    TreeNode* node = new TreeNode(lineno, NODE_CONST);
    node->type = TYPE_CHAR;
    node->ch_val = yytext[1];
    yylval = node;
    return CHAR;
}

{IDENTIFIER} {
    TreeNode* node = new TreeNode(lineno, NODE_VAR);
    node->var_name = string(yytext);
    yylval = node;
    return IDENTIFIER;
}

{STRING} {
    TreeNode* node = new TreeNode(lineno, NODE_CONST);
    node->type = TYPE_STRING;
    node->str_val = yytext;
    yylval = node;
    return STRING;
}

{WHILTESPACE} /* do nothing */

{EOL} lineno++;

. {
    cerr << "[line "<< lineno <<" ] unknown character:" << yytext << endl;
}
%%