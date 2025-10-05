# Contexte Projet - Axelor ERP pour Agence IA

## 🎯 Vue d'ensemble

Ce projet vise à déployer et personnaliser **Axelor ERP Open Source** pour une agence IA de développement. L'objectif est de disposer d'un ERP modulaire, évolutif et intégrant des outils low-code/no-code pour gérer l'ensemble des activités de l'agence.

## 📦 Version et Stack Technique

- **Axelor Open Suite** : v8.3.15 (Septembre 2025)
- **Axelor Open Platform** : v7.4
- **Java** : OpenJDK 11
- **Base de données** : PostgreSQL 13+
- **Build** : Gradle
- **Conteneurisation** : Docker + Docker Compose
- **Serveur d'application** : Tomcat

## 🏗️ Infrastructure

### Environnements

- **dev** (local) : Développement sur MacBook Pro
- **test** (serveur distant) : Serveur HPE ProLiant ML30 Gen11 via Tailscale VPN
- **production** : À définir (déploiement futur)

### Serveur de Test

- **Accès** : Via Tailscale VPN (100.124.143.6)
- **OS** : Windows Server 2022 + WSL2 Ubuntu 22.04.3
- **Docker Stack** : PostgreSQL, Redis, Axelor
- **Agent spécialisé** : `.claude/agents/agent-connexion-serveur.md`

## 🔄 Workflow Git

### Stratégie de Branching

- **main** : Production (protégée)
- **test** : Environnement de test
- **dev** : Développement actif

### Conventions de Commit

```
feat: Ajouter une nouvelle fonctionnalité
fix: Corriger un bug
docs: Mise à jour documentation
refactor: Refactoring code
test: Ajout/modification tests
style: Formatting, typos
chore: Tâches maintenance (deps, config)
```

### Philosophie

- ✅ **Commits fréquents** : Commit après chaque étape significative
- ✅ **Push réguliers** : Push après validation locale
- ✅ **Mise à jour contexte** : Mettre à jour ce fichier et docs après changements importants
- ✅ **Itératif** : Développement par petites étapes
- ✅ **Simple d'abord** : Toujours privilégier la solution la plus simple

## 📂 Navigation dans `.claude/`

### Agents Spécialisés (`.claude/agents/`)

- **agent-connexion-serveur.md** : Expert connexion serveur HPE via Tailscale VPN
- **agent-deploiement-local.md** : Expert déploiement Axelor 8.3.15 local macOS
- **agent-configuration-crm.md** : Expert configuration CRM, low-code Studio, personnalisation
- **agent-data-management.md** : Expert gestion données (import/export CSV, init-data, migration)
- **README.md** : Index et usage des agents

### Modules Axelor (`.claude/modules/`)

- **README.md** : Documentation progressive des modules Axelor implémentés
- Modules documentés au fur et à mesure du développement

### Commandes Personnalisées (`.claude/commands/`)

Commandes slash disponibles :

- `/deploy` : Déployer sur serveur de test
- `/git-commit-push` : Commit + push + mise à jour contexte automatique
- `/update-context` : Forcer mise à jour claude.md et documentation
- `/create-module` : Créer un nouveau module Axelor avec structure complète
- `/test` : Lancer les tests du projet

### Documentation (`.claude/docs/`)

**Documentation Technique :**
- **PRD.md** : Product Requirements Document (vision produit complète)
- **document-technique-axelor.md** : Documentation technique Axelor 8.3.15
- **premier-deploiement-local.md** : Retour d'expérience historique premier déploiement

**Documentation Utilisateur (`.claude/docs/utilisateur/`) :**
- **guide-administration-axelor.md** : Guide complet administration pour utilisateurs finaux

**Documentation Développeur (`.claude/docs/developpeur/`) :**
- **cycle-vie-apps.md** : Cycle de vie Apps Axelor (Module vs App, installation, base de données)
- **README.md** : Index documentation développeur

## 🎯 Phase Actuelle : Phase 1 - CRM

### Objectif Immédiat

Déployer et configurer le module **CRM** d'Axelor avec :

- Gestion prospects et opportunités
- Pipeline commercial
- Catalogue services IA
- Qualification clients (maturité IA)

### Modules Phase 1

1. CRM
2. Ventes
3. Contacts

Voir `.claude/docs/PRD.md` pour la roadmap complète.

## 🛠️ Scripts Utilitaires (`scripts/`)

Dossier contenant les scripts d'automatisation :

- Déploiement
- Backup
- Migration données
- Health checks
- Voir `scripts/README.md` pour la liste complète

## 📚 Ressources

### Documentation Officielle

- Axelor Open Platform 7.4 : https://docs.axelor.com/adk/7.4/
- Axelor Open Suite : https://docs.axelor.com/
- GitHub AOP : https://github.com/axelor/axelor-open-platform
- GitHub AOS : https://github.com/axelor/axelor-open-suite

### Forum et Support

- Forum Axelor : https://forum.axelor.com/
- GitHub Issues AOS : https://github.com/axelor/axelor-open-suite/issues

## 🔑 Principes de Développement

1. **Documentation continue** : Documenter en développant, pas après
2. **Tests réguliers** : Tester chaque fonctionnalité avant de passer à la suivante
3. **Code review** : Relire le code avant chaque commit
4. **Backup régulier** : Sauvegarder données et configuration
5. **Sécurité** : Ne jamais commiter secrets, credentials, ou .env

## 🎓 Contexte Métier : Agence IA

### Services Proposés

- Développement modèles ML/DL sur mesure
- POC Intelligence Artificielle
- Chatbots et assistants virtuels
- Computer Vision / NLP
- Intégration IA dans systèmes existants
- Conseil et audit maturité IA

### Configuration Spécifique

Voir `.claude/docs/PRD.md` section "Configuration Métier Agence IA" pour :

- Catalogue services IA détaillé
- Scoring maturité IA clients
- Qualification technique (stack, infrastructure)
- Modèles de tarification (forfait, régie, abonnement)

## 📝 Notes Importantes

- Ce fichier (`claude.md`) est lu automatiquement par Claude Code au démarrage
- Garder ce fichier concis (< 200 lignes recommandé)
- Détails techniques → `.claude/docs/document-technique-axelor.md`
- Vision produit → `.claude/docs/PRD.md`
- Mise à jour régulière après changements significatifs

---

**Dernière mise à jour** : 2025-10-03
**Version Axelor** : 8.3.15
**Phase** : Phase 1 - Setup & CRM