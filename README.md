<!-- README.md is generated from README.Rmd. Please edit that file. -->

# minintCIR · Observatoire de l'intégration

Une application **R Shiny** pour explorer les contrats d'intégration républicaine, comparer les profils des signataires et exporter une sélection de données. La version **0.1.0** conserve l'architecture Shiny et golem, avec une interface repensée autour de quatre onglets.

| Onglet | Usage |
| --- | --- |
| **Explorer** | Lire les indicateurs de synthèse et les répartitions par nationalité, sexe, âge, territoire, motif de séjour et parcours linguistique. |
| **Comparer** | Choisir des groupes et comparer leurs distributions en effectifs ou en pourcentages. |
| **Données** | Rechercher dans le tableau et télécharger le périmètre sélectionné. |
| **Comprendre** | Retrouver les définitions, la méthode, les limites et les sources. |

Le fichier fourni contient **78 764 observations de 2020**. La refonte de l'application n'actualise pas ce millésime.

## Démarrer en local

Une version récente de R est recommandée, par exemple **R 4.4 ou ultérieur**. Les dépendances et leurs éventuelles versions minimales sont déclarées dans [`DESCRIPTION`](DESCRIPTION).

Depuis la racine du dépôt, installer le package et ses dépendances, puis lancer l'application :

```r
install.packages("remotes") # Une seule fois, si nécessaire
remotes::install_local(".", dependencies = TRUE, upgrade = "never")
minintCIR::run_app()
```

Pour travailler directement sur le code avec `devtools` :

```r
remotes::install_deps(".", dependencies = TRUE, upgrade = "never")
devtools::load_all(".")
run_app()
```

`devtools` doit être installé pour ce second mode. Les dépendances se téléchargent lors de l'installation ; le fonctionnement local de l'application utilise ensuite les ressources du projet et des packages installés. La police Marianne est fournie dans le dépôt et les textes français du tableau sont définis localement.

Aucun fichier `set_cfg.R`, accès S3, identifiant cloud ou service de télémétrie n'est nécessaire au démarrage. Les liens vers les sources et le dépôt ouvrent des sites externes à la demande.

## Données et configuration

Les données de 2020 sont incluses dans [`inst/extdata/data_2020.parquet`](inst/extdata/data_2020.parquet) et installées avec le package.

Pour utiliser une copie compatible placée ailleurs, définir son chemin **avant le lancement** :

```r
options(minintCIR.data_path = "C:/mes-donnees/data_2020.parquet")
minintCIR::run_app()
```

La variable d'environnement `CIR_DATA_PATH` est également reconnue :

```r
Sys.setenv(CIR_DATA_PATH = "C:/mes-donnees/data_2020.parquet")
minintCIR::run_app()
```

L'option R `minintCIR.data_path` est prioritaire lorsqu'elle est définie. Sans chemin personnalisé, l'application charge le fichier inclus. Le fichier doit conserver les colonnes attendues ; un chemin incorrect ou des colonnes manquantes donnent un message d'erreur dans l'application.

Les libellés sont nettoyés de leurs espaces superflus. Les âges manquants deviennent « Non renseigné » ; les parcours absents accompagnés d'une prescription « Non » deviennent « Sans prescription ». Les observations ne sont pas dédupliquées : le fichier ne contient pas d'identifiant individuel.

## Filtres, graphiques et exports

Choisir les valeurs dans la barre latérale, puis cliquer sur **Appliquer les filtres**. Les filtres s'appliquent aux onglets Explorer, Comparer et Données ainsi qu'au téléchargement. Plusieurs valeurs d'un même filtre sont réunies ; les différents filtres sont croisés. **Tout réinitialiser** restaure le périmètre complet.

Les pourcentages d'exploration utilisent le total des observations sélectionnées. Dans les comparaisons, chaque groupe possède son propre total. Les graphiques affichent au maximum les **12 catégories les plus représentées**, sans regrouper les autres : les pourcentages restent calculés sur le total complet, y compris les catégories non affichées. Leur somme visible peut donc être inférieure à 100 %. Le tableau donne accès à toutes les catégories.

L'export est un **CSV séparé par des points-virgules, encodé en UTF-8 avec BOM**, adapté notamment à l'ouverture dans Excel. Il contient toutes les observations retenues par les filtres latéraux. La recherche et la pagination du tableau modifient seulement son affichage, sans restreindre l'export.

## Déployer sur Posit Connect

Le fichier `manifest.json` à la racine décrit le bundle Shiny, ses ressources et les versions de ses dépendances. Il a été généré avec R 4.5.1 et `rsconnect::writeManifest()` pour un déploiement depuis Git.

Après une modification du code, des ressources ou des dépendances, régénérer le manifeste depuis la racine du dépôt :

```r
install.packages("rsconnect") # Une seule fois, si nécessaire
source("dev/03_deploy.R")
```

Ce script prépare uniquement le manifeste. Versionner `manifest.json` avec les fichiers de l'application, puis sélectionner ce dépôt et sa racine dans Posit Connect. Le serveur devra disposer d'une version de R compatible et pouvoir restaurer les dépendances déclarées.

Le lanceur `app.R` charge le package depuis les sources avec `pkgload::load_all()`, puis appelle `getExportedValue("minintCIR", "run_app")()`. Conserver cet appel dynamique : il évite de déclarer `minintCIR` comme une dépendance distante via `minintCIR::run_app()`.

Vérifier les empreintes des fichiers et le démarrage depuis le bundle seul avec `Rscript tests/deploy-smoke.R`. Voir la [documentation officielle de writeManifest](https://rstudio.github.io/rsconnect/reference/writeManifest.html).

## Vérifications

Depuis la racine du dépôt, avec les dépendances installées :

```sh
Rscript tests/chart-smoke.R
Rscript tests/server-smoke.R
```

Ces contrôles couvrent les calculs des graphiques, les pourcentages avant limitation aux 12 premières catégories, la conservation des données d'entrée, les filtres et leur réinitialisation, les sélections vides, le tableau, l'export CSV et les erreurs de chargement.

## Source et limites

Les données proviennent du [jeu Contrat d'intégration républicaine du ministère de l'Intérieur](https://www.data.gouv.fr/datasets/contrat-dintegration-republicaine), diffusé sur data.gouv.fr sous **Licence Ouverte 2.0**. L'application utilise uniquement le fichier de **2020** fourni dans ce dépôt.

Les effectifs correspondent aux lignes du fichier, sans pondération. Ils ne décrivent pas l'ensemble de la population immigrée et ne mesurent ni la réussite des formations ni les résultats d'une politique publique. Les catégories territoriales sont celles de la source, avec notamment un regroupement « D.O.M. ». Le contexte administratif présenté est historique et ne décrit pas les règles actuellement en vigueur.

La méthode détaillée figure dans l'onglet **Comprendre** et dans [`inst/app/www/cirmeth.md`](inst/app/www/cirmeth.md).

Application de **Philippe Fontaine**, diffusée sous licence MIT.
