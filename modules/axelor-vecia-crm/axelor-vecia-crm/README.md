# Axelor Vecia CRM - Custom Module

**Version**: 1.0.0
**Purpose**: Custom CRM menus and views for Vecia AI Agency
**Created**: 2025-10-05

---

## Overview

This custom module adds two essential CRM menus that were missing from the default Axelor CRM configuration:

1. **All Partners**: Display all companies (Partners with `isContact = false`)
2. **All Contacts**: Display all persons (Partners with `isContact = true`, excluding employees)

### Why This Module?

By default, Axelor CRM only provides filtered views (Prospects, Customers) but no "view all" menu for Partners and Contacts. The complete list was buried in `Application Config → Referential → Partners`, which is unintuitive for end users.

This module provides direct access from the CRM main menu.

---

## Features

### Menu 1: All Partners

- **Location**: CRM → All Partners
- **Model**: `com.axelor.apps.base.db.Partner`
- **Domain Filter**: `self.isContact = false`
- **Views**: partner-grid, partner-form (Axelor base views)
- **Order**: 5 (positioned in CRM menu)

### Menu 2: All Contacts

- **Location**: CRM → All Contacts
- **Model**: `com.axelor.apps.base.db.Partner`
- **Domain Filter**: `self.isContact = true AND self.isEmployee = false`
- **Views**: contact-grid, contact-form (Axelor base views)
- **Order**: 6 (positioned in CRM menu)

---

## Technical Details

### Dependencies

- `axelor-base`: Provides Partner model
- `axelor-crm`: Provides CRM app configuration

### File Structure

```
modules/axelor-vecia-crm/
├── src/main/resources/
│   ├── views/
│   │   └── Menu.xml              # Custom menus and action-views
│   └── module.properties         # Module descriptor
├── build.gradle                  # Gradle build configuration
└── README.md                     # This file
```

### Menu.xml

The `Menu.xml` file defines:
- 2 `<menuitem>` elements (parent: `crm-root`)
- 2 `<action-view>` elements with domain filters
- Conditional display: `if="__config__.app.isApp('crm')"`

---

## Installation

### 1. Enable Module

Edit `settings.gradle` (root project):

```gradle
def enabledModules = [
  'axelor-base',
  'axelor-crm',
  'axelor-sale',
  'axelor-vecia-crm',  // Add this line
]
```

Add include:

```gradle
include(':modules:axelor-vecia-crm')
```

### 2. Build

```bash
./gradlew clean build
```

### 3. Deploy

```bash
docker-compose down
docker-compose up -d --build
```

### 4. Verify

1. Login to Axelor: http://localhost:8080
2. Navigate to **CRM** menu
3. Verify presence of:
   - **All Partners** (order 5)
   - **All Contacts** (order 6)
4. Click menus and verify correct filtering

---

## Configuration Tracking

This module is fully documented in the Configuration Tracking System:

- **CHANGELOG.md**: Version 1.1.0 entry
- **.claude/changelogs/studio-changelog.md**: Detailed technical documentation
- **.claude/configuration-registry.md**: Menu registry entries
- **.claude/configs/crm-menus-config.yaml**: Configuration as Code

---

## Maintenance

### Updating Menus

To modify menu titles, order, or filters:

1. Edit `src/main/resources/views/Menu.xml`
2. Rebuild: `./gradlew clean build`
3. Redeploy: `docker-compose up -d --build`
4. Update documentation (CHANGELOG, registry)

### Adding New Menus

Follow the same pattern:

```xml
<menuitem name="crm-custom-menu"
          parent="crm-root"
          title="Custom Menu"
          action="action-vecia-crm-custom"
          order="7"/>

<action-view name="action-vecia-crm-custom"
             title="Custom View"
             model="com.axelor.apps.base.db.Partner">
  <view type="grid" name="partner-grid"/>
  <view type="form" name="partner-form"/>
  <domain>/* your filter */</domain>
</action-view>
```

---

## Troubleshooting

### Menus Not Visible

1. Check Gradle build logs: No XML parsing errors
2. Check Tomcat logs: Module loaded correctly
3. Verify CRM app is installed and active
4. Clear browser cache and reload

### Wrong Filter Results

1. Test domain filter in Axelor UI (Advanced search)
2. Verify equivalent SQL query:
   ```sql
   SELECT * FROM base_partner WHERE is_contact = false;
   ```
3. Adjust domain filter in Menu.xml

### Build Errors

1. Verify module is in `settings.gradle`
2. Check dependencies are correct in `build.gradle`
3. Run `./gradlew clean` before rebuild

---

## Version History

**v1.0.0** (2025-10-05):
- Initial release
- Added "All Partners" menu
- Added "All Contacts" menu
- Full documentation and configuration tracking

---

## References

- **Documentation**: `.claude/docs/workflow-configuration-tracking.md`
- **Agent**: `.claude/agents/agent-customization.md`
- **Standards**: `.claude/knowledge-bases/kb-lowcode-standards.md`

---

**Maintained By**: Vecia AI Agency Development Team
**License**: Same as Axelor Open Suite
