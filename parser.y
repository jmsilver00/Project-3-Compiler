%{

//parser for functions, variables, loops, condtional stmts, and basic arithmetic


//C libs and header files
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "FunSymTable.h"
#include "symbolTableVar.h"
#include "AST.h"
#include "IRcode.h"
#include "Assembly.h"


typedef enum { F, T } boolean;

extern int yylex();
extern int yyparse();
extern FILE* yyin;
boolean FunctionFlag = F;

FILE * IRcode;



void yyerror(const char* s);

int sum = 0;
char curArr[50];
int arrIndex = 0;

char curFun[50];

char scope[50] = "Global";
char Global[50] = "Global";
char Local[50] = "Global";


int semanticCheckPassed = 1;
%}

//passes values between lexer and parser, holding integers, chars, stings, and pointers to the AST
%union {
	int number;
	char character;
	char* string;
	struct AST* ast;
}

//all tokens for parser use
%token <string> ID
%token <string> WRITE
%token <string> IF
%token <string> ELSE
%token <string> WHILE
%token <string> RETURN
%token <string> TYPE
%token <string> KEYWORD
%token <string> NUMBER
%token <string> CHAR
%token <char> SINGLE_QOUTE
%token <char> SEMICOLON
%token <char> COMMA
%token <char> EQ 
%token <char> OR
%token <char> LSS
%token <char> GTR
%token <char> LEQ
%token <char> GEQ
%token <char> LPAREN
%token <char> RPAREN
%token <char> LBRACE
%token <char> RBRACE
%token <char> LBRACKET
%token <char> RBRACKET
%token <char> ADD
%token <char> SUB
%token <char> MULTIPLY
%token <char> DIV

//print each token as it appears in the AST
%printer { fprintf(yyoutput, "%s", $$); } ID;
%printer { fprintf(yyoutput, "%d", $$); } NUMBER;
%printer { fprintf(yyoutput, "%s", $$); } CHAR;


%type <ast> Program FunDeclList FunDecl FuncallStmtList FuncallStmt ArrayDecl ArrayDeclList ParamDeclList ParamDecl DeclList Decl VarDeclList VarDecl Stmt StmtList AssignStmt WriteStmt Block AssignStmtList MathStatList MathStat WriteStmtList

%right EQ
%left ADD, SUB
%left MULTIPLY, DIV



//grammer rules defined by:
//specifying the non-terminal symbol on the left hand side
//then a colon
//followed by sequence of symbols on the right-hand side to make up the rules

%start Program

%%

//program rules specifies that a program is a list of declarations
//Decl List specifies a list of declarations can be a single decl or a decl followed by a list of decls
Program: DeclList  { $$ = $1;
					 printf("\n--- Abstract Syntax Tree ---\n\n");
					 printAST($$,0);
					}
;

//Decl rule specifies a decl can be a function decl, statment list, VarDecl, or ArrayDecl
DeclList:	Decl DeclList	{ $1->left = $2;
							  $$ = $1;
							}
	| Decl	{ $$ = $1; }
;

Decl: FunDecl 
	| StmtList
	| VarDecl
	| ArrayDecl
;

//FunDecl rules defines a funct decl consists of a type, identifier, list of parameters, and block stmts
//Semantic action with this rule adds function to the symbol table and generates an AST node for the function 
FunDeclList:
			| FunDecl FunDeclList {$1->left = $2;
							  $$ = $1;}
			| FunDecl {$$ = $1;};

FunDecl:	TYPE ID LPAREN ParamDeclList RPAREN Block {printf("\nRECOGNIZED RULE: Function\n");
							
								char id1[50];
								char type[50];
								strcpy(id1, $2);
								strcpy(type, $1);
								strcpy(scope, Local);
								int inSymTab = found($2, scope);
								
								if (inSymTab == 0){
									add_Item_to_var_sym_table(id1, "Fun", $1, 0, scope);

									add_Item_to_func_sym_table(id1, "Fun", &type, 0, &id1, &scope);
								}
								else{					
									printf("SEMANTIC ERROR: Fun %s is already in the symbol table", $2);
								}
								showVarSymTable();
								showFuncSymTable();

								$$ = AST_Type("Fun", $1, $2);
								
			};

//the FuncallStmtLis and FuncallStmt rules specify syntax for a function call
//semantic action with FuncallStmt rule performs semantic checks and generates AST node for function call
FuncallStmtList: FuncallStmt FuncallStmtList {$1->left = $2;
							  $$ = $1;}
			| FuncallStmt {$$ = $1;};

