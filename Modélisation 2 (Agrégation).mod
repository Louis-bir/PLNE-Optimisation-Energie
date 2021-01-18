/*********************************************
 * OPL 12.10.0.0 Model
 * Author: Louis
 * Creation Date: 30 nov. 2020 at 15:55:50
 *********************************************/

  
/** Donnees generales **/
 
int T = ...; // horizon de temps
range periodes = 1..T; // ensemble des periodes 
range sources = 0..2; // 0 pour le solaire, et 1 ou 2 pour les chaudieres (= sources pilotables)
range chaudieres = 1..2; // 1 pour Bois, 2 pour Gaz
float d[periodes]  = ...; // demande pour chaque periode
float P_max_solaire[periodes]=...; // energie solaire disponible pour chaque periode
float P_min[chaudieres]=...; // energie minimale delivree par chaque chaudiere si elle est utilisee a une periode
float P_max[chaudieres]=...; // energie maximale delivree par chaque chaudiere si elle est utilisee a une periode
float p[chaudieres] = ...; // cout unitaire de production d’energie de chaque chaudiere
float f[chaudieres] = ...; // cout fixe horaire de chaque chaudiere
float C_sto = ...; // capacite de stockage en energie entre une periode et la periode suivante
float h = ...; // cout horaire de stockage d’une unite d’energie
float g = ...; // cout horaire de variation du stock (en valeur absolue) 

/** Donnees utilisees uniquement par les parties 4 et 5 **/
 
float F[chaudieres] = ...; // cout fixe de demarrage pour chaque chaudiere
int N[chaudieres] = ...; // nombre minimum de periodes d’utilisation apres allumage pour chaque chaudiere

/** Parametres pour le modele IP2 **/

int Delta = 2; // TODO : tester avec differentes valeurs
int K = T div Delta;

/** Parametres auxiliaires permettant des statistiques **/

float debutExecution; // début execution
execute{
  var before = new Date();
  debutExecution = before.getTime();
}
 
/** Variables **/

// Nouvelle range de période agrégée
range lesK = 1..K;

// Production
dvar float+ xbois[lesK];
dvar float+ xgaz[lesK];
dvar float+ xsol[lesK];
dvar int+ ybois[lesK];
dvar int+ ygaz[lesK];

// Stock.
dvar float+ I[0..K];

// Variable pour créer la valeur absolue des variations de stock.
dvar float+ varSDesc[lesK];
dvar float+ varSAugm[lesK];

/** Objectif **/

// L'objectif est de minimiser les coûts liés à la produciton d'énergie et au stockage.

minimize (sum(k in lesK) ( f[1]*ybois[k] + f[2]*ygaz[k] + p[1]*xbois[k] + xgaz[k]*p[2] + h*I[k] + g*varSDesc[k] + g*varSAugm[k]));

/** Contraintes **/

subject to {  
   
    // Valeur absolue
    forall(k in lesK){
    I[k] - I[k-1]==varSAugm[k]-varSDesc[k];
  	}    
	
	// Initialisation du stock
   	I[0] == 0;
   
   // Contraintes liées à la définiton du stock
    forall(k in lesK){
    	sum(t in ((k-1)*Delta+1)..(k*Delta)) d[t] + I[k] == I[k-1] + xbois[k] + xgaz[k] + xsol[k];	
    }
    
       
    forall(k in lesK){
     
    // Contraintes de production via la source Bois
    ybois[k]*P_min[1] <= xbois[k];
    xbois[k] <= P_max[1]*ybois[k];
    ybois[k] <= Delta;
    
    // Contraintes de production via la source Bois
    ygaz[k]*P_min[2] <= xgaz[k];
    xgaz[k] <= P_max[2]*ygaz[k];
    ygaz[k] <= Delta;

    }
    
    // Capacité max de stockage
    forall(k in lesK){
    I[k] <= C_sto;
    }
    
    // Utilisation max de l'énergie solaire disponible
    forall(k in lesK){
    xsol[k] <= sum(t in ((k-1)*Delta+1)..(k*Delta)) P_max_solaire[t];
    }
    
}
 
/** Affichage des statistiques **/

execute{
  var after = new Date();
  var tempsExecution = 0.01*Math.round(0.1*(after.getTime() - debutExecution));
  var bestObj = cplex.getObjValue();
  var gapRelatif = cplex.getMIPRelativeGap();
  writeln("Temps d'execution : "+tempsExecution+" sec");
  writeln("Meilleur objectif : "+bestObj+" euros");
  writeln("Gap Relatif : "+gapRelatif+" %");
}
 
 
