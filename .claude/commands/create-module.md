# Commande `/create-module` - Créer Module Custom Axelor

⚠️ **IMPORTANT** : Cette commande est pour créer des **modules CUSTOM uniquement** !

Les modules standards Axelor (CRM, Ventes, Projet, etc.) sont **déjà inclus** dans Axelor Open Suite et n'ont besoin que d'être **activés** via l'interface.

## 🎯 Objectif

Automatiser la création d'un **nouveau module custom** Axelor avec tous les fichiers nécessaires pour des fonctionnalités spécifiques à votre projet.

## ⚠️ Modules Standards vs Modules Custom

### Modules Standards Axelor (Déjà Inclus)

✅ **Déjà présents** dans Axelor Open Suite 8.3.15 :
- `axelor-crm` - CRM
- `axelor-sale` - Ventes
- `axelor-project` - Gestion de projet
- `axelor-account` - Comptabilité
- `axelor-human-resource` - RH
- `axelor-production` - Production
- `axelor-supplychain` - Supply Chain
- Et plus de 30 autres modules...

**Action requise** : **ACTIVER** via Menu → Apps dans l'interface Axelor

❌ **NE PAS utiliser `/create-module` pour ces modules !**

### Modules Custom (À Créer)

💡 Créer un module custom **UNIQUEMENT** si vous avez besoin de :
- Fonctionnalités 100% spécifiques à votre métier
- Entités métier non présentes dans modules standards
- Logique métier complexe et personnalisée
- Extensions avancées des modules standards

**Exemple pour ce projet** : `axelor-custom-ai`
- Scoring maturité IA clients
- Gestion projets IA spécifiques
- Qualification technique custom
- Intégrations APIs IA

## 📝 Usage

```
/create-module <nom-module-custom>
```

Exemple :

```
/create-module custom-ai
```

Ou avec options :

```
/create-module custom-ai --package com.axelor.apps.customai --dependencies crm,project
```

## 🔧 Actions Effectuées

1. **Création structure** :
   ```
   modules/axelor-<nom-module>/
   ├── build.gradle
   └── src/main/
       ├── java/
       │   └── com/axelor/apps/<module>/
       │       ├── db/           # Entités générées
       │       ├── service/      # Services métier custom
       │       ├── web/          # Controllers custom
       │       └── module/       # Module definition
       └── resources/
           ├── domains/          # Modèles XML custom
           ├── views/            # Vues XML custom
           ├── i18n/             # Traductions
           └── data-init/        # Données initiales
   ```

2. **Génération fichiers** :
   - `build.gradle` configuré
   - `Module.java` pour injection dépendances
   - Domaine exemple
   - Vue exemple
   - Service interface et implémentation
   - Fichier i18n fr/en

3. **Configuration projet** :
   - Ajout dans `settings.gradle`
   - Documentation dans `.claude/modules/<module>.md`

4. **Validation** :
   - Test compilation
   - Génération code : `./gradlew generateCode`

## 📦 Cas d'Usage : Module `axelor-custom-ai`

### Fonctionnalités Custom Prévues

**Entité AIProject** :
```xml
<entity name="AIProject" table="custom_ai_project">
  <string name="name" title="Nom projet IA"/>
  <many-to-one name="client" ref="Partner" title="Client"/>
  <string name="aiTechnology" title="Technologie IA"
          selection="ai.technology"/>
  <integer name="maturityScore" title="Score maturité IA"/>
  <decimal name="complexityScore" title="Complexité technique"/>
</entity>
```

**Service Custom** :
```java
public interface AIProjectService {
    /**
     * Calculer score maturité IA du client
     * Basé sur : infrastructure, équipe data, budget, volume données
     */
    int calculateMaturityScore(Partner client);

    /**
     * Recommander stack technique selon projet
     */
    List<String> recommendTechStack(AIProject project);
}
```

**Intégrations Custom** :
- API GitHub pour suivi projets
- API Slack pour notifications
- APIs ML externes (Hugging Face, OpenAI, etc.)

