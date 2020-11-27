#include "type.h"

// 构造函数
Type::Type(ValueType valueType) {
    this->type = valueType;
}

string Type::getTypeInfo() {
    switch(this->type) {
        case VALUE_BOOL:
            return "bool";
        case VALUE_INT:
            return "int";
        case VALUE_CHAR:
            return "char";
        case VALUE_STRING:
            return "string";
        case VALUE_VOID:
            return "void";
        default:
            cerr << "shouldn't reach here, typeinfo";
            assert(0);
    }
    return "?";
}

void Type::addChild(Type* t)
{
    Type* cur = this->child;
    if(cur == nullptr)
        this->child = t;
    else
    {
        while(cur->sibling != nullptr)
            cur = cur->sibling;
        cur->sibling = t;
    }
}

void Type::addParam(Type* t)
{
    Type* cur = this->params;
    if(cur == nullptr)
        this->params = t;
    else
    {
        while(cur->sibling != nullptr)
            cur = cur->sibling;
        cur->sibling = t;
    }
}

void Type::addRet(Type* t)
{
    this->retType = t->type;
}

int getSize(Type* type)
{
    switch (type->type)
    {
        case VALUE_BOOL:
            return 1;
        case VALUE_INT:
            return 4;
        case VALUE_CHAR:
            return 1;
        default:
            return 0;
    }
}

void Type::addsibling(Type* t)
{
    Type* cur = this;
    while(cur->sibling != nullptr)
        cur = cur->sibling;
    cur->sibling = t;
}
