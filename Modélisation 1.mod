/*********************************************
 * IP1
 *********************************************/
 
/** Donnees generales **/
 
int T = ...; // horizon de temps
range periodes = 1..T; // ensemble des periodes 
//range sources = 0..2; // 0 pour le solaire, et 1 ou 2 pour les chaudieres (= sources pilotables)
range chaudieres = 1..2; // 1 pour Bois, 2 pour Gaz
float d[periodes]  = ...; // demande pour chaque periode
float P_max_solaire[periodes]=...; // energie solaire disponible pour chaque periode
float P_min[chaudieres]=...; // energie minimale delivree par chaque chaudiere si elle est utilisee a une periode
float P_max[chaudieres]=...; // energie maximale delivree par chaque chaudiere si elle est utilisee a une periode
float p[chaudieres] = ...; // cout unitaire de production de chaque chaudiere
float f[chaudieres] = ...; // cout fixe horaire de chaque chaudiere
float C_sto = ...; // capacite de stockage en energie entre une periode et la periode suivante
float h = ...; // cout horaire de stockage
float g = ...; // cout horaire de variation du stock (en valeur absolue)

/** Donnees utilisees uniquement par les parties 4 et 5 **/
 
float F[chaudieres] = ...; // cout fixe de demarrage pour chaque chaudiere
int N[chaudieres] = ...; // nombre minimum de periodes apres allumage pour chaque chaudiere

/** Parametres auxiliaires permettant des statistiques **/

float debutExecution;
execute{
  var before = new Date();
  debutExecution = before.getTime();
}
 
/** Variables **/

// Production
dvar float+ x[periodes][chaudieres]; 

// Stockage
dvar float+ I[0..T]; 

// Energie solaire
dvar float+ xsol[periodes];

// Booleen sur la production
dvar boolean y[periodes][chaudieres];

dvar float+ varSDesc[periodes];
dvar float+ varSAugm[periodes];

/** Objectif **/

// Minimisation du coût de production et de stockage

 minimize sum(s in chaudieres,t in periodes) (f[s]*y[t][s]+ p[s]*x[t][s])+ sum(t in periodes)(h*I[t] + g*varSDesc[t] + g*varSAugm[t]);
 
 
/** Contraintes **/

subject to {  

    // Linéarisation de la valeur absolue
    forall(t in periodes){
    ctVarStock: I[t]-I[t-1]==varSAugm[t]-varSDesc[t]; 
    }    
 
    // Initialisation du stock
    ctStockInit: I[0] == 0;
    I[1]== sum(s in chaudieres) x[1][s] + xsol[1] - d[1]; 
    
    
    // Contrainte sur le stock
    forall(t in periodes){
    ctdemandeJournaliere: I[t]==I[t-1] + sum(s in chaudieres)x[t][s]+xsol[t]-d[t]; 
    }
    
    // Contraintes sur la production
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

    // Ajout de coupe
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
 
 
