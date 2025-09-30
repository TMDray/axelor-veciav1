# Product Requirements Document (PRD) - Axelor ERP pour Agence IA

## 📋 Informations Générales

**Nom du projet** : Axelor ERP Vecia (Agence IA)
**Version Axelor** : Open Suite 8.3.15 + Open Platform 7.4
**Date de création** : 30 Septembre 2025
**Statut** : Phase 1 - CRM en cours

---

## 1. Contexte et Vision

### 1.1 Contexte

Nous sommes une **agence IA de développement** spécialisée dans la création de solutions d'intelligence artificielle sur mesure. Nous recherchons un ERP open source, modulaire et flexible pour gérer l'ensemble de nos activités commerciales, projets et opérations.

### 1.2 Pourquoi Axelor ?

- ✅ **Open source** : Contrôle total, pas de vendor lock-in
- ✅ **Low-code/No-code** : Studio, BPM, personnalisation visuelle
- ✅ **Modulaire** : Activation progressive des modules selon besoins
- ✅ **Moderne** : Interface web moderne, API REST
- ✅ **Extensible** : Framework Java pour développements custom
- ✅ **Communauté active** : Forum, GitHub, documentation

### 1.3 Vision Produit

Disposer d'un **ERP complet et personnalisé** permettant de :

- Gérer le cycle commercial complet (leads → devis → projets → facturation)
- Piloter les projets IA avec suivi temps et rentabilité
- Facturer de manière flexible (forfait, régie, abonnement)
- Gérer la relation client avec qualification spécifique IA
- Automatiser les processus métier via BPM
- Intégrer avec nos outils de développement (GitHub, Slack, etc.)

---

## 2. Stack Technique

### 2.1 Technologies Core

| Composant | Version | Rôle |
|-----------|---------|------|
| Axelor Open Suite | 8.3.15 | ERP applicatif |
| Axelor Open Platform | 7.4 | Framework Java |
| Java | OpenJDK 11 | Runtime |
| PostgreSQL | 13+ | Base de données |
| Gradle | Intégré | Build tool |
| Docker | Latest | Conteneurisation |
| Tomcat | 9+ | Serveur d'application |

### 2.2 Infrastructure

#### Environnements

| Environnement | Description | Infrastructure |
|---------------|-------------|----------------|
| **dev** | Développement local | MacBook Pro (local) |
| **test** | Tests et validation | Serveur HPE ProLiant ML30 Gen11<br>Accès via Tailscale VPN (100.124.143.6)<br>WSL2 Ubuntu 22.04.3<br>Docker Stack (PostgreSQL, Redis) |
| **production** | Production (futur) | À définir |

#### Architecture Serveur Test

```
MacBook Pro (100.75.108.76)
         ↓
    Tailscale VPN
         ↓
HPE ProLiant (100.124.143.6)
├── Windows Server 2022
└── WSL2 Ubuntu 22.04.3
    └── Docker Stack
        ├── PostgreSQL 14 (citeos-postgres)
        ├── Redis 6 (citeos-redis)
        └── Axelor 8.3.15 (à déployer)
```

---

## 3. Roadmap Modules par Phases

### Phase 1 : Fondation - CRM & Ventes (0-3 mois)

**Objectif** : Gérer le cycle commercial et premiers clients

#### Modules à activer

1. **CRM** - Gestion relation client
   - Suivi prospects et opportunités
   - Pipeline commercial visuel
   - Historique interactions

2. **Ventes** - Cycle de vente
   - Devis et propositions
   - Commandes clients
   - Catalogue services IA personnalisé

3. **Contacts** - Gestion contacts
   - Annuaire entreprises et personnes
   - Qualification clients (maturité IA)

#### Configuration métier prioritaire

- Catalogue services IA (voir section 5)
- Qualification maturité IA clients (scoring)
- Templates devis agence IA
- Pipeline commercial adapté

### Phase 2 : Gestion de Projet (3-6 mois)

**Objectif** : Piloter les projets IA de bout en bout

#### Modules à activer

4. **Projet** - Pilotage projets
   - Planning Gantt
   - Gestion tâches et jalons
   - Suivi avancement

5. **Gestion à l'affaire** - Vue transversale
   - Consolidation devis → projet → facturation
   - Analyse rentabilité
   - Suivi budgétaire