FuncallStmt: ID LPAREN ParamDeclList RPAREN SEMICOLON {printf("\nRECOGNIZED RULE: Function Call\n");
							
								char id1[50];
								strcpy(id1, $1);
								strcpy(scope, Local);
								int inSymTab = found(id1, scope);
								
								if (inSymTab == 0){
									printf("SEMANTIC ERROR: Fun %s is not in the symbol table", $1);
								}
								else{					
									

								}

								showFuncSymTable();

								$$ = AST_Type("FunCall", $1, "NULL");
								
			};

//ParamDeclList and ParamDecl rules specify the syntax for a list of parameters in a function declaration 
//Semantic actions with ParamDecl adds the parameter to the symbol table
ParamDeclList: %empty
 			| ParamDecl ParamDeclList {$1->left = $2;
							  $$ = $1;}
											
			| ParamDecl {$$ = $1;}
							

ParamDecl: TYPE ID {printf("\n RECOGNIZED RULE: Variable declaration\n");						
									char id1[50];
									symTabAccess();
									int inSymTab = found($2, scope);

									
									if (inSymTab == 0) 
										add_Item_to_var_sym_table($2, "Var", $1, 0, scope);
									else						
										printf("SEMANTIC ERROR: Var %s is already in the symbol table", $2);

									showVarSymTable();
									
									sprintf(id1, "%s", $2);
									int numid = getItemID(id1, scope);  
									emitConstantIntAssignment ($2, numid);								

									
								    $$ = AST_Type("Type",$1,$2);  	
								};
			| %empty


Block:	LBRACE FunBlock RBRACE


FunBlock: ArrayDeclList
		| VarDeclList
		| StmtList

VarDeclList:	VarDecl VarDeclList {$1->left = $2;
							  $$ = $1;}
			| VarDecl {$$ = $1;}

VarDecl:	TYPE ID SEMICOLON { printf("\n RECOGNIZED RULE: Variable declaration\n");

									char id1[50];

									symTabAccess();
									int inSymTab = found($2, scope);

									
									if (inSymTab == 0) 
										add_Item_to_var_sym_table($2, "Var", $1, 0, scope);
									else						
										printf("SEMANTIC ERROR: Var %s is already in the symbol table", $2);

									showVarSymTable();
									
									sprintf(id1, "%s", $2);
									int numid = getItemID(id1, scope);   
									emitConstantIntAssignment ($2, numid);								

									
								    $$ = AST_Type("Type",$1,$2);  	 
								};


ArrayDeclList : ArrayDecl ArrayDeclList {$1->left = $2;
							  $$ = $1;};
			| ArrayDecl {$$ = $1;};

ArrayDecl : TYPE ID LBRACKET NUMBER RBRACKET SEMICOLON { printf("\n RECOGNIZED RULE: Array declaration %s\n", $2);
									char id1[50];
									$4 = atoi($4);

									char concat[50];
									sprintf(concat, "%s[%d]", $2, $4);

									
									char temp[50];

									
									int inSymTab = found($2, scope);

									if (inSymTab == 0){
										printf("Adding array to symbol table\n");
										int tempint = $4;

										for (int i = 0; i < $4; i++){
											char arrayname[50];
											
											sprintf(temp, "%d", i);

											sprintf(arrayname, "%s[%s]", $2, temp);

											add_Item_to_var_sym_table(arrayname, "Array", $1, $4, &scope);
											
											tempint--;

	
										}
									}else{
														
										printf("SEMANTIC ERROR: Array %s is already in the symbol table", $2);
									}
									showVarSymTable();
									
									sprintf(id1, "%s", $2);
									int numid = getItemID(id1, scope);   
									emitConstantIntAssignment ($2, numid);								
									
								    $$ = AST_Type("Type",$1,concat);
									printf("%s", $$->LHS);
								}

StmtList: Stmt StmtList{ $1->left = $2;
					$$ = $1;}
	| Stmt { $$ = $1; };

Stmt: AssignStmtList {printf("AssignStmt\n");}
	| MathStatList {printf("MathStat\n");}
	| WriteStmtList {printf("WriteStmt\n");}
	| FuncallStmtList {printf("FuncallStmt\n");}



AssignStmtList: AssignStmt AssignStmtList{ $1->left = $2;
					$$ = $1;}
				| AssignStmt{ $$ = $1; };

