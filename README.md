# Projet : Optimisation de la production de chaleur pour un éco-quartier

**Equipe** : 4 étudiants  
**Date** : 14/12/2020  
**Durée** : 1 mois  
**Thème** : Recherche Opérationnelle, PLNE, Optimisation, Energie, CPLEX  
**Configuration pour les tests** : Sans coupes, sans gap  

## Background du projet :

Ce projet s'inscrit dans la conception et l'optimisation d’un réseau de chaleur pour un éco-quartier. La demande annuelle en chaleur inclut la consommation en chauffage et en
eau chaude sanitaire. Le pouvoir publique local souhaite qu’un maximum de la demande soit satisfaite par des énergies "vertes et locales" et souhaite réduire son empreinte carbone.

La demande en chaleur subit de fortes variations sur l’année, elle dépend de la météo et de facteurs sociaux-économiques (horaires en semaine, week-end, vacances, jours fériés etc.). On connaît la prévision de la demande à chaque période t pour un horizon de temps T.

L'objectif de ce projet est de modéliser à l’aide de programmes linéaires mixtes le problème de production sur l’horizon T, afin de satisfaire les demandes à moindre coût. Cet horizon pouvant être particulièrement lointain (jusqu’à 1 année).

## Données du problème :

- **dt** : la demande d'énergie à l'instant t (en MWh)
- **S** : {solaire, bois, gaz} : ensemble des sources d'énergie. (bois & gaz) les sources pilotables
- **Pmax,sol,t** : énergie disponible à l'instant t
- (**Pmin,s** & **Pmax,s**) : intervalle d’énergie délivrée par la source s appartenant à (bois & gaz) si elle est utilisée à une période
- **Csto** : capacité de stockage en énergie entre une période et la période suivante
- **Ps** : coût unitaire de production d’énergie de la source s
- **Fs** : coût fixe d’utilisation horaire pour une source s
- **h** : coût horaire de stockage d’une unité d’énergie
- **g** : coût horaire de variation du stock (en valeur absolue) d’une unité d’énergie (supposé négligeable par rapport à h)

**Exemple de demande d'énergie sur 5 heures :**

| Période       |  1   |  2  |  3  |  4  |  5  |
| ------------- |------|-----|-----|-----|-----|
| dt (demande)  |  5   |  7  |  2  |  12 |  10 |
| Ps (cu)       |  3   |  4  |  7  |  5  |  4  |
| Fs (cf)       |  4   |  3  |  2  |  3  |  5  |


## Modélisation :

Pour ce projet nous avons réalisé **4 modélisations** que nous avons run sur des instances de tailles différentes.
Les variables, fonctions objectifs et contraintes propres à chaque modélisation se trouvent dans les fichiers .mod de ce repo.
L'ensemble de ces modélisations ont été executé sur **CPLEX** et nous les avons confronté sur différents critères :

- Temps d'execution
- Relaxation au noeud racine
- Nombre de noeuds de Branch & Bound
- Meilleur objectif
- Gap relatif (%) 

**Modélisation 1 :** Modélisation "Classique"  
**Modélisation 2 :** Modélisation agrégée sur des périodes Delta  
**Modélisation 3 :** Modélisation avec traçage des périodes de consommation  
**Modélisation 4 :** Modélisation avec démarrage des chaudières  