6. **Feuilles de temps** - Tracking temporel
   - Saisie temps collaborateurs
   - Validation hiérarchique
   - Imputation projets/tâches

7. **Documents (GED)** - Gestion documentaire
   - Stockage centralisé
   - Versioning
   - Partage sécurisé

### Phase 3 : Gestion Financière (6-9 mois)

**Objectif** : Automatiser facturation et comptabilité

#### Modules à activer

8. **Facturation** - Facturation flexible
   - Forfait, régie, abonnements
   - Factures d'acompte et situations
   - Dématérialisation

9. **Comptabilité** - Gestion comptable
   - Comptabilité générale et analytique
   - Multi-société
   - Rapprochement bancaire

10. **Budget** - Pilotage budgétaire
    - Budgets prévisionnels
    - Suivi écarts
    - Tableaux de bord

11. **Contrats** - Gestion contractuelle
    - Contrats développement
    - SLA maintenance
    - Renouvellements

### Phase 4 : Collaboration & Optimisation (9-12 mois)

**Objectif** : Outils collaboratifs et automatisation avancée

#### Modules à activer

12. **Support Client** - Service après-vente
    - Gestion tickets
    - Base de connaissances
    - SLA et escalades

13. **Marketing** - Développement commercial
    - Campagnes ciblées
    - Génération leads
    - Analyse ROI

14. **Portail Collaboratif** - Espaces partagés
    - Accès clients aux projets
    - Partage livrables
    - Validation en ligne

15. **Messagerie intégrée** - Communication
    - Discussions contextuelles
    - Notifications
    - Historique centralisé

### Phase 5 : Low-Code & Intégrations (12+ mois)

**Objectif** : Personnalisation avancée et intégrations externes

#### Outils Low-Code/No-Code

16. **BPM** - Automatisation processus
    - Workflows visuels
    - Automatisation sans code
    - Intégration inter-modules

17. **BI** - Business Intelligence
    - Dashboards personnalisables
    - KPIs temps réel
    - Rapports automatisés

18. **Studio** - Personnalisation visuelle
    - Modification écrans drag & drop
    - Champs personnalisés
    - Adaptation workflows

19. **Connect** - Intégrations externes
    - APIs REST
    - Webhooks
    - Connecteurs (GitHub, Slack, etc.)

20. **Template** - Modèles documents
    - Devis personnalisés
    - Rapports projet
    - Documents contractuels

#### Modules Additionnels

21. **Intégrations techniques**
    - OCR et dématérialisation
    - Signatures électroniques (DocuSign)
    - Intégration bancaire (Open Banking)
    - Sync Office 365 / Google Workspace

22. **Application mobile** (iOS/Android)
    - Suivi projets en mobilité
    - Saisie temps
    - Validation documents

---

## 4. Architecture Technique Détaillée

### 4.1 Modules Axelor

```
axelor-vecia-v1/
├── modules/
│   ├── axelor-crm/          # Phase 1
│   ├── axelor-sales/        # Phase 1
│   ├── axelor-contact/      # Phase 1
│   ├── axelor-project/      # Phase 2
│   ├── axelor-business-project/  # Phase 2
│   ├── axelor-timesheet/    # Phase 2
│   ├── axelor-invoice/      # Phase 3
│   ├── axelor-account/      # Phase 3
│   └── axelor-custom-ai/    # Module custom agence IA
├── docker-compose.yml
├── build.gradle
└── settings.gradle
```

### 4.2 Intégrations Futures

| Outil | Type | Usage |
|-------|------|-------|
| GitHub | API REST | Suivi projets, issues, commits |
| Slack | Webhooks | Notifications CRM, projets |
| Gmail/Outlook | SMTP/IMAP | Emails clients intégrés |
| Google Calendar | API | Synchronisation rendez-vous |
| Stripe/PayPal | API | Paiements en ligne |
| Mindee/OCR | API | Traitement factures |
| DocuSign | API | Signatures électroniques |

---

## 5. Configuration Métier Agence IA

### 5.1 Catalogue Services IA

#### Développement IA