//				
AssignStmt:	ID LBRACKET NUMBER RBRACKET EQ NUMBER SEMICOLON { printf("\nRECOGNIZED RULE: Set Val of array at certine index\n"); 
									
									char concat[50];
									sprintf(concat, "%s[%s]", $1, $3);
									

									if (strcmp(scope, Global) == 0){
										if(found(concat, scope) != 1) {  
											printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, scope);
											semanticCheckPassed = 0;
										}
										if(semanticCheckPassed == 1) {
											printf("\n\nRule is semantically correct\n\n");
											setVal(concat, $6, scope);
											$$ = AST_assignment("=",concat, $6);
									
											int numid = getItemID(concat, scope);    
											emitIRAssignment(concat, $6, numid);         
											memset(concat, 0, sizeof(concat));
										}

									}else{
										if(found_in_fun_sym(concat, scope) != 1) {  
											printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, scope);
											semanticCheckPassed = 0;
											set_Int_Fun_Val(concat, $6, scope);
										}
										if(semanticCheckPassed == 1) {
											printf("\n\nRule is semantically correct\n\n");
											set_Int_Fun_Val(concat, $6, scope);
											$$ = AST_assignment("=",concat, $6);
									
											int numid = getItemID_fun_sym(concat, scope);   
											emitIRAssignment(concat, $6, numid);            
											memset(concat, 0, sizeof(concat));
										}

									}							
								}
	| ID LBRACKET NUMBER RBRACKET EQ CHAR SEMICOLON { printf("\nRECOGNIZED RULE: Set Val of array at certine index\n"); 
									
									char concat[50];
									sprintf(concat, "%s[%s]", $1, $3);
									

									if (strcmp(scope, Global) == 0){
										if(found(concat, scope) != 1) { 
											printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, scope);
											semanticCheckPassed = 0;
										}
										if(semanticCheckPassed == 1) {
											printf("\n\nRule is semantically correct\n\n");
											setcharVal(concat, $6, scope);
											$$ = AST_assignment("=",concat, $6);
									
											int numid = getItemID(concat, scope);    
											emitIRAssignment(concat, $6, numid);         

											memset(concat, 0, sizeof(concat));
										}

									}else{
										if(found_in_fun_sym(concat, scope) != 1) {  
											printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, scope);
											semanticCheckPassed = 0;
										}
										if(semanticCheckPassed == 1) {
											printf("\n\nRule is semantically correct\n\n");
											set_fun_char_val(concat, $6, scope);
											$$ = AST_assignment("=",concat, $6);
									
											int numid = getItemID_fun_sym(concat, scope);    
											emitIRAssignment(concat, $6, numid);             
											memset(concat, 0, sizeof(concat));
										}

									}							
								}

	| ID EQ CHAR SEMICOLON{ printf("\nRECOGNIZED RULE: Set String\n"); 
	
					char char1[50];
					char id1[50];
					sprintf(char1, "%s", $3);
					sprintf(id1, "%s", $1);
					if (strcmp(scope, Global) == 0){

						if(found(id1, scope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, scope);
							semanticCheckPassed = 0;
						}

						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct\n\n");
							setcharVal(id1, char1, scope);
							showVarSymTable();
							$$ = AST_assignment("=",$1, $3);
							int numid = getItemID($1, scope);    
							emitIRAssignment($1, $3, numid);             
						}

					}else{
						if(found_in_fun_sym(id1, scope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, scope);
							semanticCheckPassed = 0;
						}
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct\n\n");
							set_fun_char_val(id1, char1, scope);
							showVarSymTable();
							$$ = AST_assignment("=",$1, $3);
							int numid = getVal_from_fun_sym($1, scope);   
							emitIRAssignment($1, $3, numid);              
						}

					}
				}

	| ID EQ NUMBER SEMICOLON { printf("\nRECOGNIZED RULE: Set Val\n"); 


						char str[50];
						char id1[50];
						char id2[50];

						if (strcmp(scope, Global) == 0){


							if(found($1, scope) != 1) {
								printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, scope);
								semanticCheckPassed = 0;
							}


							if (semanticCheckPassed == 1) {
								printf("\n\nRule is semantically correct!\n\n");
								sprintf(id2, "%s", $3); 
								sprintf(id1, "%s", $1);
								symTabAccess();
								int CheckForFloat = 0;
								for(int i = 0; $3[i] != '\0'; ++i)
								{
									if($3[i] == '.')
									{
									CheckForFloat = 1;
									break;
									}
								}
								if (CheckForFloat == 1){
									printf("%s\n",$3);
									setfloatVal(id1, $3, scope);
								}else{
									setVal(id1, $3, scope);
								}



								showVarSymTable();
								$$ = AST_assignment("=",$1, id2);
								int numid = getItemID(id1, scope);    
								emitIRAssignment(id1, id2, numid);             
								

							}
						}else{
							if(found_in_fun_sym($1, scope) != 1) {
								printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, scope);
								semanticCheckPassed = 0;
							}
							if (semanticCheckPassed == 1) {
								printf("\n\nRule is semantically correct!\n\n");
								sprintf(id2, "%s", $3); 
								sprintf(id1, "%s", $1);
								int CheckForFloat = 0;
								for(int i = 0; $3[i] != '\0'; ++i)
								{
									if($3[i] == '.')
									{
									CheckForFloat = 1;
									break;
									}
								}
								if (CheckForFloat == 1){
									printf("%s\n",$3);
									set_float_Fun_Val(id1, $3, scope);
								}else{
									 
									set_Int_Fun_Val(id1, $3, scope);
								}
								showFuncSymTable();
								$$ = AST_assignment("=",$1, id2);
								int numid = getItemID_fun_sym(id1, scope);   
								emitIRAssignment(id1, id2, numid);            
								emitMIPSConstantIntAssignment(id1, id2, numid);

							}
						}
					}
	| ID EQ MathStat SEMICOLON{
					char id1[50];
					char id2[50];
					FILE * ResultF;
					sprintf(id1, "%s", $1);
					char command[50], mathVal[50];
					char ch;
					int i = 0;
					int numid = getItemID(id1, scope);
					reverseNumArr();
					strcpy( command, "python3 Operations.py" );
					printf("\n");
					addCalcFile();
					addOpArr('\0');
					system(command);
					sleep(1);
					ResultF = fopen("./Calculator/Results/CalcF.txt_results.txt", "r");
					fgets(mathVal,20,ResultF);
					int x = atoi(mathVal);
					fclose(ResultF);

					int CheckForFloat = 0;
					for(int i = 0; mathVal[i] != '\0'; ++i){
						if(mathVal[i] == '.'){
							CheckForFloat = 1;
							break;
						}
					}
						if (CheckForFloat == 1){
							printf("%s\n",mathVal);
							setfloatVal($1, mathVal, scope);
						}else{
							setVal($1, mathVal, scope);
						}
					sprintf(id2, "%s", mathVal);	
					$$ = AST_assignment("=",$1,mathVal);
					emitMIPSConstantIntAssignment(id1, mathVal, numid);	
					
					showVarSymTable();
					printOpArr();
					printArr();
					clearClacFile();
					clearArr();
					clearOpArr();
		};
		
