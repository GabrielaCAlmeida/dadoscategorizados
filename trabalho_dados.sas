libname cat "/home/u62605357/Análise de dados categorizados";
PROC import datafile= "/home/u62605357/Análise de dados categorizados/dados_trabalho (1).xlsx"
out = cat.dados dbms=xlsx; getnames = YES;
run;

proc print data= cat.dados;
run;

/* Separando a amostra em duas amostras - uma de trabalho e outra de validação*/

proc surveyselect data= cat.dados
    out=cat.worksample
    seed=1234
    sampsize=100;
run;

proc sql;
   create table cat.validsample as
   select * from cat.dados
   except
   select * from cat.worksample;
run;

proc print data= cat.worksample;
run;

proc contents data= cat.worksample;
run;

/*### primeira hipótese de trabalho ###*/
/*## Análise exploratória ##*/

proc freq data=cat.worksample;
tables x5/nocum;
LABEL x5 = 'Conta poupança';
run;


/*## Análise exploratória para todas as variáveis ##*/

proc univariate data = cat.worksample plot;
var x1 x2 x3 x4 x5;
LABEL x1 = 'Idade (em anos) do paciente'
x2 = 'Status socioeconômico'
x3 = 'Possui casa própria'
x4 = 'Setor da cidade (A ou B)'
x5 = 'Conta poupança';
run;

/*## Boxplot da variável x1 = idade do paciente ##*/
PROC SGPLOT  DATA = cat.worksample;
   VBOX x1;
   LABEL x1 = 'Idade (em anos) do paciente';
RUN; 

/*## Tabela de frequencias e gráfico de barras para a variável x2 = Status socioeconômico ##*/

proc freq data=cat.worksample;
tables x2/nocum;
run;

proc format;
value X2f 1="Superior"
2="Médio"
3="Inferior";
run;

PROC SGPLOT  DATA = cat.worksample;
   Vbar x2;
   LABEL x2 = 'Status socioeconômico';
   format  x2 x2f.;
RUN; 

/*## Tabela de frequencias e gráfico de barras para a variável x3 = Possui casa própria ##*/

proc freq data=cat.worksample;
tables x3/nocum;
run;

proc format;
value X3f 1=" Não ou Sim (financiada)"
2="Sim (Quitada)";
run;

PROC SGPLOT  DATA = cat.worksample;
   Vbar x3;
   LABEL x3 = 'Status socioeconômico';
   format  x3 x3f.;
RUN; 

/*## Tabela de frequencias e gráfico de barras para a variável x4 = Setor da cidade ##*/

proc freq data=cat.worksample;
tables x4/nocum;
run;

proc format;
value X4f 1 =" Setor A"
0 = "Setor B";
run;

PROC SGPLOT  DATA = cat.worksample;
   Vbar x4;
   LABEL x4 = 'Setor da cidade';
   format  x4 x4f.;
RUN; 

/*## Tabela de frequencias e gráfico de barras para a variável resposta x5 = Conta poupança ##*/

proc freq data=cat.worksample;
tables x5/nocum;
run;

proc format;
value X5f 1 =" Sim"
0 = "Não";
run;

PROC SGPLOT  DATA = cat.worksample;
   Vbar x5;
   LABEL x5 = 'Conta poupança';
   format  x5 x5f.;
RUN; 

/* ###Regressao Logística### */

/* Ordenando Y por ordem "decrescente" -- sucesso=(y=1) */

/* Regressao Logística - Considerando todas as variáveis*/
proc logistic data=cat.worksample descending;
 model x5 = x1 x2 x3 x4;
run;

* Testando interação;
proc logistic data=cat.worksample descending;
 model x5 = x1 | x2 | x3 | x4/lackfit;
run;

proc logistic data=cat.worksample descending;
 model x5 = x1 x2 x3 x4/lackfit;
run;

/* Resíduos - modelo saturado*/
ods graphics on;
title 'Conta poupança';
proc logistic data=cat.worksample;
model x5 = x1 x2 x3 x4/influence;
run;


/* Regressao Logística - Considerando variáveis significativas*/
proc logistic data=cat.worksample descending;
 model x5 = x1 x2;
run;

/* de Adequabilidade de Ajustamento */
proc logistic data=cat.worksample descending;
 model x5 = x1 x2/lackfit;
run;

* Testando interação - Considerando variáveis significativas*;
proc logistic data=cat.worksample descending;
 model x5 = x1 | x2 /lackfit;
run;

/* Resíduos - modelo com variáveis significativas*/
ods graphics on;
title 'Conta poupança';
proc logistic data=cat.worksample;
model x5 = x1 x2/influence;
run;

/* Regressao Logística - Considerando X2 como dumie*/
proc logistic data=cat.worksample descending;
class x2 /ref=first param=ref;
 model x5 = x1 x2;
run;