## 📦 Fichiers Générés

### build.gradle

```gradle
apply plugin: 'com.axelor.app-module'

axelor {
    title = "Axelor <Module>"
    description = "Module custom <description>"
}

dependencies {
    // Dépendances modules Axelor standards
    api project(':modules:axelor-base')
    api project(':modules:axelor-crm')
    api project(':modules:axelor-project')

    // Dépendances externes si nécessaire
    // implementation 'com.example:library:1.0.0'
}
```

### Domaine Exemple

`src/main/resources/domains/Example.xml` :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<domain-models xmlns="http://axelor.com/xml/ns/domain-models">

  <module name="<module>" package="com.axelor.apps.<module>.db"/>

  <entity name="Example" table="<module>_example">
    <string name="name" title="Nom" required="true"/>
    <string name="description" title="Description" large="true"/>
    <many-to-one name="partner" ref="com.axelor.apps.base.db.Partner" title="Partenaire"/>
    <date name="date" title="Date"/>
  </entity>

</domain-models>
```

### Vue Exemple

`src/main/resources/views/Example.xml` :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<object-views xmlns="http://axelor.com/xml/ns/object-views">

  <grid name="example-grid" title="Examples" model="com.axelor.apps.<module>.db.Example">
    <field name="name"/>
    <field name="partner"/>
    <field name="date"/>
  </grid>

  <form name="example-form" title="Example" model="com.axelor.apps.<module>.db.Example">
    <panel title="Informations">
      <field name="name"/>
      <field name="partner"/>
      <field name="date"/>
      <field name="description" colSpan="12"/>
    </panel>
  </form>

  <action-view name="action-example-view" title="Examples" model="com.axelor.apps.<module>.db.Example">
    <view type="grid" name="example-grid"/>
    <view type="form" name="example-form"/>
  </action-view>

  <menu name="menu-example-root" title="Examples" parent="menu-custom"/>
  <menu name="menu-example-all" title="All Examples" parent="menu-example-root" action="action-example-view"/>

</object-views>
```

### Service Interface

`src/main/java/com/axelor/apps/<module>/service/ExampleService.java` :

```java
package com.axelor.apps.<module>.service;

import com.axelor.apps.<module>.db.Example;

public interface ExampleService {

    /**
     * Process example
     */
    void processExample(Example example);

    /**
     * Validate example
     */
    boolean validateExample(Example example);
}
```

### Service Implementation

`src/main/java/com/axelor/apps/<module>/service/impl/ExampleServiceImpl.java` :

```java
package com.axelor.apps.<module>.service.impl;

import com.axelor.apps.<module>.db.Example;
import com.axelor.apps.<module>.service.ExampleService;
import com.google.inject.Singleton;

@Singleton
public class ExampleServiceImpl implements ExampleService {

    @Override
    public void processExample(Example example) {
        // TODO: Implementation custom
    }

    @Override
    public boolean validateExample(Example example) {
        // TODO: Implementation custom
        return true;
    }
}
```

### Module Definition

`src/main/java/com/axelor/apps/<module>/module/CustomModule.java` :

```java
package com.axelor.apps.<module>.module;

import com.axelor.app.AxelorModule;
import com.axelor.apps.<module>.service.ExampleService;
import com.axelor.apps.<module>.service.impl.ExampleServiceImpl;

public class CustomModule extends AxelorModule {

    @Override
    protected void configure() {
        bind(ExampleService.class).to(ExampleServiceImpl.class);
    }
}
```

## 🎛️ Options

| Option | Description | Exemple |
|--------|-------------|---------|
| `--package <pkg>` | Package Java custom | `--package com.vecia.ai` |
| `--dependencies <modules>` | Dépendances modules (comma-separated) | `--dependencies crm,project` |
| `--no-example` | Ne pas générer fichiers exemple | `--no-example` |
| `--template <type>` | Template prédéfini (basic/entity/service) | `--template entity` |

## 🚀 Workflow Complet

