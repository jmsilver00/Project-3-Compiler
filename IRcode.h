//Functions for handeling IR code emissions 

FILE * IRcode;

//initilizes file and writes the header for the start if the IR code section 
void  initIRcodeFile(){
    IRcode = fopen("IRcode.ir", "w");
    fprintf(IRcode, "\n\n#### IR Code ####\n\n");
    fclose(IRcode);
}
//IR code for a binary operation with the given operator op and operands id1 and id2
void emitBinaryOperation(char op[1], const char* id1, const char* id2){
    fprintf(IRcode, "T1 = %s %s %s", id1, op, id2);
    fclose(IRcode);
}
//IR code for an assignment operation, where the value of id2 is assigned to id1
void emitAssignment(char * id1, char * id2){

  fprintf(IRcode, "T0 = %s\n", id1);
  fprintf(IRcode, "T1 = %s\n", id2);
  fprintf(IRcode, "T1 = T0\n");
  fclose(IRcode);
}
//creates IR code for an assignment of a constant integer value id1 to a temporary variable with index id2
void emitConstantIntAssignment (char id1[50], int id2[50]){
    IRcode = fopen("IRcode.ir", "a");
    fprintf(IRcode, "T%d = %s\n",id2, id1);
    fclose(IRcode);
}
//creates IR code for an assignment of the value of id2 to a temporary variable with index curScope
void emitIRAssignment(char id1[50], char id2[50],int curScope[50]){
    IRcode = fopen("IRcode.ir", "a");
    fprintf(IRcode, "T%d = %s\n",curScope, id2);
    fclose(IRcode);
}

void emitWriteId(char * id){

    fprintf (IRcode, "output %s\n", "T2");
    fclose(IRcode);
}
    