| Service | Type facturation | Durée typique |
|---------|------------------|---------------|
| Création modèles ML/DL sur mesure | Forfait | 2-6 mois |
| POC Intelligence Artificielle | Forfait | 2-4 semaines |
| Chatbots / assistants virtuels | Forfait + Abonnement | 1-3 mois |
| Computer Vision / Traitement image | Forfait | 1-4 mois |
| NLP / Traitement langage naturel | Forfait | 1-4 mois |
| Système de recommandation | Forfait | 1-3 mois |

#### Intégration & Automatisation

| Service | Type facturation | Durée typique |
|---------|------------------|---------------|
| Intégration IA dans ERP existant | Régie | Variable |
| Automatisation processus par IA | Forfait | 1-2 mois |
| Création pipelines de données | Forfait | 2-8 semaines |
| Mise en place MLOps | Forfait | 1-3 mois |
| API IA as a Service | Abonnement | Continu |

#### Conseil & Audit

| Service | Type facturation | Durée typique |
|---------|------------------|---------------|
| Audit maturité IA | Forfait | 1-2 semaines |
| Stratégie data & IA | Forfait | 2-4 semaines |
| Accompagnement transformation IA | Régie | Variable |
| Formation équipes internes | Forfait/jour | 1-5 jours |

#### Maintenance & Support

| Service | Type facturation | Durée typique |
|---------|------------------|---------------|
| Maintenance évolutive modèles IA | Abonnement | Continu |
| Monitoring performance | Abonnement | Continu |
| Réentraînement modèles | Forfait récurrent | Mensuel/Trimestriel |
| Support niveau 1/2/3 | Abonnement | Continu |

### 5.2 Qualification Client (Champs Custom CRM)

#### Maturité Digitale/IA (Scoring)

- **Niveau 1 : Découverte** (0-20%) - Aucune IA, découverte besoin
- **Niveau 2 : Expérimentation** (21-40%) - POCs isolés, tests
- **Niveau 3 : Déploiement** (41-60%) - Quelques cas d'usage en production
- **Niveau 4 : Industrialisation** (61-80%) - IA intégrée aux processus
- **Niveau 5 : Transformation** (81-100%) - IA au cœur de la stratégie

#### Infrastructure Technique

**Type hébergement** :
- On-premise
- Cloud (AWS / Azure / GCP / Autres)
- Hybride

**Bases de données** :
- Relationnelles : MySQL, PostgreSQL, Oracle, SQL Server
- NoSQL : MongoDB, Cassandra, Redis
- Data warehouse : Snowflake, BigQuery, Redshift

**Volume données** :
- < 1TB
- 1-10TB
- 10-100TB
- \> 100TB

**Fréquence mise à jour** :
- Temps réel
- Batch journalier
- Hebdomadaire/Mensuel

#### Stack Technologique Client

**ERP existant** : SAP / Oracle / Microsoft / Axelor / Autres
**CRM existant** : Salesforce / HubSpot / Dynamics / Autres
**Outils BI** : PowerBI / Tableau / Qlik / Looker / Autres
**Langages** : Python / R / Java / .NET / Autres

#### Contexte Organisationnel

**Taille entreprise** :
- TPE (< 10)
- PME (10-250)
- ETI (250-5000)
- GE (> 5000)

**Présence data team** : Oui / Non
**Nombre data scientists/engineers** : 0 / 1-5 / 5-20 / > 20
**Budget IA annuel** : < 50k€ / 50-200k€ / 200k-1M€ / > 1M€

#### Scoring & Potentiel

**Score maturité** : Calculé automatiquement (0-100)
**Potentiel de développement** : Faible / Moyen / Fort
**Complexité projets** : Simple / Moyenne / Complexe
**Taille moyenne projet** : < 50k€ / 50-200k€ / > 200k€

### 5.3 Modèles de Tarification

| Modèle | Description | Usage |
|--------|-------------|-------|
| **Forfait** | Prix fixe pour livrable défini | POCs, projets définis |
| **Régie** | Facturation au temps passé (jour/homme) | Accompagnement, R&D |
| **Abonnement** | Paiement récurrent mensuel/annuel | Maintenance, API as a Service |
| **Success fee** | Rémunération à la performance | Projets ROI mesurable |
| **Hybride** | Combinaison personnalisée | Projets complexes |

