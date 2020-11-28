#include "common.h"
#include <fstream>

extern TreeNode *root;  // main.y
extern FILE *yyin;  // yacc缺省输入
extern int yyparse();//进行语法分析

using namespace std;
int main(int argc, char *argv[])
{
    // 写入文件
    if (argc == 2)
    {
        FILE *fin = fopen(argv[1], "r");
        if (fin != nullptr)
        {
            yyin = fin;
        }
        else
        {
            cerr << "failed to open file: " << argv[1] << endl;
        }
    }
    // yacc生成的语法分析程序的入口点
    yyparse();//开始进行语法分析
    if(root != NULL) {
        root->genNodeId();  // 为整棵语法树授予id
        root->printAST();
    }
    return 0;
}
