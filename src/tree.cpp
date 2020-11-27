#include "tree.h"

// 构造函数
TreeNode::TreeNode(int lineno, NodeType type) {
    this->lineno = lineno;
    this->nodeType = type;
}

// 添加孩子结点
void TreeNode::addChild(TreeNode* child) {
    // 若当前没有孩子
    if(this->child == nullptr)
        this->child = child;
    else
        this->child->addSibling(child);
}

void TreeNode::addSibling(TreeNode* sibling){
    TreeNode* cur = this;
    // 循环找到链表的尾部
    while(cur->sibling != nullptr)
        cur = cur->sibling;
    cur->sibling = sibling;
}

// 为树上每个节点分配序号
void TreeNode::genNodeId() {
    int cur_nodeID = 0;
    this->nodeID = cur_nodeID++;
    TreeNode* cur;
    // 深度优先遍历排序号
    stack<TreeNode*> s;
    s.push(this);
    while(!s.empty())
    {
        cur = s.top();
        TreeNode* child = cur->child;
        while(child != nullptr && child->nodeID != -1)
            child = child->sibling;
        if(child == nullptr)
            s.pop();
        else
        {
            child->nodeID = cur_nodeID++;
            s.push(child);
        }
    }
}

void TreeNode::printNodeInfo() {
    // 输出行号信息
    cout << "lno@" << this->lineno << "\t@" << this->nodeID << '\t';
    
    // 输出类型
    cout << this->nodeType2String(this->nodeType) << '\t';

    // 输出附加信息
    // 如果是常量或类型，输出类型
    if(this->nodeType == NODE_CONST || this->nodeType == NODE_TYPE)
        cout << "type: " << this->type->getTypeInfo() << '\t';
    // 如果是变量，输出变量名
    else if(this->nodeType == NODE_VAR)
        cout << "varname: " << this->var_name << '\t';
    else if(this->nodeType == NODE_OP)
        cout << "op: " << this->getOP() << '\t';
    this->printConstValue();
    this->printOP();
    // 如果有孩子就输出孩子
    this->printChildrenId();
    // 如果是语句，输出语句类型
    if(this->nodeType == NODE_STMT)
        cout << this->sType2String(this->stype) << '\t';
    cout << endl;
}

void TreeNode::printChildrenId() {
    // 遍历输出所有孩子的id
    TreeNode* child = this->child;
    if(child == nullptr)
        return;
    cout<< "children: [";
    while(child != nullptr)
    {
        cout<< "@" << child->nodeID << " ";
        child = child->sibling;
    }
    cout << "]\t";
}

void TreeNode::printAST() {
    int max = 0, before_line = 0;
    this->printNodeInfo();
    TreeNode* cur;
    // 深度优先遍历排序号
    stack<TreeNode*> s;
    s.push(this);
    while(!s.empty())
    {
        cur = s.top();
        TreeNode* child = cur->child;
        while(child != nullptr && child->nodeID <= max)
            child = child->sibling;
        if(child == nullptr)
            s.pop();
        else
        {
            if(child->lineno > before_line)
            {
                cout << endl;
                before_line = child->lineno;
            }
            // 仅在压栈时输出
            child->printNodeInfo();
            max = child->nodeID;
            s.push(child);
        }
    }
}

void TreeNode::printConstValue() {
    if(this->nodeType != NODE_CONST)
        return;
    switch(this->type->type) {
        case VALUE_INT:
            cout << "value: " << this->int_val << '\t';
            break;
        case VALUE_CHAR:
            cout << "value:" << this->ch_val << '\t';
            break;
        case VALUE_STRING:
            cout << "value:" << this->str_val << '\t';
            break;
        default:
            break;
    }
    return;
}

void TreeNode::printOP() {
    string op = this->getOP();
    if(op == "unknown op") return;
    if(this->nodeType != NODE_EXPR && !(this->nodeType == NODE_STMT && this->stype == STMT_ASSIGN)) return;
    cout << "op: " << op << '\t';
    return;
}

string TreeNode::getOP() {
    switch (optype)
    {
    case OP_PLUS:
        return "+";
    case OP_MINUS:
        return "-";
    case OP_MULT:
        return "*";
    case OP_DIV:
        return "/";
    case OP_AND:
        return "&&";
    case OP_OR:
        return "||";
    case OP_NOT:
        return "!";
    case OP_ASSIGN:
        return "=";
    case OP_MULASSIGN:
        return "*=";
    case OP_PLUSASSIGN:
        return "+=";
    case OP_MINUSASSIGN:
        return "-=";
    case OP_DIVASSIGN:
        return "/=";
    case OP_L:
        return ">";
    case OP_LEQ:
        return ">=";
    case OP_S:
        return "<";
    case OP_SEQ:
        return "<=";
    case OP_EQ:
        return "==";
    case OP_NEQ:
        return "!=";
    case OP_P:
        return "()";
    case OP_DPLUS:
        return "++";
    case OP_DMINUS:
        return "--";
    case OP_MOD:
        return "%";
    case OP_POS:
        return "&";
    default:
        return "unknown op";
    }
}


// You can output more info...
void TreeNode::printSpecialInfo() {
    switch(this->nodeType){
        case NODE_CONST:
            break;
        case NODE_VAR:
            break;
        case NODE_EXPR:
            break;
        case NODE_STMT:
            break;
        case NODE_TYPE:
            break;
        default:
            break;
    }
}

string TreeNode::sType2String(StmtType type) {
    switch (type)
    {
    case STMT_SKIP:
        return "skip";
    case STMT_DECL:
        return "decl";
    case STMT_ASSIGN:
        return "assign";
    case STMT_IF:
        return "if";
    case STMT_ELSE:
        return "else";
    case STMT_WHILE:
        return "while";
    case STMT_PRINTF:
        return "prinf";
    case STMT_SCANF:
        return "scanf";
    case STMT_FOR:
        return "for";
    default:
        break;
    }
    return "nonetype";
}


string TreeNode::nodeType2String (NodeType type){
    switch (type)
    {
    case NODE_CONST:
        return "const";
    case NODE_VAR:
        return "variable";
    case NODE_EXPR:
        return "expression";
    case NODE_TYPE:
        return "type";
    case NODE_STMT:
        return "statement";
    case NODE_PROG:
        return "program";
    case NODE_INIT:
        return "initiation";
    case NODE_FUNC:
        return "function";
    case NODE_PARAM:
        return "parameters";
    case NODE_OP:
        return "operation";
    default:
        break;
    }
    return "nonetype";
}
