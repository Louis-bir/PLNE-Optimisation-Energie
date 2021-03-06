/*********************************************
 * OPL 12.6.0.0 Model
 * Author: Louis
 * Creation Date: 3 déc. 2020 at 19:35:52
 *********************************************/
/*********************************************
 * IP3(delta), avec delta=2
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
float p[chaudieres] = ...; // cout unitaire de production  de chaque chaudiere
float f[chaudieres] = ...; // cout fixe horaire de chaque chaudiere
float C_sto = ...; // capacite de stockage en energie entre une periode et la periode suivante
float h = ...; // cout horaire de stockage 
float g = ...; // cout horaire de variation du stock (en valeur absolue) 

/** Donnees utilisees uniquement par les parties 4 et 5 **/
 
float F[chaudieres] = ...; // cout fixe de demarrage pour chaque chaudiere
int N[chaudieres] = ...; // nombre minimum de periodes d’utilisation apres allumage pour chaque chaudiere

/** Parametres pour le modele IP2 **/

int delta = 2; // TODO : tester avec differentes valeurs

/** Parametres auxiliaires permettant des statistiques **/

float debutExecution; // date de debut
execute{
  var before = new Date();
  debutExecution = before.getTime();
}
 
/** Variables **/

// Production
dvar float+ x[periodes][chaudieres]; 

// Stock
dvar float+ I[0..T]; 

// Energie solaire
dvar float+ xsol[periodes];

dvar boolean y[periodes][chaudieres];
dvar float+ varSDesc[periodes];
dvar float+ varSAugm[periodes];
dvar float+ x_tprime[chaudieres][periodes][periodes]; 
dvar float+ xsol_tprime[periodes][periodes]; 

/** Objectif **/

// On cherche à minimiser les coûts de production

 minimize sum(s in chaudieres,t in periodes) (f[s]*y[t][s]+ p[s]*x[t][s])+ sum(t in periodes)(h*I[t] + g*varSDesc[t] + g*varSAugm[t]);
 
 
/** Contraintes **/

subject to {  

    forall(s in chaudieres, t in periodes){
    x[t][s] >= sum(u in t..T) x_tprime[s][t][u]; 
    } 
    
    forall(t in periodes){
    xsol[t]>= sum(u in t..T) xsol_tprime[t][u];    
    }  
    
    // Linéarisation de la valeur absolue
    forall(t in periodes){
    ctVarStock: I[t]-I[t-1]==varSAugm[t]-varSDesc[t]; 
    }    

    // Initialisation du stock
    I[1]== sum(s in chaudieres) x[1][s] + xsol[1] - d[1]; 
    
    // Contraintes sur le stock
    forall(t in periodes){
    ctdemandeJournaliere: I[t]==I[t-1] + sum(s in chaudieres)x[t][s]+xsol[t]-d[t]; 
    }
    
    // Contrainte de production de type big M 
    forall(s in chaudieres,t in periodes){
    y[t][s]*P_min[s] <= x[t][s];
    x[t][s] <= P_max[s]*y[t][s];    
    }
    
    // Contrainte sur le stock max
    forall(t in 1..T-1){
    ctStockMax: I[t] <= C_sto;  
    }
    
    forall(t in periodes){
    ctNRJSol: xsol[t] <= P_max_solaire[t];
    }
   	
    forall(s in chaudieres, t in 1..T-delta, u in t..t+delta){
    x_tprime[s][t][u]<=d[u]*y[t][s];   
    }
    
    forall(s in chaudieres, t in T-delta..T, u in t..T){
    x_tprime[s][t][u]<=d[u]*y[t][s];   
    }
    
     // Ajout de coupe
    forall(t in periodes){
    	ctDemandeJournaliere : sum(s in chaudieres,u in 1..t) (x_tprime[s][u][t] + xsol_tprime[u][t]) == d[t];
    } 
    
    // Si on ne produit pas à tzero il faut avoir stocké au moins d_to en stock de la veille
    forall(tzero in 2..T){
   ctcoupe1: I[tzero-1]+xsol[tzero]>=d[tzero]*(1-(y[tzero][1]+y[tzero][2]));   
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
 
 
