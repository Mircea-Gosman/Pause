# Pause (Application android d'analyse d'horaire en format image sous serveur Flask)

*[English Version](https://github.com/Mircea-Gosman/pause_v1/blob/master/README.md)*

## Processus d'analyse d'images
L'image de départ étant une capture d'écran, la première étape est de segmenter l'image.

Il faut pouvoir distinguer, dans l'image:
* Les contours
* Les coins
* Les segments de lignes individuaux

### Contours
D'abord, il faut identifier la zone contenant l'horaire. Celle-ci est constituée, généralement, du polygone ayant la plus grande aire.  L'identification de polygones dans l'image est possible grâce à [l'algorithme de contours](https://docs.opencv.org/3.4/d4/d73/tutorial_py_contours_begin.html) d'OpenCV. 
En ajoutant une marge afin de réduire des erreurs de traitement ultérieures, le résultat est le suivant:

| Image d'origine | Image rognée |
| ------------- | ------------- |
| <img src="https://github.com/Mircea-Gosman/pause_v1/blob/master/Results/schedule.jpeg" width="300">  | <img src="https://github.com/Mircea-Gosman/pause_v1/blob/master/Results/cropped.jpg" width="300">  |

### Coins
Ayant l'horaire rogné en main, il est possible d'identifier l'ensemble des coins faisant partis de l'image en utilisant [l'algorithme des coins d'Harris](https://opencv-python-tutroals.readthedocs.io/en/latest/py_tutorials/py_feature2d/py_features_harris/py_features_harris.html). Une fois obtenus en tant que coordonnées, filtrés en colonnes et normalisés:

| Tous les coins  | Coins filtrés |
| ------------- | ------------- |
| <img src="https://github.com/Mircea-Gosman/pause_v1/blob/master/Results/allCorners.jpg" width="300">  | <img src="https://github.com/Mircea-Gosman/pause_v1/blob/master/Results/dayBoundingCorners.jpg" width="300">  |

### Segment de lignes
Les coins en inventaire correspondent à la majorité des intersections de la grille horaire. Or, ils ne correspondent pas tous à la délimitation des cours. Afin de filter les coins en trop, une vérification de la présence signifactive de segments horizontaux entre les coins doit être effectuée. L'extraction des segments de lignes de l'image est effectué par [l'algorithme HoughLinesP](https://opencv-python-tutroals.readthedocs.io/en/latest/py_tutorials/py_imgproc/py_houghlines/py_houghlines.html). 

| Tous les segments  | Segments horizontaux | Coins reliés par des segments |
| ------------- | ------------- | ------------- |
| <img src="https://github.com/Mircea-Gosman/pause_v1/blob/master/Results/allLineSegments.jpg" width="300">  | <img src="https://github.com/Mircea-Gosman/pause_v1/blob/master/Results/horizontalLineSegments.jpg" width="300">  | <img src="https://github.com/Mircea-Gosman/pause_v1/blob/master/Results/pairedCorners.jpg" width="300">  |

### Cellules
Les paires de coins reliés par des segments peuvent, deux à deux, former des cellules rectangulaires. L'ensemble des cellules forment la grille horaire.

| Grille horaire  |
| ------------- | 
| <img src="https://github.com/Mircea-Gosman/pause_v1/blob/master/Results/scheduleCells.jpg" width="300">  |

Cela permet de rogner chacune des cellues afin d'améliorer le résultat du processus d'OCR. (Des marges blanches sont ajoutées à chaque cellule. Les images des cellules sont également agrandies deux fois.)

| Cellule de temps | Cellule de cours|
| ------------- | ------------- |
| <img src="https://github.com/Mircea-Gosman/pause_v1/blob/master/Results/hourCell.jpg" width="100">  | <img src="https://github.com/Mircea-Gosman/pause_v1/blob/master/Results/courseCell.jpg" width="100">  |

### OCR
L'outil de OCR utilisé est [Tesseract](https://tesseract-ocr.github.io), l'adaptation [py_tesseract](https://pypi.org/project/pytesseract/).

### Résultat final
Le processus d'analyse d'image précédemment documenté permet et des résultats de bonne qualité du OCR, et l'obtention des coordonnées limites des cellules. Placé dans une base de données SQL-Lite, le résultat du jumelage entre les cours et leurs heure de début et d'arrivé ressemble à ceci:
The previously documented process allows both for decent OCR results and accurate positionning of the schedule's cells. 
Placed in a, SQL-Lite database, the ensued matching of courses to their start and end times appears as follows:

| Table des jours | Tables des cours |
| ------------- | ------------- |
| <img src="https://github.com/Mircea-Gosman/pause_v1/blob/master/Results/daysDB.png" width="500">  | <img src="https://github.com/Mircea-Gosman/pause_v1/blob/master/Results/coursesDB.png" width="500">  |

## Serveur & Base de données
Le serveur est basé sur Flask et la base de données utilise [Flask_Sql_Alchemy](https://flask-sqlalchemy.palletsprojects.com/en/2.x/) afin de communiquer avec lui.

En ce moment, le serveur peut:
* Enregistrer des utilisateurs
* Enregistrer des connexions d'amis
* Importer un horaire vers la base de données à partir du client
* Mettre à jour un horaire de la base de données à partir du client
* Envoyer un horaire de la base de données vers le client

En ce moment, le serveur ne peut pas encore:
* Effectuer des mises à jour avec les amis Facebooks si les utilisateurs deviennent amis après l'ouverture du compte ([webhooks](https://developers.facebook.com/docs/graph-api/webhooks/))
* Transmettre des notifications entre les utilisateurs
* Supprimer un utilisateur
* Déconnecter un utilisateur (à implémenter si l'application client le souhaite, i.e. FB Messsenger ne permet pas l'option)

## Client
En ce moment, le client est muni de:
* Une page de connexion
* Une page d'accueil
* Une page de profile

Une navigation rudimentaire est implémentée. La majorité des fonctions de l'interface utilisateur ne sont pas présentes.
Le côté client est opérationnel pour l'ensemble des fonctions actuelles du serveur.

Le modèle d'affaire doit être capable de comparer deux horaires à partir des résultats du serveur. 
(Une fois cela fait, le reste de l'application devrait être basique.)