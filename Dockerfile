# =============================================================================
# Dockerfile Multi-Stage pour Axelor Vecia
# Build Axelor Open Suite 8.3.15 avec modules Phase 1 (base, crm, sale)
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Builder - Compilation Gradle
# -----------------------------------------------------------------------------
FROM gradle:7.6-jdk11 AS builder

WORKDIR /app

# Copier fichiers Gradle pour cache des dépendances
COPY build.gradle settings.gradle gradle.properties ./
COPY gradle/ ./gradle/
COPY gradlew gradlew.bat ./

# Copier buildSrc (si existe)
COPY buildSrc/ ./buildSrc/

# Copier modules Axelor Open Suite (includes custom axelor-vecia-crm)
COPY modules/axelor-open-suite/ ./modules/axelor-open-suite/

# Copier sources de l'application
COPY src/ ./src/

# Télécharger dépendances (cache layer)
RUN gradle dependencies --no-daemon || true

# Build application (génère WAR dans build/libs/)
RUN gradle clean build -x test --no-daemon

# Vérifier que le WAR a été généré
RUN ls -lh build/libs/ && \
    test -f build/libs/*.war || (echo "ERROR: WAR file not found" && exit 1)

# -----------------------------------------------------------------------------
# Stage 2: Runtime - Tomcat avec Axelor
# -----------------------------------------------------------------------------
FROM tomcat:9-jre11

# Métadonnées
LABEL maintainer="Axelor Vecia <dev@vecia.ai>"
LABEL description="Axelor ERP pour Agence IA - Phase 1 (CRM)"
LABEL version="8.3.15"

# Variables d'environnement Axelor
ENV AXELOR_HOME=/opt/axelor
ENV CATALINA_OPTS="-Xms512m -Xmx2048m -XX:+UseG1GC"

# Installer curl pour healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Créer répertoires Axelor
RUN mkdir -p ${AXELOR_HOME}/{data,upload,logs} && \
    chmod -R 755 ${AXELOR_HOME}

# Supprimer applications Tomcat par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Fix: Configurer Tomcat pour écouter sur 0.0.0.0 (requis pour Docker macOS)
# Résout "Empty reply from server" lors de l'accès depuis host
RUN sed -i 's/<Connector port="8080" protocol="HTTP\/1.1"/<Connector port="8080" protocol="HTTP\/1.1"\n               address="0.0.0.0"/' \
    /usr/local/tomcat/conf/server.xml

# Copier WAR depuis builder
COPY --from=builder /app/build/libs/*.war /usr/local/tomcat/webapps/ROOT.war

# Copier configuration Axelor (sera écrasée par volume en prod)
COPY src/main/resources/axelor-config.properties ${AXELOR_HOME}/

# Exposer port Tomcat
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Point d'entrée
CMD ["catalina.sh", "run"]
