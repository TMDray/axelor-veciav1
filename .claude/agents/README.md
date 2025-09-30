# 🤖 Agents Spécialisés - Index

Ce dossier contient les **agents spécialisés** pour le projet Axelor Vecia. Chaque agent est un expert dans un domaine spécifique et dispose de toutes les connaissances nécessaires pour accomplir sa mission de manière autonome.

---

## 📚 Liste des Agents Disponibles

### 1. 🖥️ Agent Connexion Serveur

**Fichier** : `agent-connexion-serveur.md`

**Mission** : Expert spécialisé dans la connexion et l'accès distant au serveur HPE ProLiant ML30 Gen11 via Tailscale VPN

**Compétences** :
- Connexion SSH sécurisée via Tailscale VPN
- Diagnostic et résolution problèmes réseau
- Gestion Docker distant (PostgreSQL, Redis)
- Monitoring services et performance
- Troubleshooting WSL2/Ubuntu

**Quand l'utiliser** :
- Besoin de se connecter au serveur de test
- Déploiement application sur serveur distant
- Diagnostic problèmes connexion/réseau
- Monitoring services Docker
- Redémarrage services à distance

**Commandes clés** :
```bash
# Connexion SSH
ssh axelor@100.124.143.6

# Status services
ssh axelor@100.124.143.6 "docker ps"

# Diagnostic complet
# Voir scripts dans agent-connexion-serveur.md
```

---

## 🎯 Comment Utiliser un Agent

### Méthode 1 : Via Claude Code

```
@agent-connexion-serveur Je dois déployer Axelor sur le serveur de test,
peux-tu m'aider à me connecter et vérifier que tous les services sont OK ?
```

### Méthode 2 : Lecture Directe

1. Ouvrir le fichier markdown de l'agent
2. Consulter la section pertinente
3. Copier/exécuter les commandes nécessaires

### Méthode 3 : Scripts

Certains agents fournissent des scripts réutilisables :
- Copier dans `scripts/`
- Rendre exécutable : `chmod +x script.sh`
- Exécuter : `./script.sh`

---

## 📝 Structure d'un Agent

Chaque fichier agent contient généralement :

1. **Mission** : Objectif principal de l'agent
2. **Connaissances Essentielles** : Informations techniques nécessaires
3. **Architecture** : Schémas et configurations
4. **Problèmes Fréquents** : Troubleshooting
5. **Outils et Scripts** : Commandes et scripts utiles
6. **Best Practices** : Bonnes pratiques
7. **Historique** : Actions passées et résultats

---

## 🚀 Agents Futurs (À Créer)

### 2. 🐳 Agent Déploiement Docker

**Mission** : Spécialiste déploiement Axelor via Docker

**Compétences** :
- Docker Compose pour Axelor
- Configuration PostgreSQL/Redis
- Volumes et persistance données
- Networking containers
- Health checks et monitoring

**Statut** : À créer

---

### 3. 📦 Agent Module Axelor

**Mission** : Expert création et configuration modules Axelor custom

**Compétences** :
- Structure modules Gradle
- Domaines XML et génération code
- Vues et formulaires
- Services métier Java
- BPM et workflows

**Statut** : À créer

---

### 4. 🔧 Agent Configuration CRM

**Mission** : Spécialiste configuration CRM pour agence IA

**Compétences** :
- Catalogue services IA
- Qualification clients (scoring maturité)
- Templates devis personnalisés
- Pipeline commercial adapté
- Champs custom et sélections

**Statut** : À créer

---

### 5. 🚀 Agent CI/CD

**Mission** : Expert intégration continue et déploiement

**Compétences** :
- GitHub Actions / GitLab CI
- Tests automatisés
- Build et packaging
- Déploiement automatique
- Rollback et versioning

**Statut** : À créer

---

## 💡 Bonnes Pratiques Agents

### Création d'un Nouvel Agent

1. **Identifier le domaine d'expertise** : Un agent = une mission claire
2. **Documenter exhaustivement** : Toutes connaissances nécessaires
3. **Inclure exemples concrets** : Commandes, scripts, configurations
4. **Prévoir troubleshooting** : Problèmes courants et solutions
5. **Maintenir à jour** : Mettre à jour après chaque intervention

### Utilisation Optimale

- ✅ **Consulter agent AVANT** de faire action complexe
- ✅ **Mettre à jour agent APRÈS** résolution nouveau problème
- ✅ **Documenter changements** dans section Historique
- ✅ **Partager connaissances** : Si solution trouvée, l'ajouter
- ✅ **Référencer agents** dans autres docs (claude.md, PRD, etc.)

---

## 🔗 Liens Utiles

- **Contexte général** : `../../claude.md`
- **Documentation technique** : `../docs/document-technique-axelor.md`
- **PRD** : `../docs/PRD.md`
- **Commandes personnalisées** : `../commands/`
- **Scripts** : `../../scripts/`

---

**Maintenu par** : Équipe Dev Axelor Vecia
**Dernière mise à jour** : 30 Septembre 2025