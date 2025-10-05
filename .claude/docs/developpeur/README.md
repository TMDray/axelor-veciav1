# 👨‍💻 Documentation Développeur - Axelor Vecia

## 🎯 Vue d'Ensemble

Ce dossier contient la **documentation technique pour les développeurs** travaillant sur le projet Axelor Vecia. Cette documentation fait le lien entre l'**application Axelor** (interface utilisateur) et le **développement** (code, base de données, architecture).

## 📚 À Qui S'Adresse Cette Documentation

**Public cible** :
- 👨‍💻 Développeurs Java/Axelor
- 🏗️ Architectes techniques
- 🔧 DevOps gérant l'infrastructure
- 📊 Data engineers travaillant avec la base de données

**Prérequis** :
- Connaissance de Java et frameworks
- Compréhension bases de données relationnelles (PostgreSQL)
- Familiarité avec Gradle et Docker
- Connaissance de base d'Axelor Open Platform

## 📖 Documents Disponibles

### 🔄 **cycle-vie-apps.md** - Cycle de Vie des Applications Axelor

**Sujet** : Comprendre comment fonctionnent les Apps Axelor en interne

**Contenu** :
- Différence fondamentale **Module** (code) vs **App** (base de données)
- Processus d'installation d'une App étape par étape
- Tables créées lors de l'installation
- Chargement des données init-data
- Impact sur menus, permissions, entités
- Analyse technique concrète (BASE, STUDIO, CRM, SALE)
- Requêtes SQL pour inspecter l'état du système

**Quand le consulter** :
- Avant d'installer une nouvelle App
- Pour comprendre pourquoi une App n'apparaît pas dans l'interface
- Pour débugger des problèmes de chargement de données
- Pour comprendre l'architecture Axelor

---

## 🔀 Différence avec Autres Documentations

### vs Documentation Utilisateur (`.claude/docs/utilisateur/`)

| Documentation Utilisateur | Documentation Développeur |
|---------------------------|---------------------------|
| **Public** : Utilisateurs finaux, admins | **Public** : Développeurs, architectes |
| **Focus** : Comment utiliser l'application | **Focus** : Comment fonctionne l'application |
| **Niveau** : Interface, configuration UI | **Niveau** : Code, BDD, architecture |
| **Exemple** : "Comment créer un Lead" | **Exemple** : "Comment une App est chargée en BDD" |

### vs Documentation Technique Générale (`.claude/docs/`)

| Documentation Générale | Documentation Développeur |
|------------------------|---------------------------|
| PRD, vision produit | Architecture interne |
| Setup général projet | Fonctionnement détaillé composants |
| Premier déploiement | Cycle de vie Apps, migrations |

---

## 🗺️ Navigation Documentation Projet

```
.claude/docs/
├── developpeur/              ← VOUS ÊTES ICI
│   ├── README.md            ← Index documentation dev
│   └── cycle-vie-apps.md    ← Cycle de vie Apps Axelor
│
├── utilisateur/             ← Documentation utilisateur final
│   └── guide-administration-axelor.md
│
├── PRD.md                   ← Vision produit
├── document-technique-axelor.md  ← Doc technique Axelor 8.3.15
└── premier-deploiement-local.md  ← Retour d'expérience déploiement
```

## 🎓 Ressources Complémentaires

### Documentation Projet

**Agents Spécialisés** :
- `.claude/agents/agent-configuration-crm.md` - Configuration CRM
- `.claude/agents/agent-data-management.md` - Gestion données
- `.claude/agents/agent-deploiement-local.md` - Déploiement local

**Contexte Projet** :
- `CLAUDE.md` - Contexte général projet

### Documentation Officielle Axelor

**Développeur** :
- **Axelor Open Platform 7.4** : https://docs.axelor.com/adk/7.4/
- **Developer Guide** : https://docs.axelor.com/adk/7.4/dev-guide/
- **Domain Models** : https://docs.axelor.com/adk/7.4/dev-guide/models/
- **Views** : https://docs.axelor.com/adk/7.4/dev-guide/views/
- **Data Import** : https://docs.axelor.com/adk/7.4/dev-guide/data-import/

**Référence** :
- **GitHub AOP** : https://github.com/axelor/axelor-open-platform
- **GitHub AOS** : https://github.com/axelor/axelor-open-suite
- **Forum Axelor** : https://forum.axelor.com/

---

## 💡 Contribuer à Cette Documentation

**Quand ajouter de la documentation développeur** :
- Découverte d'un aspect technique important de l'architecture
- Résolution d'un problème complexe nécessitant compréhension interne
- Migration de données ou modification structure BDD
- Personnalisation avancée nécessitant connaissance architecture

**Format** :
- Fichiers Markdown
- Schémas et diagrammes si nécessaire
- Exemples de code et requêtes SQL
- Références vers code source projet

**Ajout Document** :
1. Créer fichier `.md` dans ce dossier
2. Ajouter entrée dans ce README
3. Mettre à jour `CLAUDE.md` si pertinent
4. Commit avec message descriptif

---

## 🚀 Prêt pour le Développement

Cette documentation développeur vous aidera à :
- ✅ Comprendre l'architecture interne Axelor
- ✅ Faire le lien entre interface et code
- ✅ Débugger efficacement
- ✅ Personnaliser en profondeur
- ✅ Contribuer au projet avec confiance

**Bonne exploration technique ! 👨‍💻🚀**

---

*Documentation Développeur Axelor Vecia v1.0*
*Axelor Open Suite 8.3.15 / Open Platform 7.4*
*Dernière mise à jour : 3 Octobre 2025*
