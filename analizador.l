%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct _token{
    int clase;
    char valor[32];
    int line;
} token;
token TOKEN;
enum clase {ID=1,PRESER,ARIT,ASIGNA,RELAC,LOGIC,SP,ENT,DEC};

void error(char *s);
%}

%option yylineno
%option noyywrap
%s COMENTARIO
%x COMENTARIO2

letra [a-zA-Z]
letra_ {letra}|_
digito [0-9]
id #({letra}|{digito})*
entero ({digito})+
real {digito}*"."{digito}+|{digito}+"."{digito}*
exp [eE][+-]?{entero}
flotante ({real}{exp}?|{entero}{exp})[Ff]
preservada @((if)|(else)|(while))
oarit [+-*/%]
oasigna ==
orelac <|>|(<=)|(>=)|=|(!=)
ologic "&"|"|"|"^"
spuntuacion "{"|"}"|"("|")"|";"|","

%%
<INITIAL>{id}    { 
            TOKEN.clase = ID;
            strcpy(TOKEN.valor, yytext);
            TOKEN.line = yylineno;
            return ID;
        }
<INITIAL>{preservada}    { 
            TOKEN.clase = PRESER;
            strcpy(TOKEN.valor, yytext);
            TOKEN.line = yylineno;
            return PRESER;
        }
<INITIAL>{oarit}    { 
            TOKEN.clase = ARIT;
            strcpy(TOKEN.valor, yytext);
            TOKEN.line = yylineno;
            return ARIT;
        }
<INITIAL>{oasigna}    { 
            TOKEN.clase = ASIGNA;
            strcpy(TOKEN.valor, yytext);
            TOKEN.line = yylineno;
            return ASIGNA;
        }
<INITIAL>{orelac}    { 
            TOKEN.clase = RELAC;
            strcpy(TOKEN.valor, yytext);
            TOKEN.line = yylineno;
            return RELAC;
        }
<INITIAL>{ologic}    { 
            TOKEN.clase = LOGIC;
            strcpy(TOKEN.valor, yytext);
            TOKEN.line = yylineno;
            return LOGIC;
        }
<INITIAL>{spuntuacion}    { 
            TOKEN.clase = SP;
            strcpy(TOKEN.valor, yytext);
            TOKEN.line = yylineno;
            return SP;
        }
<INITIAL>{entero}    { 
                TOKEN.clase = ENT;
                strcpy(TOKEN.valor, yytext);
                TOKEN.line = yylineno;
                return ENT;
            }
<INITIAL>{real}  { 
                TOKEN.clase = DEC;
                strcpy(TOKEN.valor, yytext);
                TOKEN.line = yylineno;
                return DEC;
        }
<INITIAL>[ \t\n\r] {/* Ignora los espacios en blanco*/}
<INITIAL>"/*" {BEGIN(COMENTARIO);}
<INITIAL>.   {error(yytext);}

<COMENTARIO>[^*/]  {}
<COMENTARIO>[*/]   {}    
<COMENTARIO>"*/"   {BEGIN(INITIAL);}
%%
void error(char *s){
    printf("Error léxico: %s, en la línea %d\n",s,yylineno);
}

int main(int argc, char **argv){
    FILE *f;
    if(argc<2){
        printf("Falta archivo\n");
        exit(-1);
    }
    f = fopen(argv[1],"r");
    if(!f){
        printf("No se puede abrir el archivo\n");
        exit(-1);
    }
    yyin = f;
    int tok = yylex();
    while(tok != 0){
        printf("%d\n",tok);
        tok = yylex();
    }    
    return 0;
}