### Étape 1 : Créer Module Custom

```bash
/create-module custom-ai --dependencies crm,project
```

### Étape 2 : Vérifier Structure

```bash
tree modules/axelor-custom-ai
```

### Étape 3 : Générer Code

```bash
./gradlew generateCode
```

Cela génère les classes Java dans `modules/axelor-custom-ai/build/src-gen/`

### Étape 4 : Compiler

```bash
./gradlew :modules:axelor-custom-ai:build
```

### Étape 5 : Lancer Application

```bash
./gradlew run
```

Accéder : `http://localhost:8080/`

### Étape 6 : Activer Module Custom

Dans l'interface Axelor :
1. Menu → Apps
2. Chercher votre module custom
3. Cliquer "Install" / "Activate"

### Étape 7 : Documenter

Créer `.claude/modules/custom-ai.md` avec documentation module.

## 📋 Checklist Post-Création

Après création module custom :

- [ ] Structure générée correctement
- [ ] `settings.gradle` mis à jour
- [ ] Compilation sans erreurs
- [ ] Code Java généré (entités)
- [ ] Application démarre
- [ ] Module visible dans Apps
- [ ] Activation module réussie
- [ ] Menu visible dans interface
- [ ] Vue formulaire accessible
- [ ] Documentation `.claude/modules/<module>.md` créée
- [ ] Commit : `feat: Créer module custom <nom>`

## ⚠️ Points d'Attention

### Différence Modules Standards vs Custom

| Aspect | Modules Standards | Modules Custom |
|--------|-------------------|----------------|
| **Présence** | Déjà dans Open Suite | À créer |
| **Action** | Activer via Apps | Développer + Activer |
| **Mise à jour** | Avec Axelor updates | Maintenance manuelle |
| **Exemples** | CRM, Ventes, Projet | custom-ai, custom-xyz |

### Nommage

✅ **Conventions** :
- Module : `axelor-custom-<nom>` (kebab-case)
- Package : `com.axelor.apps.custom<nom>` (lowercase)
- Préfixe "custom" pour distinguer des modules standards
- Entité : `PascalCase`
- Table : `custom_<module>_<entity>` (snake_case)

### Dépendances

Modules Axelor standards courants à référencer :
- `axelor-base` : Base (obligatoire pour tous modules)
- `axelor-crm` : Si extension CRM
- `axelor-sale` : Si extension Ventes
- `axelor-project` : Si extension Projets
- `axelor-account` : Si extension Comptabilité

Spécifier dans `--dependencies` si module custom dépend de modules standards.

### Génération Code

⚠️ **Toujours lancer** `./gradlew generateCode` après modification domaines XML !

Les classes Java sont générées dans `build/src-gen/` et ne doivent **jamais** être éditées manuellement.

## 🔍 Troubleshooting

### Module Non Reconnu

```bash
# Vérifier settings.gradle
cat settings.gradle | grep "axelor-custom-<module>"

# Si absent, ajouter :
echo "include 'modules:axelor-custom-<module>'" >> settings.gradle
```

### Erreurs Compilation

```bash
# Nettoyer et recompiler
./gradlew clean
./gradlew generateCode
./gradlew build
```

### Module Non Visible dans Apps

1. Vérifier compilation réussie
2. Redémarrer application
3. Vérifier `Module.java` présent
4. Vérifier dépendances build.gradle

### Menu Non Visible

Vérifier `views/<Entity>.xml` :
- Balise `<menu>` présente
- `parent` valide (menu existant ou créé)
- `action` pointe vers `action-view` correct

## 📚 Références

- **Documentation modules** : `.claude/docs/document-technique-axelor.md` (section 4)
- **Architecture** : `.claude/docs/PRD.md` (section 4.1)
- **Modules standards** : `.claude/modules/README.md`
- **Docs officielles** : https://docs.axelor.com/adk/7.4/tutorial/step2.html

---

**Maintenu par** : Équipe Dev Axelor Vecia
**Dernière mise à jour** : 30 Septembre 2025