### 5.4 Templates Documents

À créer dans module Template :

- Proposition commerciale IA
- Cahier des charges type par use case
- Grille d'évaluation maturité IA
- Rapport d'audit
- Documentation technique livrable
- Contrat de maintenance modèle IA
- Rapport de réentraînement modèle

### 5.5 Workflows BPM Spécifiques

À automatiser :

1. **Qualification lead IA** : Scoring automatique selon critères
2. **Circuit validation POC → Projet** : Workflow approbation
3. **Process livraison modèle IA** : Checklist qualité, validation
4. **Workflow réentraînement périodique** : Alerte + planification
5. **Escalade support technique** : Niveaux 1 → 2 → 3

---

## 6. KPIs et Objectifs

### 6.1 KPIs Commerciaux

- **Taux conversion leads → opportunités** : > 30%
- **Taux conversion opportunités → projets** : > 40%
- **Panier moyen projet** : 100k€
- **Cycle de vente moyen** : < 60 jours
- **Taux de renouvellement abonnements** : > 80%

### 6.2 KPIs Projets

- **Taux respect délais** : > 85%
- **Taux respect budget** : > 90%
- **Marge moyenne projets** : > 40%
- **Temps facturable / temps total** : > 75%

### 6.3 KPIs Satisfaction

- **NPS (Net Promoter Score)** : > 50
- **Taux satisfaction projets** : > 4.5/5
- **Temps réponse support** : < 4h (ouvrées)
- **Taux résolution tickets niveau 1** : > 70%

---

## 7. Risques et Mitigation

### 7.1 Risques Techniques

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Version 8.3.15 instable | Moyen | Fort | Tests exhaustifs en env test avant prod |
| Migration données complexe | Faible | Moyen | Démarrage sans migration, fresh install |
| Performance PostgreSQL | Faible | Moyen | Monitoring, optimisation requêtes |
| Complexité développements custom | Moyen | Moyen | Démarrer avec configuration standard |

### 7.2 Risques Organisationnels

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Courbe d'apprentissage Axelor | Moyen | Moyen | Formation, documentation, communauté |
| Résistance au changement équipe | Faible | Moyen | Implication équipe, itératif |
| Maintenance long terme | Faible | Fort | Communauté active, code open source |

---

## 8. Prochaines Étapes

### Immédiat (Sprint 1-2)

- [x] Setup infrastructure (.claude/, docs, scripts)
- [ ] Téléchargement et compilation Axelor 8.3.15 en local
- [ ] Activation modules CRM + Ventes
- [ ] Déploiement Axelor sur serveur test
- [ ] Configuration base CRM (société, utilisateurs)

### Court terme (1 mois)

- [ ] Import catalogue services IA
- [ ] Configuration champs custom qualification client
- [ ] Templates devis agence IA
- [ ] Tests cycle commercial complet

### Moyen terme (3 mois)

- [ ] Activation et configuration modules Phase 2 (Projet, Gestion à l'affaire)
- [ ] Intégration GitHub/Slack
- [ ] Formation équipe
- [ ] Premier projet pilote dans Axelor

---

## 9. Ressources et Références

### Documentation Officielle

- **Axelor Open Platform 7.4** : https://docs.axelor.com/adk/7.4/
- **Axelor Open Suite 8.x** : https://docs.axelor.com/
- **Installation Guide** : https://axelor.com/installation-guide/

### GitHub

- **AOP Repository** : https://github.com/axelor/axelor-open-platform
- **AOS Repository** : https://github.com/axelor/axelor-open-suite
- **Releases AOS** : https://github.com/axelor/axelor-open-suite/releases

### Communauté

- **Forum Axelor** : https://forum.axelor.com/
- **GitHub Issues** : https://github.com/axelor/axelor-open-suite/issues

### Documentation Interne

- **Document technique Axelor** : `.claude/docs/document-technique-axelor.md`
- **Agent connexion serveur** : `.claude/agents/agent-connexion-serveur.md`
- **Contexte général** : `claude.md`

---

**Document maintenu par** : Équipe Dev Axelor Vecia
**Dernière mise à jour** : 30 Septembre 2025
**Version** : 1.0
**Statut** : Living document - à mettre à jour régulièrement