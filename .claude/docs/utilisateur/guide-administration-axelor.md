# Guide d'Administration - Axelor Vecia
## Documentation Utilisateur Final

> **📅 Version** : 1.0 - 3 Octobre 2025
> **🎯 Public** : Administrateurs et utilisateurs finaux Axelor Vecia
> **📝 Contexte** : Axelor Open Suite 8.3.15 pour Agence IA

---

## 📋 Table des Matières

1. [Introduction à l'Interface Axelor](#1-introduction-à-linterface-axelor)
2. [Application Config](#2-application-config)
3. [Administration](#3-administration)
4. [Bonnes Pratiques](#4-bonnes-pratiques)
5. [Cas d'Usage Agence IA](#5-cas-dusage-agence-ia)
6. [FAQ et Troubleshooting](#6-faq-et-troubleshooting)

---

## 1. Introduction à l'Interface Axelor

### 1.1 Premiers Pas

Après vous être connecté à Axelor (http://localhost:8080/) avec vos identifiants, vous accédez à l'interface principale.

**Credentials par défaut :**
- **Username** : `admin`
- **Password** : `admin`

> ⚠️ **Sécurité** : Changez immédiatement le mot de passe admin après la première connexion en production.

### 1.2 Navigation Générale

L'interface Axelor est organisée autour de plusieurs éléments :

```
┌─────────────────────────────────────────────────────┐
│  [Logo Axelor]    Accueil   Recherche   Profil     │  ← Barre supérieure
├──────────┬──────────────────────────────────────────┤
│          │                                          │
│  Menu    │        Zone de Travail Principale       │
│  Latéral │        (Formulaires, Listes, etc.)      │
│  Gauche  │                                          │
│          │                                          │
│  • App   │                                          │
│    Config│                                          │
│  • Admin │                                          │
│          │                                          │
└──────────┴──────────────────────────────────────────┘
```

### 1.3 Menu Latéral Gauche

Le menu de gauche contient les sections principales :

**📌 Application Config**
- Gestion des applications et modules
- Configuration générale du système

**📌 Administration**
- Gestion des utilisateurs et permissions
- Personnalisation de l'interface
- Tâches système et maintenance

---

## 2. Application Config

### 2.1 Vue d'Ensemble

La section **Application Config** centralise la configuration globale de votre instance Axelor.

**Accès** : Cliquez sur "Application Config" dans le menu latéral gauche.

### 2.2 Apps Management

#### Objectif
Gérer les applications (Apps) installées et disponibles dans votre instance Axelor.

#### ⚠️ Distinction Critique : Module vs App

**Concept fondamental Axelor** :

| Aspect | **Module** (Code) | **App** (Base de données) |
|--------|-------------------|---------------------------|
| **Définition** | Code Java compilé | Application installée et activée |
| **Localisation** | Code sur le serveur | Table `studio_app` en base de données |
| **Visibilité** | Invisible pour utilisateur | Menus visibles dans l'interface |
| **État initial** | Compilé au déploiement | **Non installée** (nécessite installation manuelle) |

**Processus** :
```
Déploiement Application
    ↓
Modules compilés ✅
    ↓
Apps enregistrées (active=false) ⚠️
    ↓
Installation manuelle via Apps Management
    ↓
Apps activées (active=true) → Menus visibles ✅
```

**⚠️ Important** : Même si l'application Axelor est déployée, les modules CRM, Sales, etc. **ne sont pas automatiquement accessibles**. Vous devez les installer via Apps Management pour qu'ils deviennent utilisables.

📖 **Pour aller plus loin** : `.claude/docs/developpeur/cycle-vie-apps.md`

#### Fonctionnalités Principales

**📦 Applications Disponibles**
- Liste de toutes les applications Axelor disponibles
- Statut : Installé / Non installé / À mettre à jour
- Dépendances entre applications

**🔧 Actions Possibles**

| Action | Description | Cas d'Usage |
|--------|-------------|-------------|
| **Installer** | Activer une nouvelle application | Ajouter module Comptabilité, Stock, etc. |
| **Désinstaller** | Retirer une application | Supprimer module inutilisé |
| **Mettre à jour** | Upgrader vers nouvelle version | Corriger bugs, nouvelles fonctionnalités |
| **Configurer** | Paramétrer l'application | Adapter aux besoins métier |

#### 📋 Ordre d'Installation Recommandé

**Pour un nouveau déploiement, installer les Apps dans cet ordre** :

**1️⃣ BASE** (Obligatoire - ~30s)
- Socle fondamental Axelor
- Crée toutes les tables en base de données (466 tables)
- Gestion contacts, partenaires, configuration système
- **À installer en premier**

**2️⃣ STUDIO** (Fortement recommandé - ~20s)
- Outils low-code/no-code
- Permet personnalisation (custom fields, workflows, web services)
- **À installer avant les Apps métier** pour pouvoir les personnaliser immédiatement

**3️⃣ CRM** (Phase 1 - ~30s)
- Gestion relation client
- Prospects et opportunités
- Pipeline commercial

**4️⃣ SALE** (Phase 1 - ~30s)
- Cycle de vente complet
- Devis et commandes
- Catalogue produits/services

**5️⃣ Autres Apps** (selon besoins)
- PROJECT : Gestion projets
- BPM : Workflows avancés
- ACCOUNTING : Comptabilité
- etc.

**Applications Actuellement Installées (Projet Axelor Vecia Phase 1)** :
- ✅ Axelor Base
- ✅ Axelor Studio
- ✅ Axelor CRM
- ✅ Axelor Sale

#### 🔍 Vérifier l'État des Apps Installées

**Via l'interface** :
```
Apps Management → Voir la liste avec statut "Installé" ou "Non installé"
```

**Via la base de données** (pour administrateurs techniques) :
```sql
SELECT code, name, active
FROM studio_app
ORDER BY active DESC, code;
```

#### Comment Installer une Nouvelle Application

**Étape 1** : Accéder à Apps Management
```
Menu Gauche → Application Config → Apps Management
```

**Étape 2** : Explorer les applications disponibles
- Parcourir la liste des applications
- Vérifier les dépendances requises (ex: CRM nécessite BASE)
- Lire la description et fonctionnalités

**Étape 3** : Installation
1. Cliquer sur l'application souhaitée
2. Bouton "Installer" ou "Install"
3. Confirmer l'installation
4. Attendre la fin du processus (20-30 secondes généralement)

**Étape 4** : Configuration initiale
- Les menus de l'App deviennent visibles dans le menu latéral
- Configurer les paramètres de base (voir menu Configuration de l'App)
- Définir les utilisateurs avec accès (via permissions)
- Tester les fonctionnalités principales

**Étape 5** : Vérification
- Rafraîchir la page (Ctrl+F5 ou Cmd+R)
- Vérifier que les menus apparaissent dans le menu latéral gauche
- Se déconnecter/reconnecter si nécessaire

> ⚠️ **Note Technique** : L'installation d'une App charge les données initiales (init-data) comme les statuts par défaut, séquences, etc., mais ne crée pas de nouvelles tables. BASE a déjà créé toutes les tables lors de son installation.

#### Bonnes Pratiques Apps Management

✅ **Recommandations** :
- Installer uniquement les modules nécessaires (performance)
- Tester en environnement dev avant production
- Documenter les raisons de chaque installation
- Vérifier compatibilité versions avant mise à jour
- Sauvegarder la base avant installation majeure

❌ **À Éviter** :
- Installer tous les modules "au cas où"
- Désinstaller un module avec données existantes
- Mettre à jour sans lire les release notes
- Installer modules tiers non vérifiés

### 2.3 Administration (sous Application Config)

Cette section "Administration" dans Application Config est une vue d'ensemble des paramètres administratifs. Pour les détails, voir la section 3 "Administration" ci-dessous.

---

## 3. Administration

### 3.1 Vue d'Ensemble

La section **Administration** regroupe tous les outils de gestion système, utilisateurs, et personnalisation de l'interface Axelor.

**Accès** : Cliquez sur "Administration" dans le menu latéral gauche.

### 3.2 User Management

#### Objectif
Gérer les utilisateurs, leurs rôles, et leurs permissions d'accès à l'application.

#### Concepts Clés

**👤 Utilisateur (User)**
- Compte individuel avec login/password
- Associé à un ou plusieurs rôles
- Peut être activé/désactivé

**👥 Groupe (Group)**
- Ensemble d'utilisateurs partageant des permissions
- Exemples : "Équipe Commerciale", "Direction", "Développeurs"

**🔐 Rôle (Role)**
- Ensemble de permissions définissant ce qu'un utilisateur peut faire
- Exemples : "Commercial", "Admin", "Manager"

**🔑 Permission**
- Droit d'accès granulaire à une fonctionnalité
- Lecture seule, Création, Modification, Suppression

#### Gestion des Utilisateurs

**Créer un Nouvel Utilisateur**

**Étape 1** : Accéder à User Management
```
Menu Gauche → Administration → User Management
```

**Étape 2** : Créer l'utilisateur
1. Cliquer sur "Nouveau" ou "New"
2. Remplir les informations obligatoires :
   - **Login** : Identifiant unique (ex: `jdupont`)
   - **Nom** : Nom complet (ex: `Jean Dupont`)
   - **Email** : Adresse email professionnelle
   - **Mot de passe** : Mot de passe initial (sera changé à la première connexion)
   - **Langue** : Français (fr)
   - **Statut** : Actif

**Étape 3** : Assigner des rôles
1. Onglet "Rôles"
2. Ajouter un ou plusieurs rôles selon les besoins
3. Exemples :
   - Commercial → Rôle "Sales User"
   - Manager → Rôle "Sales Manager"
   - Admin → Rôle "Admin"

**Étape 4** : Associer à des groupes (optionnel)
1. Onglet "Groupes"
2. Ajouter aux groupes pertinents
3. Exemple : Ajouter à "Équipe Commerce Paris"

**Étape 5** : Enregistrer
- Cliquer sur "Enregistrer" ou "Save"
- Communiquer les identifiants à l'utilisateur

#### Rôles Prédéfinis Axelor

| Rôle | Description | Permissions Typiques |
|------|-------------|---------------------|
| **Admin** | Administrateur système | Accès complet à tout |
| **User** | Utilisateur standard | Lecture + création données métier |
| **Manager** | Responsable équipe | User + validation + reporting |
| **Guest** | Invité lecture seule | Lecture uniquement |

#### Bonnes Pratiques User Management

✅ **Recommandations** :
- Principe du moindre privilège (donner uniquement accès nécessaire)
- Utiliser des groupes plutôt que permissions individuelles
- Forcer changement mot de passe à la première connexion
- Désactiver comptes inutilisés (ne pas supprimer)
- Auditer régulièrement les permissions

❌ **À Éviter** :
- Partager le compte admin entre plusieurs personnes
- Laisser utilisateurs avec rôle Admin sans nécessité
- Supprimer utilisateurs ayant créé des données
- Mots de passe faibles (min 8 caractères, complexe)

### 3.3 Model Management

#### Objectif
Gérer et personnaliser les modèles de données (entités métier) de l'application.

#### Qu'est-ce qu'un Modèle ?

Un **modèle** (ou **entité**) représente un objet métier dans Axelor :
- **Contact** : Une personne ou entreprise
- **Opportunité** : Une chance de vente
- **Devis** : Un document commercial
- **Produit** : Un article ou service vendu

Chaque modèle a des **champs** (attributs) :
- Contact : Nom, Prénom, Email, Téléphone, Entreprise
- Opportunité : Nom, Montant, Probabilité, Date fermeture

#### Fonctionnalités Model Management

**🔍 Exploration des Modèles**
```
Administration → Model Management
```

Vous verrez la liste de tous les modèles disponibles :
- **Nom technique** : `com.axelor.apps.crm.db.Lead`
- **Nom métier** : `Lead` (Prospect)
- **Module** : `axelor-crm`

**✏️ Personnalisation des Modèles**

| Action | Description | Niveau |
|--------|-------------|--------|
| **Ajouter champs custom** | Créer nouveaux attributs métier | Avancé |
| **Modifier labels** | Renommer champs existants | Débutant |
| **Définir validations** | Règles de validation données | Intermédiaire |
| **Configurer relations** | Liens entre modèles | Avancé |

**📋 Exemple Concret : Ajouter un Champ Custom**

**Cas d'usage** : Ajouter un champ "Niveau Maturité IA" sur les Leads (Prospects)

**Étape 1** : Identifier le modèle
- Modèle : `Lead` (module CRM)
- Nom technique : `com.axelor.apps.crm.db.Lead`

**Étape 2** : Ajouter le champ custom
1. Administration → Model Management
2. Rechercher "Lead"
3. Cliquer sur "Custom Fields" ou "Champs personnalisés"
4. Nouveau champ :
   - **Nom** : `niveauMaturiteIA`
   - **Label** : Niveau Maturité IA
   - **Type** : Sélection (Selection)
   - **Valeurs** : Débutant, Intermédiaire, Avancé, Expert

**Étape 3** : Enregistrer et rafraîchir
- Sauvegarder le champ
- Rafraîchir le cache de l'application
- Le nouveau champ apparaît dans les formulaires Lead

> ⚠️ **Attention** : La personnalisation de modèles peut impacter les modules lors des mises à jour. Documenter tous les changements.

#### Bonnes Pratiques Model Management

✅ **Recommandations** :
- Préfixer noms champs custom (ex: `custom_`, `ia_`)
- Documenter raison et usage de chaque champ custom
- Tester sur données dev avant production
- Éviter suppression champs avec données existantes
- Utiliser types de données appropriés

❌ **À Éviter** :
- Modifier modèles standards sans documentation
- Créer trop de champs custom (surcharge formulaires)
- Supprimer champs utilisés dans workflows
- Noms de champs non explicites

### 3.4 View Management

#### Objectif
Personnaliser l'apparence et l'organisation des formulaires, listes et dashboards.

#### Types de Vues Axelor

**📝 Form (Formulaire)**
- Affichage et édition d'un enregistrement unique
- Exemple : Fiche détaillée d'un contact

**📊 Grid (Liste)**
- Affichage tabulaire de plusieurs enregistrements
- Exemple : Liste de toutes les opportunités

**📈 Dashboard**
- Tableaux de bord avec graphiques et KPIs
- Exemple : Dashboard commercial avec CA mensuel

**🔍 Search (Recherche)**
- Filtres et critères de recherche avancée
- Exemple : Rechercher opportunités > 10K€

#### Personnalisation des Vues

**🎨 Modifier une Vue Formulaire**

**Cas d'usage** : Réorganiser les champs du formulaire Contact

**Étape 1** : Accéder à View Management
```
Administration → View Management
```

**Étape 2** : Rechercher la vue
- Type : `form`
- Modèle : `Contact`
- Nom : `contact-form`

**Étape 3** : Édition XML (mode avancé)
La vue est définie en XML. Exemple :
```xml
<form name="contact-form" title="Contact">
  <panel name="main">
    <field name="firstName" />
    <field name="lastName" />
    <field name="email" />
    <field name="phone" />
  </panel>
</form>
```

**Étape 4** : Modifications possibles
- Réorganiser ordre des champs
- Grouper champs dans panels
- Masquer/afficher champs conditionnellement
- Modifier largeur colonnes

> 💡 **Conseil** : Pour les débutants, utiliser l'éditeur graphique (si disponible) plutôt que XML direct.

#### Personnalisation Interface Utilisateur

**🔧 Options de Personnalisation**

| Élément | Personnalisable | Niveau |
|---------|-----------------|--------|
| **Ordre des champs** | ✅ Oui | Débutant |
| **Labels des champs** | ✅ Oui | Débutant |
| **Colonnes visibles (grid)** | ✅ Oui | Débutant |
| **Filtres par défaut** | ✅ Oui | Intermédiaire |
| **Mise en page (layout)** | ✅ Oui | Avancé |
| **Logique conditionnelle** | ✅ Oui | Avancé |

#### Bonnes Pratiques View Management

✅ **Recommandations** :
- Créer copies de vues avant modification (backup)
- Tester modifications avec utilisateurs finaux
- Utiliser noms de vues explicites
- Documenter changements dans commentaires XML
- Respecter conventions UI/UX standards

❌ **À Éviter** :
- Modifier directement vues standards (préférer héritage)
- Surcharger formulaires avec trop de champs
- Cacher champs obligatoires
- Créer vues illisibles (trop complexes)

### 3.5 Help Management

#### Objectif
Gérer l'aide contextuelle et la documentation intégrée à l'application.

#### Fonctionnalités

**❓ Aide Contextuelle**
- Bulles d'aide (tooltips) sur champs
- Documentation accessible via icône "?"
- Guides pas-à-pas pour processus complexes

**📚 Base de Connaissance**
- Articles d'aide indexés
- FAQs intégrées
- Vidéos tutoriels (liens)

#### Gestion de l'Aide

**Étape 1** : Accéder à Help Management
```
Administration → Help Management
```

**Étape 2** : Créer un Article d'Aide
1. Cliquer "Nouveau"
2. Remplir :
   - **Titre** : "Comment créer un devis ?"
   - **Catégorie** : Ventes
   - **Contenu** : Description détaillée (Markdown supporté)
   - **Mots-clés** : devis, vente, commercial
   - **Cible** : Page ou formulaire concerné

**Étape 3** : Publier
- Sauvegarder et publier
- L'aide apparaît dans les contextes configurés

#### Bonnes Pratiques Help Management

✅ **Recommandations** :
- Créer aide pour processus métier complexes
- Utiliser captures d'écran annotées
- Maintenir aide à jour avec évolutions
- Organiser par catégories logiques
- Tester clarté avec utilisateurs finaux

❌ **À Éviter** :
- Aide trop technique (jargon)
- Documentation obsolète
- Textes trop longs (préférer vidéos)
- Pas de structure claire

### 3.6 Module Management

#### Objectif
Activer, désactiver et configurer les modules Axelor installés.

#### Modules vs Applications

**Application** (Apps Management)
- Ensemble fonctionnel complet
- Exemple : "CRM", "Ventes", "Comptabilité"
- Installation via Apps Management

**Module** (Module Management)
- Sous-composant technique d'une application
- Exemple : `axelor-crm`, `axelor-sale`, `axelor-base`
- Gestion technique via Module Management

#### Gestion des Modules

**📋 Liste des Modules Actifs**

Pour Axelor Vecia Phase 1 :
```
✅ axelor-base       (v8.3.15) - Socle obligatoire
✅ axelor-crm        (v8.3.15) - CRM
✅ axelor-sale       (v8.3.15) - Ventes
```

**🔧 Actions Possibles**

| Action | Description | Impact |
|--------|-------------|--------|
| **Activer** | Démarrer un module installé | Fonctionnalités disponibles |
| **Désactiver** | Stopper un module | Fonctionnalités masquées (données conservées) |
| **Configurer** | Paramétrer le module | Adapter au besoin métier |
| **Vérifier dépendances** | Voir modules requis | Éviter erreurs activation |

**⚠️ Désactivation de Module**

**Avant de désactiver** :
1. Vérifier aucune donnée active sur ce module
2. Informer utilisateurs concernés
3. Sauvegarder la base de données
4. Tester en dev d'abord

**Conséquences** :
- Menus et fonctionnalités masqués
- Données conservées mais inaccessibles
- Impact performance positif (moins de modules actifs)

#### Bonnes Pratiques Module Management

✅ **Recommandations** :
- Activer uniquement modules nécessaires
- Respecter dépendances entre modules
- Documenter raisons activation/désactivation
- Tester en environnement dev avant prod

❌ **À Éviter** :
- Désactiver `axelor-base` (obligatoire)
- Désactiver module avec données actives
- Ignorer messages d'avertissement dépendances

### 3.7 Theme Management

#### Objectif
Personnaliser l'apparence visuelle (couleurs, logo, styles) de l'application Axelor.

#### Éléments Personnalisables

**🎨 Couleurs**
- Couleur principale (primary color)
- Couleur secondaire
- Couleur des liens
- Couleur des boutons d'action

**🖼️ Branding**
- Logo de l'entreprise
- Favicon
- Écran de connexion (login page)

**📐 Mise en Page**
- Largeur maximale contenu
- Taille polices
- Espacements

#### Créer un Thème Personnalisé

**Cas d'usage** : Appliquer la charte graphique de votre agence IA

**Étape 1** : Accéder à Theme Management
```
Administration → Theme Management
```

**Étape 2** : Créer un nouveau thème
1. Cliquer "Nouveau thème"
2. Nom : "Agence IA - Charte 2025"
3. Basé sur : "Thème par défaut"

**Étape 3** : Personnalisation couleurs
- **Couleur principale** : #1E3A8A (bleu agence)
- **Couleur secondaire** : #10B981 (vert tech)
- **Couleur succès** : #10B981
- **Couleur avertissement** : #F59E0B
- **Couleur erreur** : #EF4444

**Étape 4** : Upload logo
- Logo header : `logo-agence-ia.png` (180x50px recommandé)
- Favicon : `favicon.ico` (32x32px)

**Étape 5** : Appliquer le thème
- Sauvegarder
- Définir comme thème par défaut
- Rafraîchir navigateur

#### Thèmes Prédéfinis

| Thème | Description | Usage |
|-------|-------------|-------|
| **Default** | Thème Axelor standard | Général |
| **Dark Mode** | Interface sombre | Préférence utilisateur |
| **High Contrast** | Accessibilité renforcée | Utilisateurs malvoyants |

#### Bonnes Pratiques Theme Management

✅ **Recommandations** :
- Respecter accessibilité (contraste suffisant)
- Tester sur différents écrans (desktop, mobile)
- Garder cohérence avec charte graphique
- Logo optimisé (taille fichier < 100KB)
- Valider avec équipe avant déploiement

❌ **À Éviter** :
- Couleurs trop flashy (fatigue visuelle)
- Logo trop grand (ralentit chargement)
- Contraste insuffisant (illisible)
- Changer thème trop fréquemment (perturbe utilisateurs)

### 3.8 Job Management

#### Objectif
Gérer les tâches planifiées (batch, cron jobs) et processus automatisés.

#### Qu'est-ce qu'un Job ?

Un **job** (ou tâche planifiée) est un processus automatique qui s'exécute :
- À intervalle régulier (ex: toutes les nuits)
- À heure fixe (ex: tous les lundis 9h)
- Sur déclenchement manuel

**Exemples de Jobs Axelor** :
- Export données vers système tiers
- Envoi emails automatiques (relances)
- Calcul KPIs et statistiques
- Nettoyage données obsolètes
- Synchronisation avec CRM externe

#### Gestion des Jobs

**📋 Liste des Jobs**

**Accès** :
```
Administration → Job Management
```

**Informations affichées** :
- Nom du job
- Description
- Fréquence (cron expression)
- Dernière exécution
- Statut (Actif/Inactif)
- Résultat dernière exécution

**🔧 Actions Disponibles**

| Action | Description | Usage |
|--------|-------------|-------|
| **Exécuter maintenant** | Lancer job manuellement | Test ou besoin immédiat |
| **Activer/Désactiver** | Démarrer/stopper planification | Maintenance |
| **Modifier planning** | Changer fréquence | Adapter aux besoins |
| **Voir logs** | Consulter historique exécutions | Debug |

**📅 Configuration d'un Job**

**Exemple** : Job "Export Opportunités Quotidien"

**Étape 1** : Créer le job
1. Administration → Job Management
2. Nouveau job
3. Remplir :
   - **Nom** : Export Opportunités CSV
   - **Description** : Export quotidien des opportunités pour reporting
   - **Type** : Export données
   - **Classe** : `com.axelor.apps.crm.job.ExportOpportunitiesJob`

**Étape 2** : Configurer planification (Cron)
```
Cron Expression : 0 6 * * *
```
Signification : Tous les jours à 6h00 du matin

**Exemples d'expressions cron** :
- `0 */2 * * *` → Toutes les 2 heures
- `0 9 * * 1` → Tous les lundis à 9h
- `0 0 1 * *` → Le 1er de chaque mois à minuit

**Étape 3** : Paramètres du job
- Destination export : `/opt/axelor/exports/`
- Format : CSV
- Filtres : Opportunités actives uniquement

**Étape 4** : Activer
- Sauvegarder
- Activer le job
- Tester exécution manuelle

#### Surveillance des Jobs

**📊 Monitoring**

**Vérifications régulières** :
- Jobs en échec récents
- Durée d'exécution anormale
- Logs d'erreur

**Alertes à configurer** :
- Email si job échoue
- Notification si durée > seuil
- Slack/webhook intégration possible

#### Bonnes Pratiques Job Management

✅ **Recommandations** :
- Planifier jobs heures creuses (nuit/week-end)
- Tester jobs manuellement avant activation
- Monitorer logs régulièrement
- Documenter chaque job (objectif, impact)
- Alertes sur jobs critiques

❌ **À Éviter** :
- Jobs trop fréquents (surcharge système)
- Exécution jobs lourds en heures ouvrées
- Ignorer jobs en échec répétés
- Pas de timeout configuré (risque blocage)
- Jobs sans logging

---

## 4. Bonnes Pratiques

### 4.1 Sécurité

**🔐 Gestion des Accès**

✅ **À Faire** :
- Politique mots de passe forts (min 12 caractères)
- Changement mot de passe tous les 90 jours
- Authentification à deux facteurs (si disponible)
- Révision permissions trimestrielle
- Audit trail activé (traçabilité actions)

❌ **À Éviter** :
- Comptes partagés entre utilisateurs
- Mots de passe dans emails/chats
- Maintien accès utilisateurs partis
- Permissions "Admin" par défaut

### 4.2 Performance

**⚡ Optimisation**

✅ **Recommandations** :
- Désactiver modules inutilisés
- Archiver données anciennes régulièrement
- Limiter champs custom (max 10 par modèle)
- Jobs planifiés hors heures ouvrées
- Cache configuré correctement

**📊 Surveillance** :
- Temps réponse pages < 2 secondes
- Utilisation mémoire < 70%
- Espace disque > 20% libre
- Logs erreurs surveillés

### 4.3 Maintenance

**🔧 Routine Hebdomadaire**

- [ ] Vérifier jobs en échec
- [ ] Consulter logs erreurs
- [ ] Surveiller espace disque
- [ ] Backup base de données
- [ ] Vérifier performance

**🔧 Routine Mensuelle**

- [ ] Révision utilisateurs actifs
- [ ] Nettoyage données obsolètes
- [ ] Mise à jour documentation
- [ ] Vérification sauvegardes
- [ ] Test restauration backup

**🔧 Routine Trimestrielle**

- [ ] Audit complet permissions
- [ ] Revue modules installés
- [ ] Planification mises à jour
- [ ] Formation utilisateurs nouveautés
- [ ] Optimisation base de données

### 4.4 Documentation

**📝 Documenter les Changements**

**Que documenter ?**
- Champs custom ajoutés (nom, objectif, date)
- Vues modifiées (raison, auteur)
- Nouveaux utilisateurs/rôles créés
- Jobs configurés (planification, objectif)
- Thèmes appliqués

**Où documenter ?**
- Wiki interne équipe
- Commentaires dans configurations XML
- Fichier CHANGELOG.md projet
- Notes dans Axelor (champ "Notes")

---

## 5. Cas d'Usage Agence IA

### 5.1 Configuration CRM pour Agence IA

**🎯 Objectif** : Adapter le CRM Axelor aux spécificités d'une agence IA

#### Champs Custom à Créer

**Sur le modèle Lead (Prospect)** :

| Champ | Type | Valeurs | Utilité |
|-------|------|---------|---------|
| `niveauMaturiteIA` | Sélection | Débutant, Intermédiaire, Avancé, Expert | Qualifier expertise client |
| `budgetIA` | Décimal | - | Budget dédié projets IA |
| `stackTechnique` | Texte | Python, TensorFlow, PyTorch, etc. | Stack client existante |
| `besoinsIA` | Texte long | - | Description besoins IA détaillés |
| `sourceProspection` | Sélection | LinkedIn, Référencement, Partenaire, Événement | Origine contact |

**Sur le modèle Opportunity (Opportunité)** :

| Champ | Type | Valeurs | Utilité |
|-------|------|---------|---------|
| `typeProjetIA` | Sélection | POC, MVP, Production, Audit | Nature projet |
| `technologiesIA` | Sélection multiple | ML, DL, NLP, Vision, Générative | Technologies concernées |
| `dureeEstimee` | Entier | (en jours) | Estimation durée projet |
| `complexiteTechnique` | Sélection | Faible, Moyenne, Élevée, Critique | Niveau complexité |

#### Catalogue Services IA

**Créer Produits/Services** :

Via `Application Config → Apps Management → Sales` :

1. **POC Intelligence Artificielle**
   - Prix : 5 000€ - 15 000€
   - Durée : 2-4 semaines
   - Description : Proof of Concept pour valider faisabilité

2. **MVP IA (Minimum Viable Product)**
   - Prix : 20 000€ - 50 000€
   - Durée : 2-3 mois
   - Description : Version fonctionnelle minimale

3. **Chatbot IA Personnalisé**
   - Prix : 10 000€ - 30 000€
   - Durée : 1-2 mois
   - Description : Assistant virtuel sur mesure

4. **Audit Maturité IA**
   - Prix : 3 000€ - 8 000€
   - Durée : 1-2 semaines
   - Description : Diagnostic état des lieux IA entreprise

5. **Formation Équipe IA**
   - Prix : 2 000€/jour
   - Durée : 1-5 jours
   - Description : Formation personnalisée équipes

### 5.2 Pipeline Commercial Agence IA

**Étapes Opportunité Personnalisées** :

1. **Qualification** → Scoring maturité IA
2. **Découverte** → Audit besoins techniques
3. **POC/Démo** → Démonstration faisabilité
4. **Proposition** → Devis technique détaillé
5. **Négociation** → Ajustements scope/budget
6. **Signature** → Contrat signé
7. **Delivery** → Livraison projet
8. **Support** → Maintenance et évolutions

### 5.3 Utilisateurs Types

**Profils à Créer** :

| Profil | Rôle Axelor | Permissions | Cas d'Usage |
|--------|-------------|-------------|-------------|
| **Directeur Technique** | Admin + Sales Manager | Accès complet | Vue globale projets IA |
| **Business Developer** | Sales User | CRM + Ventes | Prospection et closing |
| **Data Scientist** | Project User | Lecture projets | Suivi besoins techniques |
| **Chef de Projet IA** | Project Manager | Projets + Ventes | Gestion delivery |
| **Consultant IA** | Consultant | Lecture CRM | Support avant-vente |

### 5.4 Automatisations (Jobs)

**Jobs Utiles pour Agence IA** :

1. **Relance Automatique Leads Inactifs**
   - Fréquence : Hebdomadaire
   - Action : Email relance leads > 30j sans activité

2. **Rapport Hebdomadaire Opportunités**
   - Fréquence : Lundi 8h
   - Action : Export CSV opportunités en cours

3. **Calcul KPIs Commerciaux**
   - Fréquence : Quotidien 7h
   - Action : Mise à jour taux conversion, CA moyen

4. **Synchronisation LinkedIn**
   - Fréquence : Quotidien
   - Action : Import nouveaux contacts LinkedIn

---

## 6. FAQ et Troubleshooting

### 6.1 Questions Fréquentes

**Q1 : Comment réinitialiser le mot de passe d'un utilisateur ?**

**R** :
1. Administration → User Management
2. Rechercher l'utilisateur
3. Cliquer sur l'utilisateur
4. Bouton "Réinitialiser mot de passe"
5. Nouveau mot de passe temporaire généré
6. Communiquer à l'utilisateur (changement forcé à la connexion)

---

**Q2 : Puis-je supprimer un champ custom après création ?**

**R** : Oui, mais avec précautions :
- ⚠️ Vérifier qu'aucune donnée n'utilise ce champ
- ⚠️ Vérifier qu'aucune vue ne référence ce champ
- ⚠️ Sauvegarder la base avant suppression
- ✅ Préférer masquer le champ plutôt que supprimer

---

**Q3 : Comment exporter toutes les données d'un module ?**

**R** :
1. Naviguer vers la liste concernée (ex: Leads)
2. Sélectionner tous les enregistrements (checkbox)
3. Bouton "Actions" → "Export"
4. Choisir format (CSV, Excel, XML)
5. Télécharger le fichier

---

**Q4 : Puis-je avoir plusieurs thèmes actifs simultanément ?**

**R** : Oui, chaque utilisateur peut choisir son thème :
- Administration → User Management → Utilisateur → Préférences
- Champ "Thème préféré"
- Chaque utilisateur voit son thème choisi

---

**Q5 : Comment sauvegarder ma configuration Axelor ?**

**R** : Deux niveaux de sauvegarde :

**Niveau 1 - Base de données** :
```bash
# Backup PostgreSQL
docker exec axelor-vecia-postgres pg_dump -U axelor axelor_vecia > backup.sql
```

**Niveau 2 - Configuration** :
- Exporter champs custom (XML)
- Exporter vues personnalisées (XML)
- Documenter utilisateurs/rôles créés
- Sauvegarder fichiers configuration

---

**Q6 : Un job est en échec, que faire ?**

**R** : Diagnostic en 5 étapes :

1. **Consulter les logs** : Administration → Job Management → Job concerné → Logs
2. **Identifier l'erreur** : Message d'erreur dans logs
3. **Vérifier les prérequis** : Connexion base, fichiers accessibles, etc.
4. **Tester manuellement** : Bouton "Exécuter maintenant"
5. **Corriger et réactiver** : Corriger problème, réactiver job

**Erreurs courantes** :
- Connexion base de données perdue
- Fichier destination inaccessible
- Timeout (job trop long)
- Permissions insuffisantes

---

### 6.2 Problèmes Courants

#### Problème : "Je ne vois pas un menu que je devrais avoir"

**Diagnostic** :
- Vérifier permissions de votre rôle
- Vérifier que le module correspondant est activé

**Solution** :
1. Contacter administrateur
2. Vérifier : Administration → User Management → Votre utilisateur → Rôles
3. L'admin doit ajouter rôle manquant ou activer module

---

#### Problème : "Les modifications de vue ne s'appliquent pas"

**Diagnostic** :
- Cache navigateur
- Cache serveur Axelor

**Solution** :
1. Vider cache navigateur (Ctrl+Shift+R ou Cmd+Shift+R)
2. Relancer serveur Axelor si nécessaire
3. Vérifier que modifications sauvegardées correctement

---

#### Problème : "Un champ obligatoire bloque l'enregistrement"

**Diagnostic** :
- Champ configuré obligatoire mais non visible dans formulaire

**Solution** :
1. Administration → View Management
2. Rechercher formulaire concerné
3. Vérifier que champ obligatoire est bien visible
4. Ou modifier modèle pour rendre champ optionnel

---

#### Problème : "Performance dégradée de l'application"

**Diagnostic** :
- Trop de modules actifs
- Base de données volumineuse
- Jobs lourds en heures ouvrées

**Solution** :
1. Désactiver modules inutilisés
2. Archiver données anciennes
3. Planifier jobs hors heures de pointe
4. Consulter logs pour identifier goulots

---

## 📚 Ressources Complémentaires

### Documentation Officielle

- **Axelor Open Platform** : https://docs.axelor.com/adk/7.4/
- **Axelor Open Suite** : https://docs.axelor.com/
- **Forum Axelor** : https://forum.axelor.com/

### Documentation Projet

- **CLAUDE.md** : Contexte général projet Axelor Vecia
- **PRD** : `.claude/docs/PRD.md` - Vision produit complète
- **Guide Technique** : `.claude/docs/document-technique-axelor.md`
- **Agent Déploiement** : `.claude/agents/agent-deploiement-local.md`

### Support

**Questions techniques** :
- Forum Axelor : https://forum.axelor.com/
- GitHub Issues : https://github.com/axelor/axelor-open-suite/issues

**Support interne** :
- Contacter administrateur système
- Consulter documentation interne projet

---

## 🎯 Conclusion

Ce guide couvre les fonctionnalités essentielles d'administration et de configuration d'Axelor Vecia. Pour des besoins spécifiques ou des questions non couvertes, n'hésitez pas à consulter la documentation officielle ou contacter votre administrateur système.

**Prochaines étapes recommandées** :
1. Créer vos utilisateurs et rôles
2. Personnaliser champs CRM pour agence IA
3. Configurer catalogue services IA
4. Paramétrer pipeline commercial
5. Créer jobs automatisations
6. Appliquer votre thème/branding

**Bonne utilisation d'Axelor ! 🚀**

---

*Guide d'Administration Axelor Vecia v1.0*
*Documentation Utilisateur Final*
*Dernière mise à jour : 3 Octobre 2025*
