#ifndef TREE_H
#define TREE_H

#include "pch.h"
#include "type.h"

// 节点类型
// 可以直接把if else while等直接放在这里，而不是全部再放到stmt里
enum NodeType
{
    NODE_CONST,  // 常量
    NODE_VAR,  // 变量
    NODE_EXPR,  // 表达式
    NODE_TYPE,  // 类型
    NODE_INIT,  // 初始化
    NODE_PARAM, 
    NODE_OP,  // 操作符

    NODE_STMT,
    NODE_PROG,
    NODE_FUNC
};

// 操作数类型
enum OperatorType
{
    OP_PLUS,  // +
    OP_MINUS,  // -
    OP_MULT,  // *
    OP_DIV,  // /
    OP_AND,  // &&
    OP_OR,  // ||
    OP_NOT,  // !
    OP_ASSIGN,  // =
    OP_MULASSIGN,
    OP_PLUSASSIGN,
    OP_MINUSASSIGN,
    OP_DIVASSIGN,
    OP_L,  // >
    OP_LEQ,  // >=
    OP_S,  // <
    OP_SEQ,  // <=
    OP_EQ,  // ==
    OP_NEQ,  // !=
    OP_P,  // ()
    OP_DPLUS,  // ++
    OP_DMINUS,  // --
    OP_MOD,  // %
    OP_POS,  // &
};

// 语句类型
enum StmtType {
    STMT_SKIP,  // continue break
    STMT_DECL,
    STMT_ASSIGN,
    // STMT_SEQ,
    STMT_IF,
    STMT_ELSE,
    STMT_WHILE,
    STMT_FOR,
    STMT_PRINTF,
    STMT_SCANF,
    STMT_RETURN
}
;

// 树结点
struct TreeNode {
public:

    int nodeID = -1;  // 用于作业的序号输出
    int lineno;  // 行号
    NodeType nodeType;  // 结点类型

    TreeNode* child = nullptr;  // 孩子结点的链表
    TreeNode* sibling = nullptr;  // 当前节点的兄弟结点链表的入口

    void addChild(TreeNode*);  // 增加孩子
    void addSibling(TreeNode*);  // 增加兄弟
    
    void printNodeInfo();  // 打印当前结点信息
    void printChildrenId();  // 打印孩子id

    void printAST(); // 先输出自己 + 孩子们的id；再依次让每个孩子输出AST。
    void printSpecialInfo();

    void genNodeId();  // 单独处理结点id

public:
    OperatorType optype;  // 如果是表达式，就记录操作符

    /*
    * 包含：
    * 值的类型
    * 孩子节点的类型
    * 参数的类型，返回值的类型
    * 兄弟节点的类型
    */
    Type* type;  // 变量、类型、表达式结点，有类型。

    StmtType stype;  // 表达式的类型
    // 变量的值
    int int_val;
    char ch_val;
    bool b_val;

    string str_val;  // string值
    string var_name;  // 变量名字
    int scope;
    void printConstValue();  // 如果是常量，就输出内容
    void printOP();  // 打印运算符
    string getOP();  // 获得运算符

public:
    // 把一些信息转换为string类型后输出
    static string nodeType2String (NodeType type);
    static string opType2String (OperatorType type);
    static string sType2String (StmtType type);

public:
    // 构造函数
    TreeNode(int lineno, NodeType type);
};

#endif
