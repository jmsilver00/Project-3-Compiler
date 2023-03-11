
//AST implementation
#include <string.h>
#include <stdio.h>

//struct 'AST' is defined with 5 fields:
//nodeType: identifies the type of AST node such as "assingment" or "type"
//LHS: LHS and RHS fields are strings holding the left and right had side of expressions 
//RHS
//left: left and right are pointers to child AST nodes to represent the left and right subtrees
//right


struct AST{
	char nodeType[50];
	char LHS[50];
	char RHS[50];
	struct AST * left;
	struct AST * right;
};


//purpose of code is to provide fucntions for AST nodes of different types, currently defined is:
//AST_assignment
//AST_BinaryExpression
//AST_Type
//AST_Func
//AST_Write
struct AST * AST_assignment(char nodeType[50], char LHS[50], char RHS[50]){
	

	struct AST* ASTassign = malloc(sizeof(struct AST));
	strcpy(ASTassign->nodeType, nodeType);
	strcpy(ASTassign->LHS, LHS);
	strcpy(ASTassign->RHS, RHS);
	

/*
       =
	 /   \
	x     y

*/	
	return ASTassign;
	
}
struct AST * AST_BinaryExpression(char nodeType[50], char LHS[50], char RHS[50]){

	struct AST* ASTBinExp = malloc(sizeof(struct AST));
	strcpy(ASTBinExp->nodeType, nodeType);
	strcpy(ASTBinExp->LHS, LHS);
	strcpy(ASTBinExp->RHS, RHS);
	return ASTBinExp;
	
}
struct AST * AST_Type(char nodeType[50], char LHS[50], char RHS[50]){

	struct AST* ASTtype = malloc(sizeof(struct AST));
	strcpy(ASTtype->nodeType, nodeType);
	strcpy(ASTtype->LHS, LHS);
	strcpy(ASTtype->RHS, RHS);
		
	return ASTtype;
	
}

struct AST * AST_Func(char nodeType[50], char LHS[50], char RHS[50]){
	
	struct AST* ASTtype = malloc(sizeof(struct AST));
	strcpy(ASTtype->nodeType, nodeType);
	strcpy(ASTtype->LHS, LHS);
	strcpy(ASTtype->RHS, RHS);
		
	return ASTtype;
	
}

struct AST * AST_Write(char nodeType[50], char LHS[50], char RHS[50]){
	
	struct AST* ASTtype = malloc(sizeof(struct AST));
	strcpy(ASTtype->nodeType, nodeType);
	strcpy(ASTtype->LHS, LHS);
	strcpy(ASTtype->RHS, RHS);
		
	return ASTtype;
	
}

/*
//helper function to print appropriate number of spaces for indentation levels 
void printDots(int num)
{
	for (int i = 0; i < num; i++)
		printf("      ");
}

//prints contents of the AST, takes a pointer to the root and and interger 'level' to represent the current indentation level
//if current node has a 'left' child func calls itself recuresively with the left child and increased level
//for a right child func is called with right child and increased a 'level'
//function stops recursion when it encounters a null pointer
//void printAST(struct AST* tree, int level){
	if (tree == NULL) return;
	printDots(level);
	printf("%s\n", tree->nodeType);
	printDots(level);
	printf("%s %s\n", tree->LHS, tree->RHS);
	if(tree->left != NULL) printAST(tree->left, level+1); else return;
	if(tree->right != NULL) printAST(tree->right, level+1); else return;
	
}
*/