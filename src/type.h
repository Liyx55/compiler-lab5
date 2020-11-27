#ifndef TYPESYSTEM_H
#define TYPESYSTEM_H
#include "pch.h"
using namespace std;

// 值的类型
enum ValueType
{
    VALUE_BOOL,
    VALUE_INT,
    VALUE_CHAR,
    VALUE_STRING,
    VALUE_VOID,
    COMPOSE_STRUCT,
    COMPOSE_UNION,  // 复合数据类型
    COMPOSE_FUNCTION  // 函数
};


// 类型系统
class Type
{
public:
    ValueType type;  // 类型
    Type(ValueType valueType);  // 构造函数
public:  
    /* 如果你要设计复杂类型系统的话，可以修改这一部分 */
    Type* child = nullptr, *params = nullptr;
    ValueType retType;
    //ValueType* childType; // for union or struct
    //ValueType* paramType, retType; // for function
    
    void addChild(Type* t);
    void addParam(Type* t);
    void addRet(Type* t);
public:
    Type* sibling = nullptr;
    //ValueType* sibling;
    void addsibling(Type* t);
public:
    string getTypeInfo();
};

// 设置几个常量Type，可以节省空间开销
static Type* TYPE_VOID = new Type(VALUE_VOID);
static Type* TYPE_INT = new Type(VALUE_INT);
static Type* TYPE_CHAR = new Type(VALUE_CHAR);
static Type* TYPE_BOOL = new Type(VALUE_BOOL);
static Type* TYPE_STRING = new Type(VALUE_STRING);

int getSize(Type* type);  // 知道这个类型应该生成多大的空间

#endif