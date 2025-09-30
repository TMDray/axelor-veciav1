# Documentation Technique - Axelor Open Suite 8.3.15

## 📚 Table des Matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [Installation et Prérequis](#2-installation-et-prérequis)
3. [Architecture](#3-architecture)
4. [Développement de Modules Custom](#4-développement-de-modules-custom)
5. [Configuration](#5-configuration)
6. [API REST](#6-api-rest)
7. [Outils Low-Code](#7-outils-low-code)
8. [Déploiement](#8-déploiement)
9. [Best Practices](#9-best-practices)
10. [Ressources](#10-ressources)

---

## 1. Vue d'ensemble

### 1.1 Axelor Open Platform (AOP)

**Axelor Open Platform v7.4** est un framework Java open source pour le développement d'applications métier modernes.

**Caractéristiques** :
- Framework MVC basé sur Java
- ORM avec Hibernate
- Interface web moderne (React-like)
- Architecture REST API
- Support multi-tenant
- Extensible via modules Gradle

### 1.2 Axelor Open Suite (AOS)

**Axelor Open Suite v8.3.15** est une suite ERP complète construite sur Axelor Open Platform.

**Nouveautés Version 8.x** :
- ✨ Nouvelle interface graphique moderne
- 🔧 Outils Low-Code intégrés (Studio, BPM, Reporting)
- 🌍 Support multilingue avancé
- 📱 Dashboards mobiles
- 📋 Nouveaux modules (appels d'offres, validation partielle devis)

### 1.3 Stack Technique

| Composant | Version | Rôle |
|-----------|---------|------|
| Java | OpenJDK 11 | Runtime et développement |
| PostgreSQL | 13+ | Base de données relationnelle |
| Gradle | 7.5+ | Build automation |
| Tomcat | 9+ | Serveur d'application |
| Hibernate | 5.x | ORM |
| Groovy | 3.x | Scripting |

---

## 2. Installation et Prérequis

### 2.1 Prérequis Système

#### Logiciels Requis

```bash
# Java OpenJDK 11
java -version
# openjdk version "11.0.x"

# PostgreSQL 13+
psql --version
# psql (PostgreSQL) 13.x

# Git
git --version
```

#### Configuration PostgreSQL

```bash
# Se connecter à PostgreSQL
sudo -u postgres psql

# Créer utilisateur Axelor
CREATE USER axelor WITH PASSWORD 'axelor2024';

# Créer base de données
CREATE DATABASE axelor_vecia OWNER axelor;

# Installer extension unaccent
\c axelor_vecia
CREATE EXTENSION IF NOT EXISTS unaccent;

# Quitter
\q
```

#### Configuration Système

**Mémoire recommandée** :
- Développement : 8 GB RAM minimum
- Production : 16 GB RAM minimum

**Disque** :
- 10 GB minimum pour application
- 50+ GB pour données selon volume

### 2.2 Installation Axelor Open Suite 8.3.15

#### Option 1 : Installation depuis GitHub (Recommandée)

```bash
# Cloner le repository
git clone https://github.com/axelor/axelor-open-suite.git
cd axelor-open-suite

# Checkout version 8.3.15
git checkout v8.3.15

# Compiler et lancer
./gradlew build
./gradlew run

# Accès : http://localhost:8080/
# Login : admin / admin

# ⚠️ IMPORTANT : Tous les modules sont déjà inclus !
# Action suivante : Activer les modules nécessaires via Menu → Apps
```

#### Activation Modules

Après compilation et lancement :

1. **Se connecter** : http://localhost:8080/ (admin/admin)
2. **Menu** → **Apps**
3. **Activer modules** : CRM, Sales, Project, etc.
4. **Configurer** selon besoins

⚠️ **Les modules ne sont PAS à installer** - ils sont déjà dans le code source !

#### Option 2 : Docker (Test Rapide)

```bash
# Lancer Axelor All-in-One
docker run -it -p 8080:80 axelor/aio-erp

# Accès : http://localhost:8080/
```

### 2.3 Configuration Initiale

#### Fichier `application.properties`

```properties
# Database
db.default.driver = org.postgresql.Driver
db.default.url = jdbc:postgresql://localhost:5432/axelor_vecia
db.default.user = axelor
db.default.password = axelor2024

# Application
application.name = Axelor Vecia ERP
application.description = ERP pour Agence IA
application.version = 1.0.0
application.author = Vecia Team

# Mode (dev / prod)
application.mode = dev

# Locale
application.locale = fr
application.timezone = Europe/Paris

# Session timeout (en minutes)
session.timeout = 60

# File upload
file.upload.dir = {java.io.tmpdir}/axelor
file.upload.size = 10

# CORS (développement)
cors.allow-origin = *
cors.allow-credentials = true
```

---

## 3. Architecture

### 3.1 Structure d'un Projet Axelor

```
axelor-vecia-v1/
├── modules/                    # Modules métier
│   ├── axelor-crm/            # Module CRM
│   ├── axelor-sale/           # Module Ventes
│   ├── axelor-project/        # Module Projets
│   └── axelor-custom-ai/      # Module custom agence IA
├── src/
│   └── main/
│       ├── java/              # Code Java
│       ├── resources/         # Ressources
│       │   ├── domains/       # Modèles de données (XML)
│       │   ├── views/         # Vues (XML)
│       │   └── i18n/          # Traductions
│       └── webapp/            # Interface web
├── build.gradle               # Configuration Gradle
├── settings.gradle            # Modules Gradle
└── application.properties     # Configuration app
```

### 3.2 Architecture en Couches

```
┌─────────────────────────────────────┐
│   Interface Web (React-like)       │
├─────────────────────────────────────┤
│   REST API / JSON-RPC              │
├─────────────────────────────────────┤
│   Services Métier (Java)           │
├─────────────────────────────────────┤
│   Repositories / ORM (Hibernate)   │
├─────────────────────────────────────┤
│   PostgreSQL Database              │
└─────────────────────────────────────┘
```

### 3.3 Modèle de Données

#### Déclaration Domaine (XML)

```xml
<!-- modules/axelor-custom-ai/src/main/resources/domains/AIProject.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<domain-models xmlns="http://axelor.com/xml/ns/domain-models">

  <module name="custom-ai" package="com.axelor.apps.customai.db"/>

  <entity name="AIProject" table="custom_ai_project">
    <string name="name" title="Nom du projet" required="true"/>
    <string name="description" title="Description" large="true"/>
    <many-to-one name="client" ref="com.axelor.apps.base.db.Partner" title="Client"/>
    <date name="startDate" title="Date début"/>
    <date name="endDate" title="Date fin"/>
    <decimal name="budget" title="Budget" precision="20" scale="2"/>
    <string name="aiTechnology" title="Technologie IA"
            selection="ai.project.technology"/>
    <integer name="maturityScore" title="Score maturité" min="0" max="100"/>
  </entity>

</domain-models>
```

#### Génération Code Java

```bash
# Générer les classes Java depuis XML
./gradlew generateCode
```

### 3.4 Vues (XML)

#### Vue Formulaire

```xml
<!-- modules/axelor-custom-ai/src/main/resources/views/AIProject.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<object-views xmlns="http://axelor.com/xml/ns/object-views">

  <grid name="ai-project-grid" title="Projets IA" model="com.axelor.apps.customai.db.AIProject">
    <field name="name"/>
    <field name="client"/>
    <field name="startDate"/>
    <field name="endDate"/>
    <field name="budget"/>
    <field name="maturityScore"/>
  </grid>

  <form name="ai-project-form" title="Projet IA" model="com.axelor.apps.customai.db.AIProject">
    <panel title="Informations générales">
      <field name="name"/>
      <field name="client"/>
      <field name="description" colSpan="12"/>
    </panel>
    <panel title="Planning">
      <field name="startDate"/>
      <field name="endDate"/>
      <field name="budget"/>
    </panel>
    <panel title="Technologie IA">
      <field name="aiTechnology"/>
      <field name="maturityScore"/>
    </panel>
  </form>

</object-views>
```

---

## 4. Développement de Modules Custom

### 4.1 Créer un Module

#### Structure Module

```bash
# Créer dossier module
mkdir -p modules/axelor-custom-ai/src/main/{java,resources}

# Structure complète
modules/axelor-custom-ai/
├── build.gradle
└── src/main/
    ├── java/
    │   └── com/axelor/apps/customai/
    │       ├── db/           # Entités générées
    │       ├── service/      # Services métier
    │       ├── web/          # Controllers REST
    │       └── module/       # Module definition
    └── resources/
        ├── domains/          # Modèles XML
        ├── views/            # Vues XML
        ├── i18n/             # Traductions
        └── data-init/        # Données initiales
```

#### build.gradle

```gradle
apply plugin: 'com.axelor.app-module'

axelor {
    title = "Axelor Custom AI"
    description = "Module custom pour agence IA"
}

dependencies {
    api project(':modules:axelor-crm')
    api project(':modules:axelor-project')
}
```

#### settings.gradle

```gradle
// Ajouter dans settings.gradle racine
include 'modules:axelor-custom-ai'
```

### 4.2 Services Métier

```java
// modules/axelor-custom-ai/src/main/java/com/axelor/apps/customai/service/AIProjectService.java
package com.axelor.apps.customai.service;

import com.axelor.apps.customai.db.AIProject;

public interface AIProjectService {

    /**
     * Calculer le score de maturité IA du client
     */
    int calculateMaturityScore(AIProject project);

    /**
     * Générer proposition commerciale
     */
    void generateProposal(AIProject project);

    /**
     * Valider budget projet
     */
    boolean validateBudget(AIProject project);
}
```

```java
// Implementation
package com.axelor.apps.customai.service.impl;

import com.axelor.apps.customai.service.AIProjectService;
import com.google.inject.Singleton;

@Singleton
public class AIProjectServiceImpl implements AIProjectService {

    @Override
    public int calculateMaturityScore(AIProject project) {
        // Logique calcul score
        int score = 0;
        // ... calculs
        return score;
    }

    // ... autres méthodes
}
```

### 4.3 Controllers REST

```java
package com.axelor.apps.customai.web;

import com.axelor.apps.customai.db.AIProject;
import com.axelor.apps.customai.service.AIProjectService;
import com.axelor.rpc.ActionRequest;
import com.axelor.rpc.ActionResponse;
import com.google.inject.Inject;

public class AIProjectController {

    @Inject
    private AIProjectService projectService;

    public void calculateScore(ActionRequest request, ActionResponse response) {
        AIProject project = request.getContext().asType(AIProject.class);
        int score = projectService.calculateMaturityScore(project);
        response.setValue("maturityScore", score);
    }
}
```

---

## 5. Configuration

### 5.1 Sélections (Listes Déroulantes)

```xml
<!-- modules/axelor-custom-ai/src/main/resources/domains/Selection.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<selections xmlns="http://axelor.com/xml/ns/domain-models">

  <selection name="ai.project.technology">
    <option value="ml">Machine Learning</option>
    <option value="dl">Deep Learning</option>
    <option value="nlp">NLP</option>
    <option value="cv">Computer Vision</option>
    <option value="recommender">Système Recommandation</option>
  </selection>

  <selection name="ai.client.maturity">
    <option value="discovery">Découverte (0-20%)</option>
    <option value="experimentation">Expérimentation (21-40%)</option>
    <option value="deployment">Déploiement (41-60%)</option>
    <option value="industrialization">Industrialisation (61-80%)</option>
    <option value="transformation">Transformation (81-100%)</option>
  </selection>

</selections>
```

### 5.2 Actions

```xml
<!-- modules/axelor-custom-ai/src/main/resources/views/AIProject.xml -->
<action-method name="action-ai-project-calculate-score">
  <call class="com.axelor.apps.customai.web.AIProjectController" method="calculateScore"/>
</action-method>

<!-- Bouton dans formulaire -->
<button name="calculateScoreBtn" title="Calculer Score"
        onClick="action-ai-project-calculate-score"/>
```

---

## 6. API REST

### 6.1 Authentification

```bash
# Login
curl -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin"

# Récupérer JSESSIONID dans cookie
```

### 6.2 CRUD Operations

#### Read (Recherche)

```bash
curl -X POST http://localhost:8080/ws/rest/com.axelor.apps.customai.db.AIProject/search \
  -H "Content-Type: application/json" \
  -H "Cookie: JSESSIONID=xxx" \
  -d '{
    "offset": 0,
    "limit": 10,
    "fields": ["name", "client", "budget"],
    "sortBy": ["name"]
  }'
```

#### Create

```bash
curl -X POST http://localhost:8080/ws/rest/com.axelor.apps.customai.db.AIProject \
  -H "Content-Type: application/json" \
  -H "Cookie: JSESSIONID=xxx" \
  -d '{
    "data": {
      "name": "Projet Chatbot IA",
      "description": "Développement chatbot NLP",
      "budget": 50000,
      "aiTechnology": "nlp"
    }
  }'
```

#### Update

```bash
curl -X POST http://localhost:8080/ws/rest/com.axelor.apps.customai.db.AIProject/1 \
  -H "Content-Type: application/json" \
  -H "Cookie: JSESSIONID=xxx" \
  -d '{
    "data": {
      "id": 1,
      "version": 0,
      "budget": 60000
    }
  }'
```

#### Delete

```bash
curl -X POST http://localhost:8080/ws/rest/com.axelor.apps.customai.db.AIProject/remove \
  -H "Content-Type: application/json" \
  -H "Cookie: JSESSIONID=xxx" \
  -d '{
    "records": [{"id": 1, "version": 0}]
  }'
```

---

## 7. Outils Low-Code

### 7.1 Studio (Personnalisation Visuelle)

**Accès** : Menu > Studio

**Fonctionnalités** :
- Créer champs personnalisés (drag & drop)
- Modifier vues existantes
- Créer nouveaux menus
- Configurer actions

**Usage** :
1. Sélectionner module/objet
2. Ajouter champs custom
3. Modifier layout formulaire
4. Exporter configuration

### 7.2 BPM (Business Process Management)

**Créer un Workflow** :

1. Menu > BPM > Processus
2. Créer nouveau processus
3. Modéliser (notation BPMN)
4. Définir tâches et transitions
5. Configurer notifications
6. Activer processus

**Exemple** : Workflow validation devis
- Étape 1 : Création devis (commercial)
- Étape 2 : Validation technique (expert IA)
- Étape 3 : Validation budgétaire (direction)
- Étape 4 : Envoi client

### 7.3 Template (Modèles Documents)

**Créer Template** :

1. Menu > Administration > Templates
2. Nouveau template
3. Type : Devis / Facture / Rapport
4. Utiliser placeholders : `${object.name}`
5. Format : HTML / DOCX / PDF

**Exemple Devis IA** :

```html
<h1>Proposition Commerciale - Projet IA</h1>
<p>Client : ${object.client.name}</p>
<p>Projet : ${object.name}</p>
<p>Budget : ${object.budget} €</p>
<p>Technologie : ${object.aiTechnology}</p>
```

---

## 8. Déploiement

### 8.1 Build Production

```bash
# Compiler application
./gradlew clean build

# Générer WAR
./gradlew war

# Fichier généré : build/libs/axelor-vecia-1.0.0.war
```

### 8.2 Déploiement Tomcat

```bash
# Copier WAR dans Tomcat
cp build/libs/axelor-vecia-1.0.0.war $TOMCAT_HOME/webapps/

# Démarrer Tomcat
$TOMCAT_HOME/bin/startup.sh

# Accès : http://localhost:8080/axelor-vecia-1.0.0/
```

### 8.3 Docker Déploiement

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: axelor_vecia
      POSTGRES_USER: axelor
      POSTGRES_PASSWORD: axelor2024
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  axelor:
    build: .
    depends_on:
      - postgres
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: axelor_vecia
      DB_USER: axelor
      DB_PASSWORD: axelor2024
    ports:
      - "8080:8080"
    volumes:
      - axelor_uploads:/opt/axelor/uploads

volumes:
  postgres_data:
  axelor_uploads:
```

```bash
# Lancer stack
docker-compose up -d

# Logs
docker-compose logs -f axelor
```

---

## 9. Best Practices

### 9.1 Développement

- ✅ **Générer code** après modification domaines : `./gradlew generateCode`
- ✅ **Utiliser services** pour logique métier (pas dans controllers)
- ✅ **Transactions** : Méthodes service annotées `@Transactional`
- ✅ **Injection dépendances** : Utiliser Guice (`@Inject`)
- ✅ **Nommage** : Conventions Java (camelCase, PascalCase)

### 9.2 Performance

- ✅ **Lazy loading** : Configurer fetch strategies
- ✅ **Indexes** : Ajouter sur colonnes recherchées fréquemment
- ✅ **Pagination** : Toujours limiter résultats (`limit`, `offset`)
- ✅ **Cache** : Activer pour objets statiques
- ✅ **Requêtes** : Optimiser JPQL, éviter N+1

### 9.3 Sécurité

- ✅ **Authentification** : Utiliser mécanismes Axelor (pas custom)
- ✅ **Permissions** : Configurer via groupes et rôles
- ✅ **Validation** : Toujours valider inputs côté serveur
- ✅ **Secrets** : Ne jamais hardcoder (utiliser variables env)
- ✅ **HTTPS** : Toujours en production

### 9.4 Maintenance

- ✅ **Backup** : Base de données quotidienne minimum
- ✅ **Logs** : Configurer log4j correctement
- ✅ **Monitoring** : JMX, health checks
- ✅ **Updates** : Tester updates sur env test d'abord
- ✅ **Documentation** : Documenter modules custom

---

## 10. Ressources

### 10.1 Documentation Officielle

- **AOP 7.4 Docs** : https://docs.axelor.com/adk/7.4/
- **Installation Guide** : https://docs.axelor.com/adk/7.4/getting-started/install.html
- **Tutorial** : https://docs.axelor.com/adk/7.4/tutorial/
- **API Reference** : https://docs.axelor.com/adk/7.4/javadoc/

### 10.2 GitHub

- **AOP Repository** : https://github.com/axelor/axelor-open-platform
- **AOS Repository** : https://github.com/axelor/axelor-open-suite
- **Releases 8.3.15** : https://github.com/axelor/axelor-open-suite/releases/tag/v8.3.15
- **Changelog** : https://github.com/axelor/axelor-open-suite/blob/master/CHANGELOG.md

### 10.3 Communauté

- **Forum Axelor** : https://forum.axelor.com/
- **GitHub Issues** : https://github.com/axelor/axelor-open-suite/issues
- **Stack Overflow** : Tag `axelor`

### 10.4 Tutoriels et Guides

- **Deployment Guide** : https://medium.com/@siddique-ahmad/deployment-of-axelor-open-platform-based-application-14fa8a6653ef
- **Module Creation** : https://docs.axelor.com/adk/7.4/tutorial/step2.html
- **BPM Guide** : https://docs.axelor.com/ (section BPM)

---

**Document maintenu par** : Équipe Dev Axelor Vecia
**Dernière mise à jour** : 30 Septembre 2025
**Version Axelor** : 8.3.15 (AOS) + 7.4 (AOP)
**Statut** : Living document