WriteStmtList: WriteStmt WriteStmtList{ $1->left = $2;
					$$ = $1;}
				|	WriteStmt{ $$ = $1; };

WriteStmt: WRITE ID SEMICOLON{ printf("\nRECOGNIZED RULE: WRITE STATMENT\n");

					char id1[50];
					sprintf(id1, "%s", $2);
					char *tyoe = getVariableType(id1, scope);
					char type[50];
					sprintf(type, "%s", tyoe);
					printf("Type: %s\n", type);
					$$ = AST_Write("write",type, $2);
					
					int numid = getItemID(id1, scope);


					  
					if (found($2, scope) != 1) {	 
						printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $2, scope);
						semanticCheckPassed = 0;
					}

					if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct\n\n");
							emitWriteId($2);	 				
							emitMIPSWriteId($2,numid);		 
						}
					emitMIPSWriteId($2,numid);
				};

BinOp:	ADD	{
			addOpArr('+');
		};

		| SUB	{
			addOpArr('-');
		};

		| MULTIPLY	{
			addOpArr('*');
		};

		| DIV	{
			addOpArr('/');
		};

MathStatList: MathStat MathStatList {$1->left = $2;
					$$ = $1;}
				| MathStat{ $$ = $1; };

MathStat:	NUMBER BinOp MathStat	{
				addNumArr($1);
			};
				
			| ID BinOp MathStat	{

					symTabAccess();
					int id1;
					id1 = getVal($1, scope);
					addIDNumArr(id1);  
					
			};

			| NUMBER	{
				addNumArr($1);	
			};

			| ID	{
					symTabAccess();
					int id1;
					id1 = getVal($1, scope);
					addIDNumArr(id1);	 
					};

%%

int main(int argc, char**argv)
{

	printf("\n\n##### COMPILER STARTED #####\n\n");
	
	if (argc > 1){
	  if(!(yyin = fopen(argv[1], "r")))
          {
		perror(argv[1]);
		return(1);
	  }
	}

 
	initIRcodeFile();
	initAssemblyFile();

 
	yyparse();

 
	emitEndOfAssemblyCode();

}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}