/* Adequabilidade de Ajustamento */
proc logistic data=cat.worksample descending;
class x2 /ref=first param=ref;
 model x5 = x1 x2/lackfit;
run;

* Testando interação - Considerando variáveis significativas dumie*;
proc logistic data=cat.worksample descending;
class x2 /ref=first param=ref;
 model x5 = x1 | x2/lackfit;
run;

ods graphics on;
proc logistic data=cat.worksample descending  plots(only)=oddsratio(range=clip);
class x2 /ref=first param=reference;
 model x5 = x1 x2;
 oddsratio x2;
 effectplot ;
   title 'Conta poupança';
run;

/*Análise de resíduos - modelo com Dumie*/
ods graphics on;
title 'Conta poupança';
proc logistic data=cat.worksample;
   class x2 /ref=first param=reference;
 model x5 = x1 x2/influence;
run;

/* ###VALIDAÇÂO#### */

/*## Análise exploratória ##*/

proc freq data=cat.validsample;
tables x5/nocum;
LABEL x5 = 'Conta poupança';
run;

proc univariate data = cat.validsample plot;
var x1 x2 x3 x4 x5;
LABEL x1 = 'Idade (em anos) do paciente'
x2 = 'Status socioeconômico'
x3 = 'Possui casa própria'
x4 = 'Setor da cidade (A ou B)'
x5 = 'Conta poupança';
run;

/*## Boxplot da variável x1 = idade do paciente ##*/
PROC SGPLOT  DATA = cat.validsample;
   VBOX x1;
   LABEL x1 = 'Idade (em anos) do paciente';
RUN; 

/*## Tabela de frequencias e gráfico de barras para a variável x2 = Status socioeconômico ##*/

proc freq data=cat.validsample;
tables x2/nocum;
run;

proc format;
value X2f 1="Superior"
2="Médio"
3="Inferior";
run;

PROC SGPLOT  DATA = cat.validsample;
   Vbar x2;
   LABEL x2 = 'Status socioeconômico';
   format  x2 x2f.;
RUN; 

/*## Tabela de frequencias e gráfico de barras para a variável x3 = Possui casa própria ##*/

proc freq data=cat.validsample;
tables x3/nocum;
run;

proc format;
value X3f 1=" Não ou Sim (financiada)"
2="Sim (Quitada)";
run;

PROC SGPLOT  DATA = cat.validsample;
   Vbar x3;
   LABEL x3 = 'Status socioeconômico';
   format  x3 x3f.;
RUN; 

/*## Tabela de frequencias e gráfico de barras para a variável x4 = Setor da cidade ##*/

proc freq data=cat.validsample;
tables x4/nocum;
run;

proc format;
value X4f 1 =" Setor A"
0 = "Setor B";
run;

PROC SGPLOT  DATA = cat.validsample;
   Vbar x4;
   LABEL x4 = 'Setor da cidade';
   format  x4 x4f.;
RUN; 

/*## Tabela de frequencias e gráfico de barras para a variável resposta x5 = Conta poupança ##*/

proc freq data=cat.validsample;
tables x5/nocum;
run;

proc format;
value X5f 1 =" Sim"
0 = "Não";
run;

PROC SGPLOT  DATA = cat.validsample;
   Vbar x5;
   LABEL x5 = 'Conta poupança';
   format  x5 x5f.;
RUN; 

/* ###Regressao Logística### */

/* Ordenando Y por ordem "decrescente" -- sucesso=(y=1) */

/* Regressao Logística - Considerando todas as variáveis*/

proc glimmix data = cat.validsample;
 model x5 = x1 x2 x3 x4/link=logit dist=bin solution;
 store parameter_dat;
 output out=pre pred(noblup ilink)=p;
run;

* create probability deciles, and the ranks of probability <rank_p>;
proc rank data=pre out=ranky descending groups=10;
 var p;
 ranks rank_p;
run;
*output the median probability by deciles (‘rank_p’);
proc sort data = ranky;
by rank_p;
run; 

proc means data=ranky median mean;
 var p ;
 by rank_p;
 output out=median_pr median=median_predict_p mean=mean_predict;
run;

*output the observed transfusion rates by deciles, which is the number of
rbc events divided by the total number of observations in each decile;
proc sql;
 create table observe_pr as
 select sum(x5) as no_events, count (*) as no_obs, calculated
no_events/ calculated no_obs as observe_pr, rank_p
 from ranky
 group by rank_p;
quit;
* create the merge dataset that include the median probability and observed
transfusion rate in each decile;
data merge1;
 merge observe_pr median_pr;by rank_p;
run; 

*Plot the calibration Graph;
proc sgplot data=merge1;
 scatter x=observe_pr y=median_predict_p;
 lineparm x=0 y=0 slope=1; /** plot the reference line **/
 xaxis grid; yaxis grid;
run;


