%option nounput
%{
#include "common.h"
#include "main.tab.h"  // yacc header
int lineno = 1;  // 行号

/*void insert(const char*letter,char*lexeme,char* type);
int lookup(const char*letter,char*lexeme);
char* tp=new char[3];*/

int id_count=0;
string lasttoken;
int count_c=0;

struct List_Node{
public:
    string name;
    stack<char> s;
    int count = 0;
    int num = 0;
    int flag;
    struct List_Node* next=nullptr;
    List_Node(string name);
    void genCount();
    void IDcount();
};

List_Node* first=nullptr;
List_Node* tail=nullptr;
int Insert_undef_ID(string name);
int Insert_def_ID(string name);
void stack_add();
void stack_sub();

List_Node::List_Node(string name)
{
    this->name = name;
}

void List_Node::genCount()
{
    this->count += 1;
}

void List_Node::IDcount()
{
    this->num = id_count;
}

//若找到同名且stack为空的节点则为重复声明
int Insert_undef_ID(string name){
    if(first==nullptr)
    {
        List_Node* node = new List_Node(name);
        node->flag = 1;
        id_count += 1;
        node->IDcount();
        first = tail = node;
        first->genCount();
        return first->num;   //正常返回
    }
    else{
        List_Node* cur = first;
        while(cur)
        {
            if(cur->name==name && cur->s.empty() && cur->flag==1)
            {
                cout<<"line "<<lineno<<" error:"<<name<<"变量重复声明"<<endl;
                return -1;   //重复声明,报错
            }
            cur = cur->next;
        }
        //若不是在同一个作用域，则使用尾插法添加节点
        List_Node* node = new List_Node(name);
        node->flag = 1;
        id_count += 1;
        node->IDcount();
        tail->next = node;
        tail = node;
        tail->genCount();
        return tail->num;
    }
}

//找同名且stack最小的
int Insert_def_ID(string name)
{
    int min_count=100;
    if(first==nullptr)
    {
        cout<<"line "<<lineno<<" error:"<<name<<"变量未声明"<<endl;
        return -1;  //未声明变量
    }
    List_Node* cur = first;
    List_Node* node;
    while(cur)
    {
        if(cur->name==name && cur->flag==1 && (int)cur->s.size()<min_count)
        {
            node = cur;
            min_count = (int)cur->s.size();
        }
        cur = cur->next;
    }
    if(min_count!=100)
    {
        node->genCount();
        return node->num;
    }
    else{
        cout<<"line "<<lineno<<" error:"<<name<<"变量未声明"<<endl;
        return -1;  //未声明变量
    }
}

//遇到左大括号，所有ID的stack加上一个元素1
void stack_add()
{
    List_Node* cur = first;
    while(cur)
    {
        if(cur->flag==1)
            cur->s.push('L');
        cur = cur->next;
    }
}

//遇到右大括号，所有ID的stack pop掉一个元素，如果stack为空了，就释放掉节点
void stack_sub()
{
    List_Node* cur = first;
    while(cur)
    {
        if(!cur->s.empty())
        {
            cur->s.pop();
        }
        else cur->flag = 0;
        cur = cur->next;
    }
}

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


"int" { lasttoken = yytext; return T_INT;};
"bool" { lasttoken = yytext; return T_BOOL;};
"char" {lasttoken = yytext; return T_CHAR;};
"void"  {lasttoken = yytext;return VOID;};

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

"{" {lasttoken = " "; stack_add(); return LBRACE;};
"}" {stack_sub();return RBRACE;};

"," return COMMA;
";" {lasttoken = " "; return SEMICOLON;};
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
    int x;
    if(lasttoken==" ")
    {
        x = Insert_def_ID(yytext);
        //cout<<yytext<<":"<<x<<endl;
    }
    else{
        x = Insert_undef_ID(yytext);
        //cout<<yytext<<":"<<x<<endl;
    }
    
    TreeNode* node = new TreeNode(lineno, NODE_VAR);
    node->var_name = string(yytext);
    node->scope=x;
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
/*struct symbol1{
 char* letter;  //单词
 char* lexeme;   //词素 
 char* type;   //类型
 int value;    //第几个这样的
 struct symbol1 *m_next;//下一个symtable的字符
};
struct symbol1* symtable;//symtable中的第一个元素
int lookup(const char*letter,char*lexeme)
{
 struct symbol1 *st=symtable;
 int count=-1;
 for(;st;st=st->m_next)
 {
   if(strcmp(st->letter,letter)==0)   //有这个单词则计数++
   {
     count++;
     if(strcmp(st->lexeme,lexeme)==0)
     {
       return -2;   //说明已在符号表中
     }
   } 
 }
 return count;
}
void insert(const char*letter,char*lexeme,char* type)
{
    struct symbol1 *st;
    int count=lookup(letter,lexeme);
    if(count==-2)//已在则返回
    {
      return ;
    }
    //不在
    st=(struct symbol1*)malloc(sizeof(struct symbol1));
    st->m_next=symtable;
    st->letter=(char*)malloc(strlen(letter)+1);
    strcpy(st->letter,letter);
    st->lexeme=(char*)malloc(strlen(lexeme)+1);
    strcpy(st->lexeme,lexeme);
    st->value=count+1;
    st->type=type;
    cout<<"单词   "<<st->letter<<"\t\t"<<"词素   "<<st->lexeme<<"\t"<<"类型    "<<st->type<<"\t"<<"属性   "<<st->value<<endl;
    cout<<"单词   "<<st->letter<<"\t\t"<<"词素   "<<st->lexeme<<"\t"<<"类型    "<<st->type<<"\t"<<"属性   "<<st->value<<endl;
    symtable=st;   //symtable第一个变为st 
}*/